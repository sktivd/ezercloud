require("RPostgreSQL")

source("R/QCtoolkit-qc-floats.R")
source("R/QCtoolkit-graphs.R")
source("R/QCtoolkit-utilities.R")

# QC target
args <- commandArgs(TRUE)
equipment <- args[1]
kit <- args[2]
path.report <- args[3]

# check today
now <- Sys.time()
one.month.ago <- now - 3600 * 24 * 30
one.year.ago <- now - 3600 * 24 * 365
period <- generate.period(one.month.ago, now)

# connect to database
conn <- dbConnect(dbDriver("PostgreSQL"), host = "localhost", dbname = "skynet_development", user = "skynet")

# load basic information
qcmaterial.information <- dbGetQuery(conn, paste("SELECT assay_kits.equipment, assay_kits.manufacturer, assay_kits.device, assay_kits.kit, quality_control_materials.reagent_name, quality_control_materials.reagent_number, reagents.unit, reagents.break_points, quality_control_materials.service, quality_control_materials.lot, quality_control_materials.expire, quality_control_materials.mean, quality_control_materials.sd, specifications.imprecision, specifications.inaccuracy, specifications.allowable_total_error FROM assay_kits RIGHT JOIN reagents ON assay_kits.id = reagents.assay_kit_id RIGHT JOIN quality_control_materials ON reagents.id = quality_control_materials.reagent_id LEFT JOIN specifications ON specifications.reagent_id = reagents.id WHERE quality_control_materials.expire > '", format(one.month.ago, "%F"), "' AND quality_control_materials.reagent_number = ", kit, " AND quality_control_materials.equipment = '", equipment, "'", sep = ""))
# load equipment information
equipment.information <- dbGetQuery(conn, paste("SELECT * FROM equipment WHERE equipment = '", equipment, "'", sep = ""))
reference.information <- dbGetQuery(conn, paste("SELECT * FROM laboratories WHERE equipment = '", equipment, "' AND kit = ", qcmaterial.information$kit[1], sep = ""))

if (nrow(qcmaterial.information) == 0) {
    quit(save = "no", status = -1)                              # wrong kit ID
} else if (nrow(equipment.information) != 1) {
    quit(save = "no", status = -2)                              # invalid equipment
}
# load reference site information
references <- dbGetQuery(conn, paste("SELECT * FROM laboratories WHERE equipment = '", equipment, "' AND kit = ", qcmaterial.information$kit[1], sep = ""))

# load error code
equipment.errorcodes <- dbGetQuery(conn, paste("SELECT error_codes.error_code, error_codes.level, error_codes.description FROM error_codes LEFT JOIN equipment ON equipment.id = error_codes.equipment_id WHERE equipment.equipment = '", equipment, "'", sep = ""))
rownames(equipment.errorcodes) <- equipment.errorcodes$error_code

# load values
variables.effective <- paste(equipment.information$db, c("serial_number", "test_type", "processed", "error_code", "kit", "lot", paste(equipment.information$prefix, "id", sep = ""), paste(equipment.information$prefix, "result", sep = ""), "qc_service", "qc_lot"), sep = ".", collapse = ", ")
qc.whole <- dbGetQuery(conn, paste("SELECT diagnoses.measured_at, diagnoses.equipment, diagnoses.ip_address, diagnoses.technician, ", variables.effective, " FROM diagnoses INNER JOIN ", equipment.information$db, " ON diagnoses.diagnosable_id = ", equipment.information$db, ".id AND diagnoses.diagnosable_type = '", equipment.information$klass, "' WHERE diagnoses.measured_at > '", format(one.year.ago, "%F"), "' AND ", equipment.information$db, ".test_type = 1 AND ", equipment.information$db, ".kit = ", qcmaterial.information$kit[1], sep = ""))
if (nrow(qc.whole) == 0) {
    quit(save = "no", status = -3)                              # no qc information
}

# FREND only
if (equipment == "FREND") {
    internal.effective <- paste(variables.effective, paste("frends", c("internal_qc_laser_power_test", "internal_qc_laseralignment_test", "internal_qc_calculated_ratio_test", "internal_qc_test"), sep = ".", collapse = ", "), sep = ", ")
    internal.whole <- dbGetQuery(conn, paste("SELECT diagnoses.measured_at, diagnoses.equipment, diagnoses.ip_address, diagnoses.technician, ", internal.effective, " FROM diagnoses INNER JOIN frends ON diagnoses.diagnosable_id = frends.id AND diagnoses.diagnosable_type = 'Frend' WHERE diagnoses.measured_at > '", format(one.month.ago, "%F"), "' AND frends.test_type = 2 AND frends.kit = 11", sep = ""))    
    rm(internal.effective)
    #internal.whole[c(1, 4), "internal_qc_laser_power_test"] <- FALSE
    #internal.whole[c(2, 4), "internal_qc_laseralignment_test"] <- FALSE
    #internal.whole[c(3, 4), "internal_qc_calculated_ratio_test"] <- FALSE
    #internal.whole[1:4, "internal_qc_test"] <- FALSE
}
rm(variables.effective)

# disconnect to database
dbDisconnect(conn)

# set target variable
variables.loc <- which(strsplit(qc.whole[1, paste(equipment.information$prefix, "id", sep = "")], ":")[[1]] == kit)
qc.whole$.result <- sapply(strsplit(paste(qc.whole[, paste(equipment.information$prefix, "result", sep = "")], "e", sep = ""), ":"), function(x) as.numeric(x[variables.loc]))
rm(variables.loc)

# add controlled range into qc information
rownames(qcmaterial.information) <- paste(qcmaterial.information$service, qcmaterial.information$lot, sep = "#")
qc.whole$.qc.mean <- qcmaterial.information[paste(qc.whole$qc_service, qc.whole$qc_lot, sep = "#"), "mean"]
qc.whole$.qc.sd <- qcmaterial.information[paste(qc.whole$qc_service, qc.whole$qc_lot, sep = "#"), "sd"]
qc.whole$.result.std <- (qc.whole$.result - qc.whole$.qc.mean) / qc.whole$.qc.sd
qc.whole$.threesd.range <- paste(qc.whole$.qc.mean - 3 * qc.whole$.qc.sd, qc.whole$.qc.mean + 3 * qc.whole$.qc.sd, sep = "-")

# set subset tables
qc.month <- qc.whole[qc.whole$measured_at > one.month.ago, ]
qc.reference <- qc.whole[qc.whole$ip_address %in% reference.information$ip_address, ]

# generation base ConTeXt file
path.pdf <- file.path(path.report, "PDF")

# base keywords
keywords <- matrix(c(
    "@EQUIPMENT",       equipment,
    "@MANUFACTURER",    equipment.information$manufacturer,
    "@KIT",             qcmaterial.information$reagent_name[1],
    "@THISYEAR",        period$year,
    "@THISMONTH",       period$monthyear
), ncol = 2, byrow = TRUE)
write.table(apply(keywords, 1, function(x) {
    paste("s/", x[1], "/", x[2], "/g", sep = "")
}), file = file.path(path.pdf, paste("keywords",  kit, sep = "-")), col.names = FALSE, row.names = FALSE, quote = FALSE, sep = "\n")
keywords.file <- file.path(path.pdf, paste("keywords",  kit, sep = "-"))

for (serial in unique(qc.month$serial_number)) {
    qc.month.s <- qc.month[qc.month$serial_number == serial, ]
    if (nrow(qc.month.s) > 0) {
        qc.s <- qc.whole[qc.whole$serial_number == serial, ]
        qc.month.r <- qc.month[qc.month$ip_address %in% reference.information$ip_address, ]

        filename.prefix <- paste(equipment, serial, kit, format(max(qc.month.s$measured_at), "%F"), "qc", sep = "-")

        # IP based keywords
        keywords.serial <- matrix(c(
            "@SERIALNUMBER",        serial,
            "@FRENDONLYINTERNALQC", file.path(path.pdf, paste(filename.prefix, "-month-graph-internal.tex", sep = "")),
            "@TABLEOFMONTHHISTORY", file.path(path.pdf, paste(filename.prefix, "-month-table-history.tex", sep = "")),
            "@TABLEOFMONTHDIAGNOSIS",file.path(path.pdf, paste(filename.prefix, "-month-tablegraph-diagnosis.tex", sep = "")),
            "@TABLEGRAPHOFYEAR",    file.path(path.pdf, paste(filename.prefix, "-year-tablegraph.tex", sep = "")),
            "@TABLEOFYEARMONTHLY",  file.path(path.pdf, paste(filename.prefix, "-year-table-history.tex", sep = "")),
            "@GRAPHOFYEARMONTHLY",  file.path(path.pdf, paste(filename.prefix, "-year-graph-history.tex", sep = "")),
            "@GRAPHOFQUALITYASSURANCE", file.path(path.pdf, paste(filename.prefix, "-year-graph-quality.tex", sep = ""))
        ), ncol = 2, byrow = TRUE)
        write.table(apply(keywords.serial, 1, function(x) {
            paste("s!", x[1], "!", x[2], "!g", sep = "")
        }), file = file.path(path.pdf, paste("keywords",  serial, kit, sep = "-")), col.names = FALSE, row.names = FALSE, quote = FALSE, sep = "\n")
        keywords.serial.file <- file.path(path.pdf, paste("keywords",  serial, kit, sep = "-"))

        system(paste("sed -f ", keywords.file, " -f ", keywords.serial.file, " ", file.path(path.report, "TeX", "QCtoolkit-qc_template.tex"), " > ", file.path(path.pdf, paste(filename.prefix, ".tex", sep = "")), sep = ""))

        if (equipment == "FREND") {
            internal.s <- internal.whole[internal.whole$serial_number == serial, ]
            if (nrow(internal.s) == 0) {
                internal.s[1, "measured_at"] <- max(qc.month.s$measured_at)
            }
            generate.graph.thismonth.internal(internal.s, prefix = file.path(path.pdf, filename.prefix))
        }

#        generate.thismonth.qc(qc.month.s, prefix = file.path(path.pdf, filename.prefix), qc.info = qcmaterial.information, whole = qc.whole, reference = qc.reference)
        generate.table.thismonth.history(qc.month.s, prefix = file.path(path.pdf, filename.prefix), qc.info = qcmaterial.information, messages = equipment.errorcodes)

        generate.tablegraph.thismonth.spc(qc.month.s, prefix = file.path(path.pdf, filename.prefix), qc.info = qcmaterial.information)

        generate.tablegraph.thisyear.qc(qc.s, prefix = file.path(path.pdf, filename.prefix), qc.info = qcmaterial.information, whole = qc.whole, reference = qc.reference)
        
        generate.table.thisyear.history.qc(qc.s, prefix = file.path(path.pdf, filename.prefix), qc.info = qcmaterial.information, whole = qc.whole, reference = qc.reference)

        generate.graph.thisyear.history.qc(qc.s, prefix = file.path(path.pdf, filename.prefix), qc.info = qcmaterial.information, whole = qc.whole, reference = qc.reference)

        generate.graph.thisyear.quality.qc(qc.s, prefix = file.path(path.pdf, filename.prefix), qc.info = qcmaterial.information, whole = qc.whole, reference = qc.reference)
    }
}

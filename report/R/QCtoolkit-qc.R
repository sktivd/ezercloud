require("RPostgreSQL")

source("R/QCtoolkit-qc-floats.R")
source("R/QCtoolkit-graphs.R")
source("R/QCtoolkit-utilities.R")

# QC target
args <- commandArgs(TRUE)
equipment <- args[1]
marker <- as.integer(args[2])
path <- args[3]

# check today
now <- Sys.time()
one.month.ago <- now - 3600 * 24 * 30
one.year.ago <- now - 3600 * 24 * 365
period <- generate.period(one.month.ago, now)

# connect to database
conn <- dbConnect(dbDriver("PostgreSQL"), host = "localhost", dbname = "skynet_development", user = "skynet")

# load basic information
qcmaterial.information <- dbGetQuery(conn, paste("SELECT assay_kits.equipment, assay_kits.manufacturer, assay_kits.device, assay_kits.kit, quality_control_materials.reagent_name, quality_control_materials.reagent_number, reagents.unit, reagents.break_points, quality_control_materials.service, quality_control_materials.lot_number, quality_control_materials.expire, quality_control_materials.mean, quality_control_materials.sd FROM assay_kits RIGHT JOIN reagents ON assay_kits.id = reagents.assay_kit_id RIGHT JOIN quality_control_materials ON reagents.id = quality_control_materials.reagent_id WHERE quality_control_materials.expire > '", format(one.month.ago, "%F"), "' AND quality_control_materials.reagent_number = ", marker, " AND quality_control_materials.equipment = '", equipment, "'", sep = ""))
# load equipment information
equipment.information <- dbGetQuery(conn, paste("SELECT * FROM equipment WHERE equipment = '", equipment, "'", sep = ""))
if (nrow(qcmaterial.information) == 0) {
    quit(save = "no", status = -1)                              # wrong marker ID
} else if (nrow(equipment.information) != 1) {
    quit(save = "no", status = -2)                              # invalid equipment
}

# load values
variables.effective <- paste(equipment.information$db, c("serial_number", "test_type", "processed", "error_code", "device_id", "device_lot", paste(equipment.information$prefix, "id", 0:(equipment.information$tests - 1), sep = ""), paste(equipment.information$prefix, "result", 0:(equipment.information$tests - 1), sep = ""), "qc_service", "qc_lot"), sep = ".", collapse = ", ")
qc.total <- dbGetQuery(conn, paste("SELECT diagnoses.measured_at, diagnoses.equipment, diagnoses.ip_address, diagnoses.technician, ", variables.effective, " FROM diagnoses INNER JOIN ", equipment.information$db, " ON diagnoses.diagnosable_id = ", equipment.information$db, ".id AND diagnoses.diagnosable_type = '", equipment.information$klass, "' WHERE diagnoses.measured_at > '", format(one.year.ago, "%F"), "' AND ", equipment.information$db, ".test_type = 1 AND ", equipment.information$db, ".device_id = ", qcmaterial.information$kit[1], sep = ""))
if (nrow(qc.total) == 0) {
    quit(save = "no", status = -3)                              # no qc information
}

# FREND only
if (equipment == "FREND") {
    internal.effective <- paste(variables.effective, paste("frends", c("internal_qc_laser_power_test", "internal_qc_laseralignment_test", "internal_qc_calcaulated_ratio_test", "internal_qc_test"), sep = ".", collapse = ", "), sep = ", ")
    internal.total <- dbGetQuery(conn, paste("SELECT diagnoses.measured_at, diagnoses.equipment, diagnoses.ip_address, diagnoses.technician, ", internal.effective, " FROM diagnoses INNER JOIN frends ON diagnoses.diagnosable_id = frends.id AND diagnoses.diagnosable_type = 'Frend' WHERE diagnoses.measured_at > '", format(one.month.ago, "%F"), "' AND frends.test_type = 2 AND frends.device_id = 11", sep = ""))    
    rm(internal.effective)
}
rm(variables.effective)

# disconnect to database
dbDisconnect(conn)

# set target variable
variables.id <- paste(equipment.information$prefix, "id", 0:(equipment.information$tests - 1), sep = "")
variables.result <- paste(equipment.information$prefix, "result", 0:(equipment.information$tests - 1), sep = "")
variable.target <- variables.result[which(unlist(qc.total[1, variables.id] == marker))]
qc.total$.result <- qc.total[, variable.target]
rm(variables.id, variables.result, variable.target)

# add controlled range into qc information
rownames(qcmaterial.information) <- paste(qcmaterial.information$service, qcmaterial.information$lot_number, sep = "#")
qc.total$qc.mean <- qcmaterial.information[paste(qc.total$qc_service, qc.total$qc_lot, sep = "#"), "mean"]
qc.total$qc.sd <- qcmaterial.information[paste(qc.total$qc_service, qc.total$qc_lot, sep = "#"), "sd"]
qc.total$.result.std <- (qc.total$.result - qc.total$qc.mean) / qc.total$qc.sd
qc.total$.threesd.range <- paste(qc.total$qc.mean - 3 * qc.total$qc.sd, qc.total$qc.mean + 3 * qc.total$qc.sd, sep = "-")

# set subset tables
qc.month <- qc.total[qc.total$measured_at > one.month.ago, ]

# generation base ConTeXt file
path.pdf <- file.path(path, "PDF", format(now, "%F"))
dir.create(path.pdf)

# base keywords
keywords <- matrix(c(
    "@EQUIPMENT",       equipment,
    "@MANUFACTURER",    equipment.information$manufacturer,
    "@MARKER",          qcmaterial.information$reagent_name[1],
    "@THISYEAR",        period$year,
    "@THISMONTH",       period$monthyear
), ncol = 2, byrow = TRUE)
write.table(apply(keywords, 1, function(x) {
    paste("s/", x[1], "/", x[2], "/g", sep = "")
}), file = file.path(path.pdf, "keywords"), col.names = FALSE, row.names = FALSE, quote = FALSE, sep = "\n")
keywords.file <- file.path(path.pdf, "keywords")

for (i in unique(qc.month$ip_address)) {
    qc.by_ipaddress <- qc.total[qc.total$ip_address == i, ]
    qc.month.by_ipaddress <- qc.month[qc.month$ip_address == i, ]
#    qc.by_ipaddress$.level <- str_sub(qc.by_ipaddress$qc_lot, -1)
#    qc.month.by_ipaddress$.level <- str_sub(qc.month.by_ipaddress$qc_lot, -1)

    filename.prefix <- paste(i, "-", equipment, "-", marker, "-qc", sep = "")
    serialnumbers <- paste(unique(qc.month.by_ipaddress$serial_number), collapse = ", ")

    # IP based keywords
    keywords.ip <- matrix(c(
        "@SERIALNUMBERS",   serialnumbers,
        "@TABLEOFMONTH",  file.path(path.pdf, paste(filename.prefix, "-month.tex", sep = ""))
    ), ncol = 2, byrow = TRUE)
    write.table(apply(keywords.ip, 1, function(x) {
        paste("s!", x[1], "!", x[2], "!g", sep = "")
    }), file = file.path(path.pdf, "keywords.ip"), col.names = FALSE, row.names = FALSE, quote = FALSE, sep = "\n")
    keywords.ip.file <- file.path(path.pdf, "keywords.ip")

    system(paste("sed -f ", keywords.file, " -f ", keywords.ip.file, " ", file.path(path, "TeX", "QCtoolkit-qc_template.tex"), " > ", file.path(path.pdf, paste(filename.prefix, ".tex", sep = "")), sep = ""))

    generate.thismonth.qc(qc.month.by_ipaddress, prefix = file.path(path.pdf, filename.prefix), qc.info = qcmaterial.information, whole = qc.month)
    
#    qc.by_ipaddress <- qc.values[qc.values$ip_address == i, ]    
#    if (nrow(qc.by_ipaddress) > 0) {
#        for (j in unique(qc.values$.qcservice)) {
#        v.by_lot <- values[values$.qcservice == i, ]
#        qc.by_lot <- qc.values[qc.values$.qcservice == i, ]
#            qc.by_ipaddress <- qc.by_lot[qc.by_lot$ip_address == j, ]
#        }        
#    }
}


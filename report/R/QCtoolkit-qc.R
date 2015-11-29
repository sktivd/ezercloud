require("RPostgreSQL")
require("RCurl")

# arguments
args <- commandArgs(TRUE)
path.report <- args[1]

# variables
if (Sys.getenv("POSTGRES_DATABASE") == "skynet_production") {
    UPLOAD_HOST <- "https://127.0.0.1/reports"    
    CONTEXT_PATH <- "/usr/local/bin"
} else {
    UPLOAD_HOST <- "http://127.0.0.1:3000/reports"    
    CONTEXT_PATH <- "/Library/TeX/texbin"
}
TIMEOUT <- 10
LINESPERPAGE <- 24

source(file.path(path.report, "R/QCtoolkit-qc-floats.R"))
source(file.path(path.report, "R/QCtoolkit-graphs.R"))
source(file.path(path.report, "R/QCtoolkit-utilities.R"))

# working directory
path.pdf <- getwd()

# check today
if (!is.na(args[2])) {
    now <- as.Date(args[2])
} else {
    now <- Sys.Date()
}
this.month <- format(now, "%m")
this.year <- format(now, "%Y")
firstday.month <- as.Date(paste(this.year, this.month, "01", sep = "-"))
one.year.ago.month <- as.integer(this.month) + 1
if (one.year.ago.month == 13) {
    one.year.ago.month <- "01"
    one.year.ago.year <- this.year
} else {
    one.year.ago.month <- formatC(one.year.ago.month, width = 2, flag = "0")
    one.year.ago.year <- as.integer(this.year) - 1
}
one.year.ago <- as.Date(paste(one.year.ago.year, one.year.ago.month, "01", sep = "-"))
period <- generate.period(firstday.month, now)

# connect to database
conn <- dbConnect(dbDriver("PostgreSQL"), dbname = Sys.getenv("POSTGRES_DATABASE"), user = Sys.getenv("POSTGRES_USERNAME"), password = Sys.getenv("POSTGRES_PASSWORD"), host = "127.0.0.1")

# check available reagents
reagent.list <- dbGetQuery(conn, paste("SELECT equipment.equipment, reagents.number FROM equipment RIGHT JOIN assay_kits ON equipment.equipment = assay_kits.equipment RIGHT JOIN reagents ON assay_kits.id = reagents.assay_kit_id"))

for (rindex in 1:nrow(reagent.list)) {
#    cat("##############\nrindex: ", rindex, "\n")
    equipment <- reagent.list[rindex, "equipment"]
    kit <- reagent.list[rindex, "number"]

    # load basic information
    qcmaterial.information <- dbGetQuery(conn, paste("SELECT assay_kits.equipment, assay_kits.manufacturer, assay_kits.device, assay_kits.kit, reagents.name, reagents.number, reagents.unit, quality_control_materials.service, quality_control_materials.lot, quality_control_materials.expire, quality_control_materials.mean, quality_control_materials.sd, specifications.imprecision, specifications.inaccuracy, specifications.allowable_total_error FROM assay_kits RIGHT JOIN reagents ON assay_kits.id = reagents.assay_kit_id RIGHT JOIN quality_control_materials ON reagents.id = quality_control_materials.reagent_id LEFT JOIN specifications ON specifications.reagent_id = reagents.id WHERE quality_control_materials.expire > '", format(firstday.month, "%F"), "' AND reagents.number = ", kit, " AND assay_kits.equipment = '", equipment, "'", sep = ""))
    if (nrow(qcmaterial.information) == 0) {
        next                                                        # no QC material information
    }
    
    # load equipment information
    equipment.information <- dbGetQuery(conn, paste("SELECT * FROM equipment WHERE equipment = '", equipment, "'", sep = ""))
    reference.information <- dbGetQuery(conn, paste("SELECT * FROM laboratories WHERE equipment = '", equipment, "' AND kit = ", qcmaterial.information$kit[1], sep = ""))
            
    # load error code
    equipment.errorcodes <- dbGetQuery(conn, paste("SELECT error_codes.error_code, error_codes.level, error_codes.description FROM error_codes LEFT JOIN equipment ON equipment.id = error_codes.equipment_id WHERE equipment.equipment = '", equipment, "'", sep = ""))
    rownames(equipment.errorcodes) <- equipment.errorcodes$error_code
    
    # load values
    variables.effective <- paste(equipment.information$db, c("serial_number", "test_type", "processed", "error_code", "kit", "lot", paste(equipment.information$prefix, "id", sep = ""), paste(equipment.information$prefix, "result", sep = ""), "qc_service", "qc_lot"), sep = ".", collapse = ", ")
    qc.whole <- dbGetQuery(conn, paste("SELECT diagnoses.measured_at, diagnoses.equipment, diagnoses.location, diagnoses.ip_address, diagnoses.technician, ", variables.effective, " FROM diagnoses INNER JOIN ", equipment.information$db, " ON diagnoses.diagnosable_id = ", equipment.information$db, ".id AND diagnoses.diagnosable_type = '", equipment.information$klass, "' WHERE diagnoses.measured_at > '", format(one.year.ago, "%F"), "' AND diagnoses.measured_at <= '", format(now, "%F"), "' AND ", equipment.information$db, ".test_type = 1 AND ", equipment.information$db, ".kit = ", qcmaterial.information$kit[1], sep = ""))
    if (nrow(qc.whole) == 0) {
        next                                                    # no qc information
    }
    
    # FREND only
    if (equipment == "FREND") {
        internal.effective <- paste(variables.effective, paste("frends", c("internal_qc_laser_power_test", "internal_qc_laseralignment_test", "internal_qc_calculated_ratio_test", "internal_qc_test"), sep = ".", collapse = ", "), sep = ", ")
        internal.whole <- dbGetQuery(conn, paste("SELECT diagnoses.measured_at, diagnoses.equipment, diagnoses.ip_address, diagnoses.technician, ", internal.effective, " FROM diagnoses INNER JOIN frends ON diagnoses.diagnosable_id = frends.id AND diagnoses.diagnosable_type = 'Frend' WHERE diagnoses.measured_at > '", format(firstday.month, "%F"), "' AND frends.test_type = 2 AND frends.kit = 11", sep = ""))    
        if (nrow(internal.whole) == 0) {
            internal.whole <- data.frame(qc.whole[1, ], internal_qc_laser_power_test = NA, internal_qc_laseralignment_test = NA, internal_qc_calculated_ratio_test = NA, internal_qc_test = NA)[0, ]
        }
        rm(internal.effective)
    }
    rm(variables.effective)
        
    # set target variable
    variables.loc <- which(strsplit(qc.whole[1, paste(equipment.information$prefix, "id", sep = "")], ":")[[1]] == kit)
    qc.whole$.result <- sapply(strsplit(paste(qc.whole[, paste(equipment.information$prefix, "result", sep = "")], "e", sep = ""), ":"), function(x) as.numeric(x[variables.loc]))
    rm(variables.loc)
    
    # add controlled range into qc information
    rownames(qcmaterial.information) <- paste(qcmaterial.information$service, qcmaterial.information$lot, sep = "#")
    qc.whole$.qc.mean <- qcmaterial.information[paste(qc.whole$qc_service, qc.whole$qc_lot, sep = "#"), "mean"]
    qc.whole <- qc.whole[! is.na(qc.whole$.qc.mean), ]
    if (nrow(qc.whole) == 0 || length(is.finite(qc.whole$.result)) == 0) {
        next                                                    # no available data (all data with error or QC material information is not ready for target tests)
    }
    qc.whole$.qc.sd <- qcmaterial.information[paste(qc.whole$qc_service, qc.whole$qc_lot, sep = "#"), "sd"]
    qc.whole$.result.std <- (qc.whole$.result - qc.whole$.qc.mean) / qc.whole$.qc.sd
    qc.whole$.threesd.range <- paste(qc.whole$.qc.mean - 3 * qc.whole$.qc.sd, qc.whole$.qc.mean + 3 * qc.whole$.qc.sd, sep = "-")
    
    # set subset tables
    qc.month <- qc.whole[format(qc.whole$measured_at, "%m") == this.month, ]
    qc.reference <- qc.whole[qc.whole$ip_address %in% reference.information$ip_address, ]
        
    # base keywords
    keywords <- matrix(c(
        "@EQUIPMENT",       equipment,
        "@MANUFACTURER",    equipment.information$manufacturer,
        "@KIT",             qcmaterial.information$name[1],
        "@THISYEAR",        period$year,
        "@THISMONTH",       period$monthyear
    ), ncol = 2, byrow = TRUE)
    write.table(apply(keywords, 1, function(x) {
        paste("s/", x[1], "/", x[2], "/g", sep = "")
    }), file = file.path(path.pdf, paste("keywords",  kit, sep = "-")), col.names = FALSE, row.names = FALSE, quote = FALSE, sep = "\n")
    keywords.file <- file.path(path.pdf, paste("keywords",  kit, sep = "-"))
    
    for (serial in unique(qc.month$serial_number)) {
#        cat("###serial: ", serial, "\n")
        qc.month.s <- qc.month[qc.month$serial_number == serial, ]
        qc.s <- qc.whole[qc.whole$serial_number == serial, ]
        # too small number of tests
        
        qc.month.r <- qc.month[qc.month$ip_address %in% reference.information$ip_address, ]
        latest.measured <- qc.month.s[rev(order(qc.month.s$measured_at))[1], ]
        latest.measured.date <- format(latest.measured$measured_at, "%F")
        latest.ip_address <- latest.measured$ip_address
        latest.technician <- latest.measured$technician

        filename.prefix <- paste(equipment, serial, kit, latest.measured.date, "qc", sep = "-")

        # IP based keywords
        keywords.serial <- matrix(c(
            "@SERIALNUMBER",        serial,
            "@FRENDONLYINTERNALQC", file.path(path.pdf, paste(filename.prefix, "-month-graph-internal.tex", sep = "")),
            "@TABLEOFMONTHHISTORY", file.path(path.pdf, paste(filename.prefix, "-month-table-history.tex", sep = "")),
            "@TABLEOFMONTHDIAGNOSIS",file.path(path.pdf, paste(filename.prefix, "-month-tablegraph-diagnosis.tex", sep = "")),
            "@TABLEGRAPHOFYEAR",    file.path(path.pdf, paste(filename.prefix, "-year-tablegraph.tex", sep = "")),
            "@TABLEOFYEARMONTHLY",  file.path(path.pdf, paste(filename.prefix, "-year-table-history.tex", sep = "")),
            "@GRAPHOFYEARMONTHLY",  file.path(path.pdf, paste(filename.prefix, "-year-graph-history.tex", sep = "")),
            "@GRAPHOFQUALITYASSURANCE", file.path(path.pdf, paste(filename.prefix, "-year-graph-opspecs.tex", sep = ""))
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
                internal.s[1, "equipment"] <- "FREND"
                internal.s[1, "serial_number"] <- serial
            }
            generate.graph.thismonth.internal(internal.s, prefix = file.path(path.pdf, filename.prefix), ip_address = latest.ip_address, technician = latest.technician)
        }

        generate.table.thismonth.history(qc.month.s, prefix = file.path(path.pdf, filename.prefix), qc.info = qcmaterial.information, messages = equipment.errorcodes, ip_address = latest.ip_address, technician = latest.technician)

        generate.tablegraph.thismonth.levey_jennings(qc.month.s, prefix = file.path(path.pdf, filename.prefix), qc.info = qcmaterial.information, ip_address = latest.ip_address, technician = latest.technician)

        generate.tablegraph.thisyear.qc(qc.s, prefix = file.path(path.pdf, filename.prefix), qc.info = qcmaterial.information, whole = qc.whole, reference = qc.reference, ip_address = latest.ip_address, technician = latest.technician)
        
        generate.table.thisyear.history.qc(qc.s, prefix = file.path(path.pdf, filename.prefix), qc.info = qcmaterial.information, whole = qc.whole, reference = qc.reference, ip_address = latest.ip_address, technician = latest.technician)

        generate.graph.thisyear.history.qc(qc.s, prefix = file.path(path.pdf, filename.prefix), qc.info = qcmaterial.information, whole = qc.whole, reference = qc.reference, ip_address = latest.ip_address, technician = latest.technician)

        generate.graph.thisyear.opspecs.qc(qc.s, prefix = file.path(path.pdf, filename.prefix), qc.info = qcmaterial.information, whole = qc.whole, reference = qc.reference, ip_address = latest.ip_address, technician = latest.technician)
        
        # upload QC report
        system(paste(file.path(CONTEXT_PATH, "context"), " --mode=", equipment, " ", file.path(path.pdf, paste(filename.prefix, ".tex > /dev/null", sep = "")), sep = ""))
        if (file.access(file.path(path.pdf, paste(filename.prefix, ".pdf", sep = ""))) >= 0) {
            # TLSv1.2: sslversion = 6
            postForm(uri = UPLOAD_HOST, "report[equipment]" = equipment, "report[serial_number]" = serial, "report[date]" = latest.measured.date, "report[reagent_number]" = kit, "report[document]" = fileUpload(file.path(path.pdf, paste(filename.prefix, ".pdf", sep = "")), contentType = "application/pdf"), .opts = list(timeout = TIMEOUT, ssl.verifypeer = FALSE, sslversion = 6))
        }
    }
}

# disconnect to database
dbDisconnect(conn)

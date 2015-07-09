require("RPostgreSQL")

source("R/QCtoolkit-test-table.R")
source("R/QCtoolkit-graphs.R")
source("R/QCtoolkit-utilities.R")

# QC target
args <- commandArgs(TRUE)
equipment <- args[1]
marker <- as.integer(args[2])
path <- args[3]

# check today
now <- Sys.time()
today <- format(now, tz = "UTC", "%Y-%m-%d")
oneweekago <- now - 3600 * 24 * 7
oneyearago <- now - 3600 * 24 * 365
period <- generate.period(oneweekago, now)

# connect to database
conn <- dbConnect(dbDriver("PostgreSQL"), host = "localhost", dbname = "skynet_development", user = "skynet")

# load basic information
reagent.information <- dbGetQuery(conn, paste("SELECT * FROM assay_kits RIGHT JOIN reagents ON assay_kits.id = reagents.assay_kit_id WHERE reagents.number = ", marker, sep = ""))
kit.number <- reagent.information$kit
# load equipment information
equipment.information <- dbGetQuery(conn, paste("SELECT * FROM equipment WHERE equipment = '", equipment, "'", sep = ""))
if (is.null(kit.number)) {
    quit(save = "no", status = -2)                              # wrong marker ID
} else if (nrow(equipment.information) != 1) {
    quit(save = "no", status = -2)                              # invalid equipment
}

# load values
variables.effective <- unlist(sapply(c("variable_kit", "variables_test_ids", "variables_test_values"), function(x) strsplit(equipment.information[, x], ",")[[1]]))

values.total <- dbGetQuery(conn, paste("SELECT diagnoses.measured_at, diagnoses.equipment, diagnoses.ip_address, diagnoses.technician, ", paste(equipment.information$db, c("serial_number", "test_type", "processed", "error_code"), sep = ".", collapse = ", "), ", ", paste("frends", variables.effective, sep = ".", collapse = ", "), " FROM diagnoses INNER JOIN ", equipment.information$db, " ON diagnoses.diagnosable_id = ", equipment.information$db, ".id AND diagnoses.diagnosable_type = '", equipment.information$klass, "' WHERE diagnoses.measured_at > '", format(oneyearago, "%F"), "' AND ", equipment.information$db, ".test_type = 0 AND ", equipment.information$db, ".", equipment.information$variable_kit, " = ", kit.number, sep = ""))

# disconnect to database
dbDisconnect(conn)

# set target variable
variables.id <- strsplit(equipment.information$variables_test_ids, ",")[[1]]
variables.value <- strsplit(equipment.information$variables_test_values, ",")[[1]]
variable.target <- variables.value[which(unlist(values.total[1, variables.id] == marker) == TRUE)]
values.total$.value <- values.total[, variable.target]
rm(variables.id, variables.value, variable.target)

# set subset tables
values.week <- values.total[values.total$measured_at > oneweekago, ]

# generation base ConTeXt file
path.pdf <- file.path(path, "PDF", today)
dir.create(path.pdf)

# base keywords
keywords <- matrix(c(
    "@EQUIPMENT",       equipment,
    "@MANUFACTURER",    equipment.information$manufacturer,
    "@MARKER",          reagent.information$name,
    "@THISYEAR",        period$year,
    "@THISWEEK",   period$monthweekyear
), ncol = 2, byrow = TRUE)
write.table(apply(keywords, 1, function(x) {
    paste("s/", x[1], "/", x[2], "/g", sep = "")
}), file = file.path(path.pdf, "keywords"), col.names = FALSE, row.names = FALSE, quote = FALSE, sep = "\n")
keywords.file <- file.path(path.pdf, "keywords")

for (i in unique(values.total$ip_address)) {
    filename.prefix <- paste(i, "-", equipment, "-", marker, "-test", sep = "")
    report.file <- paste(filename.prefix, ".tex", sep = "")
    report.table.file <- paste(filename.prefix, "-table", sep = "")
    serialnumbers <- paste(unique(values.total$serial_number), collapse = ", ")

    # IP based keywords
    keywords.ip <- matrix(c(
        "@SERIALNUMBERS",   serialnumbers,
        "@TABLEOFTESTS",  paste(report.table.file, ".tex", sep = "")
    ), ncol = 2, byrow = TRUE)
    write.table(apply(keywords.ip, 1, function(x) {
        paste("s!", x[1], "!", x[2], "!g", sep = "")
    }), file = file.path(path.pdf, "keywords.ip"), col.names = FALSE, row.names = FALSE, quote = FALSE, sep = "\n")
    keywords.ip.file <- file.path(path.pdf, "keywords.ip")

    system(paste("sed -f ", keywords.file, " -f ", keywords.ip.file, " ", file.path(path, "TeX", "QCtoolkit-test_template.tex"), " > ", file.path(path.pdf, report.file), sep = ""))

    value.by_ipaddress <- values.total[values.total$ip_address == i, ]
    value.by_ipaddress.week <- value.by_ipaddress[value.by_ipaddress$measured_at > oneweekago, ]
    generate_context_table(value.by_ipaddress.week, path = path.pdf, file = report.table.file)
    
    qc.by_ipaddress <- qc.values[qc.values$ip_address == i, ]    
    if (nrow(qc.by_ipaddress) > 0) {
        for (j in unique(qc.values$.qcservice)) {
        v.by_lot <- values[values$.qcservice == i, ]
        qc.by_lot <- qc.values[qc.values$.qcservice == i, ]
            qc.by_ipaddress <- qc.by_lot[qc.by_lot$ip_address == j, ]
        }        
    }
}


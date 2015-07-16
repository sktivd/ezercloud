
diagnosis.spc <- function(y, index, lot) {
    
    
}

generate.period <- function(from, to) {
    z <- list()
    z$year <- format(to, "%Y")
    z$from <- from
    z$to <- to
    z$generated <- format(from, "%B %d-")
    if (format(from, "%m") != format(to, "%m")) {
        z$generated <- paste(z$generated, format(to, "%B %d"), sep = "")
    } else {
        z$generated <- paste(z$generated, format(to, "%d"), sep = "")
    }
    z$week.i <- as.numeric(format(to, "%U")) - as.numeric(format(as.Date(paste(format(to, "%Y-%m"), "-01", sep = "")), "%U"))
    z$week <- paste(switch(z$week.i, "1" = "1st", "2" = "2nd", "3" = "3rd", "4" = "4th", "5" = "5th"), "weekend")
    z$monthweekyear <- paste(format(to, "%B"), z$week, z$year)
    z$monthyear <- paste(format(to, "%B %Y"))

    invisible(z)
}

require("stringr")

# available columns: measured_at, ip_address, serial_number, test, processed, error_code, .result, device_id, device_lot
# qc_service, qc_lot

# sumarize from qc data
get.qcstat1 <- function(target, comparative) {
    t(sapply(unique(paste(comparative$qc_service, " \\#", comparative$qc_lot, sep = "")), function(x) {
        base        <- target[paste(target$qc_service, " \\#", target$qc_lot, sep = "") == x, ]
        objective   <- comparative[paste(comparative$qc_service, " \\#", comparative$qc_lot, sep = "") == x, ]
                    
        n           <- sum(is.finite(base$.result))
        nlabs       <- length(unique(base$ip_address))
        mean.all    <- mean(base$.result, na.rm = TRUE)
        var.all     <- var(base$.result, na.rm = TRUE)
        
        c(n             = n,
          nlabs         = nlabs,
          nequipment    = length(unique(base$serial_number)),
          mean          = mean.all,
          sd            = sqrt(var.all),
          var_total     = var.all,
          var_within    = sum(tapply(base$.result, base$ip_address, function(y) sum((y - mean(y, na.rm = TRUE))^2, na.rm = TRUE))) / (n - nlabs),
          var_between   = sum(tapply(base$.result, base$ip_address, function(y) (mean(y, na.rm = TRUE) - mean.all)^2 * sum(is.finite(y)))) / (nlabs - 1),
          sdi           = (mean(objective$.result, na.rm = TRUE) - mean(base$.result, na.rm = TRUE)) / sd(base$.result, na.rm = TRUE),
          bias          = (mean(objective$.result, na.rm = TRUE) - mean(base$.result, na.rm = TRUE)) / mean(base$.result, na.rm = TRUE),
          cv            = sd(base$.result, na.rm = TRUE) / mean(base$.result, na.rm = TRUE),
          cvr           = (sd(objective$.result, na.rm = TRUE) / mean(objective$.result, na.rm = TRUE)) / (sd(base$.result, na.rm = TRUE) / mean(base$.result, na.rm = TRUE)))
    }))
}

get.qcstat2 <- function(target, comparative) {
    mean.all    <- sapply(unique(paste(target$qc_service, " \\#", target$qc_lot, sep = "")), function(x) mean(target$.result[paste(target$qc_service, " \\#", target$qc_lot, sep = "") == x], na.rm = TRUE))
    comparative$.base <- mean.all[paste(comparative$qc_service, " \\#", comparative$qc_lot, sep = "")]
    list(lm = lm(I(log(.result)) ~ I(log(.base)), data = comparative))
}

get.qcstat3 <- function(site) {
    t(sapply(unique(paste(site$qc_service, " \\#", site$qc_lot, sep = "")), function(x) {
        base        <- site[paste(site$qc_service, " \\#", site$qc_lot, sep = "") == x, ]
                    
        n           <- sum(is.finite(base$.result))
        nlabs       <- length(unique(base$ip_address))
        mean.all    <- mean(base$.result, na.rm = TRUE)
        var.all     <- var(base$.result, na.rm = TRUE)
        
        c(n             = n,
          nlabs         = nlabs,
          nequipment    = length(unique(base$serial_number)),
          mean          = mean.all,
          sd            = sqrt(var.all),
          var           = var.all,
          sdi           = (mean(base$.result, na.rm = TRUE) - base$.qc.mean[1]) / base$.qc.sd[1],
          bias          = (mean(base$.result, na.rm = TRUE) - base$.qc.mean[1]) / base$.qc.mean[1],
          cv            = sd(base$.result, na.rm = TRUE) / mean(base$.result, na.rm = TRUE),
          cvr           = (sd(base$.result, na.rm = TRUE) / mean(base$.result, na.rm = TRUE)) / (base$.qc.sd[1] / base$.qc.mean[1]))
    }))
}

get.qcstat4 <- function(site) {
    sapply(unique(paste(site$qc_service, " \\#", site$qc_lot, sep = "")), function(x) {
        base        <- site[paste(site$qc_service, " \\#", site$qc_lot, sep = "") == x, ]       
        m           <- base[1, ".qc.mean"]
        s           <- base[1, ".qc.sd"]

        c(inaccuracy    = abs((mean(base, na.rm = TRUE) - m) / m) * 100,
          imprecision   = sd(base, na.rm = TRUE) / mean(base, na.rm = TRUE) * 100)
    })    
}

get.qcstat5 <- function(site) {
    z <- lapply(unique(paste(site$qc_service, " \\#", site$qc_lot, sep = "")), function(x) {
        base        <- site[paste(site$qc_service, " \\#", site$qc_lot, sep = "") == x, ]
        base$.date  <- format(base$measured_at, "%Y%m")
       
        m           <- base[1, ".qc.mean"]
        s           <- base[1, ".qc.sd"]

        stat <- as.data.frame(t(sapply(unique(base$.date), function(y) {
            b <- base$.result[base$.date == y]
            
            c(date          = as.numeric(y),
              n             = sum(is.finite(b)),
              inaccuracy    = abs((mean(b, na.rm = TRUE) - m) / m) * 100,
              imprecision   = sd(b, na.rm = TRUE) / mean(b, na.rm = TRUE) * 100)
        })))
        stat$date <- as.ordered(stat$date)
        stat$imprecision[is.na(stat$imprecision)] <- 0
        l <- levels(stat$date)
        levels(stat$date) <- format(as.Date(paste(substr(l, 1, 4), substr(l, 5, 6), "01", sep = "-")), "%Y %b")
        stat
    })
    names(z) <- unique(paste(site$qc_service, " #", site$qc_lot, sep = ""))
    
    z
}

get.location <- function(ip_address, technician, longitude, latitude) {
    location <- paste("Location: ", technician, " (", ip_address, ")", sep = "")
    
    if (! missing(longitude) && ! missing(latitude)) {
    }
    
    location
}

generate.frame.withtitle <- function(contents, title, subtitles = "", footnote = "") {
    if (! is.list(contents)) {
        contents <- list(contents)
    }
    
    z <- c(
        "\\bTABLE[setups={table:titledframe}, split=repeat]",
        "\\bTABLEhead",
        paste("\\bTR \\bTD [align=flushleft] {\\ss\\bf\\tfa ", title, "} \\eTD \\bTD [align=flushright] {\\tfxx ", paste(subtitles, collapse = "\\\\"), "} \\eTD \\eTR", sep = ""),
        "\\eTABLEhead",
        "\\bTABLEbody"
    )
    for (content in contents) {
        z <- c(z,
            "\\bTR \\bTD [nc=2] {",
            content,
            "} \\eTD \\eTR"
        )
    }
    z <- c(z, 
        "\\eTABLEbody",
        "\\bTABLEfoot",
        "\\bTR[align=flushleft, style=\\ss\\tfxx, color=graytitlecolor] \\bTD [nc=2] {",
        footnote,
        "} \\eTD \\eTR",
        "\\eTABLEfoot",
        "\\eTABLE"
    )
    
    z
}

generate.multiple.pages <- function(contents, header = "", footer = "", lines = LINESPERPAGE) {
    z <- list()
    count <- 1
    z[[count]] <- header
    for (i in 1:length(contents)) {
        if (is.list(contents)) {
            z[[count]] <- c(z[[count]], contents[[i]])
        } else {
            z[[count]] <- c(z[[count]], contents[i])            
        }
        if (i %% lines == 0) {
            z[[count]] <- c(z[[count]], footer)
            count <- count + 1
            z[[count]] <- header
        }
    }
    z[[count]] <- c(z[[count]], footer)
    z
}

generate.graph.thismonth.internal <- function(object, prefix, ip_address, technician, ...) {
    object <- object[order(format(object$measured_at, "%F %X")), ]    

    # FREND internal plot
    pdf(file = paste(prefix, "month-internal.pdf", sep = "-"), width = 10, height = 7)
    grid.draw(frendInternal.plot(date = measured_at, data = object, ...))
    dev.off()
    
   
    z <- paste("\\placefigure[center,here,none][fig:", serial, "-internal]{}{\\externalfigure[", paste(prefix, "month-internal.pdf", sep = "-"), "][width=\\hsize]}", sep = "")

    # equipment title
    z <- generate.frame.withtitle(z, object$serial_number[1], get.location(ip_address, technician), 
        "P Error: FREND Laser Power Failure\\\\A Error: FREND Laser Alignment Failure\\\\M Error: Measurement Failure (Calculated Ratio differs from Manufacture setting)")
    
    write.table(z, file = paste(prefix, "-month-graph-internal.tex", sep = ""), row.names = FALSE, col.names = FALSE, quote = FALSE, sep = "\n")
    
}

generate.table.thismonth.history <- function(object, prefix, qc.information, messages, ip_address, technician, ...) {
    object <- object[order(paste(object$qc_service, object$qc_lot, format(object$measured_at, "%F %X"))), ]
    object$.bs <- paste(object$qc_service, object$qc_lot, sep = "#")
        
    # history table
    errorcodes <- character()
    header <- c(
        "\\bTABLE[setups={table:monthhistory}, split=repeat]", 
        "\\bTABLEhead", 
        paste("\\bTR[style=\\rm] \\bTH Date \\eTH \\bTH Service \\eTH \\bTH Lot \\eTH \\bTH Mean \\eTH \\bTH 3SD Range \\eTH \\bTH", qc.information$unit[1], " \\eTH \\bTH QC status \\eTH \\eTR"), 
        "\\eTABLEhead", 
        "\\bTABLEbody"
    )
    contents <- c()        
    for (n in 1:nrow(object)) {
        if (object$processed[n]) {
            value <- formatC(object$.result[n], digits = 2, format = 'f')
            status <- ifelse(abs(object$.result.std[n]) < 3, "pass", "[style=\\tfx\\bf] fail")
        } else {
            value <- object$error_code[n]
            status <- "na"
            errorcodes <- c(errorcodes, value)
        }
        contents <- c(contents, 
            sprintf("\\bTR[style=\\ss\\tfx] \\bTD %s \\eTD \\bTD %s \\eTD \\bTD %s \\eTD \\bTD %s \\eTD \\bTD %s \\eTD \\bTD %s \\eTD \\bTD %s \\eTD \\eTR", 
                format(object$measured_at[n], "%b %d"), 
                object$qc_service[n],
                object$qc_lot[n],
                object$.qc.mean[n],
                object$.threesd.range[n],
                value, 
                status
            )
        )
    }
    footer <- c( 
        "\\eTABLEbody",  
        "\\eTABLE"
    )
    # qc status
    qc.status <- c("pass: managed within 2SD range\\\\fail: out of 3SD range")
    # error codes
    errorcodes <- unique(errorcodes)
    if (length(errorcodes) > 0) {
        error.messages <- paste(messages[errorcodes, "error_code"], messages[errorcodes, "description"], sep = ": ", collapse = "\\\\")
    } else {
        error.messages <- ""
    }
    
    # multiple pages for large history
    z <- generate.multiple.pages(contents, header, footer)
    
    # equipment title
    z <- generate.frame.withtitle(z, object$serial_number[1], get.location(ip_address, technician), paste(qc.status, error.messages, collapse = "\\\\"))
    
    write.table(z, file = paste(prefix, "-month-table-history.tex", sep = ""), row.names = FALSE, col.names = FALSE, quote = FALSE, sep = "\n")
}

generate.tablegraph.thismonth.levey_jennings <- function(object, prefix, qc.information, ip_address, technician, ...) {
    object <- object[order(paste(object$qc_service, object$qc_lot, format(object$measured_at, "%F %X"))), ]
    object$.bs <- paste(object$qc_service, object$qc_lot, sep = "#")
        
    # Levey-Jennings plot
    pdf(file = paste(prefix, "month-levey_jennings.pdf", sep = "-"), width = 12, height = 4)
    grid.draw(levey_jennings.plot(y = .result.std, date = measured_at, service = qc_service, lot = qc_lot, data = object, ...))
    dev.off()
    
    z <- c(
        "\\startcombination[1*2]",
        "{\\bTABLE[setups={table:monthsummary}, split=repeat]",
        "\\bTABLEhead",
        "\\bTR \\bTH Diagnosis \\eTH \\bTH Result \\eTH \\eTR",
        "\\eTABLEhead",
        "\\bTABLEbody",
        paste("\\bTR \\bTD $\\tfx \\mathrm{1_{3s}}$ (Out of 3SD range) \\eTD \\bTD", switch(as.character(sum(abs(object$.result.std) > 3, na.rm = TRUE)), "0" = "ok", "1" = "not accpetable", "2" = "serious", "critical"), "\\eTD \\eTR"),
        paste("\\bTR \\bTD $\\tfx \\mathrm{1_{2s}}$ (Out of 2SD range) \\eTD \\bTD", switch(as.character(sum(abs(object$.result.std) > 2, na.rm = TRUE)), "0" = "ok", "1" = "available", "2" = "torelable", "3" = "not acceptable", "4" = "serious", "5" = "serous", "critical"), " \\eTD \\eTR"),
        paste("\\bTR \\bTD $\\tfx \\mathrm{R_{4s}}$ (over 4SD variation) \\eTD \\bTD", ifelse(diff(range(object$.result.std, na.rm = TRUE)) > 4, "detected", "no"), " \\eTD \\eTR"),
        paste("\\bTR \\bTD Pattern (increasing or deceasing) \\eTD \\bTD", ifelse(FALSE, "detected", "no"), " \\eTD \\eTR"),
        "\\eTABLEbody",  
        "\\eTABLE}{}",
        paste("{\\externalfigure[", paste(prefix, "month-levey_jennings.pdf", sep = "-"), "][width=\\hsize]}{}", sep = ""),
        "\\stopcombination"
    )
    
    # equipment title
    z <- generate.frame.withtitle(z, object$serial_number[1], get.location(ip_address, technician),
    "$\\tfx\\rm{1_{3s}}$: Out of 3SD Range\\\\$\\tfx\\rm{1_{2s}}$: Out of 2SD Range\\\\$\\tfx\\rm{R_{4s}}$: Over 4SD variation")
    
    write.table(z, file = paste(prefix, "-month-tablegraph-diagnosis.tex", sep = ""), row.names = FALSE, col.names = FALSE, quote = FALSE, sep = "\n")
}

generate.tablegraph.thisyear.qc <- function(object, prefix, qc.information, whole, reference, ip_address, technician, ...) {
    object <- object[order(paste(object$qc_service, object$qc_lot, format(object$measured_at, "%F %X"))), ]
    object$.bs <- paste(object$qc_service, object$qc_lot, sep = "#")

    # comparative statistics
    qcstat.w <- get.qcstat1(whole, object)
    qcstat.r <- get.qcstat1(reference, object)
    qcstat.b <- get.qcstat3(object)

    # generate summary table    
    z <- "\\bTABLE[setups={table:yearframe}]"
    for (l in 1:nrow(qcstat.w)) {
        sdicvr <- data.frame(sdi = c(qcstat.b[l, "sdi"], qcstat.w[l, "sdi"], qcstat.r[l, "sdi"]), cvr = c(qcstat.b[l, "cvr"], qcstat.w[l, "cvr"], qcstat.r[l, "cvr"]), shape = c("insert", "whole", "reference"))
        pdf(file = paste(prefix, "-year-sdi_cvr-", l,".pdf", sep = ""), width = 5, height = 4)
        grid.draw(sdi_cvr.plot(sdi, cvr, shape, sdicvr))
        dev.off()
        z <- c(z,
            "\\bTR \\bTD {\\startcombination[2*1]",
            "{\\bTABLE[setups={table:yearsdicvr}, style=\\tfx\\ss]",
            paste("\\bTR[bottomframe=on, framecolor=titlebackgroundcolor, rulethickness=1pt] \\bTD[nc=5, align=right, style=\\rm] ", rownames(qcstat.w)[l]," \\eTD \\bTD \\eTD \\eTR", sep = ""),
            "\\bTR \\bTH \\eTH \\bTH \\eTH \\bTH \\bullet       \\eTH \\bTH \\diamond    \\eTH \\bTH \\boxplus        \\eTH \\bTH \\eTH \\eTR",
            "\\bTR \\bTH \\eTH \\bTH \\eTH \\bTH {\\bf insert } \\eTH \\bTH {\\bf whole} \\eTH \\bTH {\\bf reference} \\eTH \\bTH \\eTH \\eTR",
            paste("\\bTR \\bTD \\eTD \\bTD SDI \\eTD \\bTD", formatC(qcstat.b[l, "sdi"], digits = 2, width = 2, format = "f"), "\\eTD \\bTD", formatC(qcstat.w[l, "sdi"], digits = 2, width = 2, format = "f"), "\\eTD \\bTD", formatC(qcstat.r[l, "sdi"], digits = 2, width = 2, format = "f"), "\\eTD \\bTD \\eTD \\eTR"),
            paste("\\bTR \\bTD \\eTD \\bTD CVR \\eTD \\bTD", formatC(qcstat.b[l, "cvr"], digits = 2, width = 2, format = "f"), "\\eTD \\bTD", formatC(qcstat.w[l, "cvr"], digits = 2, width = 2, format = "f"), "\\eTD \\bTD", formatC(qcstat.r[l, "cvr"], digits = 2, width = 2, format = "f"), "\\eTD \\bTD \\eTD \\eTR"),
            paste("\\bTR[aligncharacter=no] \\bTD \\eTD \\bTD N. Labs \\eTD \\bTD . \\eTD \\bTD", formatC(qcstat.w[l, "nlabs"], digits = 2, width = 2, format = "d"), "\\eTD \\bTD", formatC(qcstat.r[l, "nlabs"], digits = 2, width = 2, format = "d"), "\\eTD \\bTD \\eTD \\eTR"),
            paste("\\bTR[aligncharacter=no] \\bTD \\eTD \\bTD N. Measurement \\eTD \\bTD . \\eTD \\bTD", formatC(qcstat.w[l, "n"], digits = 2, width = 2, format = "d"), "\\eTD \\bTD", formatC(qcstat.r[l, "n"], digits = 2, width = 2, format = "d"), "\\eTD \\bTD \\eTD \\eTR"),
            "\\bTR[offset=none] \\eTR",
            "\\eTABLE}{}",
            paste("{\\externalfigure[", paste(prefix, "-year-sdi_cvr-", l,".pdf", sep = ""), "][width=.4\\hsize]}{}", sep = ""),
            "\\stopcombination} \\eTD \\eTR"
        )
    }
    z <- c(z, 
        "\\eTABLE"
    )
    
    # equipment title
    z <- generate.frame.withtitle(z, object$serial_number[1], get.location(ip_address, technician), "{\\tfa\\bf White zone (Great), Gray zone (in Control), Dark zone (need more management) and Out of zone (out of Control)} \\\\Standard Deviation Index (SDI): (Laboratory Mean - Consensus Group Mean) / (Consensus Group SD) \\\\Coefficient of Variation Ratio (CVR): Laboratory CV / Consensus Group CV")
    
    write.table(z, file = paste(prefix, "-year-tablegraph.tex", sep = ""), row.names = FALSE, col.names = FALSE, quote = FALSE, sep = "\n")
}

generate.table.thisyear.history.qc <- function(object, prefix, qc.information, whole, reference, period = 12, ip_address, technician, ...) {
    object <- object[order(paste(object$qc_service, object$qc_lot, format(object$measured_at, "%F %X"))), ]
    object$.bs <- paste(object$qc_service, object$qc_lot, sep = "#")
    latest.measured <- max(object$measured_at)
    dates <- seq(latest.measured, length = period, by = "-1 month")
    yearmonths <- format(dates, "%Y%m")
    months <- format(dates, "%m")
    monthLabels <- format(dates, "%b")
    years <- character(period)
    years[months == "01"] <- format(dates[months == "12"], "%Y")
    years[1] <- format(dates[1], "%Y")

    # comparative statistics
    qcstat <- lapply(yearmonths, function(x) get.qcstat3(object[format(object$measured_at, "%Y%m") == x, ]))
    names(qcstat) <- monthLabels
    qcnames <- unique(unlist(sapply(qcstat, function(x) rownames(x))))
    qcnames <- qcnames[qcnames != " \\#"]

    qcstat2 <- lapply(qcnames, function(x) { sapply(qcstat, function(y) {
        if (x %in% rownames(y)) {
            formatC(y[x, ], width = 2, digits = 2) 
        } else {
            rep(".", ncol(y))
        }
    }) })
    names(qcstat2) <- rownames(qcstat[[1]])
    
    # generate summary table    
    header <- c(
        "\\bTABLE[setups={table:yearsummary}, split=repeat]",
        "\\bTABLEhead",
        sprintf("\\bTR \\bTH \\eTH \\bTH %s \\eTH \\eTR", paste(years, collapse = " \\eTH \\bTH ")),
        sprintf("\\bTR[rulethickness=5pt] \\bTH \\eTH \\bTH %s \\eTH \\eTR", paste(monthLabels, collapse = " \\eTH \\bTH ")),
        "\\eTABLEhead",
        "\\bTABLEbody"
    )
    footer <- c(    
        "\\bTR[rulethickness=0pt] \\eTR",
        "\\eTABLEbody",
        "\\eTABLE"
    )    
    
    contents <- list()
    for (i in 1:length(qcstat2)) {
        contents[[i]] <- c(
            "\\bTR[rulethickness=0pt] \\eTR",
            paste("\\bTR[align=right, rulethickness=2pt] \\bTD[nc=13]", names(qcstat2)[i], "\\eTD \\eTR", sep = " "),
            paste("\\bTR \\bTD {\\ss\\bf\\tfxx N} \\eTD \\bTD {\\ss\\tfxx", paste(qcstat2[[i]][1, ], collapse = " } \\eTD \\bTD {\\ss\\tfxx "), "} \\eTD \\eTR"),
            paste("\\bTR \\bTD {\\ss\\bf\\tfxx Mean} \\eTD \\bTD {\\ss\\tfxx", paste(qcstat2[[i]][4, ], collapse = " } \\eTD \\bTD {\\ss\\tfxx "), "} \\eTD \\eTR"),
            paste("\\bTR \\bTD {\\ss\\bf\\tfxx SD} \\eTD \\bTD {\\ss\\tfxx", paste(qcstat2[[i]][5, ], collapse = " } \\eTD \\bTD {\\ss\\tfxx "), "} \\eTD \\eTR"),
            paste("\\bTR \\bTD {\\ss\\bf\\tfxx Bias} \\eTD \\bTD {\\ss\\tfxx", paste(qcstat2[[i]][8, ], collapse = " } \\eTD \\bTD {\\ss\\tfxx "), "} \\eTD \\eTR"),
            paste("\\bTR \\bTD {\\ss\\bf\\tfxx CV} \\eTD \\bTD {\\ss\\tfxx", paste(qcstat2[[i]][9, ], collapse = " } \\eTD \\bTD {\\ss\\tfxx "), "} \\eTD \\eTR"),
            paste("\\bTR \\bTD {\\ss\\bf\\tfxx SDI} \\eTD \\bTD {\\ss\\tfxx", paste(qcstat2[[i]][7, ], collapse = " } \\eTD \\bTD {\\ss\\tfxx "), "} \\eTD \\eTR"),
            paste("\\bTR \\bTD {\\ss\\bf\\tfxx CVR} \\eTD \\bTD {\\ss\\tfxx", paste(qcstat2[[i]][10, ], collapse = " } \\eTD \\bTD {\\ss\\tfxx "), "} \\eTD \\eTR")
        )
    }

    # multiple pages for large history
    z <- generate.multiple.pages(contents, header, footer, lines = 3)
    
    # equipment title
    z <- generate.frame.withtitle(z, object$serial_number[1], get.location(ip_address, technician))
    
    write.table(z, file = paste(prefix, "-year-table-history.tex", sep = ""), row.names = FALSE, col.names = FALSE, quote = FALSE, sep = "\n")
}

generate.graph.thisyear.history.qc <- function(object, prefix, qc.information, whole, reference, period = 12, ip_address, technician, ...) {
    object <- object[order(paste(object$qc_service, object$qc_lot, format(object$measured_at, "%F %X"))), ]
    object$.qs <- paste(object$qc_service, object$qc_lot, sep = " #")
    latest.measured <- max(object$measured_at)
    dates <- seq(latest.measured, length = period, by = "-1 month")
    yearmonths <- format(dates, "%Y%m")
    months <- format(dates, "%m")
    monthLabels <- format(dates, "%b")
    years <- character(period)
    years[months == "01"] <- format(dates[months == "12"], "%Y")
    years[1] <- format(dates[1], "%Y")

    # comparative statistics
    qcstat <- lapply(yearmonths, function(x) get.qcstat3(object[format(object$measured_at, "%Y%m") == x, ]))
    names(qcstat) <- monthLabels
    qcnames <- unique(unlist(sapply(qcstat, function(x) rownames(x))))
    qcnames <- qcnames[qcnames != " \\#"]

    qcstat2 <- lapply(qcnames, function(x) { sapply(qcstat, function(y) {
        if (x %in% rownames(y)) {
            y[x, ]
        } else {
            rep(NA, ncol(y))
        }
    }) })
    names(qcstat2) <- rownames(qcstat[[1]])
            
    # generate summary figure
    contents <- list()
    qs <- unique(object$.qs)
    for (i in 1:length(qs)) {
        pdf(file = paste(prefix, "-year-graph-history-", i, ".pdf", sep = ""), width = 12, height = 5)
        grid.draw(history.plot(y = .result.std, date = measured_at, base.mean = .qc.mean, base.sd = .qc.sd, data = object[object$.qs == qs[i], ], title = qs[i], qc.stat = qcstat2[[i]], dates = dates, months = months, years = years, ...))
        dev.off()        
        contents[[i]] <- c(
            "\\placefigure[center,here,none][fig:yearhistory]{}{",
            paste("\\externalfigure[", prefix, "-year-graph-history-", i, ".pdf][width=\\hsize]", sep = ""), 
            "}"
        )    
    }
    # multiple pages for large history
    z <- generate.multiple.pages(contents, lines = 3)
    
    # equipment title
    z <- generate.frame.withtitle(z, object$serial_number[1], get.location(ip_address, technician))
    
    write.table(z, file = paste(prefix, "-year-graph-history.tex", sep = ""), row.names = FALSE, col.names = FALSE, quote = FALSE, sep = "\n")
}

# method: database - imprecision & inaccuracy suggested from database
# method: adaptive - imprecision & inaccuracy computed on whole data
generate.graph.thisyear.opspecs.qc <- function(object, prefix, qc.information, whole, reference, method = "adaptive", ip_address, technician, ...) {
    object <- object[order(format(object$measured_at, "%F %X")), ]    
#    object$.date.lot <- paste(format(object$measured_at, "%Y %b"), object$qc_lot, paste = ":")

    # bias & CV
    opspecs <- get.qcstat5(object)
    
    if (method != "adaptive" || missing(whole)) {
        inaccuracy <- imprecision <- numeric(length(opspecs))
        names(inaccuracy) <- names(imprecision) <- names(opspecs)
        inaccuracy[]  <- qc.information$inaccuracy[1]
        imprecision[] <- qc.information$imprecision[1]
    } else {
        z <- get.qcstat5(whole)
        inaccuracy  <- sapply(z, function(x) x$inaccuracy)
        imprecision <- sapply(z, function(x) x$imprecision)
    }

    z <- c( 
        "\\bTABLE[setups={table:yearframe}]"
    )
    for (l in 1:length(opspecs)) {
        # QCSpecs Chart plot
        pdf(file = paste(prefix, "-year-opspecs-", l, ".pdf", sep = ""), width = 10, height = 6)
        grid.draw(opspecs.plot(data = opspecs[[l]], base.inaccuracy = inaccuracy[names(opspecs)[l]], base.imprecision = imprecision[names(opspecs)[l]], title = names(opspecs)[l], ...))
        dev.off()        
        
        z <- c(z,
            paste("\\bTR \\bTD[align=right, style=\\rm\\tfa]", str_replace(names(opspecs)[l], "#", "\\\\#"), "\\\\"), 
            paste("\\placefigure[center,here,none][fig:", serial, "-quality]{}{\\externalfigure[", paste(prefix, "-year-opspecs-", l, ".pdf", sep = ""), "][width=.75\\hsize]} \\eTD \\eTR", sep = "")
        )
    }
    z <- c(z,
        "\\eTABLE"
    )   

    # equipment title
    z <- generate.frame.withtitle(z, object$serial_number[1], get.location(ip_address, technician), 
        "{\\tfa\\bf Gray zone (in Control), Up right zone (out of Control), and Down left zone (Superior control)} \\\\Dashed line: Limits of bias and imprecision for suggested QC procedure (Operating Limits line)\\\\Solid line: Maximum limits of a stable process")
    
    write.table(z, file = paste(prefix, "-year-graph-opspecs.tex", sep = ""), row.names = FALSE, col.names = FALSE, quote = FALSE, sep = "\n") 
}

generate.TableHistory.qc <- function(object, prefix, unit, ip_address, technician, ...) {
    o <- object[order(object$measured_at), ]
    z <- NULL
    for (f in unique(o$serial_number)) {
        e <- o[o$serial_number == f, ]
        e.odd <- e[seq(1, nrow(e), 2), ]
        e.even <- e[seq(0, nrow(e), 2), ]

        z <- c(z, "\\blank[2*big]", paste("\\framedtext{\\ss\\tfa ", f, "}", sep = ""), "\\blank[big]", "\\bTABLE[split=repeat]", "\\bTABLEhead", "\\bTR \\bTD No. \\eTD \\bTD Date \\eTD \\bTD Time \\eTD \\bTD ", unit, " \\eTD \\bTD Tech. \\eTD \\bTD \\eTD \\bTD No. \\eTD \\bTD Date \\eTD \\bTD Time \\eTD \\bTD ", unit, " \\eTD \\bTD Tech. \\eTD \\eTR ", "\\eTABLEhead", "\\bTABLEbody")        
        for (i in 1:nrow(e.odd)) {
            row.odd <- sprintf("\\bTD %d \\eTD \\bTD %s \\eTD \\bTD %s \\eTD \\bTD %s \\eTD \\bTD %s \\eTD \\bTD \\eTD", i * 2 - 1, format(e.odd$measured_at[i], "%m-%d"), format(e.odd$measured_at[i], "%H:%M"), switch(as.integer(e.odd$processed[i]) + 1, paste("[aligncharacter=no, align={middle,lohi}] ", e.odd$error_code[i], sep = ""), formatC(e.odd$.result[i], digits = 2, format = 'f')), e.odd$technician[i])
            if (! is.null(e.even$.result[i])) {
                row.even <- sprintf("\\bTD %d \\eTD \\bTD %s \\eTD \\bTD %s \\eTD \\bTD %s \\eTD \\bTD %s \\eTD", i * 2, format(e.even$measured_at[i], "%m-%d"), format(e.even$measured_at[i], "%H:%M"), switch(as.integer(e.even$processed[i]) + 1, paste("[aligncharacter=no, align={middle,lohi}] ", e.even$error_code[i], sep = ""), formatC(e.even$.result[i], digits = 2, format = 'f')), e.even$technician[i])
            } else {
                row.even <- "\\bTD[nc=5, backgroundcolor=white] \\eTD"
            }
            z <- c(z, paste("\\bTR", row.odd, row.even, "\\eTR"))
        }
                        
        z <- c(z, "\\eTABLEbody",  "\\eTABLE")
        
        # history plot
        pdf(file = paste(prefix, "-tablehistory-", f, ".pdf", sep = ""), width = 12, height = 3)
        grid.draw(history.plot(y = .result, date = measured_at, data = e, ...))
        dev.off()
        
        z <- c(z, paste("\\placefigure[center,bottom,none][fig:", f, "]{}{", "\\externalfigure[", paste(prefix, "-tablehistory-", f, ".pdf", "][width=\\hsize]", sep = ""), sep = ""), "}", "\\page[yes]")
    }
    write.table(z, file = paste(prefix, "-tablehistory.tex", sep = ""), row.names = FALSE, col.names = FALSE, quote = FALSE, sep = "\n")
}

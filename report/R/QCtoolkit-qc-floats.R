require("stringr")

# available columns: measured_at, ip_address, serial_number, test, processed, error_code, .result, device_id, device_lot
# qc_service, qc_lot

# sumarize from qc data
get.qcstat1 <- function(target, comparative) {
    t(sapply(unique(paste(target$qc_service, " \\#", target$qc_lot, sep = "")), function(x) {
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
        stat
    })
    names(z) <- unique(paste(site$qc_service, " #", site$qc_lot, sep = ""))
    
    z
}

generate.frame.withtitle <- function(contents, title, subtitles = "", footnote = "") {
    z <- c(
        "\\bTABLE[setups={table:titledframe}, split=repeat]",
        "\\bTABLEhead",
        paste("\\bTR \\bTD [align=flushleft] {\\ss\\bf\\tfa ", title, "} \\eTD \\bTD [align=flushright] {\\tfxx ", paste(subtitles, collapse = "\\\\"), "} \\eTD \\eTR", sep = ""),
        "\\eTABLEhead",
        "\\bTABLEbody",
        "\\bTR \\bTD [nc=2] {",
        contents,
        "} \\eTD \\eTR",
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

#generate.thismonth.qc <- function(object, prefix, qc.information, whole, reference, ...) {
#    # comparative statistics
#    qcstat1.w <- get.qcstat1(whole, object)
#    qcstat2.w <- get.qcstat2(whole, object)
#    qcstat1.r <- get.qcstat1(reference, object)
#    qcstat2.r <- get.qcstat2(reference, object)
#    
#    o <- object[order(paste(object$qc_service, object$qc_lot, format(object$measured_at, "%F %X"))), ]
#    o$.bs <- paste(o$qc_service, o$qc_lot, sep = "#")
#    z <- NULL
#    
#    # equipment title
#    z <- c(z,
#        "\\blank[2*big]", 
#        paste("\\framedtext{\\ss\\tfa ", serial, "}", sep = ""), 
#        "\\blank[big]")
#    # history table
#    z <- c(z,
#        "% HISTORY TABLE START", 
#        "\\bTABLE[setups={table:history}, split=repeat]", 
#        "\\bTABLEhead", 
#        "\\bTR \\bTD Date \\eTD \\bTD Time \\eTD \\bTD Service \\eTD \\bTD Lot \\eTD \\bTD 3SD Range \\eTD \\bTD [aligncharacter=no, align={middle,lohi}] ", qc.information$unit[1], " \\eTD \\bTD QC status \\eTD \\bTD Tech. \\eTD \\eTR", 
#        "\\eTABLEhead", 
#        "\\bTABLEbody")        
#    for (n in 1:nrow(e)) {
#        tt <- sprintf("\\bTR \\bTD %s \\eTD \\bTD %s \\eTD \\bTD %s \\eTD \\bTD %s \\eTD \\bTD %s \\eTD \\bTD %s \\eTD \\bTD %s \\eTD \\bTD %s \\eTD \\eTR", 
#            format(o$measured_at[n], "%m-%d"), 
#            format(o$measured_at[n], "%H:%M"),
#            o$qc_service[n],
#            o$qc_lot[n],
#            o$.threesd.range[n],
#            switch(as.integer(o$processed[n]) + 1, paste("[aligncharacter=no, align={middle,lohi}] ", o$error_code[n], sep = ""), formatC(o$.result[n], digits = 2, format = 'f')), 
#            switch(as.integer(o$processed[n]) + 1, "NA", switch(as.integer(abs(o$.result.std[n]) < 3) + 1, "X", "O")),
#            o$technician[n])
#        z <- c(z, 
#            sprintf("\\bTR \\bTD %s \\eTD \\bTD %s \\eTD \\bTD %s \\eTD \\bTD %s \\eTD \\bTD %s \\eTD \\bTD %s \\eTD \\bTD %s \\eTD \\bTD %s \\eTD \\eTR", 
#                format(o$measured_at[n], "%m-%d"), 
#                format(o$measured_at[n], "%H:%M"),
#                o$qc_service[n],
#                o$qc_lot[n],
#                o$.threesd.range[n],
#                switch(as.integer(o$processed[n]) + 1, paste("[aligncharacter=no, align={middle,lohi}] ", o$error_code[n], sep = ""), formatC(o$.result[n], digits = 2, format = 'f')), 
#                switch(as.integer(o$processed[n]) + 1, "NA", switch(as.integer(abs(o$.result.std[n]) < 3) + 1, "X", "O")),
#                o$technician[n]))
#        }
#        z <- c(z, 
#            "\\eTABLEbody",  
#            "\\eTABLE", 
#            "% HISTORY TABLE STOP")
#        
#        # spc plot
#        pdf(file = paste(prefix, "-monthspc-", serial, ".pdf", sep = ""), width = 4, height = 4)
#        grid.draw(spc.plot(y = .result.std, date = measured_at, lot = qc_lot, data = e, ...))
#        dev.off()
#        # linearity plot
#        pdf(file = paste(prefix, "-monthlinear-", serial, ".pdf", sep = ""), width = 4, height = 4)
#        grid.draw(linearity.plot(y = .result, x = qc.mean, error = qc.sd, data = e, breaks = sapply(strsplit(qc.information$break_points[1], ",")[[1]], as.numeric), ...))
#        dev.off()
#        z <- c(z, 
#            "% SPC GRAPH START",
#            paste("\\placefigure[center,here,none][fig:", serial, "-spclinear]{}", sep = ""),
#            "{\\startcombination[2*1]",
#            paste("{\\externalfigure[", paste(prefix, "-monthspc-", serial, ".pdf", "][width=.4\\hsize]}{}", sep = ""), sep = ""), 
#            paste("{\\externalfigure[", paste(prefix, "-monthlinear-", serial, ".pdf", "][width=.4\\hsize]}{}", sep = ""), sep = ""), 
#            "\\stopcombination}",
#            "%\\blank[2*big]",
#            "% SPC GRAPH STOP",
#            "\\page[yes]")
#        
#        # qc statistic (precision & linearity)
#        qc.summary1 <- get.qcstat(e)
#        qc.summary2 <- list(r2 = cor(log(o$qc.mean), log(o$.result), use = "complete"))
#        z <- c(z, 
#            "% SUMMARY STATISTICS TABLE START",
#            "\\bTABLE[setups={table:summaryframe}, split=yes]")
#            for (l in 1:length(qc.summary1)) {
#                qc.sum <- data.frame(sdi = c(qc.summary1[[l]]["sdi"], qc.summary1.w[[l]]["sdi"], qc.summary1.p[[l]]["sdi"]), cvr = c(qc.summary1[[l]]["cvr"], qc.summary1.w[[l]]["cvr"], qc.summary1.p[[l]]["cvr"]), shape = as.factor(1:3))
#                pdf(file = paste(prefix, "-month_sdi_cvr-", serial, "-", l,".pdf", sep = ""), width = 4, height = 4)
#                grid.draw(sdi_cvr.plot(sdi, cvr, shape, qc.sum))
#                dev.off()
#                z <- c(z,
#                    "\\bTR \\bTD {\\startcombination[2*1]",
#                    "{\\bTABLE[setups={table:summary}, style=\\tfx\\ss] \\bTR \\eTR",
#                    paste("\\bTR \\bTD[nc=5, background=color, backgroundcolor=titlebackgroundcolor] ", names(qc.summary1)[l]," \\eTD \\eTR", sep = ""),
#                    "\\bTR \\bTD \\eTD \\bTD \\eTD \\bTD \\eTD \\bTD whole \\eTD \\bTD reference \\eTD \\eTR",
#                    paste("\\bTR \\bTD \\eTD \\bTD N \\eTD \\bTD ", formatC(qc.summary1[[l]]["n"], digits = 2), " \\eTD \\bTD ", formatC(qc.summary1.w[[l]]["n"], digits = 2), " \\eTD \\bTD", formatC(qc.summary1.p[[l]]["n"], digits = 2), " \\eTD \\eTR", sep = ""),
#                    paste("\\bTR \\bTD \\eTD \\bTD Labs \\eTD \\bTD . \\eTD \\bTD ", formatC(qc.summary1.w[[l]]["nlabs"], digits = 2), " \\eTD \\bTD", formatC(qc.summary1.p[[l]]["nlabs"], digits = 2), " \\eTD \\eTR", sep = ""),
#                    paste("\\bTR \\bTD \\eTD \\bTD Mean \\eTD \\bTD ", formatC(qc.summary1[[l]]["mean"], digits = 2), " \\eTD \\bTD ", formatC(qc.summary1.w[[l]]["mean"], digits = 2), " \\eTD \\bTD", formatC(qc.summary1.p[[l]]["mean"], digits = 2), " \\eTD \\eTR", sep = ""),
#                    paste("\\bTR \\bTD \\eTD \\bTD SD \\eTD \\bTD ", formatC(qc.summary1[[l]]["sd"], digits = 2), " \\eTD \\bTD ", formatC(qc.summary1.w[[l]]["sd"], digits = 2), " \\eTD \\bTD", formatC(qc.summary1.p[[l]]["sd"], digits = 2), " \\eTD \\eTR", sep = ""),
#                    paste("\\bTR \\bTD \\eTD \\bTD Bias \\eTD \\bTD ", formatC(qc.summary1[[l]]["bias"], digits = 2), " \\eTD \\bTD ", formatC(qc.summary1.w[[l]]["bias"], digits = 2), " \\eTD \\bTD", formatC(qc.summary1.p[[l]]["bias"], digits = 2), " \\eTD \\eTR", sep = ""),
#                    paste("\\bTR \\bTD \\eTD \\bTD CV \\eTD \\bTD ", formatC(qc.summary1[[l]]["cv"], digits = 2), " \\eTD \\bTD ", formatC(qc.summary1.w[[l]]["cv"], digits = 2), " \\eTD \\bTD", formatC(qc.summary1.p[[l]]["cv"], digits = 2), " \\eTD \\eTR", sep = ""),
#                    paste("\\bTR \\bTD \\eTD \\bTD SDI \\eTD \\bTD ", formatC(qc.summary1[[l]]["sdi"], digits = 2), " \\eTD \\bTD ", formatC(qc.summary1.w[[l]]["sdi"], digits = 2), " \\eTD \\bTD", formatC(qc.summary1.p[[l]]["sdi"], digits = 2), " \\eTD \\eTR", sep = ""),
#                    paste("\\bTR \\bTD \\eTD \\bTD CVR \\eTD \\bTD ", formatC(qc.summary1[[l]]["cvr"], digits = 2), " \\eTD \\bTD ", formatC(qc.summary1.w[[l]]["cvr"], digits = 2), " \\eTD \\bTD", formatC(qc.summary1.p[[l]]["cvr"], digits = 2), " \\eTD \\eTR", sep = ""),
#                    "\\bTR \\eTR",
#                    "\\eTABLE}{}",
#                    paste("{\\externalfigure[", paste(prefix, "-month_sdi_cvr-", serial, "-", l,".pdf", sep = ""), "][width=.25\\hsize]}{}", sep = ""),
#                    "\\stopcombination} \\eTD \\eTR")
#            }
#        z <- c(z, 
#            "\\eTABLE")
#        
#        z <- c(z, 
#            "\\page[yes]")
#    }
#    write.table(z, file = paste(prefix, "-month.tex", sep = ""), row.names = FALSE, col.names = FALSE, quote = FALSE, sep = "\n")
#}

generate.graph.thismonth.internal <- function(object, prefix, ...) {
    object <- object[order(format(object$measured_at, "%F %X")), ]    

    # FREND internal plot
    pdf(file = paste(prefix, "month-internal.pdf", sep = "-"), width = 10, height = 7)
    grid.draw(frendInternal.plot(date = measured_at, data = object, ...))
    dev.off()
    
   
    z <- paste("\\placefigure[center,here,none][fig:", serial, "-internal]{}{\\externalfigure[", paste(prefix, "month-internal.pdf", sep = "-"), "][width=\\hsize]}", sep = "")

    # equipment title
    z <- generate.frame.withtitle(z, object$serial_number[1], paste("Location: ", object$ip_address[1], sep = ""), 
        "P Error: FREND Laser Power Failure\\\\A Error: FREND Laser Alignment Failure\\\\M Error: Measurement Failure (Calculated Ratio differs from Manufacture setting)")
    
    write.table(z, file = paste(prefix, "-month-graph-internal.tex", sep = ""), row.names = FALSE, col.names = FALSE, quote = FALSE, sep = "\n")
    
}

generate.table.thismonth.history <- function(object, prefix, qc.information, messages, ...) {
    object <- object[order(paste(object$qc_service, object$qc_lot, format(object$measured_at, "%F %X"))), ]
    object$.bs <- paste(object$qc_service, object$qc_lot, sep = "#")
        
    # history table
    errorcodes <- character()
    z <- c(
        "\\bTABLE[setups={table:monthhistory}, split=repeat]", 
        "\\bTABLEhead", 
        paste("\\bTR[style=\\rm] \\bTH Date \\eTH \\bTH Time \\eTH \\bTH Service \\eTH \\bTH Lot \\eTH \\bTH 3SD Range \\eTH \\bTH", qc.information$unit[1], " \\eTH \\bTH QC status \\eTH \\bTH Technician \\eTH \\eTR"), 
        "\\eTABLEhead", 
        "\\bTABLEbody")        
    for (n in 1:nrow(object)) {
        if (object$processed[n]) {
            value <- formatC(object$.result[n], digits = 2, format = 'f')
            status <- ifelse(abs(object$.result.std[n]) < 3, ifelse(abs(object$.result.std[n]) < 2, "pass", "warning"), "[style=\\bf] fail")
        } else {
            value <- object$error_code[n]
            status <- "na"
            errorcodes <- c(errorcodes, value)
        }
        z <- c(z, 
            sprintf("\\bTR[style=\\ss\\tfx] \\bTD %s \\eTD \\bTD %s \\eTD \\bTD %s \\eTD \\bTD %s \\eTD \\bTD %s \\eTD \\bTD %s \\eTD \\bTD %s \\eTD \\bTD %s \\eTD \\eTR", 
                format(object$measured_at[n], "%m-%d"), 
                format(object$measured_at[n], "%H:%M"),
                object$qc_service[n],
                object$qc_lot[n],
                object$.threesd.range[n],
                value, 
                status,
                object$technician[n])
        )
    }
    z <- c(z, 
        "\\eTABLEbody",  
        "\\eTABLE"
    )
    # error codes
    errorcodes <- unique(errorcodes)
    if (length(errorcodes) > 0) {
        error.messages <- paste(messages[errorcodes, "error_code"], messages[errorcodes, "description"], sep = ": ", collapse = "\\\\")
    } else {
        error.messages <- ""
    }
    
    # equipment title
    z <- generate.frame.withtitle(z, object$serial_number[1], paste("Location: ", object$ip_address[1], sep = ""), error.messages)
    
    write.table(z, file = paste(prefix, "-month-table-history.tex", sep = ""), row.names = FALSE, col.names = FALSE, quote = FALSE, sep = "\n")
}

generate.tablegraph.thismonth.spc <- function(object, prefix, qc.information, ...) {
    object <- object[order(paste(object$qc_service, object$qc_lot, format(object$measured_at, "%F %X"))), ]
    object$.bs <- paste(object$qc_service, object$qc_lot, sep = "#")
        
    # spc plot
    pdf(file = paste(prefix, "month-spc.pdf", sep = "-"), width = 12, height = 4)
    grid.draw(spc.plot(y = .result.std, date = measured_at, lot = qc_lot, data = object, ...))
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
        paste("{\\externalfigure[", paste(prefix, "month-spc.pdf", sep = "-"), "][width=\\hsize]}{}", sep = ""),
        "\\stopcombination"
    )
    
    # equipment title
    z <- generate.frame.withtitle(z, object$serial_number[1], paste("Location: ", object$ip_address[1], sep = ""),
    "$\\tfx\\rm{1_{3s}}$: Out of 3SD Range\\\\$\\tfx\\rm{1_{2s}}$: Out of 2SD Range\\\\$\\tfx\\rm{R_{4s}}$: Over 4SD variation")
    
    write.table(z, file = paste(prefix, "-month-tablegraph-diagnosis.tex", sep = ""), row.names = FALSE, col.names = FALSE, quote = FALSE, sep = "\n")
}

generate.tablegraph.thisyear.qc <- function(object, prefix, qc.information, whole, reference, ...) {
    object <- object[order(paste(object$qc_service, object$qc_lot, format(object$measured_at, "%F %X"))), ]
    object$.bs <- paste(object$qc_service, object$qc_lot, sep = "#")

    # comparative statistics
    qcstat.w <- get.qcstat1(whole, object)
    qcstat.r <- get.qcstat1(reference, object)

    # generate summary table    
    z <- c( 
        "\\bTABLE[setups={table:yearframe}]"
    )
        for (l in 1:nrow(qcstat.w)) {
            sdicvr <- data.frame(sdi = c(qcstat.w[l, "sdi"], qcstat.r[l, "sdi"]), cvr = c(qcstat.w[l, "cvr"], qcstat.r[l, "cvr"]), shape = c("whole", "reference"))
            pdf(file = paste(prefix, "-year-sdi_cvr-", l,".pdf", sep = ""), width = 5, height = 4)
            grid.draw(sdi_cvr.plot(sdi, cvr, shape, sdicvr))
            dev.off()
            z <- c(z,
                "\\bTR \\bTD {\\startcombination[2*1]",
                "{\\bTABLE[setups={table:yearsdicvr}, style=\\tfx\\ss]",
#                "\\bTR \\eTR",
#                paste("\\bTR \\bTD[nc=4, background=color, backgroundcolor=titlebackgroundcolor, align=right, style=\\rm] ", rownames(qcstat.w)[l]," \\eTD \\bTD \\eTD \\eTR", sep = ""),
                paste("\\bTR[bottomframe=on, framecolor=titlebackgroundcolor, rulethickness=1pt] \\bTD[nc=4, align=right, style=\\rm] ", rownames(qcstat.w)[l]," \\eTD \\bTD \\eTD \\eTR", sep = ""),
                "\\bTR \\bTH \\eTH \\bTH \\eTH \\bTH whole \\eTH \\bTH reference \\eTH \\bTH \\eTH \\eTR",
                paste("\\bTR \\bTD \\eTD \\bTD SDI \\eTD \\bTD", formatC(qcstat.w[l, "sdi"], digits = 2, width = 2, format = "f"), "\\eTD \\bTD", formatC(qcstat.r[l, "sdi"], digits = 2, width = 2, format = "f"), "\\eTD \\bTD \\eTD \\eTR"),
                paste("\\bTR \\bTD \\eTD \\bTD CVR \\eTD \\bTD", formatC(qcstat.w[l, "cvr"], digits = 2, width = 2, format = "f"), "\\eTD \\bTD", formatC(qcstat.r[l, "cvr"], digits = 2, width = 2, format = "f"), "\\eTD \\bTD \\eTD \\eTR"),
                paste("\\bTR[aligncharacter=no] \\bTD \\eTD \\bTD N. Labs \\eTD \\bTD", formatC(qcstat.w[l, "nlabs"], digits = 2, width = 2, format = "d"), "\\eTD \\bTD", formatC(qcstat.r[l, "nlabs"], digits = 2, width = 2, format = "d"), "\\eTD \\bTD \\eTD \\eTR"),
                paste("\\bTR[aligncharacter=no] \\bTD \\eTD \\bTD N. Measurement \\eTD \\bTD", formatC(qcstat.w[l, "n"], digits = 2, width = 2, format = "d"), "\\eTD \\bTD", formatC(qcstat.r[l, "n"], digits = 2, width = 2, format = "d"), "\\eTD \\bTD \\eTD \\eTR"),
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
    z <- generate.frame.withtitle(z, object$serial_number[1], paste("Location: ", object$ip_address[1], sep = ""), "Standard Deviation Index (SDI): (Laboratory Mean - Consensus Group Mean) / (Consensus Group SD)\\\\Coefficient of Variation Ratio (CVR): Laboratory CV / Consensus Group CV")
    
    write.table(z, file = paste(prefix, "-year-tablegraph.tex", sep = ""), row.names = FALSE, col.names = FALSE, quote = FALSE, sep = "\n")
}

generate.table.thisyear.history.qc <- function(object, prefix, qc.information, whole, reference, ...) {
    object <- object[order(paste(object$qc_service, object$qc_lot, format(object$measured_at, "%F %X"))), ]
    object$.bs <- paste(object$qc_service, object$qc_lot, sep = "#")

    # Title for months
    base.year <- unique(format(range(object$measured_at), "%Y")) 
    base.date <- format(as.Date(paste(rep(base.year, each = 12), rep(1:12, length(base.year)), 1, sep = "-")), "%b")
    names(base.date) <- format(as.Date(paste(rep(base.year, each = 12), rep(1:12, length(base.year)), 1, sep = "-")), "%Y%m")
    base.date[str_sub(names(base.date), -2) == "01"] <- paste(str_sub(names(base.date)[str_sub(names(base.date), -2) == "01"], 1, 4), base.date[str_sub(names(base.date), -2) == "01"], sep = "\\\\")
    object$.date <- as.ordered(format(object$measured_at, "%Y%m"))
    levels(object$.date) <- base.date[levels(object$.date)]

    # comparative statistics
    qcstat <- lapply(levels(object$.date), function(x) get.qcstat3(object[object$.date == x, ]))
    names(qcstat) <- levels(object$.date)
    qcstat2 <- lapply(rownames(qcstat[[1]]), function(x) { sapply(qcstat, function(y) formatC(y[x, ], width = 2, digits = 2)) })
    names(qcstat2) <- rownames(qcstat[[1]])
    
    # generate summary table    
    z <- c(
        "\\bTABLE[setups={table:yearsummary}, split=repeat]",
        "\\bTABLEhead",
        paste("\\bTR \\bTH \\eTH \\bTH", paste(colnames(qcstat2[[1]]), collapse = " \\eTH \\bTH "), " \\eTH \\eTR", sep = " "),
        "\\eTABLEhead",
        "\\bTABLEbody"
    )
    for (i in 1:length(qcstat2)) {
        z <- c(z, 
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
        
    z <- c(z,    
        "\\bTR[rulethickness=0pt] \\eTR",
        "\\eTABLEbody",
        "\\eTABLE"
    )    
    
    # equipment title
    z <- generate.frame.withtitle(z, object$serial_number[1], paste("Location: ", object$ip_address[1], sep = ""))
    
    write.table(z, file = paste(prefix, "-year-table-history.tex", sep = ""), row.names = FALSE, col.names = FALSE, quote = FALSE, sep = "\n")
}

generate.graph.thisyear.history.qc <- function(object, prefix, qc.information, whole, reference, ...) {
    object <- object[order(paste(object$qc_service, object$qc_lot, format(object$measured_at, "%F %X"))), ]
    object$.bs <- paste(object$qc_service, object$qc_lot, sep = "#")

    # comparative statistics
    qcstat1.w <- get.qcstat1(whole, object)
    qcstat2.w <- get.qcstat2(whole, object)
    qcstat1.r <- get.qcstat1(reference, object)
    qcstat2.r <- get.qcstat2(reference, object)
        
    # generate summary figure
    pdf(file = paste(prefix, "year-graph-history.pdf", sep = "-"), width = 12, height = 5 * length(unique(object$qc_lot)))
    grid.draw(history.plot(y = .result.std, date = measured_at, service = qc_service, lot = qc_lot, base.mean = .qc.mean, base.sd = .qc.sd, data = object, ...))
    dev.off()
    
    z <- c(
        "\\placefigure[center,here,none][fig:yearhistory]{}{",
        paste("\\externalfigure[", prefix, "-year-graph-history.pdf", "][width=\\hsize]", sep = ""), 
        "}"
    )    
    
    # equipment title
    z <- generate.frame.withtitle(z, object$serial_number[1], paste("Location: ", object$ip_address[1], sep = ""))
    
    write.table(z, file = paste(prefix, "-year-graph-history.tex", sep = ""), row.names = FALSE, col.names = FALSE, quote = FALSE, sep = "\n")
}

# method: database - imprecision & inaccuracy suggested from database
# method: adaptive - imprecision & inaccuracy computed on whole data
generate.graph.thisyear.quality.qc <- function(object, prefix, qc.information, whole, reference, method = "database", ...) {
    object <- object[order(format(object$measured_at, "%F %X")), ]    
    object$.date.lot <- paste(format(object$measured_at, "%Y%m"), object$qc_lot, paste = ":")

    # bias & CV
    opspecs <- get.qcstat5(object)
    
    if (method != "adaptive" || missing(whole)) {
        inaccuracy  <- qc.information$inaccuracy[1]
        imprecision <- qc.information$imprecision[1]
    } else {
        z <- get.qcstat5(whole)
        inaccuracy  <- z$inaccuracy
        imprecision <- z$imprecision
    }

    z <- c( 
        "\\bTABLE[setups={table:yearframe}]"
    )
    for (l in 1:length(opspecs)) {
        # QCSpecs Chart plot
        pdf(file = paste(prefix, "year-quality-", l, ".pdf", sep = ""), width = 10, height = 6)
        grid.draw(opspecs.plot(data = opspecs[[l]], base.inaccuracy = inaccuracy, base.imprecision = imprecision, title = names(opspecs)[l], ...))
        dev.off()        
        
        z <- c(z,
            paste("\\bTR \\bTD[align=right, style=\\rm\\tfa]", str_replace(names(opspecs)[l], "#", "\\\\#"), "\\\\"), 
            paste("\\placefigure[center,here,none][fig:", serial, "-quality]{}{\\externalfigure[", paste(prefix, "year-quality-", l, ".pdf", sep = ""), "][width=.75\\hsize]} \\eTD \\eTR", sep = "")
        )
    }
    z <- c(z,
        "\\eTABLE"
    )   

    # equipment title
    z <- generate.frame.withtitle(z, object$serial_number[1], paste("Location: ", object$ip_address[1], sep = ""), 
        "Dashed line: Limits of bias and imprecision for suggested QC procedure (Operating Limits line)\\\\Solid line: Maximum limits of a stable process")
    
    write.table(z, file = paste(prefix, "-year-graph-quality.tex", sep = ""), row.names = FALSE, col.names = FALSE, quote = FALSE, sep = "\n") 
}

generate.TableHistory.qc <- function(object, prefix, unit, ...) {
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

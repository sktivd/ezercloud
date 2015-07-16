require("stringr")

# available columns: measured_at, ip_address, serial_number, test, processed, error_code, .result, device_id, device_lot
# qc_service, qc_lot

generate.thismonth.qc <- function(object, prefix, qc.information, whole, peer, ...) {
    # whole 
    qc.summary1.w <- tapply(1:nrow(whole), paste(whole$qc_service, " \\#", whole$qc_lot, sep = ""), function(x)  
        c(n = sum(is.finite(whole$.result[x])),
          nlabs = length(unique(whole$ip_address)),
          mean = mean(whole$.result[x], na.rm = TRUE),
          sd = sd(whole$.result[x], na.rm = TRUE),
          sdi = (mean(whole$.result[x], na.rm = TRUE) - whole$qc.mean[x[1]]) / whole$qc.sd[x[1]],
          bias = (mean(whole$.result[x], na.rm = TRUE) - whole$qc.mean[x[1]]) / whole$qc.mean[x[1]],
          cv = sd(whole$.result[x], na.rm = TRUE) / mean(whole$.result[x], na.rm = TRUE),
          cvr = (sd(whole$.result[x], na.rm = TRUE) / mean(whole$.result[x], na.rm = TRUE)) / (whole$qc.sd[x[1]] / whole$qc.mean[x[1]])))
    qc.summary2.w <- list(r = cor(log(whole$qc.mean), log(whole$.result), use = "complete"))
    if (missing(peer)) {
        peer <- whole
    }
    qc.summary1.p <- tapply(1:nrow(peer), paste(peer$qc_service, " \\#", peer$qc_lot, sep = ""), function(x)  
        c(n = sum(is.finite(peer$.result[x])),
          nlabs = length(unique(peer$ip_address)),
          mean = mean(peer$.result[x], na.rm = TRUE),
          sd = sd(peer$.result[x], na.rm = TRUE),
          sdi = (mean(peer$.result[x], na.rm = TRUE) - peer$qc.mean[x[1]]) / peer$qc.sd[x[1]],
          bias = (mean(peer$.result[x], na.rm = TRUE) - peer$qc.mean[x[1]]) / peer$qc.mean[x[1]],
          cv = sd(peer$.result[x], na.rm = TRUE) / mean(peer$.result[x], na.rm = TRUE),
          cvr = (sd(peer$.result[x], na.rm = TRUE) / mean(peer$.result[x], na.rm = TRUE)) / (peer$qc.sd[x[1]] / peer$qc.mean[x[1]])))
    qc.summary2.p <- list(r = cor(log(peer$qc.mean), log(peer$.result), use = "complete"))
    
    
    o <- object[order(paste(object$qc_service, object$qc_lot, format(object$measured_at, "%F %X"))), ]
    o$.bs <- paste(o$qc_service, o$qc_lot, sep = "#")
    z <- NULL
    for (f in unique(o$serial_number)) {
        e <- o[o$serial_number == f, ]
        
        # equipment title
        z <- c(z,
            "\\blank[2*big]", 
            paste("\\framedtext{\\ss\\tfa ", f, "}", sep = ""), 
            "\\blank[big]")
        # history table
        z <- c(z,
            "% HISTORY TABLE START", 
            "\\bTABLE[setups={table:history}, split=repeat]", 
            "\\bTABLEhead", 
            "\\bTR \\bTD Date \\eTD \\bTD Time \\eTD \\bTD Service \\eTD \\bTD Lot \\eTD \\bTD 3SD Range \\eTD \\bTD [aligncharacter=no, align={middle,lohi}] ", qc.information$unit[1], " \\eTD \\bTD QC status \\eTD \\bTD Tech. \\eTD \\eTR", 
            "\\eTABLEhead", 
            "\\bTABLEbody")        
        for (n in 1:nrow(e)) {
            tt <- sprintf("\\bTR \\bTD %s \\eTD \\bTD %s \\eTD \\bTD %s \\eTD \\bTD %s \\eTD \\bTD %s \\eTD \\bTD %s \\eTD \\bTD %s \\eTD \\bTD %s \\eTD \\eTR", 
                format(e$measured_at[n], "%m-%d"), 
                format(e$measured_at[n], "%H:%M"),
                e$qc_service[n],
                e$qc_lot[n],
                e$.threesd.range[n],
                switch(as.integer(e$processed[n]) + 1, paste("[aligncharacter=no, align={middle,lohi}] ", e$error_code[n], sep = ""), formatC(e$.result[n], digits = 2, format = 'f')), 
                switch(as.integer(e$processed[n]) + 1, "NA", switch(as.integer(abs(e$.result.std[n]) < 3) + 1, "X", "O")),
                e$technician[n])
            z <- c(z, 
                sprintf("\\bTR \\bTD %s \\eTD \\bTD %s \\eTD \\bTD %s \\eTD \\bTD %s \\eTD \\bTD %s \\eTD \\bTD %s \\eTD \\bTD %s \\eTD \\bTD %s \\eTD \\eTR", 
                    format(e$measured_at[n], "%m-%d"), 
                    format(e$measured_at[n], "%H:%M"),
                    e$qc_service[n],
                    e$qc_lot[n],
                    e$.threesd.range[n],
                    switch(as.integer(e$processed[n]) + 1, paste("[aligncharacter=no, align={middle,lohi}] ", e$error_code[n], sep = ""), formatC(e$.result[n], digits = 2, format = 'f')), 
                    switch(as.integer(e$processed[n]) + 1, "NA", switch(as.integer(abs(e$.result.std[n]) < 3) + 1, "X", "O")),
                    e$technician[n]))
        }
        z <- c(z, 
            "\\eTABLEbody",  
            "\\eTABLE", 
            "% HISTORY TABLE STOP")
        
        # spc plot
        pdf(file = paste(prefix, "-monthspc-", f, ".pdf", sep = ""), width = 4, height = 4)
        grid.draw(spc.plot(y = .result.std, date = measured_at, lot = qc_lot, data = e, ...))
        dev.off()
        # linearity plot
        pdf(file = paste(prefix, "-monthlinear-", f, ".pdf", sep = ""), width = 4, height = 4)
        grid.draw(linearity.plot(y = .result, x = qc.mean, error = qc.sd, data = e, breaks = sapply(strsplit(qc.information$break_points[1], ",")[[1]], as.numeric), ...))
        dev.off()
        z <- c(z, 
            "% SPC GRAPH START",
            paste("\\placefigure[center,here,none][fig:", f, "-spclinear]{}", sep = ""),
            "{\\startcombination[2*1]",
            paste("{\\externalfigure[", paste(prefix, "-monthspc-", f, ".pdf", "][width=.4\\hsize]}{}", sep = ""), sep = ""), 
            paste("{\\externalfigure[", paste(prefix, "-monthlinear-", f, ".pdf", "][width=.4\\hsize]}{}", sep = ""), sep = ""), 
            "\\stopcombination}",
            "%\\blank[2*big]",
            "% SPC GRAPH STOP",
            "\\page[yes]")
        
        # qc statistic (precision & linearity)
        qc.summary1 <- tapply(1:nrow(e), paste(e$qc_service, " \\#", e$qc_lot, sep = ""), function(x)  
            c(n = sum(is.finite(e$.result[x])),
              mean = mean(e$.result[x], na.rm = TRUE),
              sd = sd(e$.result[x], na.rm = TRUE),
              sdi = (mean(e$.result[x], na.rm = TRUE) - e$qc.mean[x[1]]) / e$qc.sd[x[1]],
              bias = (mean(e$.result[x], na.rm = TRUE) - e$qc.mean[x[1]]) / e$qc.mean[x[1]],
              cv = sd(e$.result[x], na.rm = TRUE) / mean(e$.result[x], na.rm = TRUE),
              cvr = (sd(e$.result[x], na.rm = TRUE) / mean(e$.result[x], na.rm = TRUE)) / (e$qc.sd[x[1]] / e$qc.mean[x[1]])))
        qc.summary2 <- list(r2 = cor(log(e$qc.mean), log(e$.result), use = "complete"))
        z <- c(z, 
            "% SUMMARY STATISTICS TABLE START",
            "\\bTABLE[setups={table:summaryframe}, split=yes]")
            for (l in 1:length(qc.summary1)) {
                qc.sum <- data.frame(sdi = c(qc.summary1[[l]]["sdi"], qc.summary1.w[[l]]["sdi"], qc.summary1.p[[l]]["sdi"]), cvr = c(qc.summary1[[l]]["cvr"], qc.summary1.w[[l]]["cvr"], qc.summary1.p[[l]]["cvr"]), shape = as.factor(1:3))
                pdf(file = paste(prefix, "-month_sdi_cvr-", f, "-", l,".pdf", sep = ""), width = 4, height = 4)
                grid.draw(sdi_cvr.plot(sdi, cvr, shape, qc.sum))
                dev.off()
                z <- c(z,
                    "\\bTR \\bTD {\\startcombination[2*1]",
                    "{\\bTABLE[setups={table:summary}, style=\\tfx\\ss] \\bTR \\eTR",
                    paste("\\bTR \\bTD[nc=5, background=color, backgroundcolor=titlebackgroundcolor] ", names(qc.summary1)[l]," \\eTD \\eTR", sep = ""),
                    "\\bTR \\bTD \\eTD \\bTD \\eTD \\bTD \\eTD \\bTD whole \\eTD \\bTD peer \\eTD \\eTR",
                    paste("\\bTR \\bTD \\eTD \\bTD N \\eTD \\bTD ", formatC(qc.summary1[[l]]["n"], digits = 2), " \\eTD \\bTD ", formatC(qc.summary1.w[[l]]["n"], digits = 2), " \\eTD \\bTD", formatC(qc.summary1.p[[l]]["n"], digits = 2), " \\eTD \\eTR", sep = ""),
                    paste("\\bTR \\bTD \\eTD \\bTD Labs \\eTD \\bTD . \\eTD \\bTD ", formatC(qc.summary1.w[[l]]["nlabs"], digits = 2), " \\eTD \\bTD", formatC(qc.summary1.p[[l]]["nlabs"], digits = 2), " \\eTD \\eTR", sep = ""),
                    paste("\\bTR \\bTD \\eTD \\bTD Mean \\eTD \\bTD ", formatC(qc.summary1[[l]]["mean"], digits = 2), " \\eTD \\bTD ", formatC(qc.summary1.w[[l]]["mean"], digits = 2), " \\eTD \\bTD", formatC(qc.summary1.p[[l]]["mean"], digits = 2), " \\eTD \\eTR", sep = ""),
                    paste("\\bTR \\bTD \\eTD \\bTD SD \\eTD \\bTD ", formatC(qc.summary1[[l]]["sd"], digits = 2), " \\eTD \\bTD ", formatC(qc.summary1.w[[l]]["sd"], digits = 2), " \\eTD \\bTD", formatC(qc.summary1.p[[l]]["sd"], digits = 2), " \\eTD \\eTR", sep = ""),
                    paste("\\bTR \\bTD \\eTD \\bTD Bias \\eTD \\bTD ", formatC(qc.summary1[[l]]["bias"], digits = 2), " \\eTD \\bTD ", formatC(qc.summary1.w[[l]]["bias"], digits = 2), " \\eTD \\bTD", formatC(qc.summary1.p[[l]]["bias"], digits = 2), " \\eTD \\eTR", sep = ""),
                    paste("\\bTR \\bTD \\eTD \\bTD CV \\eTD \\bTD ", formatC(qc.summary1[[l]]["cv"], digits = 2), " \\eTD \\bTD ", formatC(qc.summary1.w[[l]]["cv"], digits = 2), " \\eTD \\bTD", formatC(qc.summary1.p[[l]]["cv"], digits = 2), " \\eTD \\eTR", sep = ""),
                    paste("\\bTR \\bTD \\eTD \\bTD SDI \\eTD \\bTD ", formatC(qc.summary1[[l]]["sdi"], digits = 2), " \\eTD \\bTD ", formatC(qc.summary1.w[[l]]["sdi"], digits = 2), " \\eTD \\bTD", formatC(qc.summary1.p[[l]]["sdi"], digits = 2), " \\eTD \\eTR", sep = ""),
                    paste("\\bTR \\bTD \\eTD \\bTD CVR \\eTD \\bTD ", formatC(qc.summary1[[l]]["cvr"], digits = 2), " \\eTD \\bTD ", formatC(qc.summary1.w[[l]]["cvr"], digits = 2), " \\eTD \\bTD", formatC(qc.summary1.p[[l]]["cvr"], digits = 2), " \\eTD \\eTR", sep = ""),
                    "\\bTR \\eTR",
                    "\\eTABLE}{}",
                    paste("{\\externalfigure[", paste(prefix, "-month_sdi_cvr-", f, "-", l,".pdf", sep = ""), "][width=.42\\hsize]}{}", sep = ""),
                    "\\stopcombination} \\eTD \\eTR")
            }
        z <- c(z, 
            "\\eTABLE")
        
        z <- c(z, 
            "\\page[yes]")
    }
    write.table(z, file = paste(prefix, "-month.tex", sep = ""), row.names = FALSE, col.names = FALSE, quote = FALSE, sep = "\n")
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

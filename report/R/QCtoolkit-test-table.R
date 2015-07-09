
# available columns: measured_at, ip_address, serial_number, test values

generate.TableGraph.test <- function(object, path.table, file, ...) {
    o <- object[order(object$measured_at), ]
    z <- c(
           "% setup framedtext",
           "\\setupframedtexts[frame=off, leftframe=on, framecolor=darkgray, rulethickness=5pt, width=local]",
           "% setup tables", 
           "\\setupTABLE[frame=off]", 
           "\\setupTABLE[column][1][align={middle,lohi}, width=36pt]",
           "\\setupTABLE[column][2][align={middle,lohi}, width=48pt]",
           "\\setupTABLE[column][3][align={middle,lohi}, width=48pt]",
           "\\setupTABLE[column][4][alignmentcharacter={.}, aligncharacter=yes, align={left,lohi}, width=56pt]",
           "\\setupTABLE[column][5][align={middle,lohi}, width=48pt]",
           "\\setupTABLE[column][7][align={middle,lohi}, width=36pt]",
           "\\setupTABLE[column][8][align={middle,lohi}, width=48pt]",
           "\\setupTABLE[column][9][align={middle,lohi}, width=48pt]",
           "\\setupTABLE[column][10][alignmentcharacter={.},aligncharacter=yes, align={left,lohi}, width=56pt]",
           "\\setupTABLE[column][11][align={middle,lohi}, width=48pt]",
           "\\setupTABLE[row][even][background=color, backgroundcolor=tablebackgroundcolor]",
           "\\setupTABLE[header][each][bottomframe=on, framecolor=darkgray, rulethickness=0.3mm, align={middle,lohi}]",
           "\\setupTABLE[header][6][bottomframe=off]",
           "\\setupTABLE[footer][each][topframe=on, framecolor=darkgray]",
           "\\setupTABLE[column][6][align={right,lohi}, width=18pt, background=color, backgroundcolor=white]"
           )
    for (f in unique(o$serial_number)) {
        e <- o[o$serial_number == f, ]
        e.odd <- e[seq(1, nrow(e), 2), ]
        e.even <- e[seq(0, nrow(e), 2), ]

        z <- c(z, "\\blank[2*big]", paste("\\framedtext{", f, "}", sep = ""), "\\blank[big]", "\\bTABLE[split=repeat]", "\\bTABLEhead", "\\bTR \\bTD No. \\eTD \\bTD Date \\eTD \\bTD Time \\eTD \\bTD Value \\eTD \\bTD Tech. \\eTD \\bTD \\eTD \\bTD No. \\eTD \\bTD Date \\eTD \\bTD Time \\eTD \\bTD Value \\eTD \\bTD Tech. \\eTD \\eTR ", "\\eTABLEhead", "\\bTABLEbody")        
        for (i in 1:nrow(e.odd)) {
            row.odd <- sprintf("\\bTD %d \\eTD \\bTD %s \\eTD \\bTD %s \\eTD \\bTD %s \\eTD \\bTD %s \\eTD \\bTD \\eTD", i * 2 - 1, format(e.odd$measured_at[i], "%m-%d"), format(e.odd$measured_at[i], "%H:%M"), switch(as.integer(e.odd$processed[i]) + 1, e.odd$error_code[i], formatC(e.odd$.value[i], width = 4, digits = 2, format = 'f')), e.odd$technician[i])
            if (! is.na(e.even$.value[i])) {
                row.even <- sprintf("\\bTD %d \\eTD \\bTD %s \\eTD \\bTD %s \\eTD \\bTD %s \\eTD \\bTD %s \\eTD", i * 2, format(e.even$measured_at[i], "%m-%d"), format(e.even$measured_at[i], "%H:%M"), switch(as.integer(e.even$processed[i]) + 1, e.even$error_code[i], formatC(e.even$.value[i], width = 2, digits = 2, format = 'f')), e.even$technician[i])
            } else {
                row.even <- "\\bTD[nc=5, backgroundcolor=white] \\eTD"
            }
            z <- c(z, paste("\\bTR", row.odd, row.even, "\\eTR"))
        }
                        
        z <- c(z, "\\eTABLEbody",  "\\eTABLE")
        
        # history plot
        pdf(file = file.path(path.table, paste(file, "-history-", f, ".pdf", sep = "")), width = 12, height = 3)
#        grid.draw(history.plot(y = .value, date = measured_at, data = e, ...))
        grid.draw(history.plot(y = .value, date = measured_at, data = e))
        dev.off()
        
        z <- c(z, paste("\\placefigure[center,bottom,none][fig:", f, "]{}{", "\\externalfigure[", file.path(path.table, paste(file, "-history-", f, ".pdf", "][width=\\hsize]", sep = "")), sep = ""), "}", "\\page[yes]")
    }
    write.table(z, file = file.path(path.table, paste(file, ".tex", sep = "")), row.names = FALSE, col.names = FALSE, quote = FALSE, sep = "\n")
}
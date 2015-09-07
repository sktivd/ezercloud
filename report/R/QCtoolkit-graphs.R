require(ggplot2)
require(grid)
require(gtable)

.scale.identity <- function(x, ...) {
    x
}
.scale.log10 <- function(x, ...) {
    log(x, 10)
}
.scale.log <- function(x, base, ...) {
    log(x, base)
}
.expression.identity <- function(x, ...) {
    formatC(x, ...)
}
.expression.exp <- function(x, base = "10", ...) {
    x <- log(x, base)
    if (is.character(base)) {
        base <- as.symbol(base)        
    }
    sapply(x, function(y) bquote(.(base)^.(formatC(y, ...))))
}

get.histogram.block <- function(x, centers) {
    z <- data.frame(center = sort(centers), count = 0)
    if (length(z$center) > 1) {
        mid.centers <- c(-Inf, z$center[1:(length(z$center) - 1)] + diff(z$center) / 2, Inf)
    }
    values <- x
    for (i in 1:length(mid.centers[-1])) {
        z$count[i] <- sum(values > mid.centers[i] & values <= mid.centers[i + 1])
    }
    breaks <- mid.centers
    breaks[1] <- z$center[1] - (mid.centers[2] - z$center[1])
    breaks[length(breaks)] <- z$center[nrow(z)] + (z$center[nrow(z)] - mid.centers[nrow(z)]) 
    z$weight <- diff(breaks)
    attr(z, "breaks") <- breaks
    
    z
}
get.histogram.path <- function(block) {
    breaks <- attributes(block)$breaks
    
    y <- numeric(2 * nrow(block))
    for (i in 1:nrow(block)) {
        y[i * 2 - 1] <- breaks[i]
        y[i * 2] <- breaks[i + 1]
    }
    z <- data.frame(x = c(0, rep(block$count, each = 2), 0), y = c(y[1], y, y[length(y)]))
    
    z
}
update.breaks <- function(breaks, guided.number = 7) {
    z <- (1:length(breaks))[is.finite(breaks)]
    margin <- diff(range(breaks[z], na.rm = TRUE)) / 7
    
    while (TRUE) {
        diffs <- diff(breaks[z])
        if (any(diffs < margin)) {
            loc <- which.min(diffs) + 1
            if (loc == length(z)) {
                loc <- loc - 1
            }
            z <- z[-loc]
        } else {
            break
        }
    }
    
    z
}

get.steppedlimit <- function(x, step.size = 1, lower = TRUE) {
    if (lower) {
        as.integer((x - step.size) / step.size) * step.size
    } else {
        as.integer((x + step.size) / step.size) * step.size
    }
}

get.gtableloc.all <- function(x, name) {
    loc <- as.numeric(x$layout[x$layout$name == name, c("t", "l", "b", "r")])
    names(loc) <- c("t", "l", "b", "r")
    loc
}

get.gtableloc <- function(x, name, position) {
    x$layout[x$layout$name == name, position]
}

# internal_qc_laser_power_test, internal_qc_laseralignment_test, internal_qc_calculated_ratio_test, internal_qc_test
frendInternal.plot <- function(date, data) {
    mf <- match.call(expand.dots = FALSE)
    m <- match(c("data", "na.action"), names(mf), 0L)
    mf <- mf[c(1L, m)]
    mf$formula <- as.formula(paste("~", substitute(date), "+ internal_qc_laser_power_test + internal_qc_laseralignment_test + internal_qc_calculated_ratio_test + internal_qc_test"))
    mf$drop.unused.levels <- FALSE
    mf$na.action <- "na.pass"
    mf[[1L]] <- quote(stats::model.frame)
    mf <- eval(mf, parent.frame())
    mf$.date <- format(mf[, 1], "%m-%d")
    mf <- mf[! duplicated(mf$.date, fromLast = TRUE), ]
    mf[, 2] <- as.character(as.integer(! mf[, 2]))
    mf[, 3] <- as.character(as.integer(! mf[, 3]))
    mf[, 4] <- as.character(as.integer(! mf[, 4]))
    
    md <- data.frame(.date = format(max(mf[, 1]) - 0:30 * 86400, "%m-%d"), .index = 28:-2 + as.integer(format(max(mf[, 1]), "%w")))
    md <- merge(mf, md, all.y = TRUE)
    md$.date2 <- sapply(1:nrow(md), function(x) ifelse(x == 1 || str_sub(md$.date[x], -2) == "01", paste(as.integer(str_sub(md$.date[x], 1, 2)), as.integer(str_sub(md$.date[x], -2)), sep = "/"), as.integer(str_sub(md$.date[x], -2))))
    md$.x <- md$.index %% 7 + 1
    md$.y <- 5 - md$.index %/% 7 + 1
    md$internal_qc_test <- as.character(as.integer(is.na(md$internal_qc_test)))
    
    frend.ggplot <- ggplot(data = md, aes(x = .x, y = .y)) + geom_point(aes(colour = internal_qc_laser_power_test), size = 30, shape = 16) + geom_point(aes(colour = internal_qc_laseralignment_test), size = 20, shape = 16) + geom_point(aes(colour = internal_qc_calculated_ratio_test), size = 10, shape = 16) + geom_point(aes(colour = internal_qc_test), size = 10, shape = 1) + geom_point(aes(colour = internal_qc_test), size = 20, shape = 1) + geom_point(aes(colour = "0"), size = 30, shape = 1) + geom_text(aes(label = .date2), colour = "#00000080", size = 4) + scale_x_continuous(breaks = 1:7, labels = c("SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT")) + scale_colour_manual(values = c("#00000020", "#00000000"), breaks = c("0", "1"), labels = c("Laser Power Error", "Laser Alignment Error"), name = "Test Result") + theme(panel.background = element_rect(fill = "white"), axis.title = element_blank(), axis.text.y = element_blank(), axis.ticks = element_blank(), legend.position = "none", panel.grid = element_blank()) + coord_cartesian(xlim = c(0.5, 7.5), ylim = c(1.5, 7.5))

    legend <- data.frame(x = 1, y = 1:8, q1 = gl(2, 4, 8, labels = c(0, 1)), q2 = gl(2, 2, 8, labels = c(0, 1)), q3 = gl(2, 1, 8, labels = c(0, 1)), error = c("P/A/M Error", "P/A Error", "P/M Error", "P Error", "A/M Error", "A Error", "M Error", "Pass"))
    legend.ggplot <- ggplot(data = legend, aes(x = x, y = y)) + geom_point(aes(colour = q1), size = 18, shape = 16) + geom_point(aes(colour = q2), size = 12, shape = 16) + geom_point(aes(colour = q3), size = 6, shape = 16) + geom_point(aes(colour = "1"), size = 18, shape = 1) + geom_point(aes(colour = "1"), size = 12, shape = 1) + geom_point(aes(colour = "1"), size = 6, shape = 1) + geom_text(aes(x = x + 0.4, y = y, label = error), hjust = 0, size = 3.5) +  scale_colour_manual(values = c("#00000000", "#00000020"), breaks = c("0", "1")) + annotate("text", x = 0.7, y = 8.8, label = "Test Result", hjust = 0, vjust = 1, fontface = 2, size = 4) + theme(panel.background = element_rect(fill = "white"), axis.title = element_blank(), axis.text = element_blank(), axis.ticks = element_blank(), legend.position = "none", panel.grid = element_blank()) + coord_cartesian(xlim = c(0.5, 2), ylim = c(0.5, 9))

    legend.gtable <- ggplot_gtable(ggplot_build(legend.ggplot))
    frend.gtable <- ggplot_gtable(ggplot_build(frend.ggplot))
    frend.gtable <- gtable_add_cols(frend.gtable, unit(10, "lines"), pos = frend.gtable$layout$r[frend.gtable$layout$name == "panel"])
    frend.gtable <- gtable_add_grob(frend.gtable, grob = legend.gtable$grobs[[which(legend.gtable$layout$name == "panel")]], name = "legend", clip = "off", l = frend.gtable$layout$r[frend.gtable$layout$name == "panel"] + 1, r = frend.gtable$layout$r[frend.gtable$layout$name == "panel"] + 1, t = frend.gtable$layout$t[frend.gtable$layout$name == "panel"], b = frend.gtable$layout$b[frend.gtable$layout$name == "panel"])

#    frend.gtable <- ggplot_gtable(ggplot_build(frend.ggplot))
    
    frend.gtable
}

# y should be standardized as linear scale although original scale is non-linear.
spc.plot <- function(y, date, lot, data, date.format = "%m-%d", y.breaks = seq(-10, 10), y.scale = "identity", y.scale.options = "", y.expression = "identity", y.expression.options = c("digit = 0", "format = 'f'"), breaks.augumentation = 2) {
    mf <- match.call(expand.dots = FALSE)
    m <- match(c("data", "na.action"), names(mf), 0L)
    mf <- mf[c(1L, m)]
    mf$formula <- as.formula(paste(substitute(y), "~", substitute(date) , "+", substitute(lot)))
    mf$drop.unused.levels <- TRUE
    mf[[1L]] <- quote(stats::model.frame)
    mf <- eval(mf, parent.frame())
    
    y.labels <- y.breaks
    if (data.class(y.scale) == "character") {
        mf$.y <- eval(parse(text = paste(".scale.", y.scale, "(mf[, 1], ", paste(y.scale.options, collapse = ", "), ")", sep = "")))
        y.breaks <- eval(parse(text = paste(".scale.", y.scale, "(y.breaks, ", paste(y.scale.options, collapse = ", "), ")", sep = "")))
    } else {
        mf$.y <- y.scale(mf[, 1])
        y.breaks <- y.scale(y.breaks)
    }
    
    y.labels <- y.labels[is.finite(y.breaks)]
    y.breaks <- y.breaks[is.finite(y.breaks)]
    if (data.class(y.expression[1]) == "character") {
        y.labels <- eval(parse(text = paste(".expression.", y.expression, "(y.labels, ", paste(y.expression.options, collapse = ", "), ")", sep = "")))
    } else {
        y.labels <- y.expression(y.labels)
    }
    y.bp <- unique(as.numeric(sapply(1:(length(y.breaks) - 1), function(x) seq(y.breaks[x], y.breaks[x + 1], len = breaks.augumentation + 1))))
    y.bl <- character(length(y.bp))
    y.bl[seq(1, length(y.bp), by = breaks.augumentation)] <- y.labels
    
    mf$.date <- as.ordered(format(mf[, 2], date.format))
    mf$.index <- unlist(tapply(mf$.date, mf[, 3], function(x) 1:length(x)))
    mf$.indexlabel <- as.ordered(unlist(tapply(mf$.date, mf[, 3], function(x) paste(1:length(x), x, sep = ":"))))
    mf$.lot <- mf[, 3]
    
    spc.labels <- data.frame(label = unique(mf$.indexlabel))
    spc.labels$bp <- as.integer(spc.labels$label)
    ylim <- range(mf$.y)
    ylim[1] <- min(ylim[1], -3.5)
    ylim[2] <- max(ylim[2], 3.5)
    xlim <- range(mf$.index, na.rm = TRUE) + c(-0.5, 0.5)
    if (xlim[2] < 6) {
        xlim[2] <- 6.5
    }
    ylim <- (ylim - mean(ylim)) * 1.1 + mean(ylim)
    spc.ggplot <- ggplot(data = mf) + geom_rect(xmin = 0, xmax = xlim[2] + 1, ymin = 2, ymax = ylim[2] + 1, fill = "#F0F0F0") + geom_rect(xmin = 0, xmax = xlim[2] + 1, ymin = ylim[1] - 1, ymax = -2, fill = "#F0F0F0") + geom_hline(yintercept = c(-3, 0, 3), colour = c("#00000020", "white", "#00000020"), size = c(1, 3, 1), linetype = c(3, 1, 3)) + geom_line(aes(x = .index, y = .y, colour = .lot), size = 1.25) + scale_x_continuous(breaks = spc.labels$bp, label = spc.labels$label) + scale_y_continuous(breaks = c(seq(-10, -2), 0, seq(2, 10))) +  scale_colour_manual(values = c("#00000028", "#00000050", "#00000078", "#000000A0", "#000000B8", "#000000E0"), name = "Lot #") + coord_cartesian(xlim = xlim, ylim = ylim) + theme(panel.background = element_rect(fill = "#00000008"), legend.position = "right", axis.text = element_text(size = 10), axis.ticks = element_blank(), axis.title.x = element_blank(), panel.grid.minor = element_blank(), panel.grid.major.y = element_line(colour = "#FFFFFF60")) + ylab("Standardized value")
    
    if (any(abs(mf$.y) > 2)) {
        mfsub <- mf[abs(mf$.y) > 2, ]
        mfsub$.type <- ifelse(abs(mfsub$.y) < 3, "s2", "s3")
        spc.ggplot <- spc.ggplot + geom_point(data = mfsub, aes(x = .index, y = .y, shape = .type), size = 5, colour = "#00000080") + scale_shape_manual(values = c(1, 16), name = "Type", breaks = c("s2", "s3"), labels = c(expression(1[2*s]), expression(1[3*s])))
    }
    
    spc.gtable <- ggplot_gtable(ggplot_build(spc.ggplot))
    
    spc.gtable
}

linearity.plot <- function(y, x, error, data, breaks, scale = "log10", scale.options = "", axis.expression = "identity", axis.expression.options = c("digit = 1", "format = 'f'"), breaks.augumentation = 1) {
    mf <- match.call(expand.dots = FALSE)
    m <- match(c("data", "na.action"), names(mf), 0L)
    mf <- mf[c(1L, m)]
    mf$formula <- as.formula(paste(substitute(y), "~", substitute(x), "+", substitute(error)))
    mf$drop.unused.levels <- TRUE
    mf[[1L]] <- quote(stats::model.frame)
    mf <- eval(mf, parent.frame())
    
    labels <- breaks
    if (data.class(scale) == "character") {
        mf$.x <- eval(parse(text = paste(".scale.", scale, "(mf[, 2], ", paste(scale.options, collapse = ", "), ")", sep = "")))
        mf$.y <- eval(parse(text = paste(".scale.", scale, "(mf[, 1], ", paste(scale.options, collapse = ", "), ")", sep = "")))
        mf$.ymin <- eval(parse(text = paste(".scale.", scale, "(mf[, 2] + 3 * mf[, 3], ", paste(scale.options, collapse = ", "), ")", sep = "")))
        mf$.ymax <- eval(parse(text = paste(".scale.", scale, "(mf[, 2] - 3 * mf[, 3], ", paste(scale.options, collapse = ", "), ")", sep = "")))
        breaks <- eval(parse(text = paste(".scale.", scale, "(breaks, ", paste(scale.options, collapse = ", "), ")", sep = "")))
    } else {
        mf$.x <- scale(mf[, 2])
        mf$.y <- scale(mf[, 1])
        mf$.ymin <- scale(mf[, 2] + 3 * mf[, 3])
        mf$.ymax <- scale(mf[, 2] - 3 * mf[, 3])
        breaks <- scale(breaks)
    }
    
    labels <- labels[update.breaks(breaks)]
    breaks <- breaks[update.breaks(breaks)]
    if (data.class(axis.expression[1]) == "character") {
        labels <- eval(parse(text = paste(".expression.", axis.expression, "(labels, ", paste(axis.expression.options, collapse = ", "), ")", sep = "")))
    } else {
        labels <- axis.expression(labels)
    }
    bp <- unique(as.numeric(sapply(1:(length(breaks) - 1), function(x) seq(breaks[x], breaks[x + 1], len = breaks.augumentation + 1))))
    bl <- character(length(bp))
    bl[seq(1, length(bp), by = breaks.augumentation)] <- labels
    
    mf.sub <- mf[! duplicated(mf$.x), ]

    lim <- range(c(mf$.y, mf$.x), na.rm = TRUE)
    lim <- (lim - mean(lim)) * 1.1 + mean(lim)
    linearity.ggplot <- ggplot(data = mf) + geom_abline(xintercept = 0, slope = 1, colour = "#00000010") + geom_errorbar(data = mf.sub, aes(x = .x, ymin = .ymin, ymax = .ymax), colour = "#00000030", width = diff(range(bp)) / 20, size = 1) + geom_smooth(data = mf, aes(x = .x, y = .y), method = "lm", se = TRUE, level = pnorm(3), fullrange = TRUE, linetype = 2, colour = "#00800040", fill = "#E0E0E010") + geom_point(aes(x = .x, y = .y), colour = "#808080") + scale_x_continuous(breaks = bp, label = bl) + scale_y_continuous(breaks = bp, label = bl) + theme(panel.background = element_rect(fill = "#00000003"), axis.text = element_text(size = 10), axis.ticks = element_blank(), panel.grid.major = element_line(colour = "white", size = 2), panel.grid.minor = element_line(colour = "white")) + coord_cartesian(xlim = lim, ylim = lim) + xlab("Expected value") + ylab("Value")
    
    linearity.gtable <- ggplot_gtable(ggplot_build(linearity.ggplot))
    
    linearity.gtable
}

sdi_cvr.plot <- function(sdi, cvr, shape, data) {
    mf <- match.call(expand.dots = FALSE)
    m <- match(c("data", "na.action"), names(mf), 0L)
    mf <- mf[c(1L, m)]
    mf$formula <- as.formula(paste(substitute(sdi), "~", substitute(cvr), "+", substitute(shape)))
    mf$drop.unused.levels <- TRUE
    mf[[1L]] <- quote(stats::model.frame)
    mf <- eval(mf, parent.frame())
    
    mf$.y <- mf[, 1]
    mf$.x <- mf[, 2]
    mf$.shape <- mf[, 3]
    
    sdi_cvr.ggplot <- ggplot(data = mf) + geom_rect(xmin = 0, xmax = 2, ymin = -2, ymax = 2, fill = "#E0E0E0") + geom_rect(xmin = 0, xmax = 1.5, ymin = -1.5, ymax = 1.5, fill = "#F0F0F0") + geom_rect(xmin = 0, xmax = 1, ymin = -1, ymax = 1, fill = "white") + geom_point(aes(x = .x, y = .y, shape = .shape, size = 2)) + geom_vline(xintercept = 0, size = 2, colour = "#00000080") + geom_hline(yintercept = 0, size = 1, colour = "#00000080") + scale_y_continuous(breaks = c(-2, -1, 0, 1, 2)) + annotate("text", x = c(1, 2), y = -0.2, label = c(1, 2), size = 6, colour = "#000000C0") + scale_shape_manual(values = c(16, 5, 0, 1)) + coord_cartesian(xlim = c(0, 2.08), ylim = c(-2.04, 2.04)) + theme(panel.background = element_rect(fill = "white"), axis.title.y = element_text(size = 20), axis.text.y = element_text(size = 20), axis.title.x = element_blank(), axis.text.x = element_blank(), axis.ticks = element_blank(), legend.position = "none") + ylab("SDI")
    
    sdi_cvr.gtable <- ggplot_gtable(ggplot_build(sdi_cvr.ggplot))
    x.lengend.pos <- sdi_cvr.gtable$layout$r[which(sdi_cvr.gtable$layout$name == "panel")]
    y.lengend.pos <- sdi_cvr.gtable$layout$t[which(sdi_cvr.gtable$layout$name == "panel")]
    sdi_cvr.gtable <- gtable_add_cols(sdi_cvr.gtable, unit(3, "lines"), x.lengend.pos)
    sdi_cvr.gtable <- gtable_add_grob(sdi_cvr.gtable, textGrob("CVR", gp = gpar(fontsize = 20)), name = "x_legend", l = x.lengend.pos + 1, r = x.lengend.pos + 1, t = y.lengend.pos, b = y.lengend.pos)
    
    sdi_cvr.gtable
}

opspecs.plot <- function(data, base.inaccuracy, base.imprecision, title, base.multiplier = qnorm(0.99)) {
    n <- max(data$n, na.rm = TRUE)
    # 90% AOA (SE): probability to detect at least one systematic bias of 3s with 90% power on n trials
    q <- 3 - qnorm(0.1^(1/n))
    allowableTotalError <- base.inaccuracy + base.multiplier * base.imprecision
    area <- data.frame(x = c(0, allowableTotalError / (base.multiplier + q), allowableTotalError / base.multiplier, 0), y = c(allowableTotalError, 0, 0, allowableTotalError))
    
    # outliers
    test <- data$inaccuracy > (allowableTotalError -  base.multiplier * data$imprecision) | data$inaccuracy < (allowableTotalError -  (q + base.multiplier) * data$imprecision)
    d.out <- data[test, ]
    data <- data[! test, ]
    
    opspecs.ggplot <- ggplot(data = data) + geom_polygon(data = area, aes(x = x, y = y), fill = "#00000010") + geom_abline(intercept = allowableTotalError, slope = -base.multiplier, colour = "#00000080") + geom_abline(intercept = allowableTotalError, slope = - base.multiplier - q, linetype = 2, colour = "#00000080") + geom_point(aes(x = imprecision, y = inaccuracy, shape = date), size = 2, colour = "#00000080", show_guide = FALSE) + geom_point(data = d.out, aes(x = imprecision, y = inaccuracy, shape = date), size = 4, colour = "black") + scale_shape_manual(values = 1:12, name = "Month") + xlab("Allowable Imprecision (%)") + ylab("Allowable Inaccuracy (%)") + ggtitle(substitute(title * ": OPSpecs Chart " * TE[a] * " " * ate * "% with 90% AOA (SE)", list(title = title, ate = formatC(allowableTotalError, width = 2, digit = 2, format = "d")))) + coord_cartesian(xlim = c(0, allowableTotalError / base.multiplier * 1.2), ylim = c(0, allowableTotalError)) + theme(panel.background = element_rect(fill = "#00000008"), legend.position = "right", axis.text = element_text(size = 10), axis.ticks = element_blank(), panel.grid.minor = element_blank(), panel.grid.major.y = element_line(colour = "#FFFFFF60"))
    
    opspecs.gtable <- ggplot_gtable(ggplot_build(opspecs.ggplot))
    
    opspecs.gtable
}

# y: standardized value
history.plot <- function(y, date, service, lot, base.mean, base.sd, data, date.format = "%b", y.scale = "identity", y.scale.options = "", y.expression = "identity", y.expression.options = c("digit = 2", "format = 'f'"), scale.factor = 2, breaks.augumentation = 2) {
    mf <- match.call(expand.dots = FALSE)
    m <- match(c("data", "na.action"), names(mf), 0L)
    mf <- mf[c(1L, m)]
    mf$formula <- as.formula(paste(substitute(y), "~", substitute(date), "+", substitute(lot), "+", substitute(base.mean), "+", substitute(base.sd), "+", substitute(service)))
    mf$drop.unused.levels <- TRUE
    mf[[1L]] <- quote(stats::model.frame)
    mf <- eval(mf, parent.frame())

    base.year <- unique(format(range(mf[, 2]), "%Y")) 
    base.date <- format(as.Date(paste(rep(base.year, each = 12), rep(1:12, length(base.year)), 1, sep = "-")), date.format)
    names(base.date) <- format(as.Date(paste(rep(base.year, each = 12), rep(1:12, length(base.year)), 1, sep = "-")), "%Y%m")
    base.date[str_sub(names(base.date), -2) == "01"] <- paste(base.date[str_sub(names(base.date), -2) == "01"], str_sub(names(base.date)[str_sub(names(base.date), -2) == "01"], 1, 4), sep = "\n")
    mf$.date <- as.ordered(format(mf[, 2], "%Y%m"))
    levels(mf$.date) <- base.date[levels(mf$.date)]
    mf$.lot <- mf[, 3]
    mf$.mean <- mf[, 4]
    mf$.sd <- mf[, 5]
    mf$.service <- paste(mf[, 6], " #", mf[, 3], sep = "")
    lots <- unique(mf$.service)
    
    if (data.class(y.scale) == "character") {
        mf$.y <- eval(parse(text = paste(".scale.", y.scale, "(mf[, 1], ", paste(y.scale.options, collapse = ", "), ")", sep = "")))
    } else {
        mf$.y <- y.scale(mf[, 1])
    }    
    
    history.ggplot <- ggplot(data = mf) + geom_point(aes(x = .date, y = .y)) + theme(panel.background = element_rect(fill = "#00000005"), axis.text = element_text(size = 15), axis.ticks = element_blank(), axis.title = element_blank(), panel.grid.minor = element_blank(), panel.grid.major.y = element_line(colour = "#FFFFFF60"))
    tmp.gtable <- ggplot_gtable(ggplot_build(history.ggplot))
    panel.loc <- get.gtableloc.all(tmp.gtable, "panel")
    base.gtable <- gtable(heights = tmp.gtable$heights, widths = tmp.gtable$widths)
    base.gtable <- gtable_add_rows(base.gtable, height = unit(2, "lines"), pos = panel.loc["t"] - 1)
    base.gtable <- gtable_add_cols(base.gtable, width = unit(0.5, "null"), pos = panel.loc["l"] - 1)
    base.gtable <- gtable_add_cols(base.gtable, width = unit.c(unit(0.25, "lines"), unit(0.15, "null")), pos = panel.loc["r"] + 1)
    base.gtable <- gtable_add_rows(base.gtable, height = unit.c(unit(0.25, "lines"), unit(0.25, "null")), pos = panel.loc["b"] + 1)
    
    panel.loc <- c(panel.loc["l"], panel.loc["r"] + 1)
    names(panel.loc) <- c("l", "r")
    
    height.loc <- 3
    if (length(lots) > 1) {
        for (l in 2:length(lots)) {
            base.gtable <- gtable_add_rows(base.gtable, height = unit.c(unit(0.5, "lines"), unit(2, "lines"), unit(1, "null"), unit(0.25, "lines"), unit(0.25, "null")), pos = height.loc[l - 1] + 3)
            height.loc <- c(height.loc, height.loc[l - 1] + 5)
        }
    }
    base.gtable <- gtable_add_grob(base.gtable, tmp.gtable$grobs[[which(tmp.gtable$layout$name == "background")]], name = "background", clip = "on", t = 1, l = 1, b = length(base.gtable$heights), r = length(base.gtable$widths))
    base.gtable <- gtable_add_grob(base.gtable, tmp.gtable$grobs[[which(tmp.gtable$layout$name == "axis-b")]], name = "axis-b:date", clip = "off", t = height.loc[length(height.loc)] + 4, l = panel.loc["l"], b = height.loc[length(height.loc)] + 4, r = panel.loc["r"])
    
    statistics <- data.frame(index = paste("D", formatC(unique(as.integer(mf$.date)), width = 2, flag = "0"), sep = "_"))
    statistics$index.n <- 1:nrow(statistics)
    # base
    for (l in 1:length(lots)) {
        mf.sub <- mf[mf$.service == lots[l], ]
    
        y.breaks <- seq(min(get.steppedlimit(min(mf.sub[, 1], na.rm = TRUE), scale.factor, lower = TRUE), -3), max(get.steppedlimit(max(mf.sub[, 1], na.rm = TRUE), scale.factor, lower = FALSE), 3), by = scale.factor)
        y.labels <- y.breaks * mf.sub$.sd[1] + mf.sub$.mean[1]
        if (data.class(y.scale) == "character") {
            y.breaks <- eval(parse(text = paste(".scale.", y.scale, "(y.breaks, ", paste(y.scale.options, collapse = ", "), ")", sep = "")))
        } else {
            y.breaks <- y.scale(y.breaks)
        }
        y.labels <- y.labels[is.finite(y.breaks)]
        y.breaks <- y.breaks[is.finite(y.breaks)]
        if (data.class(y.expression[1]) == "character") {
            y.labels <- eval(parse(text = paste(".expression.", y.expression, "(y.labels, ", paste(y.expression.options, collapse = ", "), ")", sep = "")))
        } else {
            y.labels <- y.expression(y.labels)
        }
        y.bp <- unique(as.numeric(sapply(1:(length(y.breaks) - 1), function(x) seq(y.breaks[x], y.breaks[x + 1], len = breaks.augumentation + 1))))
        y.bl <- character(length(y.bp))
        y.bl[seq(1, length(y.bp), by = breaks.augumentation)] <- y.labels
    
        histogram.stat <- get.histogram.block(mf.sub$.y, y.bp)
        histogram.path <- get.histogram.path(histogram.stat)
        statistics.sub <- tapply(mf.sub[, 1], paste("D", formatC(as.integer(mf.sub$.date), width = 2, flag = "0"), sep = "_"), function(x) {
            c(bias = mean(x, na.rm = TRUE), cv = sd(x, na.rm = TRUE) * mf.sub$.sd[1] / (mean(x, na.rm = TRUE) * mf.sub$.sd[1] + mf.sub$.mean[1]))
        })
        statistics$bias <- sapply(statistics$index, function(x) if (x %in% names(statistics.sub)) {
            statistics.sub[[x]]["bias"]
        } else {
            NA
        })
        statistics$cv <- sapply(statistics$index, function(x) if (x %in% names(statistics.sub)) {
            statistics.sub[[x]]["cv"]
        } else {
            NA
        })
        
        ylim <- range(histogram.path$y)
        ylim <- (ylim - mean(ylim)) * 1.1 + mean(ylim)
        history.ggplot <- ggplot(data = mf.sub) + geom_hline(yintercept = c(-3, 0, 3), colour = c("#00000020", "white", "#00000020"), size = c(1, 3, 1), linetype = c(3, 1, 3)) + geom_point(aes(x = .date, y = .y), position = position_jitter(width = 0.05, height = 0), colour = "#00000080", shape = 1) + geom_line(data = statistics, aes(x = index.n, y = bias), colour = "#00000060") + geom_point(data = statistics, aes(x = index.n, y = bias), colour = "#808080", size = 3) + scale_y_continuous(breaks = y.bp, label = y.bl) + coord_cartesian(ylim = ylim) + theme(panel.background = element_rect(fill = "#00000005"), axis.text = element_text(size = 15), axis.ticks = element_blank(), axis.title = element_blank(), panel.grid.minor = element_blank(), panel.grid.major.y = element_line(colour = "#FFFFFF60"))
        histogram.ggplot <- ggplot(data = histogram.path) + geom_vline(xintercept = -1, colour = "#00000020", size = 0.5) + geom_polygon(aes(x = x, y = y), fill = "gray95") + xlab("") + ylab("") + theme(panel.background = element_rect(fill = "white"), axis.ticks = element_blank(), panel.grid = element_blank(), axis.title.x = element_blank()) + scale_y_continuous(breaks = y.bp, label = y.bl) + geom_path(data = histogram.path[2:(nrow(histogram.path) - 1), ], aes(x = x, y = y), colour = "#00000080", size = 0.25) + coord_cartesian(ylim = ylim)
        statistics.ggplot <- ggplot(data = statistics) + geom_bar(aes(x = index, y = cv), colour = "white", fill = "#00000025", stat = "identity", width = 0.4, size = 0.8) + geom_text(aes_string(x = "index", label = "format(cv * 100, digit = 2)"), y = max(statistics$cv, na.rm = TRUE) * 1.25, vjust = 1, colour = "#00000050", size = 4)+ theme(panel.background = element_rect(fill = "#00000005"), axis.text = element_text(size = 15), axis.ticks = element_blank(), axis.title = element_blank(), panel.grid.minor = element_blank(), panel.grid.major.y = element_line(colour = "#FFFFFF60"), legend.position = "none") + scale_y_continuous(breaks = seq(0, 1, 0.1)) + coord_cartesian(ylim = c(0, max(statistics$cv, na.rm = TRUE) * 1.3))
        x <<- statistics

        history.gtable <- ggplot_gtable(ggplot_build(history.ggplot))
        histogram.gtable <- ggplot_gtable(ggplot_build(histogram.ggplot))
        statistics.gtable <- ggplot_gtable(ggplot_build(statistics.ggplot))

        base.gtable <- gtable_add_grob(base.gtable, rectGrob(gp = gpar(fill = "#00000010", col = 0)), name = paste(lots[l], ":background", sep = ""), clip = "off", t = height.loc[l], l = panel.loc["l"], b = height.loc[l], r = panel.loc["l"])
        base.gtable <- gtable_add_grob(base.gtable, textGrob(lots[l], x = unit(0.1, "npc"), hjust = 0, gp = gpar(col = "gray20", fontsize = 18)), name = lots[l], clip = "on", t = height.loc[l], l = panel.loc["l"], b = height.loc[l], r = panel.loc["l"])
        base.gtable <- gtable_add_grob(base.gtable, history.gtable$grob[[which(tmp.gtable$layout$name == "panel")]], name = paste("history:", l, sep = ""), clip = "on", t = height.loc[l] + 1, l = panel.loc["l"], b = height.loc[l] + 1, r = panel.loc["r"])
        base.gtable <- gtable_add_grob(base.gtable, histogram.gtable$grob[[which(tmp.gtable$layout$name == "panel")]], name = paste("histogram:", l, sep = ""), clip = "on", t = height.loc[l] + 1, l = panel.loc["r"] + 2, b = height.loc[l] + 1, r = panel.loc["r"] + 2)
        base.gtable <- gtable_add_grob(base.gtable, statistics.gtable$grob[[which(tmp.gtable$layout$name == "panel")]], name = paste("cv:", l, sep = ""), clip = "on", t = height.loc[l] + 3, l = panel.loc["l"], b = height.loc[l] + 3, r = panel.loc["r"])
        base.gtable <- gtable_add_grob(base.gtable, textGrob("CV\n(%)", gp = gpar(col = "gray20", fontsize = 10)), name = paste("axis-l-cv:", l, sep = ""), clip = "off", t = height.loc[l] + 3, l = panel.loc["l"] - 1, b = height.loc[l] + 3, r = panel.loc["l"] - 1)
        base.gtable <- gtable_add_grob(base.gtable, history.gtable$grob[[which(tmp.gtable$layout$name == "axis-l")]], name = paste("axis-l:", l, sep = ""), clip = "off", t = height.loc[l] + 1, l = panel.loc["l"] - 1, b = height.loc[l] + 1, r = panel.loc["l"] - 1)
    }
        
    base.gtable
}

# y.scale: identity, log10, log
# y.representation: identity, exp
history.plot.old <- function(y, date, data, date.format = "%m-%d", y.breaks, y.scale = "identity", y.scale.options = "", y.expression = "identity", y.expression.options = c("digit = 0", "format = 'f'"), breaks.augumentation = 2) {
    mf <- match.call(expand.dots = FALSE)
    m <- match(c("data", "na.action"), names(mf), 0L)
    mf <- mf[c(1L, m)]
    mf$formula <- as.formula(paste(substitute(y), "~", substitute(date)))
    mf$drop.unused.levels <- TRUE
    mf[[1L]] <- quote(stats::model.frame)
    mf <- eval(mf, parent.frame())
    y.labels <- y.breaks
    if (data.class(y.scale) == "character") {
        mf$.y <- eval(parse(text = paste(".scale.", y.scale, "(mf[, 1], ", paste(y.scale.options, collapse = ", "), ")", sep = "")))
        y.breaks <- eval(parse(text = paste(".scale.", y.scale, "(y.breaks, ", paste(y.scale.options, collapse = ", "), ")", sep = "")))
    } else {
        mf$.y <- y.scale(mf[, 1])
        y.breaks <- y.scale(y.breaks)
    }
    y.labels <- y.labels[is.finite(y.breaks)]
    y.breaks <- y.breaks[is.finite(y.breaks)]
    mf$.date <- as.ordered(format(mf[, 2], date.format))
    if (data.class(y.expression[1]) == "character") {
        y.labels <- eval(parse(text = paste(".expression.", y.expression, "(y.labels, ", paste(y.expression.options, collapse = ", "), ")", sep = "")))
    } else {
        y.labels <- y.expression(y.labels)
    }
    y.bp <- unique(as.numeric(sapply(1:(length(y.breaks) - 1), function(x) seq(y.breaks[x], y.breaks[x + 1], len = breaks.augumentation + 1))))
    y.bl <- character(length(y.bp))
    y.bl[seq(1, length(y.bp), by = breaks.augumentation)] <- y.labels

    histogram.stat <- get.histogram.block(mf$.y, y.bp)
    histogram.path <- get.histogram.path(histogram.stat)
    ylim <- range(histogram.path$y)
    ylim <- (ylim - mean(ylim)) * 1.1 + mean(ylim)
    history.ggplot <- ggplot(data = mf) + geom_point(aes(x = .date, y = .y), position = position_jitter(width = 0.05, height = 0)) + scale_y_continuous(breaks = y.bp, label = y.bl) + coord_cartesian(ylim = ylim) + theme(panel.background = element_rect(fill = "#00000005"), axis.text = element_text(size = 15), axis.ticks = element_blank(), axis.title = element_blank(), panel.grid.minor = element_blank(), panel.grid.major.y = element_line(colour = "#FFFFFF60"))
    histogram.ggplot <- ggplot(data = histogram.path) + geom_vline(xintercept = -1, colour = "#00000020", size = 0.5) + geom_polygon(aes(x = x, y = y), fill = "gray95") + xlab("") + ylab("") + theme(panel.background = element_rect(fill = "white"), axis.ticks = element_blank(), panel.grid = element_blank(), axis.title.x = element_blank()) + scale_y_continuous(breaks = y.bp, label = y.bl) + geom_path(data = histogram.path[2:(nrow(histogram.path) - 1), ], aes(x = x, y = y), colour = "#00000080", size = 0.25) + coord_cartesian(ylim = ylim)
    history.gtable <- ggplot_gtable(ggplot_build(history.ggplot))
    histogram.gtable <- ggplot_gtable(ggplot_build(histogram.ggplot))
    history.gtable <- gtable_add_cols(history.gtable, width = unit.c(unit(0.25, "line"), unit(0.15, "null")), pos = history.gtable$layout$r[history.gtable$layout$name == "panel"])
    history.gtable <- gtable_add_grob(history.gtable, histogram.gtable$grob[which(histogram.gtable$layout$name == "panel")], name = "histogram", t = history.gtable$layout$t[history.gtable$layout$name == "panel"], b = history.gtable$layout$b[history.gtable$layout$name == "panel"], l = history.gtable$layout$r[history.gtable$layout$name == "panel"] + 2, r = history.gtable$layout$r[history.gtable$layout$name == "panel"] + 2)
    
    history.gtable
}

#
precision.plot <- function(y, date, lot, data, qc, date.format = c("%Y-%m-%d %H:%M:%OS"), tz = "UTC", file.prefix = "", width = 6, height = 3) {
    mf <- match.call(expand.dots = FALSE)
    m <- match(c("data", "subset", "weights", "na.action", "offset"), names(mf), 0L)
    mf <- mf[c(1L, m)]
    mf$formula <- as.formula(paste(substitute(y), "~", substitute(date), "+", substitute(lot)))
    mf$drop.unused.levels <- TRUE
    mf[[1L]] <- quote(stats::model.frame)
    mf <- eval(mf, parent.frame())
    mf$.y <- mf[, 1]
    mf$.date <- as.ordered(format(strptime(mf[, 2], date.format, tz), "%Y-%m-%d"))
    mf$.ln <- as.ordered(mf[, 3])
    
    precision.ggplot.list <- list()
    lot_numbers <- levels(mf$.ln)
    for (i in seq(along = lot_numbers)) {
        mf.sub <- mf[mf$.ln == lot_numbers[i], c(".y", ".date")]
        mf.sub$colour <- "gray25"
        mf.sub$size <- 2
        mf.sub$shape <- 16
        qc.sub <- data.frame(position = as.numeric(qc[qc$lot_number == lot_numbers[i], c("lower", "mean", "upper")]), type = c("0.lower", "1.center", "2.upper"), colour = c("darkred", "darkgreen", "darkred"))
        qc.brand <- qc[qc$lot_number == lot_numbers[i], "brand"]
        if (any(mf.sub$.y < qc.sub$position[1] | mf.sub$.y > qc.sub$position[3])) {
            mf.sub[mf.sub$.y < qc.sub$position[1] | mf.sub$.y > qc.sub$position[3], "size"] <- 3
            mf.sub[mf.sub$.y < qc.sub$position[1] | mf.sub$.y > qc.sub$position[3], "shape"] <- 1
            mf.sub[mf.sub$.y < qc.sub$position[1] | mf.sub$.y > qc.sub$position[3], "colour"] <- "red"
        }
        ylim <- range(mf.sub$.y, na.rm = TRUE)
        ylim[1] <- min(ylim[1], qc.sub$position[1])
        ylim[2] <- max(ylim[2], qc.sub$position[3])
        ylim <- (ylim - mean(ylim)) * 1.1 + mean(ylim)
        mf.summary <- data.frame(.y = rowsum(mf.sub$.y, mf.sub$.date, na.rm = TRUE) / rowsum(sapply(mf.sub$.y, function(x) as.integer(is.finite(x))), mf.sub$.date))
        mf.summary$.date <- as.ordered(rownames(mf.summary))
        mf.summary$.date.n <- as.numeric(mf.summary$.date)
        precision.ggplot <- ggplot(data = mf.sub) + geom_point(data = mf.sub, aes(x = .date, y = .y, size = size, colour = colour, shape = shape), position = position_jitter(width = 0.05, height = 0)) + geom_line(data = mf.summary, aes(x = .date.n, y = .y), colour = "darkblue", linetype = 2) + coord_cartesian(ylim = ylim) + geom_abline(data = qc.sub, aes(intercept = position, slope = 0, colour = colour), linetype = 3) + geom_point(data = mf.summary, aes(x = .date, y = .y), size = 5, colour = "blue") + geom_point(data = mf.summary, aes(x = .date, y = .y), size = 3.5, colour = "white") + scale_colour_identity() + scale_shape_identity() + scale_size_identity() + xlab("Date") + ylab("Value") + ggtitle("") + theme(axis.ticks = element_blank())
        precision.gtable <- ggplot_gtable(ggplot_build(precision.ggplot))
        precision.gtable.bl <- precision.gtable$layout[precision.gtable$layout$name == "background", c("t", "l", "b", "r")]
        precision.gtable$layout[precision.gtable$layout$name == "title", c("t", "l", "b", "r")] <- c(precision.gtable.bl$t, precision.gtable.bl$l, 2, precision.gtable.bl$r)
        precision.gtable <- gtable_add_grob(precision.gtable, name = "title-bound", rectGrob(gp = gpar(fill = "gray90", col = 0)), t = precision.gtable.bl$t, l = precision.gtable.bl$l, b = 2, r = precision.gtable.bl$r, z = precision.gtable$layout$z[precision.gtable$layout$name == "title"])
        precision.gtable$layout$z[precision.gtable$layout$name == "title"] <- max(precision.gtable$layout$z) + 1
        precision.gtable$grobs[[which(precision.gtable$layout$name == "title")]] <- textGrob(paste(qc.brand, ": Lot #", lot_numbers[i], " (Date: ", min(mf.sub$.date), " ~ ", max(mf.sub$.date), ")", sep = ""), x = unit(12, "points"), hjust = 0)
        precision.gtable <- gtable_add_rows(precision.gtable, unit(12, "points"), pos = 2)  
        precision.gtable.bl$b <- precision.gtable.bl$b + 1
        precision.gtable <- gtable_add_grob(precision.gtable, name = "background-bound", rectGrob(gp = gpar(col = "gray80", lwd = 7)), t = precision.gtable.bl$t, l = precision.gtable.bl$l, b = precision.gtable.bl$b, r = precision.gtable.bl$r)
        if (file.prefix != "") {
            pdf(file = paste(qc.brand, lot_numbers[i], min(mf.sub$.date), max(mf.sub$.date), ".pdf", sep = "_"), width = 6, height = 3)
            grid.draw(precision.gtable)
            dev.off()
        }
        precision.ggplot.list[[i]] <- precision.gtable
    }
             
    invisible(precision.ggplot.list)
}

linearity.plot.old <- function(y, date, lot, data, qc, date.format = c("%Y-%m-%d %H:%M:%OS"), tz = "UTC", file.prefix = "", width = 6, height = 6, resolution = 0.5) {
    scales <- seq(-10, 10, resolution)
    mf <- match.call(expand.dots = FALSE)
    m <- match(c("data", "subset", "weights", "na.action", "offset"), names(mf), 0L)
    mf <- mf[c(1L, m)]
    mf$formula <- as.formula(paste(substitute(y), "~", substitute(date), "+", substitute(lot)))
    mf$drop.unused.levels <- TRUE
    mf[[1L]] <- quote(stats::model.frame)
    mf <- eval(mf, parent.frame())
    mf$.y <- mf[, 1]
    mf$.date <- as.ordered(format(strptime(mf[, 2], date.format, tz), "%Y-%m-%d"))
    mf$.ln <- as.ordered(mf[, 3])

    rownames(qc) <- paste("Q", qc$lot_number, sep = "")
    
    linearity.ggplot.list <- list()
    dates <- levels(mf$.date)
    for (i in seq(along = dates)) {
        mf.sub <- mf[mf$.date == dates[i], c(".y", ".ln")]
        mf.sub$.mean <- qc[paste("Q", mf.sub$.ln, sep = ""), "mean"]
        mf.sub$.ly <- log(mf.sub$.y, 10)
        mf.sub$.lm <- log(mf.sub$.mean, 10)
        lim <- range(c(mf.sub$.ly, mf.sub$.lm), na.rm = TRUE)
        lim <- (lim - mean(lim)) * 1.1 + mean(lim)
        linearity.ggplot <- ggplot(mf.sub) + geom_point(data = mf.sub, aes(x = .lm, y = .ly), colour = "gray25") + geom_smooth(data = mf.sub, aes(x = .lm, y = .ly), method = "lm", se = TRUE, level = 0.9995, fullrange = TRUE, linetype = 2, colour = "darkgreen") + scale_x_continuous(breaks = scales, label = expExpression(scales, 10, format = "f", digits = 2)) + scale_y_continuous(breaks = scales, label = expExpression(scales, 10, format = "f", digits = 2)) + theme(axis.ticks = element_blank()) + coord_cartesian(xlim = lim, ylim = lim) + xlab("Expected value") + ylab("Value") + ggtitle("")
        linearity.gtable <- ggplot_gtable(ggplot_build(linearity.ggplot))
        linearity.gtable.bl <- linearity.gtable$layout[linearity.gtable$layout$name == "background", c("t", "l", "b", "r")]
        linearity.gtable$layout[linearity.gtable$layout$name == "title", c("t", "l", "b", "r")] <- c(linearity.gtable.bl$t, linearity.gtable.bl$l, 2, linearity.gtable.bl$r)
        linearity.gtable <- gtable_add_grob(linearity.gtable, name = "title-bound", rectGrob(gp = gpar(fill = "gray90", col = 0)), t = linearity.gtable.bl$t, l = linearity.gtable.bl$l, b = 2, r = linearity.gtable.bl$r, z = linearity.gtable$layout$z[linearity.gtable$layout$name == "title"])
        linearity.gtable$layout$z[linearity.gtable$layout$name == "title"] <- max(linearity.gtable$layout$z) + 1
        linearity.gtable$grobs[[which(linearity.gtable$layout$name == "title")]] <- textGrob(paste("Date ", dates[i], " (", qc$brand[1], " Lot #", paste(qc$lot_number, collapse = ", #"), ")", sep = ""), x = unit(12, "points"), hjust = 0)
        linearity.gtable <- gtable_add_rows(linearity.gtable, unit(12, "points"), pos = 2)  
        linearity.gtable.bl$b <- linearity.gtable.bl$b + 1
        linearity.gtable <- gtable_add_grob(linearity.gtable, name = "background-bound", rectGrob(gp = gpar(col = "gray80", lwd = 7)), t = linearity.gtable.bl$t, l = linearity.gtable.bl$l, b = linearity.gtable.bl$b, r = linearity.gtable.bl$r)
        if (file.prefix != "") {
            pdf(file = paste(qc$brand[1], dates[i], min(mf.sub$.ln), max(mf.sub$.ln), ".pdf", sep = "_"), width = 6, height = 6)
            grid.draw(linearity.gtable)
            dev.off()
        }
        linearity.ggplot.list[[i]] <- linearity.gtable
    }
             
    invisible(linearity.ggplot.list)
}


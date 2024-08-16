#!/usr/bin/Rscript --vanilla

suppressPackageStartupMessages({
    library(ggplot2)
    
    library(dplyr)
})

source("settings.R")

df.mw <- GetData("df_mw_first.csv")

df.realized.wages <- subset(df.mw, mean_wage_over_contract > 0 &
                            hours > 0)

df.realized.wages$cell <- with(df.realized.wages,
                               reorder(cell, min.wage, mean))

df.vert <- data.frame(cell = c(">4", ">3", ">2", "Control"),
                      min.wage = c(4, 3, 2, 0))

df.realized.wages$opening.cat <- with(df.realized.wages,
                                      ifelse(kpo, "ADMIN", "NON-ADMIN"))

df.tmp <- subset(df.realized.wages, cell == "Control" & !is.na(kpo)) %>%
    select(mean_wage_over_contract, opening.cat)

df.tmp <- subset(df.realized.wages, cell == 0 & !is.na(kpo)) %>%
    select(mean_wage_over_contract, opening.cat)

g.realized.wage.distro <- ggplot(
    data = df.tmp,
    aes(x = mean_wage_over_contract)) +
    stat_ecdf() +
    theme_bw() +
    scale_x_log10(limit = c(.50, 100),
                  breaks = c(1, 2, 3, 4, 10, 25, 50, 100)) +
    geom_vline(data = df.vert,
               aes(xintercept = min.wage),
               linetype = "dashed",
               colour = "red") +
                   xlab("Mean hourly wage (USD)") +
    theme(legend.position = "none") +
    ylab("Cumulative\nDensity")

suppressWarnings({
    writeImage(g.realized.wage.distro,
                        "realized_wage_distro", path = "../writeup/plots/",
                        width = 3, height = 3)
    writeImage(
                 g.realized.wage.distro + facet_wrap(~opening.cat, ncol = 1),
                 "realized_wage_distro_facet",
                 width = 3, height = 3, path = "../writeup/plots/")
})

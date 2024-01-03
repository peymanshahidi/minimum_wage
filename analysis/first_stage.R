#!/usr/bin/Rscript --vanilla

suppressPackageStartupMessages({
    library(plyr)
    library(ggplot2)
})

source("settings.R")

df.mw <- GetData("df_mw_first.csv")

df.realized.wages <- subset(df.mw,
                            mean_wage_over_contract > 0 &
                            hours > 0)

new.labels <-  c(
    "4" = "$4/hour minimum wage",
    "3" = "$3/hour minimum wage",
    "2" = "$2/hour minimum wage",
    "0" = "Control - No Minimum")

df.realized.wages$cell <- revalue(as.character(df.realized.wages$cell),
                                  new.labels)

df.realized.wages$cell <- with(df.realized.wages,
                          reorder(cell, min.wage, mean))

df.vert <- data.frame(cell = as.vector(new.labels),
                      min.wage = c(4, 3, 2, 0))

g <- ggplot(data = df.realized.wages,
            aes(x = mean_wage_over_contract + 0.01, ..density..),
            fill = "white") +
    geom_histogram(binwidth = 0.05,
                   fill = "white", colour = "black",
                   breaks = c(seq(0, 45, 1))) +
    theme_bw() +
    facet_wrap(~cell, ncol = 1) +
    scale_x_log10(limit = c(.50, 75),
                  breaks = c(1, 2, 3, 4, 10, 25, 75)) +
    facet_wrap(~cell, ncol = 1) +
    geom_vline(data = df.vert,
               aes(xintercept = min.wage),
               linetype = "dashed", colour = "red") +
    scale_y_continuous(labels = scales::comma) +
    xlab("Mean wage over contract ($/hour)") +
    theme(legend.position = "none") +
    ylab("Density")

JJHmisc::writeImage(g, "first_stage",
                    width = 6,
                    height = 5,
                    path = "../writeup/plots/")

#!/usr/bin/Rscript --vanilla

suppressPackageStartupMessages({
    library(ggplot2)
    library(data.table)
    library(dplyr)
    library(scales)
})

plots.path <- "../writeup/plots/"

source("settings.R")


df.mw.first <- GetData("df_mw_first.csv") %>% 
    select(hours, avg.wage, level1) %>%
    filter(hours > 1) %>% 
    filter(!is.na(level1)) %>% 
    filter(avg.wage > 0.25)

df.mw <- df.mw.first %>%
    group_by(level1) %>%
    mutate(level1.median.hours = median(hours[hours > 0]),
           level1.median.wage = median(avg.wage[avg.wage > 0]))

df.mw$level1 <- with(df.mw, reorder(level1, level1.median.wage, mean))

g.wage <- ggplot(data = df.mw, aes(x = level1, y = avg.wage)) +
    geom_boxplot(outlier.shape = NA) +
    theme_bw() +
    scale_y_log10(breaks = c(1, 2, 3, 5, 10, 20, 50, 100)) +
    coord_flip() +
    xlab("") +
    ylab("Average hourly wage in USD (log scale)")

JJHmisc::writeImage(g.wage, "avg_wages_by_cat", width = 6, height = 3, plots.path)

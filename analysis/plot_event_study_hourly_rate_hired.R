#!/usr/bin/env Rscript

################################################################################
suppressPackageStartupMessages({
    library(dplyr)
    library(magrittr)
    library(ggplot2)
    library(lubridate)
    library(tidyr)
    library(ggrepel)
})

source("settings.R")

df.raw <- GetData("event_study_hired.csv") %>%
    mutate(date = as.Date(date))

df.eda <- df.raw %>%
    filter(outcome == "hourly_rate") %>%
    filter(date < as.Date("2015-03-01")) %>%
    filter(date > as.Date("2014-01-01")) %>%
    mutate(name = gsub("y\\.pctile\\.", "", name))

df.eda$level1 <- with(df.eda, reorder(level1, value, mean))

df.eda %<>% filter(!(name %in% c("y.mean", "y.mean.log", "75th")))

df.eda.level <- df.eda %>% group_by(level1) %>%
    mutate(first.date = min(date)) %>%
    filter(date == first.date)
                   
g <- ggplot(data = df.eda, aes(x = date, y = value)) +
    geom_line(aes(group = name)) +
    theme_bw() +
    facet_wrap(~level1, ncol = 3) + 
    geom_vline(xintercept = as.Date("2014-08-25"), linetype = "dashed", colour = "red") +
    geom_vline(xintercept = as.Date("2014-11-15"), linetype = "dashed", colour = "red") +
    geom_hline(yintercept = 3, colour = "red", alpha= 0.5) +
    annotate("text", x = as.Date("2014-08-25") - 26, y = 60, label = "Announced", size = 3, colour = "red") +
    annotate("text", x = as.Date("2014-11-15") + 26, y = 60, label = "Imposed", size = 3, colour = "red") +
    scale_y_log10() +
    geom_label_repel(data = df.eda.level, aes(label = name), xlim = c(NA, as.Date("2014-01-01")), size = 3,
                     segment.colour = "grey") +
    expand_limits(x = as.Date("2013-11-01")) +
    theme(axis.text.x = element_text(angle = 30, vjust = 0.5)) +
    xlab("Week") + ylab("Mean log hourly wage")


JJHmisc::writeImage(g, "event_study_hourly_rate_hired",
                    path = "../writeup/plots/",
                    width = 9,
                    height = 6)



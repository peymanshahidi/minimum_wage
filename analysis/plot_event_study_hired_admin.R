#!/usr/bin/env Rscript

################################################################################
suppressPackageStartupMessages({
    library(dplyr)
    library(magrittr)
    library(ggplot2)
    library(lubridate)
    library(tidyr)
    library(ggrepel)
    library(gridExtra)
})

source("settings.R")

df.raw <- GetData("event_study_hired.csv") %>% 
    mutate(date = as.Date(date))

df.eda <-  df.raw %>%
    filter(level1 == "Administrative Support") %>% 
    filter(date < as.Date("2015-03-01")) %>%
    filter(date > as.Date("2014-01-01")) %>%
    filter(!(name %in% c("y.mean", "y.mean.log"))) %>% 
    mutate(name = gsub("y\\.pctile\\.", "", name)) %>%
    filter(!(outcome %in% c("profile_rate")))

df.eda$level1 <- with(df.eda, reorder(level1, value, mean))

outcomes <- list("avg_wage" = "Past average wage of hired worker (1)",
                 "hourly_rate" = "Hourly rate for current contract",
                 "hours" = "Hours-worked on current contract",
                 "total_hours" = "Past cumulative hours-worked of hired worker (3)",
                 "total_earnings" = "Past cumulative earnings of hired worker (2)")

df.eda$pretty.outcome <- with(df.eda, unlist(outcomes[as.character(outcome)]))

df.eda %<>% filter(outcome %in% c("avg_wage"
                                 ,"total_earnings"
                                  )
                   )

df.eda.level <- df.eda %>% group_by(level1) %>%
    mutate(first.date = min(date)) %>%
    filter(date == first.date)


g <- ggplot(data = df.eda, aes(x = date, y = value)) +
    geom_line(aes(group = name)) +
    theme_bw() +
    facet_wrap(~pretty.outcome, ncol = 1, scale = "free_y") + 
    geom_vline(xintercept = as.Date("2014-08-25"), linetype = "dashed",
               colour = "red") +
    geom_vline(xintercept = as.Date("2014-11-15"), linetype = "dashed",
               colour = "red") +
    scale_y_log10( label = scales::comma) +
    geom_label_repel(data = df.eda.level, aes(label = name),
                     segment.colour = "grey", 
                     xlim = c(NA, as.Date("2014-01-01")), size = 2) +
    expand_limits(x = as.Date("2013-11-01"),
                  y = 0.1) +
    annotate("text", x = as.Date("2014-08-25"), y = .5, label = "Announced", size = 3, colour = "red") +
    annotate("text", x = as.Date("2014-11-15"), y = .5, label = "Imposed", size = 3, colour = "red") +
    ylab("") +
    xlab("") 


JJHmisc::writeImage(g,
                    "event_study_hired_admin",
                    path = "../writeup/plots/", width = 6, height = 3)

#!/usr/bin/Rscript --vanilla

suppressPackageStartupMessages({
    library(sandwich)
    library(ggplot2)
    library(dplyr)
    library(magrittr)
    library(gt)
    library(tidyr)
    library(cowplot)
    
    library(stargazer)
    library(quantreg)
})

source("settings.R")

df.raw <- GetData("event_study_windows_hr_v_fp.csv") %>%
    mutate(opening_date = as.Date(opening_date))

fp.posting.employers <- df.raw %>%
    ungroup %>% 
    filter(opening_date > as.Date("2014-08-26")) %>% 
    filter(job_type == "fp") %$% employer %>% unique

posting.employers <- df.raw %>%
    ungroup %>% 
    filter(opening_date > as.Date("2014-08-26")) %$% employer %>% unique

df.mw.first <- GetData("df_mw_first.csv") %>%
    mutate(fp = employer %in% fp.posting.employers,
           posting.employer = employer %in% posting.employers)

df.mw.kpo <- subset(df.mw.first, level1 %in% "Administrative Support")
df.mw.wage.hat <- subset(df.mw.first, lwage.hat <= log(5))

r99 <- rq(hours ~ cell, tau = 0.99, data = df.mw.kpo)
r95 <- rq(hours ~ cell, tau = 0.95, data = df.mw.kpo)
r90 <- rq(hours ~ cell, tau = 0.90, data = df.mw.kpo)
r80 <- rq(hours ~ cell, tau = 0.80, data = df.mw.kpo)
r70 <- rq(hours ~ cell, tau = 0.70, data = df.mw.kpo)

#stargazer::stargazer(r99, r95, r90, r80, r70, type = "text", column.labels = c("p99", "p95", "p90", "p80", "p70"))

out.file <- "../writeup/tables/quantile_hours_worked.tex"

file.name.no.ext <- "quantile_hours_worked"

sink("/dev/null")
s <- stargazer(r99, r95, r90, r80, r70,
               column.labels = c("99th", "95th", "90th", "80th", "70th"), 
               title = "Quantile regressions of hours-worked (0s in included) in ADMIN category",
               dep.var.labels = c("Hours-worked"), 
               dep.var.labels.include = TRUE, 
               label = paste0("tab:", file.name.no.ext),
               no.space = TRUE,
               align = TRUE, 
               font.size = "small",
               star.cutoffs = NA,
               covariate.labels = c("MW4", "MW3",
                                    "MW2",
                                    "Constant"
                                    ),
               omit.stat = c("aic", "f", "adj.rsq", "ll", "bic", "ser"),
               type = "latex"
               )
sink()

note <- c("\\\\",
          "\\begin{minipage}{0.95 \\textwidth}", 
"{\\footnotesize \\emph{Notes}: The outcome in this table is hours-worked, in levels. 
Each column is quantile regression, with the quantile labeled.}", "\\end{minipage}")

AddTableNote(s, out.file, note = note)



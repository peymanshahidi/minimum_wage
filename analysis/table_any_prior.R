#!/usr/bin/Rscript --vanilla

suppressPackageStartupMessages({
    library(lmtest)
    library(dplyr)
    library(stargazer)
    library(JJHmisc)
})

source("settings.R")

df.raw <- GetData("df_mw_first.csv")
df.mw.first <- df.raw %>%
    mutate(any.prior = I(prior_spend > 0))

df.mw.first %$% any.prior %>% mean

df.admin <- df.mw.first %>% filter(level1 == "Administrative Support")

m.charge <- lm(I(total_charge > 0) ~ cell + any.prior, data = df.admin)
m.charge.exper <- lm(I(total_charge > 0) ~ cell*any.prior, data = df.admin)

p.value.1 <- lrtest(m.charge.exper, m.charge)["Pr(>Chisq)"]

m.ll <- lm(log1p(hired_past_y)  ~ cell + any.prior, data = df.admin)
m.ll.exper <- lm(log1p(hired_past_y) ~ cell*any.prior, data = df.admin)

p.value.2 <- lrtest(m.ll.exper, m.ll)["Pr(>Chisq)"]

out.file <- "../writeup/tables/any_prior.tex"
file.name.no.ext <- "any_prior"

sink("/dev/null")
s <- stargazer(m.charge, m.charge.exper, m.ll, m.ll.exper, 
#               column.labels = c("Anyone hired?"), 
               title = "Effects of the employer prior experience",
#               dep.var.caption = "Anyone hired?",
               dep.var.labels = c("Anyone hired?", "Hired worker past earnings"), 
               dep.var.labels.include = TRUE, 
               label = paste0("tab:", file.name.no.ext),
               no.space = TRUE,
               align = TRUE, 
               font.size = "small",
              star.cutoffs = NA, 
               covariate.labels = c("MW4", "MW3",
                                    "MW2",
                                    "Prior Experience",
                                    "Prior Experience $\\times$ MW4",
                                    "Prior Experience $\\times$ MW3",
                                    "Prior Experience $\\times$ MW2",
                                    "Constant"
                                    ),
               omit.stat = c("aic", "f", "adj.rsq", "ll", "bic", "ser"),
               type = "latex"
               )
sink()

note <- c("\\\\",
          "\\begin{minipage}{0.95 \\textwidth}", 
"{\\footnotesize \\emph{Notes}: The outcome in Columns (1) and (2) are whether the employer hired anyone at all.
In Columns~(3) and (4), it is the cumulative prior earnings of the hired worker, if any.
In addition to the treatment cell indicators, one of the regressors is a whether the employer had any on-platform experience (as measured by having hired in the past).}", "\\end{minipage}")

JJHmisc::AddTableNote(s, out.file, note = note)


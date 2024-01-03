#!/usr/bin/Rscript --vanilla

suppressPackageStartupMessages({
    library(lfe)
    library(ggplot2)
    library(JJHmisc)
    library(magrittr)
    library(dplyr)
    options(dplyr.summarise.inform = FALSE)
    library(directlabels)
    library(ggrepel)
})

source("settings.R")

df.windows <- GetData("event_study_windows.csv")

m.wage.bid <- felm(log(hr_charge_rate) ~ as.numeric(post):wage.bands | contractor | 0 | contractor,
          data = subset(df.windows, pre.obs > 1 & year == 2014))

m.wage.bid.placebo <- felm(log(hr_charge_rate) ~ as.numeric(post):wage.bands | contractor | 0 | contractor,
          data = subset(df.windows, pre.obs > 1 & year == 2013))

actual.lang <- "Imposition Year"
placebo.lang <- "Placebo Year"

getCoef <- function(model, label){
    beta <- coef(model)
    se <- sqrt(diag(vcov(model)))
    names <- names(coef(model))
    bands <- gsub("as\\.numeric\\(post\\):wage\\.bands", "", names)
    data.frame(beta = beta, se = se, bands = factor(bands), label = label)
}

df.wb <- getCoef(m.wage.bid, actual.lang)
df.wb.placebo <- getCoef(m.wage.bid.placebo, placebo.lang)

bands <- getCoef(m.wage.bid, actual.lang)$bands

df.wb <- rbind(
    getCoef(m.wage.bid, actual.lang),
    getCoef(m.wage.bid.placebo, placebo.lang)
)


## collapse
df.tmp <- df.windows %>% filter(pre.obs > 1) %>%
    group_by(contractor, post, wage.bands, year) %>%
    summarise(num.hires = sum(status == "filled"),
              num.apps = n())

m.hired <- felm(I(status == "filled") ~ as.numeric(post):wage.bands | contractor | 0 | contractor,
          data = subset(df.windows, pre.obs > 1 & year == 2014))

m.hired.placebo <- felm(I(status == "filled") ~ as.numeric(post):wage.bands | contractor | 0 | contractor,
          data = subset(df.windows, pre.obs > 1 & year == 2013))

df.hired <- rbind(
    getCoef(m.hired, actual.lang),
    getCoef(m.hired.placebo, placebo.lang)
)


m.apps <- felm(num.apps ~ as.numeric(post):wage.bands | contractor | 0 | contractor,
          data = df.tmp %>% filter(year == 2014))

m.apps.placebo <- felm(num.apps ~ as.numeric(post):wage.bands | contractor | 0 | contractor,
          data = df.tmp %>% filter(year == 2013))

df.apps <- rbind(
    getCoef(m.apps, actual.lang),
    getCoef(m.apps.placebo, placebo.lang)
)

m.hires <- felm(num.hires ~ as.numeric(post):wage.bands | contractor | 0 | contractor,
          data = df.tmp %>% filter(year == 2014))

m.hires.placebo <- felm(num.hires ~ as.numeric(post):wage.bands | contractor | 0 | contractor,
          data = df.tmp %>% filter(year == 2013))

df.hires <- rbind(
    getCoef(m.hires, actual.lang),
    getCoef(m.hires.placebo, placebo.lang)
)


df.hired$outcome <- "Outcome: Applicant hired"
df.wb$outcome <-    "Outcome: Applicant's log wage bid"
df.hires$outcome <- "Outcome: Number of hires"
df.apps$outcome <-  "Outcome: Number of applications"

df.combo <- rbind(df.hired, df.wb, df.hires, df.apps)

df.combo$bands <- factor(df.combo$bands, levels = bands, ordered = TRUE)

df.combo$outcome <- factor(df.combo$outcome, levels = c(
                                                 "Outcome: Applicant's log wage bid",
                                                 "Outcome: Applicant hired",
                                                 "Outcome: Number of hires",
                                                 "Outcome: Number of applications"),
                           ordered = TRUE)

g <- ggplot(data = df.combo,
            aes(x = bands, y = beta, linetype = label)) +
    geom_point(position = position_dodge(0.1)) +
    geom_line(aes(group = label)) + 
    geom_errorbar(aes(ymin = beta - 2*se,
                      ymax = beta + 2*se), width = 0.1,
                  position = position_dodge(0.1)) +
    facet_wrap(~outcome, ncol = 1, scale = "free_y") + 
    theme_bw() +
    xlab("Pre-Imposition Mean Wage Bid") +
    ylab("Post-Impostition x Wage Bid Band Coefficient") +
    theme(legend.position = "none",
          strip.background = element_rect(fill="grey95")) +
                                        #geom_dl(aes(label=label), method = "first.points") +
    geom_label_repel(data = df.combo %>% filter(as.numeric(bands) == 1), aes(label = label),
                     xlim = c(-Inf, 1), size = 3.5, segment.colour = "grey") + 
    expand_limits(x = -4) +
    theme(axis.text.x = element_text(angle = 20, vjust = 1.0, hjust=1)) +
    geom_vline(xintercept = 3, colour = "red", linetype = "dashed")
    

JJHmisc::writeImage(g, "application_event_study", path = "../writeup/plots/",
                    width = 7, height = 7)


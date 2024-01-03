#!/usr/bin/Rscript --vanilla

suppressPackageStartupMessages({
    library(stargazer)
    library(JJHmisc)
    library(ggplot2)
    library(dplyr)
    library(magrittr)
})

source("settings.R")

df.combo.first <- GetData("hires_country_composition.csv")
df.mw.first <- GetData("df_mw_first.csv")

df.mw.kpo <- subset(df.mw.first,  level2 %in% c("Web Research",
                                  "Sales & Lead Generation",
                                  "Data Entry",
                                  "Other - Business Services", 
                                  "Other - Sales & Marketing",
                                  "SEO - Search Engine Optimization", 
                                  "Personal Assistant",
                                  "Other - Administrative Support",
                                  "Advertising", 
                                  "SMM - Social Media Marketing",
                                  "Customer Service & Support", 
                                  "Order Processing",
                                  "Market Research & Surveys",
                                  "Other - Customer Service", 
                                  "Technical Support",
                                  "Email Marketing",
                                  "Email Response Handling", 
                                  "Payment Processing"))

admin.openings <- subset(df.mw.kpo, first_opening == economic_opening)$first_opening
lpw.openings <- subset(df.mw.first, lwage.hat <= log(5))$first_opening

df.est <- subset(df.combo.first, first_opening %in% admin.openings)
df.est <- subset(df.combo.first, first_opening %in% lpw.openings)

m.us <- lm(frac.us ~ factor(cell) - 1, data = df.est)
m.ph <- lm(frac.ph ~ factor(cell) - 1, data = df.est)
m.india <- lm(frac.india ~ factor(cell) - 1, data = df.est)
m.bn <- lm(frac.bn ~ factor(cell) - 1 , data = df.est)

GetEffect <- function(m, country) data.frame(frac = coef(m),
                                             group = sapply(names(coef(m.us)),
                                                            function(x) as.numeric(gsub("factor\\(cell\\)", "", x))),
                                             country = country,
                                             se = sqrt(diag(vcov(m)))) 

df.combo <- rbind(
    GetEffect(m.us, "United States"),
    GetEffect(m.india, "India"),
    GetEffect(m.ph, "Philippines"),
    GetEffect(m.bn, "Bangladesh")
    )



df.combo$country <- with(df.combo,
                         factor(country,
                                levels = c("United States", "India", "Philippines", "Bangladesh"))) 

addParam <- JJHmisc::genParamAdder("../writeup/parameters/params_country_selection.tex")

addParam("\\USfractionControl", df.combo %>% filter(country == "United States") %>% filter(group == 0) %$% frac %>% multiply_by(100) %>% round(1))

addParam("\\USfractionFour", df.combo %>% filter(country == "United States") %>% filter(group == 4) %$% frac %>% multiply_by(100) %>% round(1))


addParam("\\BANGfractionControl", df.combo %>% filter(country == "Bangladesh") %>% filter(group == 0) %$% frac %>% multiply_by(100) %>% round(1))

addParam("\\PHILfractionControl", df.combo %>% filter(country == "Philippines") %>% filter(group == 0) %$% frac %>% multiply_by(100) %>% round(1))

addParam("\\IndiafractionControl", df.combo %>% filter(country == "India") %>% filter(group == 0) %$% frac %>% multiply_by(100) %>% round(1))

addParam("\\BANGfractionFour", df.combo %>% filter(country == "Bangladesh") %>% filter(group == 4) %$% frac %>% multiply_by(100) %>% round(1))


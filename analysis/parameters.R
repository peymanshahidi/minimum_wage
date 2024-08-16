#!/usr/bin/Rscript --vanilla

suppressPackageStartupMessages({
    
    library(magrittr)
    library(dplyr)
})

options(scipen = 999)

source("settings.R")
df.mw.first <- GetData("df_mw_first.csv")

addParam <- genParamAdder("../writeup/parameters/parameters.tex")

addParam("\\numTotal", formatC(dim(df.mw.first)[1], big.mark = ","))
addParam("\\numControl", formatC(sum(df.mw.first$cell=="0"), big.mark = ","))
addParam("\\numMWFour", formatC(sum(df.mw.first$cell=="4"), big.mark = ","))
addParam("\\numMWThree", formatC(sum(df.mw.first$cell=="3"), big.mark = ","))
addParam("\\numMWTwo", formatC(sum(df.mw.first$cell=="2"), big.mark = ","))

addParam("\\FracSingleHires", formatC(100 * sum(df.mw.first$num_hires == 1)/sum(df.mw.first$num_hires > 0),
                                      digits = 1,
                                      format = "d"))
addParam("\\FracDoubleHires", formatC(100 * sum(df.mw.first$num_hires == 2)/sum(df.mw.first$num_hires > 0),
                                      digits = 1,
                                      format = "d"))

df.windows <- GetData("event_study_windows.csv") %>% ungroup

df.tmp <- subset(df.windows, pre.obs > 1 & year == 2014) %>%
    group_by(wage.bands) %>%
    summarise(
        avg.hire.rate = mean(I(status == "filled"))
    )



addParam("\\TwoThreePerAppWinRate", formatC(df.tmp$avg.hire.rate[3], digits = 2))

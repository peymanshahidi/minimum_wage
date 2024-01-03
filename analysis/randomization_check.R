#!/usr/bin/Rscript --vanilla 

suppressPackageStartupMessages({
    library(JJHmisc)
})

##################################
# Construct Means Comparison Table
##################################

# This code creates a table of means comparisons.
# It is used for verify the randomizationa
source("settings.R")

df.mw <- GetData("df_mw_first.csv")

numberFormat <- function(x) formatC(x, digits = digits, format = "f")
standardError <- function(x) sd(x)/sqrt( length(x) )
seBracket <- function(x) paste("(", x, ")", sep = "")
bigCount <- function(x) formatC(x, big.mark = ",", format = "f", digits = 0)
TCv <- function(outcome, label, df) list(df[df$trt == 1, outcome],
                                         df[df$trt == 0, outcome], label)

df.mw.mc <- subset(df.mw, (min.wage == 0 | min.wage == 4)
                   & economic_opening == first_opening)
df.mw.mc$trt <- with(df.mw.mc, as.numeric(min.wage==4))
nT <- bigCount( with(df.mw.mc, sum(trt)) )
nC <- bigCount( with(df.mw.mc, sum(!trt)) )

df.mw.mc$technical <- with(df.mw.mc,
                           as.numeric(level1 %in% c("Web Development",
                                                    "Software Development")))
df.mw.mc <- as.data.frame(df.mw.mc)

ssLine <- function(T,C,label,header = "",
                   numberFormat = function(x) formatC(x,
                       digits = 3, format = "f")){
  p <- numberFormat(t.test(T,C)$p.value)
  display.p <- if (p < 0.001) "<0.001" else p
  paste(header, label,"&",
        numberFormat(mean(T)),
        seBracket( numberFormat( standardError(T) )), "&",
        numberFormat(mean(C)),
        seBracket( numberFormat( standardError(C) )), "&",
        numberFormat(mean(T) - mean(C)),
        seBracket( numberFormat( sqrt(standardError(T)**2 +
                                      standardError(C)**2) ) ), "&",
        display.p, "& ", starLabel(p), "\\\\ \n ", sep = " ")
}

df.mw.mc <- subset(df.mw.mc, !is.na(level1) & !is.na(contractor_tier))

# deal with some number of refunds that give negative prior spend
df.mw.mc$prior_spend = with(df.mw.mc, ifelse(prior_spend > 0, prior_spend, 0))

df.mw.mc <- within(df.mw.mc, {
    new.employer <- I(prior_spend == 0)
    admin <- as.numeric(level1 == "Administrative Support")
    software <- as.numeric(level1 == "Software Development")
    high.tier <- as.numeric(contractor_tier == 3)
    has.team <- as.numeric(team_hours_30day > 0)
    jdl <- log1p(job_desc_length)
    ps <- ifelse(prior_spend > 0, log1p(prior_spend), 0)
})

randomization.check <- c(
    "\\\\",
    "\\multicolumn{2}{l}{\\emph{Observation Counts}} \\\\",
    paste("&&", nT , "&", nC, "& &", "", "\\\\"),
    "\\multicolumn{2}{l}{\\emph{Type of work}} \\\\",
    do.call(ssLine, c(TCv("technical", "Technical (1 if yes, 0 otherwise)",
                          df.mw.mc), "&")),
    "\\multicolumn{2}{l}{\\emph{Type of work---(more detailed)}} \\\\",
    do.call(ssLine, c(TCv("admin", "Admin", df.mw.mc), "&")),
    do.call(ssLine, c(TCv("software", "Software Dev.", df.mw.mc), "&")),   
    "\\multicolumn{2}{l}{\\emph{Vacancy attributes}} \\\\",
    do.call(ssLine, c(TCv("new.employer", "New employer?",
                          df.mw.mc), "&")),
    do.call(ssLine, c(TCv("high.tier", "Prefers high quality?",
                          df.mw.mc), "&")),
    do.call(ssLine, c(TCv("has.team", "Has employees already?",
                          df.mw.mc), "&")),
    do.call(ssLine, c(TCv("jdl", "Log job description length (chars)",
                          df.mw.mc), "&")),
    do.call(ssLine, c(TCv("ps", "Log prior spend + 1",
                          df.mw.mc), "&"))
)

writeLines(randomization.check, "../writeup/tables/randomization_check.tex")

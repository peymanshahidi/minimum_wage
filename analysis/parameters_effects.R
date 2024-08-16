#!/usr/bin/Rscript --vanilla

suppressPackageStartupMessages({
    library(sandwich)
    library(ggplot2)
    library(dplyr)
    options(dplyr.summarise.inform = FALSE)
    library(magrittr)
    library(tidyr)
    library(cowplot)
    library(purrr)
})

source("jjh_misc.R")

source("utilities_outcome_experimental_plots.R")

df.effects <- AllEffects(outcome.set, wide = FALSE) %>%
    mutate(dataset = as.character(dataset)) %>%
    filter(name %in% c("effects", "pct.change", "control.value", "y"))

addParam <- genParamAdder("../writeup/parameters/effects_parameters.tex")

formatter <- list(
    "pct.change" = function(p) p %>% abs %>% round(2),
    "control.value" = function(p) round(p,2),
    "effects" = function(p) round(p,2),
    "y" = function(p) round(p,2)
)

Replace <- function(x, replacements){
    for(l in names(replacements)){
        x <- gsub(l, replacements[[l]], x)
    }
    x
}

replacements <- list("\\(" = "",
                     "\\)" = "",
                     "\\."  = "",
                     " "  = "",
                     "\\*" = "times",
                     "\\_" = "",
                     "\\/" = "",
                     ">"  = "gt", 
                     "1" = "One",
                     "2" = "Two",
                     "3" = "Three",
                     "4" = "Four",
                     "5" = "Five",
                     "6" = "Six",
                     "7" = "Seven",
                     "8" = "Eight",
                     "9" = "Nine",
                     "0" = "Zero"
                    )

for(i in 1:nrow(df.effects)){
    name <- as.character(df.effects[i, "name"])
    outcome <- as.character(df.effects[i, "outcome"])
    dataset <- as.character(df.effects[i, "dataset"])
    cell <- as.character(df.effects[i, "cell.name"])
    line <- paste(dataset, cell, outcome, name)
    key <- Replace(paste(sapply(line, as.character), sep = "", collapse = ""), replacements)
    value <- df.effects[i, "value"] %>% as.numeric
    addParam(paste0("\\", key), formatter[[name]](value))
}

max.hours.reduction <- df.effects %>% filter(cell.name == 4) %>%
    filter(outcome == "log(hours)") %>%
    filter(name == "pct.change") %$% value %>% abs %>% max

addParam("\\HoursReduction", max.hours.reduction)

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

source("settings.R")

brewer.neg <<- "#d7191c"
brewer.pos <<- "#abdda4"

group.names <- list("ALL" = "Sample: ALL\nAll job posts",
                    "ADMIN" = "Sample: ADMIN\nAdmin support posts",
                    "LPW" = "Sample: LPW\nLow predicted wage posts")

df.mw.all <- GetData("df_mw_all.csv") %>% mutate(cell.name = factor(cell))
df.mw.admin <- GetData("df_mw_admin.csv") %>% mutate(cell.name = factor(cell))
df.mw.lpw <- GetData("df_mw_lpw.csv") %>% mutate(cell.name = factor(cell))

GetRobustSE <- function(model) {
    sqrt(diag(sandwich::vcovHC(model, type = "HC")))
}

outcome.set <- list(
    "I(total_charge > 0)" = list(
        "condition" = "1==1",
        "desc" = "Anyone hired?",
        "type"="match"),
    "log(hours)" = list(
        'condition' = "mean_wage_over_contract > 0.25 & hours > 0",
        'desc' = "Log hours-worked\n (conditional upon any)",
        'type'='match'
    ),
        "log(mean_wage_over_contract)" = list(
        'condition' = "mean_wage_over_contract > 0.25 & hours > 0",
        'desc' = "Log mean wage,\n conditional upon a hire",
        'type'='match'),
    "log(hours * mean_wage_over_contract)" = list(
        'condition' = "mean_wage_over_contract > 0.25 & hours > 0",
        'desc' = "Log earnings\n (conditional upon any)",
        'type'='match'
    ),
    "I(total_charge/100)" = list(
        'condition' = "total_charge > -1",
        'desc' = "Earnings \n(in 100s of USDs,\n 0s included)",
        'type'='match'
    ),
    "log(hired.past.w)" = list(
        'condition' = 'hired.past.w > 0.15 & hired.past.w < 100',
        'desc' = "Log past wage \n of the \n hired worker",
        'type'='selection'),
    "log(hired_past_y)" = list(
        'condition' = 'hired_past_y > 0',
        'desc' = 'Log cumulative \n past \n earnings of \n the hired worker',
        'type'='selection'
    ),
    "log(hired_pr)" = list(
        'condition' = 'mean_wage_over_contract > 0.25 & hired_pr > 0',
        'desc' = 'Log profile rate \nof hired worker',
        'type'='selection'
    ),
    "markup" = list(
        'condition' = "mean_wage_over_contract > 0.25 & hired_pr > 0",
        'dep.var.label' = "markup in the wage bid of the hired worker",
        'desc' = "Markup of the wage\n bid of the\n hired worker",
        'type' = 'selection'),
    "average_feedback_to_contractor" = list(
        'condition' = '!is.na(average_feedback_to_contractor)',
        'desc' = 'Employer feedback to worker',
        'type'='selection'),
    "average_feedback_to_client" = list(
        'condition' = '!is.na(average_feedback_to_client)',
        'desc' = "Worker feedback to employer",
        'type'='selection'),
    "frac.us" = list(
        'condition' = "mean_wage_over_contract > 0.25 & hours > 0",  #'!is.na(frac.us)',
        'desc' = "Hire from US",
        'type' = 'selection'
    ),
    "frac.bn" = list(
        'condition' = "mean_wage_over_contract > 0.25 & hours > 0",  #'!is.na(frac.us)','!is.na(frac.bn)',
        'desc' = "Hire from Bangladesh",
        'type' = 'selection'
    ),
      "hours" = list(
        'condition' = "1==1",
        'desc' = "Hours (0s included)",
        'type' = "match"
      ),
    "log(num_organic_applications)" = list(
        'condition' = "num_organic_applications > 0",
        'desc' = "Number of organic\n applications received",
        'type' = "match"
    ),
    "I(num.openings > 1)" = list(
        "condition" = "1 == 1",
        "desc" = "Follow-on opening by the emplopyer",
        "type" = "match"),
    "I(hired_past_y > 0)" = list(
        "condition" = "1 == 1",
        "desc" = "Hired worker has any past experience",
        "type" = "match"
    ),
    "fp" = list(
        "condition" = "posting.employer",
        "desc" = "Subsequently posted a fixed price job",
        "type" = "Match"
    )
)

descriptions <- as.character(sapply(names(outcome.set), function(x) outcome.set[[x]][['desc']]))

pretty.dataset.names <- list("ALL" = "Full sample\n of job posts\n (ALL)",
                             "ADMIN" = "Admnistrative\n job posts\n (ADMIN)",
                             "LPW" = "Low predicted wage \n job posts\n (LPW)")

data.frame.list <- c(
        "df.mw.all",
        "df.mw.admin",
        "df.mw.lpw")

df.labels <- c("ALL", "ADMIN", "LPW")
 
EstimateEffect <- function(outcome.measure, title, add.condition){
    df.effects <- data.frame(y = c(), se = c(), cell.name = c(), direction = c(),
                          dataset = c(), control.value = c(), num.obs.cell = c())
    for(dataset in data.frame.list){
        df <- subset(eval(parse(text = dataset)),
                     eval(parse(text = add.condition)))
        formula <- as.formula(paste0(outcome.measure, "~ cell.name - 1"))
        m  <- lm(formula, data = df) # used to get means
        m.diff  <- lm(as.formula(paste0(outcome.measure, "~ cell.name")), data = df)
        df.effects.tmp <- data.frame(
            y = coef(m), 
            effects = coef(m.diff),
            effects.se = sqrt(diag(vcovHC(m.diff))), 
            control.value = rep(coef(m)[1], 4), 
            se = GetRobustSE(m),
            cell.name = sapply(names(coef(m)),
                               function(x) gsub("cell.name", "", x)),
            direction = c('same', ifelse(coef(m)[-1] > coef(m)[1], 'pos', 'neg')),
            dataset = dataset
        )
        df.n <- df %>% group_by(cell) %>% summarise(num.obs.cell = n()) %>%
            mutate(cell.name = as.character(cell)) %>%
            select(-cell)
        df.combo <- df.effects.tmp %>% left_join(df.n, by = "cell.name")
        df.effects <- rbind(df.effects, df.combo)
    }
    df.effects$direction <- factor(df.effects$direction, levels = c('same', 'pos', 'neg'))
#    df.effects$dataset.short <- factor(df.effects$dataset)
    df.effects$dataset <- factor(df.effects$dataset, labels = df.labels)
    df.effects %<>% mutate(outcome = outcome.measure)
    df.effects
}

ComputeEffects <- function(outcome.set){
    df.plot <- data.frame()    
    for(outcome in names(outcome.set)){
        log.outcome = grepl("log", outcome)
        cond = outcome.set[outcome]
        desc = outcome.set[[outcome]][['desc']]
        df.tmp <- EstimateEffect(outcome,
                                 outcome.set[[outcome]][['desc']],
                                 outcome.set[[outcome]][['condition']]) %>%
            mutate(log.outcome = log.outcome) %>%
            mutate(desc = desc)
        df.plot <- rbind(df.plot, df.tmp)
    }
    df.plot %<>% mutate(pct.change = ifelse(
                            log.outcome, round(100 * (y - control.value), 0),
                            round(100*(y - control.value) / control.value,0)
                        ))
    df.plot %<>% mutate(pct.change = ifelse(as.character(outcome) == "markup", NA, pct.change))
    df.plot
}

AddContext <- function(outcome.set){
    df.plot <- ComputeEffects(outcome.set) %>%
    mutate(desc2 = factor(desc, levels = descriptions)) %>% 
    group_by(outcome) %>%
    mutate(min.y = min(y - 2*se),
           max.y = max(y + 2*se),
           range = max.y - min.y
           ) %>%
    mutate(cell.name = as.numeric(as.character(cell.name))) %>% 
    ungroup %>%
    mutate(baseline = ifelse(direction == "pos",
                      ifelse(control.value < y - 2*se, control.value, y - 2*se),
                      ifelse(control.value > y + 2*se, control.value, y + 2*se))
           ) %>%
    mutate(outcome2 =  factor(as.character(outcome), levels = names(outcome.set))) %>%
    mutate(pct.change = ifelse(log.outcome,
                               round(100 * (y - control.value), 0),
                               round(100*(y - control.value) / control.value,0)
                               )) %>%
    mutate(pct.change = ifelse(as.character(outcome) == "markup", NA, pct.change)) %>%
    mutate(dataset2 = factor(unlist(pretty.dataset.names[as.character(dataset)]),
                             levels = as.character(unlist(pretty.dataset.names[names(pretty.dataset.names)]))))
}

AllEffects <- function(outcome.set, numbered = TRUE, wide = TRUE){
    df.plot <- AddContext(outcome.set)
    epsilon <- 0.4
    dataset.levels <- as.character(unlist(group.names))
    dataset.levels.short <- as.character(names(group.names))
    outcome.levels <- as.character(unlist(sapply(outcome.set, function(x) x['desc'])))
    # add number under each outcome
    if (numbered){
        outcome.levels.numbered <- unlist(imap(outcome.levels, ~ paste0(.x, "\n(", .y, ")")))
    } else {
        outcome.levels.numbered <- outcome.levels
    }
    df.small <- df.plot %>%
    select(-direction, -min.y, -max.y, -range, -baseline, -outcome2,
           -dataset2, -log.outcome, -outcome2, -desc2) %>%
    pivot_longer(-c(dataset, outcome, desc, cell.name))
    df.small %<>% mutate(value = ifelse(name == "effects" & cell.name == 0, NA, value))
    df.small %<>% mutate(value = ifelse(name == "effects.se" & cell.name == 0, NA, value))
    df.small %<>% mutate(value = ifelse(name == "pct.change" & cell.name == 0, NA, value))
    if (wide){
        df.outcome <- df.small %>% 
            pivot_wider(names_from = name, values_from = value) %>%
            mutate(sign = ifelse(effects > 0, "pos", "neg")) %>%
            mutate(cell.name = factor(cell.name)) %>%
            mutate(order = as.numeric(factor(desc)))
        df.outcome$desc = with(df.outcome, factor(desc, levels = outcome.levels))
        df.outcome$dataset.short <- with(df.outcome, dataset)
        levels(df.outcome)$dataset.short <- dataset.levels.short
        levels(df.outcome$desc) <- outcome.levels.numbered
        levels(df.outcome$dataset) <- dataset.levels
        df.outcome
    } else {
        df.small
    }
}

CreatePlot <- function(outcome.set, offset.text = 0.25, plot.title = "Test"){
    df <- AllEffects(outcome.set)
    divisor <- 3
    max.x <- df %>% mutate(ul = effects + 2*effects.se,
                       ll = effects - 2*effects.se,
                       al = max(abs(ul), abs(ll), na.rm = TRUE)
                       ) %>% pull(al) %>% max
    max.x.se <- df %$% se %>% abs %>% max
    df$offset <- with(
        df,
        ifelse(sign == "pos",
        ifelse((effects - 2*effects.se) < -(max.x / (1 + divisor)), effects - 3*effects.se, -max.x / divisor) ,
        ifelse((effects + 2*effects.se) >  (max.x / (1 + divisor)),  effects + 3*effects.se, max.x / divisor)
        )
    )
    g <- ggplot(data = df %>% filter(!is.na(effects)), aes(y = cell.name, x = effects)) +
        geom_point() +
        geom_errorbarh(aes(xmin = effects - 2*effects.se, xmax = effects + 2*effects.se), height = 0.1) + 
        facet_grid(desc ~ dataset) +
        geom_col(aes(x = effects, y = cell.name, fill = sign), colour = "grey", alpha = 0.3) +
        theme_bw() + 
        theme(strip.text.y.right = element_text(angle = 0),
              panel.spacing.x = unit(1.2, "lines"),
              legend.position = "none") +
        geom_vline(xintercept = 0, linetype = "dashed") +
        geom_text(data = df %>% filter(!is.na(pct.change)),
                  aes(x = offset,
                      label = ifelse(sign == "pos", paste0("+", pct.change, "%"), paste0(pct.change, "%")))) + 
        scale_fill_manual(values = c(brewer.neg, brewer.pos)) +
        expand_limits(y = -1) +
        geom_text(data = df %>% filter(as.character(cell.name) == "0"), y = -0.5, x = -max.x / 2,
                  aes(label = paste0("Ctl mean=",round(y, 2))), size = 3) +
        geom_text(data = df %>% group_by(desc, dataset) %>% summarise(sample.size = sum(num.obs.cell)),
                  y = -0.5,
                  x = max.x / 2,
                  aes(label = paste0("N=", format(sample.size, big.mark = ","))), size = 3) +
        xlab("Treatment effect") +
        ylab("MW") +
        labs(title = plot.title) +
        expand_limits(x = c(-max.x, max.x))
    g
}


GetImage <- function(outcome.range, plot.title, offset.text = 0.25, param.name = NA){
    g <- CreatePlot(outcome.set[outcome.range],
                    offset.text = offset.text,
                    plot.title = plot.title)
    if (!is.na(param.name)){
        addParam(param.name, plot.title)
    }
    g
}


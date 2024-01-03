#!/usr/bin/env Rscript

suppressPackageStartupMessages({
    library(magrittr)
    library(cowplot)
    library(ggrepel)
    library(ggplot2)
    library(dplyr)
    library(tidyr)
    library(magrittr)
    options(tibble.width = Inf)
})

source("settings.R")


df.panel <- GetData("did_panel.csv")

################################

MakePlot <- function(df){
    ggplot(data = df, aes(x = period, y = y.hat)) +
        geom_line() +
        geom_point() + facet_wrap(~unit, ncol = 3) +
        geom_vline(xintercept = -0.5, linetype = "dashed") + 
        geom_smooth(data = df %>% filter(period < 0), method = "lm", formula = "y ~ x") +
        theme_bw() +
        ylab("Outcome") +
        scale_x_continuous(breaks = unique(df$period))
}


GenPlot <- function(outcome, transform = function(x) I(x), detrend = TRUE, weighted = FALSE){
    if (! weighted){
        df.panel %<>% mutate(weight = 1)
    }
    df.panel %<>% mutate(y.hat = transform(get(outcome)))
    #df.panel$y.hat <- df.panel$y
    g.raw <- MakePlot(df.panel)
    # First, remove unit-specific FE
    m <- lm(y.hat ~ unit, data = df.panel, weight = weight)
    df.panel$y.hat <- with(df.panel, y.hat - predict(m, newdata = df.panel))
    g.no.unit <- MakePlot(df.panel)
    # Remove period-specific FE 
    m <- lm(y.hat ~ factor(period), data = df.panel %>% filter(treated.unit == 0),
            weight = weight)
    df.panel$y.hat <- with(df.panel, y.hat - predict(m, newdata = df.panel))
    g.no.time <- MakePlot(df.panel)
    # Remove period-specific time trends
    if (detrend){
        m <- lm(y.hat ~ period*unit, data = df.panel %>% filter(period < 0),
                weight = weight)
        df.panel$y.hat <- with(df.panel, y.hat - predict(m, newdata = df.panel))
    }
    g.no.trend <- MakePlot(df.panel)
    # group means (should be zero)
    df.mean <- df.panel %>% filter(treated.unit == 0) %>% group_by(period) %>%
        mutate(y.mean = sum(y.hat * weight) / sum(weight))
    m <- lm(y.hat ~ treated.unit:factor(period) - 1, data = df.panel, weight = weight)
    df.results <- data.frame(beta = coef(m),
                         se = sqrt(diag(vcov(m))),
                         name = names(coef(m))
                         ) %>%
    mutate(t = sub("treated.unit:factor\\(period\\)", "", name) %>% as.numeric)
    df.mean <- df.panel %>% filter(treated.unit == 0) %>%
        group_by(period) %>% mutate(y.mean = mean(y.hat))
    g <- ggplot(data = df.panel, aes(x = period)) +
        geom_line(aes(y = y.hat, linetype = factor(treated.unit), group = interaction(unit, post))) +
        theme_bw() +
        scale_linetype_manual(values = c("dotted", "solid")) + 
        geom_vline(xintercept = -0.5, linetype = "dashed") + 
        theme_bw() +
        ylab("Outcome") +
        geom_label_repel(data = df.panel %>% filter(period == max(df.panel$period)),
                         aes(label = unit, y = y.hat, fill = factor(treated.unit)), xlim = c(max(df.panel$period), NA), segment.colour = "grey", size = 3) +
        geom_line(data = df.mean, aes(y = y.mean), colour = "blue", linetype = "solid", linewidth = 1) +
        theme(legend.position = "none") +
        scale_x_continuous(breaks = unique(df.panel$period)) +
        geom_errorbar(data = df.results %>% mutate(period = t),
                      aes(x = period, ymin = beta - 2*se, ymax = beta + 2*se), width = 0) +
        geom_point(data = df.results %>% mutate(period = t),
                   aes(x = period, y = beta)) +
        expand_limits(x = max(df.panel$period) + 1) +
        scale_fill_manual(values = c("white", "pink"))
    list(
        "raw" = g.raw,
        "no_unit" = g.no.unit,
        "no_time" = g.no.time,
        "no_linear_trend" = g.no.trend,
        "effects" = g,
        "df_results" = df.results)
}




pretty.names <- list("effects" = "Overall",
                     "raw" = "Raw",
                     "no_time" = "+Time FEs removed",
                     "no_linear_trend" = "+Unit-Specific Time Trend Removed",
                     "no_unit" = "+Unit FEs Removed")

CreatePlots <- function(base, g) {    
    for (t in names(pretty.names)){
        JJHmisc::writeImage(g[t][[1]], paste0(base, "_", t), width = width, height = height, path = "../writeup/plots/")
    }
    g["effects"] <- NULL
    g["df_results"] <- NULL
    result <- do.call(plot_grid,
                      c(g, list(ncol = 2,
                                scale = 0.9, 
                                labels = as.character(unlist(pretty.names[names(g)]))
                                )))
    save_plot(paste0("../writeup/plots/", base, "_combo.pdf"),
              result,
              base_width = 12,
              base_height = 12
              )    
}


df.results <- data.frame()


outcomes <- list(
    'filled_jobs' = list(
        transform = log,
        detrend = TRUE,
        pretty.name = 'Log number of filled jobs'), 
    'avg_earnings' = list(
        transform = log,
        detrend = TRUE,
        pretty.name = "Log average worker earnings"), 
    'avg_duration' = list(
        transform = log,
        detrend = TRUE,
        pretty.name = "Log formed contract duration in days"), 
    'num_jobs' = list(
        transform = log,
        detrend = TRUE,
        pretty.name = "Log number of hourly jobs posted"
    ),
    'total_jobs' = list(
        transform = log,
        detrend = TRUE,
        pretty.name = "Log number of jobs posted\n(hourly and fixed price)"
    ),
    'fp' = list(
        transform = log,
        detrend = TRUE,
        pretty.name = 'Log number of fixed price jobs'),
    'fp_ratio' = list(
        transform = I,
        detrend = TRUE,
        pretty.name = 'Ratio of fixed price to hourly jobs'), 
    'fill_rate' = list(
        transform = I,
        detrend = TRUE,
        pretty.name = "Fraction of hourly jobs filling"
    ),
    'avg_wage' = list(
        transform = log,
        detrend = TRUE,
        pretty.name = "Log average wage of hired workers"
    ),
    'hours' = list(
        transform = log,
        detrend = TRUE,
        pretty.name = "Log total hours worked"
    ),
    'mean_hours' = list(
        transform = log,
        detrend = TRUE,
        pretty.name = "Log mean hours worked per contract"
    ),
    'cumulative_past_earnings' = list(
        transform = log,
        detrend = TRUE,
        pretty.name = "Log mean past earnings of hired worker"
    ),
    'cumulative_past_hours' = list(
        transform = log,
        detrend = TRUE,
        pretty.name = "Log cumulative past hours-worked"
    ),
    'past_avg_wage' = list(
        transform = log,
        detrend = TRUE,
        pretty.name = "Log mean past wage of hired worker"
    ),
    'spend' = list(
        transform = log,
        detrend = TRUE,
        pretty.name = "Log total wage bill"
    ),
    'median_bid' = list(
        transform = log,
        detrend = TRUE,
        pretty.name = "Log median bid"
    ),
    'est_hours' = list(
        transform = log,
        detrend = TRUE,
        pretty.name = "Log predicted hours"
    )
)


height <- 3
width <- 9

df.results <- data.frame()
for(outcome in names(outcomes)){
    g <- GenPlot(outcome,
                 outcomes[[outcome]]$transform,
                 outcomes[[outcome]]$detrend)
    pretty.name = outcomes[[outcome]]$pretty.name
    df.results <- rbind(df.results, g[["df_results"]] %>% mutate(outcome = outcome) %>% mutate(pretty.name = pretty.name))
    CreatePlots(paste0("did_", outcome), g)
}

# map between experiment names and observational names
outcomes.mapping <- list(
    "Anyone hired?" = "Fraction of hourly jobs filling",
    "Log cumulative \n past \n earnings of \n the hired worker" = "Log mean past earnings of hired worker",
    "Log mean wage,\n conditional upon a hire" = "Log average wage of hired workers",
    "Log hours-worked\n (conditional upon any)" =  "Log mean hours worked per contract",
    "Log past wage \n of the \n hired worker" = "Log mean past wage of hired worker",
    "Log earnings\n (conditional upon any)" = "Log total wage bill")


df.exp.results <- GetData("df_exp_results.csv") %>%
    filter(dataset == "Sample: ADMIN\nAdmin support posts") %>%
    filter(cell.name == 3) %>%
    mutate(beta = effects) %>%
    filter(desc %in% names(outcomes.mapping)) %>%
    mutate(pretty.name = as.character(unlist(outcomes.mapping[as.character(desc)]))) 

    ## %>% 
    ## filter(name == "Trt. Effect") %>%
    ## select(ADMIN_3, name, desc) %>%
    ## mutate(beta = ADMIN_3)


g <- ggplot(data = df.results %>% mutate(post = I(t > -1)), aes(x = t, y = beta)) + 
    geom_point() +
    geom_line(aes(group = post), colour = "grey") + 
    geom_errorbar(aes(ymin = beta - 2*se, ymax = beta + 2*se), width = 0) +
    theme_bw() +
    facet_wrap(~pretty.name, ncol = 3, scale = "free_y") +
#    facet_wrap(~pretty.name, ncol = 3) + 
                geom_hline(yintercept = 0, colour = "blue") + 
    geom_vline(xintercept = -0.5, colour = "red", linetype = "dashed")  +
    geom_segment(data = df.exp.results, aes(x = -0.5, y =  beta, xend = max(df.results$t) + 1/2, yend = beta), colour = "darkgreen") +
    geom_text(data = df.exp.results, aes(x = max(df.results$t) + 2, y = beta), label = "MW3\nExp.\nEst", colour = "darkgreen", size = 3) + 
    theme_bw() +
    expand_limits(x = max(df.results$t) + 3)

JJHmisc::writeImage(g, "did_all_outcomes", width = 9, height = 9, path = "../writeup/plots/")

######################
## Posts, and creation 
######################

DidPlotRow <- function(q.outcomes){
    num.cols <- length(q.outcomes)
    outcome.levels <- as.character(sapply(q.outcomes, function(x) outcomes[[x]]$pretty.name))
    q.outcomes.pretty <- sapply(q.outcomes, function(x) outcomes[[x]]$pretty.name)

    df.q.plot <- df.results %>% mutate(post = I(t > -1)) %>%
        filter(outcome %in% q.outcomes)

    df.q.plot$pretty.name <- with(
        df.q.plot, factor(
                       as.character(pretty.name), levels = outcome.levels))

    df.labels <- df.exp.results %>% filter(pretty.name %in% q.outcomes.pretty)
    df.labels$pretty.name <- with(df.labels, factor(as.character(pretty.name),
                                                    levels = outcome.levels))
     
    g <- ggplot(data = df.q.plot, aes(x = t, y = beta)) + 
        geom_point() +
        geom_line(aes(group = post), colour = "grey") + 
        geom_errorbar(aes(ymin = beta - 2*se, ymax = beta + 2*se), width = 0) +
        facet_wrap(~pretty.name, ncol = num.cols) +
        geom_hline(yintercept = 0, colour = "blue") + 
        geom_vline(xintercept = -0.5, colour = "red", linetype = "dashed")  +
        theme_bw() +
        { if(nrow(df.labels) > 0) {
        geom_segment(data = df.labels,
                     aes(x = -0.5, y =  beta, xend = max(df.results$t) + 1/2, yend = beta), colour = "darkgreen")
          }} +
        { if(nrow(df.labels) > 0) {
              geom_text(data = df.labels,
                        aes(x = max(df.results$t) + 2, y = beta), label = "MW3\nExp.\nEst", colour = "darkgreen", size = 3)
        }} + 
        expand_limits(x = max(df.results$t) + 3) +
        ylab("Effect") +
        xlab("Month relative to MW imposition")
    g
}

#g <- DidPlotRow(c("num_jobs","total_jobs", "fp_ratio", "fp"))
#print(g)
#g <- DidPlotRow(c("fp_ratio"))
#print(g)

g <- DidPlotRow(c("num_jobs", "total_jobs", "fill_rate"))

JJHmisc::writeImage(g, "did_q_outcomes", width = 8, height = 2.5, path = "../writeup/plots/")

g <- DidPlotRow(c(
    "avg_wage",
    "mean_hours",
    "avg_earnings"
    ))

JJHmisc::writeImage(g, "did_match_outcomes",
                    width = 8,
                    height = 2.5,
                    path = "../writeup/plots/")

####################
## LL Subst Outcomes 
####################

ll.subst.outcomes <- c(
    'cumulative_past_hours',
    "cumulative_past_earnings",
    "past_avg_wage")

g <- DidPlotRow(ll.subst.outcomes)

JJHmisc::writeImage(g,
                    "did_ll_subst_outcomes",
                    width = 8,
                    height = 2.5,
                    path = "../writeup/plots/")


df.effects <- df.results %>% filter(t > -1) %>%
    group_by(outcome) %>%
    summarise(mean.beta = mean(beta))

addParam <- JJHmisc::genParamAdder("../writeup/parameters/did_parameters.tex")

for(i in 1:nrow(df.effects)){
    key <- gsub("_", "", as.character(df.effects[i, "outcome"]))
    value <- df.effects[i, "mean.beta"] %>% as.numeric %>% round(2)
    addParam(paste0("\\DID", key), value)
}

#!/usr/bin/env Rscript

source("settings.R")
source("utilities_outcome_experimental_plots.R")

addParam <- genParamAdder(
    "../writeup/parameters/parameters_fill_and_hours.tex")

plot.width <- 8.25

g.fill <- GetImage(outcome.range = 1:1, plot.title = "(A) Match formation", offset.text = 0.03, param.name = "\\panelA")
g.wage.hours <- GetImage(2:5,"(B) Wages, hours-worked and earnings of hired workers", param.name = "\\panelB")

g.combo <- plot_grid(g.fill,
                     g.wage.hours,
                     ncol = 1,
                     align = "v",
                     rel_heights = c(2.2, 5))

adj <- 1
ggsave("../writeup/plots/fill_and_hours.pdf", g.combo,
       width = plot.width + adj,
       height = 5 + adj)

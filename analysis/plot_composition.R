#!/usr/bin/env Rscript

source("utilities_outcome_experimental_plots.R")

addParam <- genParamAdder(
    "../writeup/parameters/parameters_composition.tex")

plot.width <- 8.25

g.composition <- GetImage(6:9, "(C) Hired worker composition, by productivity", offset.text = 0.14, "\\panelC")
g.country <- GetImage(12:13, "(D) Hired worker composition, by country", offset.text = 0.03, "\\panelD")

g.combo <- plot_grid(
    g.composition,
    g.country, 
    ncol = 1,
    align = "v",
    rel_heights = c(5, 3))

adj <- 1
ggsave("../writeup/plots/composition.pdf", g.combo,
       width = plot.width + adj,
       height = 5 + adj)


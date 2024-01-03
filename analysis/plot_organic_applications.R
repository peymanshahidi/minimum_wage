#!/usr/bin/env Rscript

source("utilities_outcome_experimental_plots.R")

plot.width <- 8.25
adj <- 1
g.apps <- GetImage(15, "Organic applications", offset.text = 0.01)

g.combo <- plot_grid(g.apps,
                     ncol = 1,
                     align = "v",
                     rel_heights = c(2))

ggsave("../writeup/plots/organic_applications.pdf", g.combo,
       width = plot.width + adj,
       height = 2 + adj)


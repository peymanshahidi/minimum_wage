#!/usr/bin/env Rscript

source("utilities_outcome_experimental_plots.R")

plot.width <- 8.25
adj <- 1

g.hours <- GetImage(14, "Hours (0s included)", offset.text = 7)

g.combo <- plot_grid(g.hours,
                     ncol = 1, align = "v",
                     rel_heights = c(2))

ggsave("../writeup/plots/hours_zero.pdf", g.combo,
       width = plot.width + adj,
       height = 2 + adj)



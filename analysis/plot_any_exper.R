#!/usr/bin/env Rscript

source("utilities_outcome_experimental_plots.R")

plot.width <- 8.25
adj <- 1
g.any.exper <- GetImage(17, "Any past experience", offset.text = 0.02)

g.combo <- plot_grid(g.any.exper,
                     ncol = 1,
                     align = "v",
                     rel_heights = c(2))

ggsave("../writeup/plots/any_exper.pdf", g.combo,
       width = plot.width + adj,
       height = 2 + adj)


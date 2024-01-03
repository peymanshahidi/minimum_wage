#!/usr/bin/env Rscript

source("utilities_outcome_experimental_plots.R")

plot.width <- 8.25
adj <- 1
g.fb <- GetImage(10:11, "(E) Feedback", offset.text = 0.14)


g.combo <- plot_grid(g.fb,
                     ncol = 1,
                     align = "v",
                     rel_heights = c(2))

ggsave("../writeup/plots/feedback.pdf", g.combo,
       width = plot.width + adj,
       height = 2 + adj)



#!/usr/bin/env Rscript

source("utilities_outcome_experimental_plots.R")

plot.width <- 8.25
adj <- 1

g.follow <- GetImage(16:18, "Follow-on openings", offset.text = 0.02)

g.combo <- plot_grid(g.follow,
                     ncol = 1, align = "v",
                     rel_heights = c(2))

ggsave("../writeup/plots/follow_on_openings.pdf",
       g.combo,
       width = plot.width + adj,
       height = 2 + adj)


#!/bin/bash

apt-get update
apt-get -y install tzdata
apt-get -y install pkg-config
apt-get -y install r-recommended
apt-get -y install make
apt-get -y install libcurl4-gnutls-dev
apt-get -y install build-essential
apt-get -y install libxml2-dev
apt-get -y install libssl-dev
apt-get -y install libnlopt-dev
apt-get -y install ghostscript
apt-get -y install wget
apt-get -y install python3 


apt-get -y install texlive-latex-base
apt-get -y install texlive-latex-extra


echo "r <- getOption('repos'); r['CRAN'] <- 'http://cran.us.r-project.org'; options(repos = r);" > ~/.Rprofile

Rscript -e "packages <- c('dotenv', 'cowplot', 'data.table', 'directlabels', 'dplyr', 'ggplot2', 'ggrepel', 'gridExtra', 'gt', 'lfe', 'lmtest', 'lubridate', 'magrittr', 'plyr', 'purrr', 'quantreg', 'sandwich', 'scales', 'stargazer', 'tidyr', 'remotes'); \
                 install_if_missing <- function(p) { if (!require(p, character.only = TRUE)) install.packages(p, repos = 'http://cran.us.r-project.org') }; \
                 sapply(packages, install_if_missing)" > /dev/null 2>&1
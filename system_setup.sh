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

# Rscript -e "install.packages('dotenv')"
# Rscript -e "install.packages('cowplot')"
# Rscript -e "install.packages('data.table')"
# Rscript -e "install.packages('directlabels')"
# Rscript -e "install.packages('dplyr')"
# Rscript -e "install.packages('ggplot2')"
# Rscript -e "install.packages('ggrepel')"
# Rscript -e "install.packages('gridExtra')"
# Rscript -e "install.packages('gt')"
# Rscript -e "install.packages('lfe')"
# Rscript -e "install.packages('lmtest')"
# Rscript -e "install.packages('lubridate')"
# Rscript -e "install.packages('magrittr')"
# Rscript -e "install.packages('plyr')"
# Rscript -e "install.packages('purrr')"
# Rscript -e "install.packages('quantreg')"
# Rscript -e "install.packages('sandwich')"
# Rscript -e "install.packages('scales')"
# Rscript -e "install.packages('stargazer')"
# Rscript -e "install.packages('tidyr')"
# Rscript -e "install.packages('remotes')"
# Rscript -e 'remotes::install_github("johnjosephhorton/JJHmisc")'

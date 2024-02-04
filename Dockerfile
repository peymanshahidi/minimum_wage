FROM ubuntu:latest AS base
RUN apt-get update
RUN apt-get -y install tzdata
RUN apt-get -y install pkg-config
RUN apt-get -y install r-recommended
RUN apt-get -y install make
RUN apt-get -y install libcurl4-gnutls-dev
RUN apt-get -y install build-essential
RUN apt-get -y install libxml2-dev
RUN apt-get -y install libssl-dev
RUN apt-get -y install libnlopt-dev
RUN apt-get -y install ghostscript
RUN apt-get -y install wget
RUN apt-get -y install python3 

from base as latex
RUN apt-get -y install texlive-latex-base
RUN apt-get -y install texlive-latex-extra

from latex as rcran
#setup R configs
RUN echo "r <- getOption('repos'); r['CRAN'] <- 'http://cran.us.r-project.org'; options(repos = r);" > ~/.Rprofile
RUN Rscript -e "install.packages('dotenv')"
RUN Rscript -e "install.packages('cowplot')"
RUN Rscript -e "install.packages('data.table')"
RUN Rscript -e "install.packages('directlabels')"
RUN Rscript -e "install.packages('dplyr')"
RUN Rscript -e "install.packages('ggplot2')"
RUN Rscript -e "install.packages('ggrepel')"
RUN Rscript -e "install.packages('gridExtra')"
RUN Rscript -e "install.packages('gt')"
RUN Rscript -e "install.packages('lfe')"
RUN Rscript -e "install.packages('lmtest')"
RUN Rscript -e "install.packages('lubridate')"
RUN Rscript -e "install.packages('magrittr')"
RUN Rscript -e "install.packages('plyr')"
RUN Rscript -e "install.packages('purrr')"
RUN Rscript -e "install.packages('quantreg')"
RUN Rscript -e "install.packages('sandwich')"
RUN Rscript -e "install.packages('scales')"
RUN Rscript -e "install.packages('stargazer')"
RUN Rscript -e "install.packages('tidyr')"
RUN Rscript -e "install.packages('remotes')"

RUN Rscript -e 'remotes::install_github("johnjosephhorton/JJHmisc")'

from rcran as main

RUN mkdir minimum_wage
COPY . minimum_wage
RUN cd minimum_wage/writeup && make minimum_wage.pdf

WORKDIR /minimum_wage/
CMD ["python3", "-m", "http.server", "8000"]

###############
# Instructions: 
###############

# sudo docker build -t minimum_wage
# sudo docker run -p 8080:8000 minimum_wage
# Naviate to: http://localhost:8080/writeup/minimum_wage.pdf
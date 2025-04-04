FROM ubuntu:24.04 AS base
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
RUN apt-get -y install gnupg
RUN apt-get -y install file
RUN apt-get -y install curl

FROM base AS latex
RUN apt-get -y install texlive-latex-base
RUN apt-get -y install texlive-latex-extra

FROM latex AS rcran
# setup R configs
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

FROM rcran AS main


# Set working directory inside the image
WORKDIR /minimum_wage/writeup

# Copy the project folder into the container
COPY . /minimum_wage

# Final run command
CMD ["bash", "-c", "bash /minimum_wage/fetch_data.sh && make minimum_wage.pdf"]
# Dockerfile from https://hub.docker.com/r/rocker/tidyverse/dockerfile  

FROM rocker/rstudio:devel

RUN apt-get update -qq && apt-get -y --no-install-recommends install \
  libxml2-dev \
  libcairo2-dev \
  libsqlite-dev \
  libmariadbd-dev \
  libmariadb-client-lgpl-dev \
  libpq-dev \
  libssh2-1-dev \
  && install2.r --error \
    --deps TRUE \
    tidyverse \
    dplyr \
    devtools \
    formatR \
    remotes \
    selectr \
    BiocManager

#----------------------------------------------------------------------------------------
## Notes: Above install2.r uses --deps TRUE to get Suggests dependencies as well,
## dplyr and ggplot are already part of tidyverse, but listed explicitly to get their (many) suggested dependencies.
## In addition to the the title 'tidyverse' packages, devtools is included for package development.
## RStudio wants formatR for rmarkdown, even though it's not suggested.
## remotes included for installation from heterogenous sources including git/svn, local, url, and specific cran versions

#----------------------------------------------------------------------------------------
# AFTER BUILDING FROM THIS DOCKERFILE AND RUNNING THE DOCKER CONTAINER, installed tidycensus package in R by doing the following:
# --> on command line (see https://philmikejones.me/tutorials/2018-08-29-install-sf-ubuntu/):
# sudo apt install -y libudunits2-0 libudunits2-dev
# sudo apt install -y libgdal-dev
# --> in R:
# install.packages("tidycensus")

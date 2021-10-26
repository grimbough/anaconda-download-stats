FROM rocker/tidyverse:4.1

RUN Rscript \
    -e 'source("https://raw.githubusercontent.com/apache/arrow/master/r/R/install-arrow.R")' \
    -e 'install_arrow()'

RUN apt-get -y update && \
    apt-get -y install git-lfs && \
    rm -rf /var/lib/apt/lists/*
    
RUN git lfs install --skip-repo

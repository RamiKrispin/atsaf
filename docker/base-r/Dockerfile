FROM ubuntu:18.04

LABEL maintainer="Rami Krispin <rami.krispin@gmail.com>"

# Setting the R version
    ARG R_VERSION_MAJOR=4
    ARG R_VERSION_MINOR=1 
    ARG R_VERSION_PATCH=0 
    ENV CONFIGURE_OPTIONS="--with-cairo --with-jpeglib --enable-R-shlib --with-blas --with-lapack"
    ENV RENV_VERSION 0.9.3

    # Installing tzdata
    ARG DEBIAN_FRONTEND=noninteractive
    ENV TZ=UTC

    # Install dependencies
    RUN apt-get update && apt-get install -y --no-install-recommends \
        apt-utils\
        gfortran \
        git \
        g++ \
        psmisc \
        procps \
        python-setuptools \
        libreadline-dev \
        libx11-dev \
        libxt-dev \
        libpng-dev \
        libjpeg-dev \
        libcairo2-dev \
        libcurl4-openssl-dev \
        libssl-dev \
        libxml2-dev \
        libudunits2-dev \
        libgdal-dev \
        libbz2-dev \
        libzstd-dev \
        liblzma-dev \
        libpcre2-dev \
        locales \
        openjdk-8-jdk \
        screen \
        texinfo \
        texlive \
        texlive-fonts-extra \
        vim \
        wget \
        xvfb \
        tzdata \
        sudo\
        jq\
        curl\
        file \
        libapparmor1 \
        libclang-dev \
        libedit2 \
        lsb-release \
        multiarch-support \
        python-setuptools \
        libv8-dev \
        r-cran-rcpp \
        r-cran-inline \
    && rm -rf /var/lib/apt/lists/*


    # Setting the encoding to UTF-8
    RUN locale-gen en_US.UTF-8
    ENV LANG en_US.UTF-8
    ENV LANGUAGE en_US:en
    ENV LC_ALL en_US.UTF-8

    RUN apt-get update && apt-get install -y --no-install-recommends \
        libgit2-dev \
       libmagick++-dev \
    && rm -rf /var/lib/apt/lists/*
    

    # Install R
    RUN wget https://cran.rstudio.com/src/base/R-${R_VERSION_MAJOR}/R-${R_VERSION_MAJOR}.${R_VERSION_MINOR}.${R_VERSION_PATCH}.tar.gz && \
        tar zxvf R-${R_VERSION_MAJOR}.${R_VERSION_MINOR}.${R_VERSION_PATCH}.tar.gz && \
        rm R-${R_VERSION_MAJOR}.${R_VERSION_MINOR}.${R_VERSION_PATCH}.tar.gz

    WORKDIR /R-${R_VERSION_MAJOR}.${R_VERSION_MINOR}.${R_VERSION_PATCH}

    RUN ./configure ${CONFIGURE_OPTIONS} && \
        make && \
        make install

    # Updating the git version
    RUN apt-get update && \
        apt-get -y install sudo 

    RUN sudo apt-get install software-properties-common -y
    RUN sudo add-apt-repository ppa:git-core/ppa && \
        sudo apt-get update -y && \
        sudo apt-get install git -y

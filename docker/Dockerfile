# Pulling Rocker image with RStudio and R version 4.2
FROM rocker/rstudio:4.2

# Setting environment variables
ARG CONDA_ENV=atsaf
ENV CONDA_ENV=$CONDA_ENV

ARG PYTHON_VER=3.10
ENV PYTHON_VER=$PYTHON_VER

ARG QUARTO_VERSION=1.1.149
ENV QUARTO_VERSION=$QUARTO_VERSION
# Disabling the authentication step
ENV USER="rstudio"
CMD ["/usr/lib/rstudio-server/bin/rserver", "--server-daemonize", "0", "--auth-none", "1"]

# Copy files
RUN mkdir packages
COPY install_dependencies.sh packages/
COPY install_packages.R packages/
COPY install_python.R packages/
COPY packages.json packages/

# Install jq to parse json files
RUN bash packages/install_dependencies.sh $QUARTO_VERSION

EXPOSE 8787

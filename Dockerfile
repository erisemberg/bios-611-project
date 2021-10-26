FROM rocker/verse
RUN R -e "install.packages(\"shiny\")"
RUN R -e "install.packages(\"dplyr\")"
RUN R -e "install.packages(\"tidyverse\")"
RUN R -e "install.packages(\"ggplot2\")"
RUN R -e "install.packages(\"plotly\")"
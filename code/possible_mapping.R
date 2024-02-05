install.packages(c("tidycensus", "wk", "classInt", "s2", "sf", "tigris", "units"))
library(c(tidycensus, wk, classInt, s2, sf, tigris, units))
library(tidyverse)
library(readr)

places <- read_csv("work/source_data/places_nomissing.csv", locale = locale(encoding = "latin1"))


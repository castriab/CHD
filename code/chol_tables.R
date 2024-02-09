library(knitr)
library(tidyverse)
library(readr)
library(dplyr)
library(ggplot2)
library(scales)
library(kableExtra)

places <- read_csv("source_data/places_nomissing.csv", locale = locale(encoding = "latin1"))

# find highest cholesterol screening census tracts and make a df with that information
sorted_data <- places[order(-places$CHOLSCREEN), ]
highest_counties <- head(sorted_data, 7)
highest_counties_list <- highest_counties$CountyName
highest_chol_list <- highest_counties$CHOLSCREEN
highest_census_list <- highest_counties$LocationID

highest_counties <- data.frame(
  County = highest_counties_list,
  Census_Tract = highest_census_list,
  Cholesterol_Screening = highest_chol_list
)

# find lowest cholesterol screening census tracts and make a df with that information
sorted_data <- places[order(places$CHOLSCREEN), ]
lowest_counties <- head(sorted_data, 7)
lowest_counties_list <- lowest_counties$CountyName
lowest_chol_list <- lowest_counties$CHOLSCREEN
lowest_census_list <- lowest_counties$LocationID

lowest_counties <- data.frame(
  County = lowest_counties_list,
  Census_Tract = lowest_census_list,
  Cholesterol_Screening = lowest_chol_list
)

# create nice looking tables with the highest and lowest cholesterol screening census tracts information
top_table <- highest_counties %>%
  kable("html") %>%
  kable_styling(full_width = FALSE) %>%
  add_header_above(c("Highest 5 Census Tracts by Cholesterol Screening Prevalence (%)" = 3), align = "center") 
print(top_table)

low_table <- lowest_counties %>%
  kable("html") %>%
  kable_styling(full_width = FALSE) %>%
  add_header_above(c("Lowest 5 Census Tracts by Cholesterol Screening Prevalence (%)" = 3), align = "center") 
print(low_table)
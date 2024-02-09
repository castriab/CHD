library(knitr)
library(tidyverse)
library(readr)
library(dplyr)
library(ggplot2)
library(scales)
library(kableExtra)

places <- read_csv("work/source_data/places_nomissing.csv", locale = locale(encoding = "latin1"))

# find highest smoking census tracts and make a df with that information
sorted_data <- places[order(-places$CSMOKING), ]
highest_counties <- head(sorted_data, 5)
highest_counties_list <- highest_counties$CountyName
highest_smoking_list <- highest_counties$CSMOKING
highest_census_list <- highest_counties$LocationID

highest_counties <- data.frame(
  County = highest_counties_list,
  Census_Tract = highest_census_list,
  Smoking = highest_smoking_list
)

# find lowest smoking census tracts and make a df with that information
sorted_data <- places[order(places$CSMOKING), ]
lowest_counties <- head(sorted_data, 5)
lowest_counties_list <- lowest_counties$CountyName
lowest_smoking_list <- lowest_counties$CSMOKING
lowest_census_list <- lowest_counties$LocationID

lowest_counties <- data.frame(
  County = lowest_counties_list,
  Census_Tract = lowest_census_list,
  Smoking = lowest_smoking_list
)

# create nice looking tables with the highest and lowest smoking census tracts information
top_table <- highest_counties %>%
  kable("html") %>%
  kable_styling(full_width = FALSE) %>%
  add_header_above(c("Highest 5 Census Tracts by Current Smoking Prevalence (%)" = 3), align = "center") 
print(top_table)

low_table <- lowest_counties %>%
  kable("html") %>%
  kable_styling(full_width = FALSE) %>%
  add_header_above(c("Lowest 5 Census Tracts by Current Smoking  Prevalence (%)" = 3), align = "center") 
print(low_table)
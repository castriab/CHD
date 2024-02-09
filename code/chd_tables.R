library(knitr)
library(tidyverse)
library(readr)
library(dplyr)
library(ggplot2)
library(scales)
library(kableExtra)

places <- read_csv("source_data/places_nomissing.csv", locale = locale(encoding = "latin1"))

# find highest CHD census tracts and make a df 
sorted_data <- places[order(-places$CHD), ]
highest_counties <- head(sorted_data, 5)
highest_counties_list <- highest_counties$CountyName
highest_CHD_list <- highest_counties$CHD
highest_census_list <- highest_counties$LocationID

highest_counties <- data.frame(
  County = highest_counties_list,
  Census_Tract = highest_census_list,
  CHD = highest_CHD_list
)

# find lowest CHD census tracts and make a df with that information
sorted_data <- places[order(places$CHD), ]
lowest_counties <- head(sorted_data, 5)
lowest_counties_list <- lowest_counties$CountyName
lowest_CHD_list <- lowest_counties$CHD
lowest_census_list <- lowest_counties$LocationID

lowest_counties <- data.frame(
  County = lowest_counties_list,
  Census_Tract = lowest_census_list,
  CHD = lowest_CHD_list
)

# create tables with the highest and lowest CHD census tracts information
top_table <- highest_counties %>%
  kable("html") %>%
  kable_styling(full_width = FALSE) %>%
  add_header_above(c("Highest 5 Census Tracts by CHD Prevalence (%)" = 3), 
                   align = "center") 
print(top_table)

low_table <- lowest_counties %>%
  kable("html") %>%
  kable_styling(full_width = FALSE) %>%
  add_header_above(c("Lowest 5 Census Tracts by CHD Prevalence (%)" = 3), align = "center")  
print(low_table)
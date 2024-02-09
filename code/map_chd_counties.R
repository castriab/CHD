library(tidyverse)
library(readr)
library(dplyr)
library(ggplot2)
library(grid)
library(maps)
library(ggthemes)
library(scales)
library(mapproj)

places <- read_csv("source_data/places_nomissing.csv", 
                   locale = locale(encoding = "latin1"))
nc_map <- tbl_df(map_data("county", region = "north carolina"))

places$CountyName <- tolower(places$CountyName)

# Find average of CHD
places_avg <- places %>%
  group_by(CountyName) %>%
  summarise(avg_CHD = mean(CHD, na.rm = TRUE))

# Join the average CHD values to the map data
mapdata <- left_join(nc_map, places_avg, by = c("subregion" = "CountyName"))

# find highest CHD census tracts
sorted_data <- places[order(-places$CHD), ]
highest_counties <- head(sorted_data, 5)
highest_counties_list <- highest_counties$CountyName
highest_counties <- highest_counties_list

# find lowest CHD census tracts
sorted_data <- places[order(places$CHD), ]
lowest_counties <- head(sorted_data, 5)
lowest_counties_list <- lowest_counties$CountyName
lowest_counties <- lowest_counties_list

# Filter the map data for the selected counties
highest_mapdata <- mapdata %>%
  filter(subregion %in% highest_counties) %>%
  distinct(subregion, .keep_all = TRUE)

lowest_mapdata <- mapdata %>%
  filter(subregion %in% lowest_counties) %>%
  distinct(subregion, .keep_all = TRUE)


# Plot the map with average CHD values and points for selected counties
ggplot(data = mapdata) +
  geom_polygon(aes(x = long, y = lat, group = group, fill = avg_CHD),
               color = "black") +
  geom_point(data = highest_mapdata,
             aes(x = long, y = lat, color = "Highest"),
             size = 2, show.legend = TRUE) +  
  geom_point(data = lowest_mapdata,
             aes(x = long, y = lat, color = "Lowest"), 
             size = 2, show.legend = TRUE) +  
  scale_color_brewer(name = "Average CHD", direction = -1) +
  coord_map("polyconic") +
  theme_map() +
  theme(legend.position = "right") +
  theme(plot.title = element_text(hjust = 0.5))+
  labs(
    fill = "CHD Prevalence (%)",  # Legend label for fill scale",
    title = "Average Coronary Heart Disease Prevalence by County") +
  scale_color_manual(name='Census Tracts with \nHighest/Lowest Prevalences',
                     breaks=c('Highest', 'Lowest'),
                     values=c('Highest'='red2', 'Lowest'='lightgreen')) +
theme(legend.title=element_text(size=10),
      legend.text=element_text(size=10)) 

ggsave(filename = "figures/nc_chd_prevalence_map.png", 
       width = 6,  
       height = 4, 
       units = "in")  

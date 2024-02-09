library(tidyverse)
library(readr)
library(dplyr)
library(ggplot2)
library(grid)
library(maps)
library(ggthemes)
library(scales)

places <- read_csv("source_data/places_nomissing.csv", locale = locale(encoding = "latin1"))
nc_map <- tbl_df(map_data("county", region = "north carolina"))

places$CountyName <- tolower(places$CountyName)

mapdata_full <- merge(nc_map, places, by.x = "subregion", by.y = "CountyName")

# Find average of current smoking
places_avg <- places %>%
  group_by(CountyName) %>%
  summarise(avg_smoking = mean(CSMOKING, na.rm = TRUE))

# Join the average current smoking values to the map data
mapdata <- left_join(nc_map, places_avg, by = c("subregion" = "CountyName"))

# find highest current smoking census tracts
sorted_data <- places[order(-places$CSMOKING), ]
highest_counties <- head(sorted_data, 7)
highest_counties_list <- highest_counties$CountyName
highest_counties <- highest_counties_list

highest_mapdata <- mapdata %>%
  filter(subregion %in% highest_counties)

# find lowest current smoking census tracts
sorted_data <- places[order(places$CSMOKING), ]
lowest_counties <- head(sorted_data, 9)
lowest_counties_list <- lowest_counties$CountyName
lowest_counties <- lowest_counties_list

# Filter the map data for the selected counties
highest_mapdata <- mapdata %>%
  filter(subregion %in% highest_counties) %>%
  distinct(subregion, .keep_all = TRUE)

lowest_mapdata <- mapdata %>%
  filter(subregion %in% lowest_counties) %>%
  distinct(subregion, .keep_all = TRUE)


# Plot the map with average current smoking values and points for selected counties
ggplot(data = mapdata) +
  geom_polygon(aes(x = long, y = lat, group = group, fill = avg_smoking),
               color = "black") +
  geom_point(data = highest_mapdata,
             aes(x = long, y = lat, color = "Highest"),
             size = 2, show.legend = TRUE) +  
  geom_point(data = lowest_mapdata,
             aes(x = long, y = lat, color = "Lowest"), 
             size = 2, show.legend = TRUE) +  
  scale_color_brewer(name = "Average Smoking", direction = -1) +
  coord_map("polyconic") +
  theme_map() +
  theme(legend.position = "right") +
  theme(plot.title = element_text(hjust = 0.5))+
  labs(
    fill = "Current Smoking Prevalence (%)",  # Legend label for fill scale",
    title = "Average Current Smoking Prevalence by County") +
  scale_color_manual(name='Census Tracts with \nHighest/Lowest Prevalences',
                     breaks=c('Highest', 'Lowest'),
                     values=c('Highest'='red2', 'Lowest'='lightgreen')) +
  theme(legend.title=element_text(size=10),
        legend.text=element_text(size=10)) 

ggsave(filename = "figures/nc_smoking_map.png", 
       width = 10,  
       height = 6, 
       units = "in")  

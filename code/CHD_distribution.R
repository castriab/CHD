library(tidyverse)
library(readr)
library(ggplot2)

places <- read_csv("source_data/places_nomissing.csv", locale = locale(encoding = "latin1"))


# Create a histogram
ggplot(places, aes(x = CHD)) +
  geom_histogram(binwidth = 1, fill = "#3498db", color = "#2c3e50", alpha = 0.7) +
  theme_minimal() +
  labs(
    title = "Distribution of Coronary Heart Disease Prevalence in North Carolina",
    subtitle = "N = 2153",
    x = "CHD Prevalence (%)",
    y = "Frequency"
  ) +
  theme(
    text = element_text(size = 12),
    plot.title = element_text(size = 14, face = "bold"),  # Adjusted font size
    plot.subtitle = element_text(size = 12),
    axis.title = element_text(size = 14),
    axis.text = element_text(size = 12),
  )

ggsave(filename = "figures/CHD_distribution.png", 
       width = 10,  
       height = 8, 
       units = "in")  
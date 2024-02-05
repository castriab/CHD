library(readr)
library(ggplot2)
library(dplyr)
library(patchwork)

# Extract predictor variables (assuming they are numeric)
predictor_vars <- select_if(places, is.numeric)%>%
  select(-LocationID, -TotalPopulation)

# Create a list to store the plots
plots_list <- list()

# Loop through predictor variables and create box plots
for (col in colnames(predictor_vars)) {
  
  # Create box plot
  box_plot <- ggplot(places, aes(x = 1, y = places[[col]])) +
    geom_boxplot(fill = "#3498db", color = "#2c3e50", alpha = 0.7) +
    labs(
      title = paste("Box Plot of", col),
      y = col
    ) +
    theme_minimal()
  
  # Add descriptive statistics to the plot
  box_plot <- box_plot +
    geom_text(
      aes(label = paste("Mean:", round(mean(places[[col]]), 2),
                        "\nSD:", round(sd(places[[col]]), 2),
                        "\nNobs:", length(places[[col]]))),
      x = 1.5, y = mean(places[[col]]),
      vjust = -1, hjust = 0,
      size = 3,
      color = "#e74c3c"
    )
  
  # Store the plot in the list
  plots_list[[col]] <- box_plot
}

# Arrange and print the plots
plots_list_patchwork <- wrap_plots(plots_list, ncol = 3)
print(plots_list_patchwork)


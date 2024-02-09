library(tidyverse)
library(dplyr)
library(png)
library(corrplot)

places <- read_csv("work/source_data/places_nomissing.csv", locale = locale(encoding = "latin1"))

selected_columns <- places %>%
  select(CHD, BINGE, CSMOKING, LPA, SLEEP, CERVICAL, CHOLSCREEN, ACCESS2, COLON_SCREEN, MAMMOUSE, COREM, COREW, BPMED, DENTAL, CHECKUP)

colnames(selected_columns) <- c('CHD', "Binge Drinking", "Smoking", "Physical Inactivity", "Sleep", 
                                "Cervical Screening", "Cholesterol Screening", "Health Insurance", "Colonoscopy", 
                                "Mammography", "Men Preventative", "Women Preventative", "BP Medication",
                                "Dental Visit", "Checkup Visit")
corr <- round(cor(selected_columns), 1)

png("work/figures/correlation_matrix.png", width=680, height=680)
corrplot(corr, type = "lower", tl.cex = 1.5)
dev.off()
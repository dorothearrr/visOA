# bonus: OpenAPC

# Step 1: load packages

#install.packages("readr")
#install.packages("dplyr")
#install.packages("ggplot2")
library(readr)
library(dplyr)
library(ggplot2)



# Step 2: loading the data from GitHub
DF <- read_csv("https://raw.githubusercontent.com/OpenAPC/openapc-de/master/data/apc_de.csv")

str(DF)

HU_data <- filter(DF, institution == "HU Berlin")



# Step 3: inspecting the data
table(HU_data$period)
table(HU_data$publisher)



# Step 4: analyse the results
summary(HU_data$euro)

ggplot(HU_data, aes(x = euro)) +
  geom_histogram(bins = 50)

HU_data %>%
  group_by(period) %>%
  summarise(mean = mean(euro),
            min = min(euro),
            max = max(euro))

ggplot(HU_data, aes(x = period, y = euro, group = period)) +
  geom_boxplot() +
  geom_point(position = "jitter")

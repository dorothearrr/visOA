# bonus: OpenAPC

# Step 1: load packages

# readr for reading tabular data
# dplyr for data manipulation
# ggplot2 for data visualization
# If necessary, install the packages before loading them.

#install.packages("readr")
#install.packages("dplyr")
#install.packages("ggplot2")
library(readr)
library(dplyr)
library(ggplot2)



# Step 2: loading the data from GitHub

# To download data from GitHub, we pass the URL (of the "raw" data) to the function read_csv. We store the results in DF and inspect the structure of the data frame.
# Next, we filter rows where *institution* hast the value "HU Belrin" and store the results in HU_data.

# Question:
# What information does the data set provide?
# The OpenAPC provides information on fees paid for Open Access journal articles. Each row corresponds to an article. Information on the institution paying the fee, the year the fee was paid, the amount paid (in EUR), the journal the article is published in etc. is included.

DF <- read_csv("https://raw.githubusercontent.com/OpenAPC/openapc-de/master/data/apc_de.csv")

str(DF)

HU_data <- filter(DF, institution == "HU Berlin")



# Step 3: inspecting the data

# Question: Use table to look at frequency distribution tables of period and publisher. What years does the data set cover? What publishers are mentioned most?
# The data set covers the years 2018 - 2021.
# The publisher mentioned most is Informa UK Limited.

table(HU_data$period)
table(HU_data$publisher)



# Step 4: analyse the results

# The function summary is an easy way to get summary statistics of a numerical variable: it returns the minimum and maximum values, median, mean and the 1st and 3rd quartile.

# Question: Use summary to look at summary statistics of *euro*. What do you notice about the distribution of fees?
# The fees range from 265.2 to 3962.7 EUR.
# On average, 1280.7 EUR were paid per article.

summary(HU_data$euro)

# A great way of exploring distributions visually are Histograms. Below, we use the ggplot2 geometry geom_histogram, and set the number of bins to 50.

# Question: Look at the histogram of euro. What do you notice about the distribution of fees?
# There is a bimodal distribution, with the two peaks at approximately 700 and 2000 EUR, and only few values above that.

ggplot(HU_data, aes(x = euro)) +
  geom_histogram(bins = 50)

# We can also calculate summary statistics for groups within the data. Below, we first group the data by period. Then, we pass the results to summarise, a dplyr funtion that lets you summarise all observations in a group by a function you choose. Here, we use the funtions mean, min and max.

# Question: Look at the grouped summary statistics of euro. What do you notice?
# The mean and maximum fees have increased continually from 2018 - 2020.

HU_data %>%
  group_by(period) %>%
  summarise(mean = mean(euro),
            min = min(euro),
            max = max(euro))

# Another approach to visualizing distributions are Histograms. Below, we create a boxplot of euro by period. We layer the ggplot2 geometries geom_boxplot and geom_point (with position set to jitter to avoid overlapping points).

ggplot(HU_data, aes(x = period, y = euro, group = period)) +
  geom_boxplot() +
  geom_point(position = "jitter")

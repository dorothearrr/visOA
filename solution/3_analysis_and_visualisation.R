# analysis and visualisation

# Step 1: load packages

# dplyr for data manipulation
# ggplot2 for data visualization
# forcats for working with categorical variables
# If necessary, install the packages before loading them.

#install.packages("dplyr")
#install.packages("ggplot2")
#install.packages("forcats")
library(dplyr)
library(ggplot2)
library(forcats)



# Step 2: loading and preparing the data

# First, we import the metadata we retrieved from crossref and Unpaywall. We use the function read.csv, specify that the colum X should be interpreted as row names, and store the results in the objects DF_crossref and DF_Unpaywall.
# We can combine both data sets by joining them. Join operations combine two data frames by a shared column, following specific rules. The package dplyr includes several join operations.
# In our case, both data frames share the DOIs of the documents we are analysing, and they hold information on the same set of documents. Therefore, we can use the function left_join, and specify that we want to join the two data frames by the column DOIs.

DF_crossref <- read.csv("./data/crossref_metadata.csv", row.names = "X")
DF_Unpaywall <- read.csv("./data/Unpaywall_metadata.csv", row.names = "X")

# What do you think, why are DOIs great for joining metadata on publications?
DF <- left_join(DF_crossref, DF_Unpaywall, by = "DOIs")



# Step 3: inspecting the data

# Next, we inspect the results. The functions str, head, and table are very useful to get an overview of a data frame:
# str returns a description of the structure of an object, and
# table returns a frequency distribution of the variables in one or more column(s).

# What does str tell you about the structure of the data frame?
str(DF)

# Use table to look at frequency distribution tables of publication_year and resource_type. Do you notice any issues with the data we might have to adress before we proceed?
table(DF$publication_year)
table(DF$resource_type)



# Step 4: cleaning the data

# The package dplyr includes several functions for manipulating data. For example, we can filter out rows where the column publication_year contains a value that are larger than 2020 (publication_year <= 2020), and overwrite DF with the new result. If we look at the frequency distribution table of publication_year, we see that we have sucessfully removed documents with the publication years 2021 and 2022.

DF <- filter(DF, publication_year <= 2020)
table(DF$publication_year)

# We want to restrict our analysis to journal articles and articles published in proceedings. We can do this by specifying two conditions in filter, and combine them with the or-operator "|". This will return all rows where resource_type is either journal-article or proceedings-article.

DF <- filter(DF, resource_type == "journal-article" | resource_type == "proceedings-article")
table(DF$resource_type)

# Now that we have cleaned the data, we can check for duplicates. We can do this by passing the DOIs to duplicated and the result to sum. duplicated returns a Boolean vector with the same length as the input, where TRUE means that a value is duplicated and FALSE means it is not. Most R functions interpret TRUE as 1 and FALSE as 0. Therefore, we can count the number of TRUE values in the vector (= the number of duplicated DOIs) by calling sum. In this example, there are no duplicate DOIs.

sum(duplicated(DF$DOIs))



# Step 5: Analyze the results

# dplyr functions are also very useful for analysing data.
# For example, you can use count to count the frequency of variables in a column, exactly like table. The advantage of count is that you can pass the output directly to a new dplyr function using the pipe operator "%>%". Below, we pass the output of *count* to mutate, a function that lets you create a new column based on other columns. We create a new column *percent* by dividing n (the output column of count) by the *sum* of n, multiplied by 100.

# How many publications are (not) Open Access?
DF %>%
  count(is_oa) %>%
  mutate(percent = n / sum(n) * 100)

# Building on this, we can calculate frequency distributions and percentages by publication year. All we have to do is pass the data through group_by first. group_by groups a column by its values and lets you treat each group separately.

# From the results, do you suspect a trend in the data?
DF %>%
  group_by(publication_year) %>%
  count(is_oa) %>%
  mutate(percent = n / sum(n) * 100)

# We can try to quantitify the trends in we observed by fitting linear regression models. Here, we fit two models using the funtion *lm*: one for publication rates of Open Access publications, and one for non-OA publication rates. (lm uses the leas-squares method)

# First, we prepare our data by filtering for "is_oa == FALSE", grouping by publication_year and counting the cases. We then pass this data and the formula. We also specify the formula, which follows the pattern "dependent variable ~ independent variable". Here, n is our dependent variable, which we expect to change depending on *publication_year*. We store the results in lm_not_oa.

# Using summary, we can access some summary statistics of lm_not_oa:
# coef: The coefficient indicated the slope of the linear model.
# r.squared: R squared is a goodness-of-fit measure that indicates how much of the variance in the dependent variable can be explained by the independent variable.

# Below, we can see that the coefficient for lm_ot_oa is ca. 212 non-OA publications per year. R squared indicates that the linear model does not fit the data very well. This makes sense, considering non-OA publication rates increased until 2018 and decreased since.

lm_not_oa <- DF %>%
  filter(is_oa == FALSE) %>%
  group_by(publication_year) %>%
  count(is_oa)
lm_not_oa <- lm(data = lm_not_oa, formula = n ~ publication_year)
summary(lm_not_oa)$coef
summary(lm_not_oa)$r.squared

# Repeat the procedure for Open Access publications (setting *"is_oa == TRUE"*) and compare the results. What do you notice?
lm_oa <- DF %>%
  filter(is_oa == TRUE) %>%
  group_by(publication_year) %>%
  count(is_oa)
lm_oa <- lm(data = lm_oa, formula = n ~ publication_year)
summary(lm_oa)$coef
summary(lm_oa)$r.squared



# Step 6: visualise the results

# dplyr works very well with ggplot2, an R package for data visualisation. You can manipulate your data with dplyr functions and pipe the results directly to the ggplot function.

# Within the ggplot function, you can assign your data frame columns to common aesthetic properties of graphs (within the aes argument), for example the x and y axis (required in most cases), color, or size. Then, you add a geometry (with + geom_...), which determines the type of plot that will be generated.

# We can use our previous example and create a bar chart (geom_col), where is_oa is shown on the x axis, and the frequency on the y axis.

# Do you like this plot? Why (not)?
DF %>%
  count(is_oa) %>%
  ggplot(aes(x = is_oa, y = n)) +
  geom_col()

# By adding information on publication years, we can look at the development of Open Access over the years. We map publication_year to the x axis, n to the y axis, and is_oa to the fill aesthetic (determining the color of the bar). Note that ggplot2 automatically generates a legend! This example creates a stacked bar chart where, the segments are stacked on top of each other.

DF %>%
  group_by(publication_year) %>%
  count(is_oa) %>%
  ggplot(aes(x = publication_year, y = n, fill = is_oa)) +
  geom_col()

# If we want to establish a common baseline for all bars, we can adjust the position in geom_col and set it to dodge. This will plot the bars side by side, but still grouped together by publication year.

DF %>%
  group_by(publication_year) %>%
  count(is_oa) %>%
  ggplot(aes(x = publication_year, y = n, fill = is_oa)) +
  geom_col(position = "dodge")

# position is also very useful if you want to show proportions. If you set *position* to fill, the bars will be plotted stacked on top of each other, but the height of the bars will be normalised. As a result, the full length of the stacked bars will correspond to 100 %, and each segment will be plotted proportionally.

DF %>%
  group_by(publication_year) %>%
  count(is_oa) %>%
  ggplot(aes(x = publication_year, y = n, fill = is_oa)) +
  geom_col(position = "fill")



# Step 7: going beyond...

# With ggplot2 you can...
# You can stack multipe geometries (here: geom_point and geom_line; geom_area and geom_hline)
# You can vary how variables are displayed (here: total or cumulative)
# You can change the color palette and the order of the segments
# You can change how axis are displayed
# You can change labels (here: axis and legend)
# You can change the theme (use predefined themes or build your own)

DF %>%
  group_by(publication_year) %>%
  count(oa_status) %>%
  ggplot(aes(x = publication_year, y = n, color = oa_status)) +
  geom_point(size = 3, alpha = 0.7) +
  geom_line(size = 1.5, alpha = 0.7) +
  scale_color_manual(values = c("#917013", "grey50", "#e3ac10", "#308a17", "#c4273f")) +
  scale_x_continuous(expand = c(0,0)) +
  labs(x = "publication year", y = "publication output", color = "OA status") +
  theme_linedraw() +
  theme(panel.grid = element_blank())

DF %>%
  group_by(publication_year) %>%
  count(oa_status) %>%
  ggplot(aes(x = publication_year, y = cumsum(n), color = oa_status)) +
  geom_point(size = 3, alpha = 0.7) +
  geom_line(size = 1.5, alpha = 0.7) +
  scale_color_manual(values = c("#917013", "grey50", "#e3ac10", "#308a17", "#c4273f")) +
  scale_x_continuous(expand = c(0,0)) +
  labs(x = "publication year", y = "publication output", color = "OA status") +
  theme_linedraw() +
  theme(panel.grid = element_blank())

DF %>%
  group_by(publication_year) %>%
  count(oa_status) %>%
  mutate(oa_status = fct_relevel(oa_status, "closed", "hybrid", "bronze", "gold", "green")) %>%
  ggplot(aes(x = publication_year, y = n, fill = oa_status)) +
  geom_area(position = "fill", alpha = 0.8) +
  geom_hline(yintercept = 0.6, linetype = "dashed", color = "white", size = 2) +
  scale_fill_manual(values = c( "grey50", "#c4273f", "#917013", "#e3ac10", "#308a17")) +
  scale_x_continuous(expand = c(0,0)) +
  scale_y_continuous(expand = c(0,0), labels = scales::percent) +
  labs(x = "publication year", y = "publication output", color = "OA status") +
  theme_linedraw() +
  theme(panel.grid = element_blank())



# EXTRA: credit where credit is due

# Software has become an essential form of research output. Developers of research software carry out valuable work for the research community, and their contribution should be acknowledged in publications.
# If you want to know how to cite an R package, try the function citation: it returns a suggestion for citing a given package, as well as a BibTex entry you can copy and paste.

citation("base")
citation("jsonlite")
citation("roadoi")
citation("rcrossref")
citation("dplyr")
citation("ggplot2")
citation("forcats")

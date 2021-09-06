# analysis and visualisation

# Step 1: load packages
#install.packages("dplyr")
#install.packages("ggplot2")
#install.packages("forcats")
library(dplyr)
library(ggplot2)
library(forcats)



# Step 2: loading and preparing the data
DF_crossref <- read.csv("./data/crossref_metadata.csv", row.names = "X")
DF_Unpaywall <- read.csv("./data/Unpaywall_metadata.csv", row.names = "X")

DF <- left_join(DF_crossref, DF_Unpaywall, by = "DOIs")



# Step 3: inspecting the data
str(DF)

table(DF$publication_year)
table(DF$resource_type)



# Step 4: cleaning the data
DF <- filter(DF, publication_year <= 2020)
table(DF$publication_year)

DF <- filter(DF, resource_type == "journal-article" | resource_type == "proceedings-article")
table(DF$resource_type)

sum(duplicated(DF$DOIs))



# Step 5: 
DF %>%
  count(is_oa) %>%
  mutate(percent = n / sum(n) * 100)

DF %>%
  group_by(publication_year) %>%
  count(is_oa) %>%
  mutate(percent = n / sum(n) * 100)

lm_not_oa <- DF %>%
  filter(is_oa == FALSE) %>%
  group_by(publication_year) %>%
  count(is_oa)
lm_not_oa <- lm(data = lm_not_oa, formula = n ~ publication_year)
summary(lm_not_oa)$coef
summary(lm_not_oa)$r.squared

lm_oa <- DF %>%
  filter(is_oa == TRUE) %>%
  group_by(publication_year) %>%
  count(is_oa)
lm_oa <- lm(data = lm_oa, formula = n ~ publication_year)
summary(lm_oa)$coef
summary(lm_oa)$r.squared



# Step 6: visualise the results
DF %>%
  count(is_oa) %>%
  ggplot(aes(x = is_oa, y = n)) +
  geom_col()

DF %>%
  group_by(publication_year) %>%
  count(is_oa) %>%
  ggplot(aes(x = publication_year, y = n, fill = is_oa)) +
  geom_col()

DF %>%
  group_by(publication_year) %>%
  count(is_oa) %>%
  ggplot(aes(x = publication_year, y = n, fill = is_oa)) +
  geom_col(position = "dodge")

DF %>%
  group_by(publication_year) %>%
  count(is_oa) %>%
  ggplot(aes(x = publication_year, y = n, fill = is_oa)) +
  geom_col(position = "fill")



# Step 7: going beyond...
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
citation("base")
citation("jsonlite")
citation("roadoi")
citation("rcrossref")
citation("dplyr")
citation("ggplot2")
citation("forcats")

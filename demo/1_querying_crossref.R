# querying crossref


# Step 1: load packages
#install.packages("jsonlite")
#install.packages("purrr")
#install.packages("dplyr")
library(jsonlite)
library(purrr)
library(dplyr)



# Step 2: specify the query parameters
query <- "https://api.crossref.org/works?query.affiliation=humboldt+universit+berlin&filter=from-pub-date:2015-01-01"



# Step 3: politely using APIs
mailto <- "&mailto=jdoe@example.org"



# Step 4: exploring the results
results <- jsonlite::fromJSON(paste0(query, mailto))

results$message$items$DOI
results$message$items$published
results$message$items$type
results$message$items$author

results$message$`total-results`



# Step 5: retrieving all DOIs matching the query
# DO NOT RUN THIS!

#results <- fromJSON(paste0("https://api.crossref.org/works?query.affiliation=humboldt+universit+berlin&filter=from-pub-date:2015-01-01&cursor=", "*&mailto=janedoe@example.org"))

#DF <- data.frame(c(DOIs = list(results$message$items$DOI),
#                   publication_year = list(unlist(map(results$message$items$published$`date-parts`, 1))),
#                   resource_type = list(results$message$items$type),
#                   affiliation = paste(unique(unlist(lapply(results$message$items$author, function(x) x %>% select(affiliation)))), collapse = " _AND_ ")))

#next_cursor <- results$message$`next-cursor`

#while (nrow(DF) < results$message$`total-results`) {
#  results <- fromJSON(paste0("https://api.crossref.org/works?query.affiliation=humboldt+universit+berlin&filter=from-pub-date:2015-01-01&cursor=", next_cursor, "&mailto=janedoe@example.org"))
  
#  DF <- rbind(DF,  data.frame(c(DOIs = list(results$message$items$DOI),
#                                publication_year = list(unlist(map(results$message$items$published$`date-parts`, 1))),
#                                resource_type = list(results$message$items$type),
#                                affiliation = tryCatch({paste(unique(unlist(lapply(results$message$items$author, function(x) x %>% select(affiliation)))), collapse = " _AND_ ")},  error = function(e) {NA}))))
  
#  next_cursor <- results$message$`next-cursor`
#}



# EXERCISE: try the package rcrossref
#install.packages("rcrossref")
library(rcrossref)

DOI_sample <- read.csv("./data/DOI_sample.csv", row.names = "X")

DF_citations <- cr_citation_count(doi = DOI_sample$x)

# Have a look at the result.
# What is the average citation count of this sample?
# What publication has the highest citation count?
# Try to access that publication. Can you open and read it?

print(DF_citations)
summary(DF_citations$count)

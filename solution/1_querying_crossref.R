# querying crossref


# Step 1: load packages

# jsonlite for working with JSON
# purrr for working with vectors
# dplyr for data manipulation
# If necessary, install the packages before loading them.

#install.packages("jsonlite")
#install.packages("purrr")
#install.packages("dplyr")
library(jsonlite)
library(purrr)
library(dplyr)



# Step 2: specify the query parameters

# For our use case, we want to retrieve DOIs of publications published since 2015 from authors that are afiiliated with a specific organization (Humboldt-Universität zu Berlin).

# The crossref API is well documented (see here: https://github.com/CrossRef/rest-api-doc) and offers many functionalities.
# In the query URL we build, we first specify that we are interested in works.

# Crossref has not yet implemented organisation identifiers in the affiliation information (see the schema definition here: https://data.crossref.org/schemas/common4.4.2.xsd). Therefore, we have to rely on searching for name variants in the affiliation field. Here, we pass the term "humboldt+universit+berlin"to the query parameter query.affiliation. (For demonstration purposes, we use a very simple query and clean the data afterwards. To ensure that all publications from authors affiliated with an organization are found, multiple name variants should be used - see this example: https://github.com/tuub/oa-eval )

# We use the filter from-pub-date with the value 2015-01-01 to limit results to publications published sinc 2015.

# Below, the resulting query is stored in the object query.

query <- "https://api.crossref.org/works?query.affiliation=humboldt+universit+berlin&filter=from-pub-date:2015-01-01"



# Step 3: politely using APIs

# APIs offer valuable services to many people and organizations. Therefore, it is important to politely use APIs and not burden them with too many requests.  Some services regularly make data dumps available, so you might not even have to use the service's API.

# Some APIs specify polite use in their documentation, including crossref (see here: https://github.com/CrossRef/rest-api-doc#etiquette). To comply with the API etiquette, we will append the mailto parameter to the query. This allows crossref to contact us in case there are any issues with our query.

mailto <- "&mailto=jdoe@example.org"



# Step 4: exploring the results

# The crossref API returns results in JSON, a common data format. We concatenate the strings query and mailto and pass the new URL string to the function fromJSON. The function retrieves and converts results from JSON to R objects. We store the converted results in the object results.

results <- jsonlite::fromJSON(paste0(query, mailto))

# Information in JSON objects is stored similarly to nested lists with names. Therefore, we can access a specific piece of information by subsetting the results object using names. Here, we want to access DOIs, publication year, type and author information of publications matching the query. Notice that results are returned in different classes - two character vectors, one data frame, and a list of data frames.
# By default, crossref returns 20 items at a time.

results$message$items$DOI
results$message$items$published
results$message$items$type
results$message$items$author

# You can find out how many items match your query by accessing total-results - in this case, we have more than 51,000 matches!

results$message$`total-results`



# Step 5: retrieving all DOIs matching the query

# To retrieve the information on all matches, we have to iterate through the results, which by default are returned in sets of 20. For this purpose, crossref offers cursors. They work like this: to your first query, you add the cursor parameter with the value " \* ". Alongside the results, crossref returns a next-cursor field. You can use this value to access the next set of 20 items, and so on.

# We can implement this in R using a while loop, a useful form of iteration if you don't exactly know how long a sequence is. 

# In the example below, we first add "&cursor=\*" to the first of our query URLs, pass that URL to fromJSON, and store the result in results. Next, we extract the DOIs, publication year (since this is a data frame, extraction is a little more complex), resource type and affiliation (this case is also more complex and includes condition handling (http://adv-r.had.co.nz/Exceptions-Debugging.html#condition-handling)) and store them in a data frame. We store the next cursor in next_cursor.

# We then initiate a while loop that will repeat itself until a condition is met. Here, the loop is repeated until the number of rows (= items already retrieved) is no longer smaller than the total number of items matching the query. Within the loop, we will use rbind to add the new results to the data frame we previously created for storing DOIs, publication year and resource type.

# The result also includes affiliation information, which you could use to further narrow down your sample, for example by excluding publications that are affiliated with Charité Universitätsmedizin Berlin. In this workshop, we continue with the full dataset.

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

# rcrossref is an R package specifically for using the crossref API. Crossref holds a lot of metadata about various aspects of scholarly publication. For example, crossref offers citation counts for works, based on reference matching within its holdings. 
# The availability of this information depends on members choosing to add references upon metadata creation. Citation information is also less complete compared to other bibliometric databases. However, opening up citation information is a major issue in bibliometric research, and therefore will hopefully grow in the future.
# The function cr_citation_count works in a similar way to what we did above. The function takes a vector of dois, and returns a dataframe with citation counts provided by crossref.
# Below, we first install and load rcrossref. Then, we load a sample of 50 DOIs and retrieve citation counts from crossref.

# Have a look at the result.
# What is the average citation count of this sample?
# What publication has the highest citation count?
# Try to access that publication. Can you open and read it?

print(DF_citations)
summary(DF_citations$count)

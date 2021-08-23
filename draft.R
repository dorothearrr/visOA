library(jsonlite)
library(dplyr)
library(tidyr)
library(ggplot2)

base_query <- "https://api.crossref.org/works?query.affiliation="
name_variants <- list("humboldt+universit%C3%A4t+berlin", "humboldt+university+berlin", "hu+berlin")
mailto <- "&mailto=janedoe@example.org"

urls <- paste0(rep(base_query, 3), name_variants, rep(mailto, 3))
print(urls)
urls



results <- fromJSON(paste0(urls[1], "&cursor=*"))

DOIs_1 <- results$message$items$DOI
publication_year_1 <- unlist(map(results$message$items$published$`date-parts`, 1))
resource_type_1 <- results$message$items$type
next_cursor <- results$message$`next-cursor`

while (!is.null(next_cursor)) {
  results <- fromJSON(paste0(urls[1], "&cursor=", next_cursor))
  DOIs_1 <- append(DOIs_1, results$message$items$DOI)
  publication_year_1 <- append(publication_year_1, unlist(map(results$message$items$published$`date-parts`, 1)))
  resource_type_1 <- append(resource_type_1, results$message$items$type)
  next_cursor <- results$message$`next-cursor`
}

DOIs_1[10000]
length(DOIs_1)
length(publication_year_1)
length(resource_type_1)
sum(duplicated(DOIs_1))

save(DOIs_1, file = "./DOIs.rda")
save(publication_year_1, file = "./publication_year.rda")
save(resource_type_1, file = "./resource_type.rda")
load("DOIs.rda")
load("publication_year.rda")
load("resource_type.rda")

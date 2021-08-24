
### crossref

library(jsonlite)
library(purrr)

results <- fromJSON(paste0("https://api.crossref.org/works?query.affiliation=humboldt+universit+berlin&filter=from-pub-date:2015-01-01&cursor=", "*&mailto=janedoe@example.org"))

DF <- data.frame(c(DOIs = list(results$message$items$DOI),
             publication_year = list(unlist(map(results$message$items$published$`date-parts`, 1))),
             resource_type = list(results$message$items$type)))
next_cursor <- results$message$`next-cursor`


while (nrow(DF) < results$message$`total-results`) {
  results <- fromJSON(paste0("https://api.crossref.org/works?query.affiliation=humboldt+universit+berlin&filter=from-pub-date:2015-01-01&cursor=", next_cursor, "&mailto=jdoe@example.org"))
  DF <- rbind(DF, data.frame(c(DOIs = list(results$message$items$DOI),
                     publication_year = list(unlist(map(results$message$items$published$`date-parts`, 1))),
                     resource_type = list(results$message$items$type))))
  next_cursor <- results$message$`next-cursor`
  print(round(nrow(DF)/results$message$`total-results`*100, 2))
}

write.csv(DF, "crossref_metadata.csv")



### Unpaywall


DF <- read.csv("crossref_metadata.csv")

table(DF$publication_year)
table(DF$resource_type)

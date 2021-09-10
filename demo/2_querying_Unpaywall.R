# querying Unpaywall

# Step 1: load packages
#install.packages("jsonlite")
library(jsonlite)



# Step 2: loading crossref metadata
DF_crossref <- read.csv("./data/crossref_metadata.csv", row.names = "X")



# Step 3: build query URLs
URLs <- paste0("https://api.unpaywall.org/v2/", DF_crossref$DOIs, "?email=jdoe@example.org")



# Step 4: exploring the results
results <- fromJSON(URLs[1])

results$is_oa

results$oa_status




# retrieving Open Access information from Unpaywall
# DO NOT RUN THIS!
#DF_Unpaywall <- data.frame(c(DOIs = character(),
#                             is_oa = logical(),
#                             oa_status = character()))

#for (i in 1:nrow(DF_crossref)) {
#  results <- fromJSON(URLs[i])
#  DF_Unpaywall[i,1] <- DF_crossref[i,1]
#  DF_Unpaywall[i,2] <- results$is_oa
#  DF_Unpaywall[i,3] <- results$oa_status
#  }



# EXERCISE: try the package roadoi
#install.packages("roadoi")
library(roadoi)

results <- roadoi::oadoi_fetch(dois = DF_crossref[1:10,1], email = "jdoe@example.org")
names(results)

# Have a look at the columns is_oa and journal_is_oa.
# Can you imagine what the two variables represen?
# Why do the values diverge in some cases, but not in others?

results$is_oa
results$journal_is_oa

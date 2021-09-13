# querying Unpaywall

# Step 1: load packages

# jsonlite for working with JSON
# If necessary, install the packages before loading them.

#install.packages("jsonlite")
library(jsonlite)



# Step 2: loading crossref metadata

# First, we import the crossref metadata. We use the function read.csv, specify that the colum *X* should be interpreted as row names, and store the result in the object DF_crossref.

DF_crossref <- read.csv("./data/crossref_metadata.csv", row.names = "X")



# Step 3: build query URLs

# Unpaywall offers an API endpoint that returns metadata and information on Open Access for a given DOI (see here: https://unpaywall.org/products/api). We can build the query URLs by concatenating the base URL, the DOI column in DF_crossref, and your email adress (required).

URLs <- paste0("https://api.unpaywall.org/v2/", DF_crossref$DOIs, "?email=jdoe@example.org")



# Step 4: exploring the results

# Unpaywall aggregates information from several sources, and processes the results to generate information on various aspects of Open Access. The Unpaywall Data Format (see here: https://unpaywall.org/data-format) describes all properties the service makes available.

# Here, we are interested in:
# is_oa (A boolean indicating whether there is an OA copy of this resource.)
# oa_status*(The OA type of this resource: gold, hybrid, bronze, green or closed. See here: https://support.unpaywall.org/support/solutions/articles/44001777288-what-do-the-types-of-oa-status-green-gold-hybrid-and-bronze-mean- how Unpaywall assigns OA status.)

# Unpaywall also returns results in JSON, so we can follow a similar approach to crossref. Below, we retrieve and parste results for the first query URL using fromJSON. We can then access the is_oa and oa_status properties by subsetting.

results <- fromJSON(URLs[1])

results$is_oa

results$oa_status




# Step 5: retrieving Open Access information from Unpaywall
  
# To retrieve the data for all items, we first create an empty data frame with three columns (DOIs, is_oa and oa_status) for storing the results.
# We then initiate a for loop that will iterate through the numbers from 1 to the number of items in the data frame DF_crossref. These numbers, below represented by i, express which item in DF_crossref is currently being processed. This information is used to successively subset the list of URLs. Each URL is passed to fromJSON. Then, for each item is_oa and oa_status are extracted and stored in column 2 and 3 of DF_Unpaywall. The row is specified by i, so the rows in DF_crossref and DF_Unpaywall end up storing information on the same item in the same rows. The respective DOI is selected from DOI_crossref and stored in the 1st column.

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

# roadoi is an R package specifically for using the Unpaywall API. Its function oadoi_fetch works in a very similar way to what we did above. The function takes two arguments: a vector of dois, and an email adress. It returns a dataframe with information provided by Unpaywall.
# Below, we first install and load *roadoi*. Then, we retrieve information on the first 10 items from Unpaywall.

#install.packages("roadoi")
library(roadoi)

results <- roadoi::oadoi_fetch(dois = DF_crossref[1:10,1], email = "jdoe@example.org")
names(results)

# Have a look at the columns is_oa and journal_is_oa.
# Can you imagine what the two variables represen?
# Why do the values diverge in some cases, but not in others?

results$is_oa
results$journal_is_oa

# Example reading from the EURO Registry using rsdmx:

library(rsdmx)

# The standard list of rsdmx data providers:
# providers <- getSDMXServiceProviders()
# df_providers <- as.data.frame(providers)
# Conclusion: the Global Registry is not in the standard rsdmx list of service providers, so we calculate the REST url ourselves:


# reading a codelist from the registry:
url1 <- "https://registry.sdmx.org/ws/public/sdmxapi/rest/codelist/ESTAT/CL_ACTIVITY/latest"
codelist <- readSDMX(url1)
df <- as.data.frame(codelist)


# reading a dsd from the registry:
url2 <- "https://registry.sdmx.org/ws/public/sdmxapi/rest/datastructure/ESTAT/CPI/latest"
dsd <- readSDMX(url2)
dimensions <- slot(slot(dsd, "datastructures")[[1]], "Components")
df2 <- as.data.frame(dimensions)

# Example reading from the EURO Registry using rsdmx:

library(rsdmx)

# The standard list of rsdmx data providers:
# providers <- getSDMXServiceProviders()
# df_providers <- as.data.frame(providers)
# Conclusion: the Euro SDMX Registry is not in the standard rsdmx list of service providers, so we calculate the REST url ourselves:


# reading a codelist from the registry:
url1 <- "https://ec.europa.eu/tools/cspa_services_global/sdmxregistry/rest/codelist/ESTAT/CL_ACTIVITY/latest"
codelist <- readSDMX(url1) # SLOW: needs some time to access the registry! 
df <- as.data.frame(codelist)


# reading a dsd from the registry:
url2 <- "https://ec.europa.eu/tools/cspa_services_global/sdmxregistry/rest/datastructure/ESTAT/STSALL/latest"
dsd <- readSDMX(url2) # SLOW: needs some time to access the registry!
dimensions <- slot(slot(dsd, "datastructures")[[1]], "Components")
df2 <- as.data.frame(dimensions)

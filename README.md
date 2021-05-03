## validatesdmx

Data validation using SDMX metadata.

This R package extends the
[validate](https://cran.r-project.org/package=validate) package for data
validation. The aim of this package is to make it easier to use [SDMX](https://sdmx.org/) metadata, such as code list or field types with the validate package.

> The aim of `validatesdmx` is to make it possible to re-use internationally-agreed SDMX metadata, specified in SDMX registries or local DSD files, for data validation.


### SDMX, registries, and APIs

The Statistical Data and Metadata eXchange ([SDMX](https://sdmx.org)) standard is an ISO standard designed to facilitate the exchange or dissemination of [Official Statistics](https://en.wikipedia.org/wiki/Official_statistics#:~:text=Official%20statistics%20are%20statistics%20published,organizations%20as%20a%20public%20good.).
At the core it has a logical informational model describing the key characteristics of statistical data and metadata, which can be applied to any statistical domain.
Various data formats have been defined based on this information model, such as SDMX-[CSV](https://tools.ietf.org/html/rfc4180), SDMX-[JSON](https://www.json.org/json-en.html) format), and - by far the most widely known - SDMX-ML (data in [XML](https://www.w3.org/XML/)).
A key aspect of the SDMS standard is that one defines the metadata, including data structure, variables, and code lists beforehand in order to describe what data is shared or published.
This metadata is defined in a so-called *Data Structure Definition* file, which is an XML format.

In order to facilitate standardized data exchange, DSD files can be published
in central registries that can be accessed through a [REST
API](https://en.wikipedia.org/wiki/Representational_state_transfer), using a
standardized set of parameters.  Some important SDMX registries include the following.

- [Global SDMX Registry](https://registry.sdmx.org/): for global metadata, hosted by the SDMX consortium.
- [Eurostat SDMX Registry](https://webgate.ec.europa.eu/sdmxregistry/): for Eurostat-wide metadata, hosted by Eurostat.
- [IMF SDMX Central](https://sdmxcentral.imf.org/overview.html): Registry by the IMF. 

It is also possible for organizations to create their own (internal) SDMX
registry.

In addition there are several organisations that offer automated access to their dissemination database via an SDMX API, including access to the metadata:
- [ECB](https://sdw-wsrest.ecb.europa.eu/help/): access to the ECB SDMX web services
- [OECD SDMX access](https://data.oecd.org/api/): access to OECD statistics via [SDMX-JSON](https://data.oecd.org/api/sdmx-json-documentation/) or [SDMX-ML](https://data.oecd.org/api/sdmx-ml-documentation/).
- [ILOstat](https://www.ilo.org/sdmx/index.html): SDMX REST (2.1) API ([doc](https://www.ilo.org/ilostat-files/Documents/SDMX_User_Guide.pdf)) to [ILOstat](https://ilostat.ilo.org/) 
- [FAO SDMX access](http://api.data.fao.org/1.0/esb-rest/sdmx/introduction.html): access to data from the FAO 
- [Worldbank](https://datahelpdesk.worldbank.org/knowledgebase/articles/1886701-sdmx-api-queries): SDMX access to World Development indicators 
- [ISTAT](https://www.istat.it/it/metodi-e-strumenti/web-service-sdmx): access to data from the Italian statistical institute.


### Variety within standard implementations

Although the SDMX standard prescribes the set of parameters that need to be
present in an API that offers access to an SDMX registry, the actual name of
those parameters is not fixed. Moreover, depending on the registry an
organization may decide which elements of the API are exposed. For example, the
API standard defines methods to retrieve code lists from a DSD, but this
functionality may or may not be offered by an API instance. If it is not
offered, this means that client software needs to make assumptions and extract
code lists locally from a DSD file. Indeed, on a technical level the API of the
various institutes may differ considerably.
To make things worse not all SDMX services implement the same version of SDMX. 

As a consequence, it is not possible to create a generic client that works
out-of-the-box for every registry. Any client that accesses multiple SDMX registries
either needs to store API-specific information or make this user-configurable.

Considering the differences in APIs, there are two sources of variability
in API.

1. The order and naming of parameters and their values.
2. The extent to which the API fully covers functionality described in the standard.


**Ad 1.** This can be solved by creating maps between the different
representations of parameters.

**Ad 2.** This can be solved by creating a fall-back scenario where in stead
of asking the API to query a DSD, we download the whole DSD and extract the
information ourselves. Extra assumptions will probably be necessary.


As starting point for the 'generic' client the structural metadata part of the 
[SDMX API cheet sheet](https://raw.githubusercontent.com/sdmx-twg/sdmx-rest/master/v2_1/ws/rest/docs/rest_cheat_sheet.pdf) 
will be used.

### Design

From a user-perspective it is important to have an interface that 

a. hides details that are related to a specific SDMX DSD API
b. is extensible so that new APIs may be added.
c. has speedy performance and avoids unnecessary downloads

We therefore propose a reference class which looks roughly like this.

```
  class:   SDMXAPI
  private: 
     - API dependent information, such as base URL.
     - session information, downloaded data.
  public:
     - methods for getting DSD, code lists, etc.
```
Where all methods that ask an API to extract information from a DSD possibly
need API-specific fallback scenarios for incomplete APIs.










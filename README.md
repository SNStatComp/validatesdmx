## validatesdmx

Data validation using SDMX metadata.

This R package extends the
[validate](https://cran.r-project.org/package=validate) package for data
validation. The aim of this package is to make it easier to use [SDMX](https://sdmx.org/) metadata, such as code list or field types or field limits with the validate package.

> The aim of `validatesdmx` is to make it possible to re-use internationally-agreed SDMX metadata, specified in SDMX registries or local DSD files, for data validation.


### SDMX landscape

The Statistical Data and Metadata eXchange ([SDMX](https://sdmx.org)) standard is an ISO standard designed to facilitate the exchange or dissemination of [Official Statistics](https://en.wikipedia.org/wiki/Official_statistics#:~:text=Official%20statistics%20are%20statistics%20published,organizations%20as%20a%20public%20good.).
At the core it has a logical informational model describing the key characteristics of statistical data and metadata, which can be applied to any statistical domain.
Various data formats have been defined based on this information model, such as SDMX-[CSV](https://tools.ietf.org/html/rfc4180), SDMX-[JSON](https://www.json.org/json-en.html) format), and - by far the most widely known - SDMX-ML (data in [XML](https://www.w3.org/XML/)).
A key aspect of the SDMS standard is that one defines the metadata, including data structure, variables, and code lists beforehand in order to describe what data is shared or published.
This metadata is defined in an *SDMX registry* where data producers can download or query the necessary metadata. Alternatively metadata is distributed in a so-called *Data Structure Definition* file, which is usually an XML format.
Both types of modes should result in exactly the same metadata agreements. 

SDMX registries can be accessed through a [REST
API](https://en.wikipedia.org/wiki/Representational_state_transfer), using a
standardized set of parameters.  Some important SDMX registries are:

- [Global SDMX Registry](https://registry.sdmx.org/): for global metadata, hosted by the SDMX consortium. The central place for ESS-wide metadata. This registry hosts important statistical metadata such as for CPI/HICP, National Accounts (NA), Environmental accounting (SEEA), BOP, GFS, FDI and many more. Unfortunately not all ESS metadata is present in this registry.
- [Eurostat SDMX Registry](https://webgate.ec.europa.eu/sdmxregistry/): for Eurostat-wide metadata, hosted by Eurostat. This registry contains statistical metadata for all other official statistics in the ESS. [Documentation](https://ec.europa.eu/eurostat/web/sdmx-web-services/rest-sdmx-2.1)
- [IMF SDMX Central](https://sdmxcentral.imf.org/overview.html): Registry by the IMF. 
- [UNICEF](https://sdmx.data.unicef.org/): Registry by UNICEF

It is also possible for organizations to create their own (internal) SDMX registry. For the goal of reusing international metadata for data validation this is less of our interest as we cannot access these.

In addition there are several organisations that offer automated access to their dissemination database via an SDMX API, including access to the metadata:
- [ECB](https://sdw-wsrest.ecb.europa.eu/help/): access to the ECB SDMX web services
- [OECD](https://data.oecd.org/api/): access to OECD statistics via [SDMX-JSON](https://data.oecd.org/api/sdmx-json-documentation/) or [SDMX-ML](https://data.oecd.org/api/sdmx-ml-documentation/).
- [ILO](https://www.ilo.org/sdmx/index.html): SDMX REST (2.1) API ([doc](https://www.ilo.org/ilostat-files/Documents/SDMX_User_Guide.pdf)) to [ILOstat](https://ilostat.ilo.org/) 
- [FAO](http://api.data.fao.org/1.0/esb-rest/sdmx/introduction.html): access to data from the FAO 
- [Worldbank](https://datahelpdesk.worldbank.org/knowledgebase/articles/1886701-sdmx-api-queries): SDMX access to World Development indicators 
- [BIS](https://www.bis.org/statistics/sdmx_techspec.htm?accordion1=1&m=6%7C346%7C718): SDMX access to [BIS statistics](https://www.bis.org/statistics/index.htm)
- [ISTAT](https://www.istat.it/it/metodi-e-strumenti/web-service-sdmx): access to data from the Italian statistical institute.

Unfortunately the SDMX consortium does not maintain a list of active SDMX endpoints. The [rsdmx R package](https://cran.r-project.org/package=rsdmx) maintains such a list based on an earlier inventory of Data Sources. Inspecting the [endpoint links](https://github.com/opensdmx/rsdmx/wiki#success_stories) shows that quite some are not active.


### Variety within standard implementations

Ideally all SDMX providers would have implemented SDMX in a coordinated way
so that a client looking for SDMX metadata to validate its data before sending
could query the respective registry using one and the same API.
The latest version of the API is 2.1 which is described excellent way in the 
[SDMX API cheet sheet](https://raw.githubusercontent.com/sdmx-twg/sdmx-rest/master/v2_1/ws/rest/docs/rest_cheat_sheet.pdf).
Although this standard prescribes the set of parameters that need to be
present in an API that offers access to an SDMX registry or dissemination database, the actual values of those parameters is not fixed.
Moreover, depending on the registry an
organization may decide which elements of the API are exposed. For example, the
API standard defines methods to retrieve code lists from a DSD, but this
functionality may or may not be offered by an API instance. If it is not
offered, this means that client software needs to make assumptions and extract
code lists locally from a DSD file. Indeed, on a technical level the API of the
various institutes may differ considerably.
To make things worse not all SDMX services implement the same version of SDMX. 

However for the aim of our exercise (see above) we don't need the full metadata of every single metadata ingredient of the ESS. Inspection of the most common validation rules by Eurostat [ref: Vincent eUROSTAT] and in an [earlier project](https://github.com/SNStatComp/GenericValidationRules) shows that certain elements are more imortant than others for executing validation based on SDMX metadata.
The most important elements that we will focus on are 
- code list checks
- field type and range checks

Our goal is to retrieve the necessary information from the applicable registries, with a priority to the SDMX global registry and the Eurostat registry.

### Query the registry
The folder *SDMX_Global_Registry* contains a Python notebook that shows how the two artefacts can be queried via SDMX-JSON for any element in the SDMX global registry.
This is relatively simple because the global registry supports SDMX 2.1 out of the box and allows these artefacts to be queried in JSON format. The [example Python notebook](SDMX_Global_Registry/read_validation_metadata.ipynb) serves as an example to implement similar functionality in R to connect the R validate package directly with the SDMX global registry.

The folder *Eurostat SDMX registry* contains the notebook developed for querying this registry. Unfortunately the SDMX 2.1 interface seems not to be implemented to a large extent, which is also described on the bottom of the [documentation page](https://ec.europa.eu/eurostat/web/sdmx-web-services/rest-sdmx-2.1). It is especially unfortunate that a query for a codelist has not been implemented. Also, contrary to the global regisrty SDMX-JSON is not implemented. To make things worse, this registry is very slow, both in user interaction as in API responses. This makes it difficult to develop an efficient connection between validation in R and this regisrty.

Solution???????




### Design

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










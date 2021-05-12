## validatesdmx

Data validation using SDMX metadata.

This R package extends the
[validate](https://cran.r-project.org/package=validate) package for data
validation. The aim of this package is to make it easier to use [SDMX](https://sdmx.org/) metadata, such as code list or field types or field limits with the validate package.

> The aim of `validatesdmx` is to make it possible to re-use internationally-agreed SDMX metadata, specified in SDMX registries or local DSD files, for data validation.


### SDMX landscape

The Statistical Data and Metadata eXchange ([SDMX](https://sdmx.org)) standard is an ISO standard designed to facilitate the exchange or dissemination of [Official Statistics](https://en.wikipedia.org/wiki/Official_statistics#:~:text=Official%20statistics%20are%20statistics%20published,organizations%20as%20a%20public%20good.).
At the core it has a logical information model describing the key characteristics of statistical data and metadata, which can be applied to any statistical domain.
Various data formats have been defined based on this information model, such as SDMX-[CSV](https://tools.ietf.org/html/rfc4180), SDMX-[JSON](https://www.json.org/json-en.html)), and - by far the most widely known - SDMX-ML (data in [XML](https://www.w3.org/XML/)).
A key aspect of the SDMX standard is that one defines the metadata, including data structure, variables, and code lists beforehand in order to describe what data is shared or published.
This metadata is defined in an *SDMX registry* where data producers can download or query the necessary metadata. Alternatively metadata is distributed in a so-called *Data Structure Definition* (DSD) file, which is usually an XML format.
Both types of modes should result in exactly the same metadata agreements. 

SDMX registries can be accessed through a [REST
API](https://en.wikipedia.org/wiki/Representational_state_transfer), using a
standardized set of parameters.  Some important SDMX registries are:

- [Global SDMX Registry](https://registry.sdmx.org/): for global metadata, hosted by the SDMX consortium. The central place for ESS-wide metadata. This registry hosts important statistical metadata such as for CPI/HICP, National Accounts (NA), Environmental accounting (SEEA), BOP, GFS, FDI and many more. Unfortunately not all ESS metadata is present in this registry.
- [Eurostat SDMX Registry](https://webgate.ec.europa.eu/sdmxregistry/): for Eurostat-wide metadata, hosted by Eurostat. This registry contains statistical metadata for all other official statistics in the ESS. Access is offered via SDMX 2.1 REST API.
- [IMF SDMX Central](https://sdmxcentral.imf.org/overview.html): Registry by the IMF. 
- [UNICEF](https://sdmx.data.unicef.org/): Registry by UNICEF

It is also possible for organizations to create their own (internal) SDMX registry. For the goal of reusing international metadata for data validation this is less of our interest as we cannot access these.

In addition there are several organisations that offer automated access to their dissemination database via an SDMX API, including access to the metadata:
- [ECB](https://sdw-wsrest.ecb.europa.eu/help/): access to the ECB SDMX web services
- [OECD](https://data.oecd.org/api/): access to OECD statistics via [SDMX-JSON](https://data.oecd.org/api/sdmx-json-documentation/) or [SDMX-ML](https://data.oecd.org/api/sdmx-ml-documentation/).
- [Eurostat](https://ec.europa.eu/eurostat/web/sdmx-web-services/rest-sdmx-2.1): SDMX REST (2.1) API for accessing teh Eurostat dissemination database (https://ec.europa.eu/eurostat/data/database)
- [ILO](https://www.ilo.org/sdmx/index.html): SDMX REST (2.1) API ([doc](https://www.ilo.org/ilostat-files/Documents/SDMX_User_Guide.pdf)) to [ILOstat](https://ilostat.ilo.org/) 
- [FAO](http://api.data.fao.org/1.0/esb-rest/sdmx/introduction.html): access to data from the FAO 
- [Worldbank](https://datahelpdesk.worldbank.org/knowledgebase/articles/1886701-sdmx-api-queries): SDMX access to World Development indicators 
- [BIS](https://www.bis.org/statistics/sdmx_techspec.htm?accordion1=1&m=6%7C346%7C718): SDMX access to [BIS statistics](https://www.bis.org/statistics/index.htm)
- [ISTAT](https://www.istat.it/it/metodi-e-strumenti/web-service-sdmx): access to data from the Italian statistical institute.

Unfortunately the SDMX consortium does not maintain a list of active SDMX endpoints. The [rsdmx R package](https://cran.r-project.org/package=rsdmx) maintains such a list based on an earlier inventory of Data Sources. Inspecting the [endpoint links](https://github.com/opensdmx/rsdmx/wiki#success_stories) shows that some are not active or legacy. The [pandasSDMX Python package](https://pandasdmx.readthedocs.io) also maintains such a [list of data sources](https://pandasdmx.readthedocs.io/en/v1.0/sources.html). The same applies here. All in all we think that the above lists pretty well summarizes the active SDMX providers.

We explicitly categorised the SDMX endpoints above into two distinct categories:

- endpoints of registries providing metadata / agreements to be used for the exchange of statistics in the European Statistical System (ESS)
- endpoints of dissemination databases providing official statistics

We recall that our goal is to re-use as internationally agreed metadata for data validation.
With this goal in mind we conclude that the registries should be the main targets of our exercise as they form the metadata backbone of the ESS and will contain (versions) of standardised codelists and possibly other metadata relevant for data validation.
Endpoints to dissemination databases may be interesting as well, as there is a relationship between what is published and the validity of the underlying data that we want to validate, however the first step in improving international data validation practices should be the re-use of officially agreed metadata (DSDs) in registries.
Hence, in the rest of this exercise this is the subject of our focus.   



### Variety within standard implementations

Ideally all SDMX providers would have implemented SDMX in a coordinated way
so that a client looking for SDMX metadata to validate its data before sending
could query the respective sources using one and the same API.
The latest version of the REST API is 2.1 which is described very well in the easy to use  
[SDMX API cheet sheet](https://raw.githubusercontent.com/sdmx-twg/sdmx-rest/master/v2_1/ws/rest/docs/rest_cheat_sheet.pdf).
Inspecting the endpoints shows that not all providers implement all same resource values.
Depending on the provider an organization may decide which elements of the API are exposed.
For example, the API standard defines methods to retrieve code lists from a DSD, but this
functionality may or may not be offered by an API instance. If it is not
offered, this means the client software needs to retrieve this metadata via other resource requests or 
alternatively extract them locally from a DSD file.
Finally we signal that on a technical level the API of the various institutes may differ considerably and that not all SDMX services implement the same version of SDMX. 

However for the aim of our exercise (see above) we don't need the full metadata of every single metadata ingredient of the ESS. Inspection of the most common validation rules by Eurostat [ref: Vincent eUROSTAT] and in an [earlier project](https://github.com/SNStatComp/GenericValidationRules) shows that certain elements are especially imortant for executing validation based on SDMX metadata.
The most important elements that we will focus on in this first implementation are:
- code list checks
- field type and range checks

So our goal is to retrieve the necessary information from the applicable registries, with a priority to the SDMX global registry and the Eurostat registry as they form the backbone of the ESS metadata system. Access to other registries would be welcome. Access to dissemination database would be an optional extra. 

### Analysis of registries

#### SDMX global registry

Automated access to artefacts from the global registry is relatively simple because this registry supports many of the SDMX 2.1 resources from the standard including codelists. It is convenient that it not only allows these artefacts to be queried in XML but also in [JSON](https://www.json.org/json-en.html) format and that this doesn't even has to be specified via content-negotiation but can be done via a *format* querystring parameter. It offers a REST [web service playing area for structures](https://registry.sdmx.org/webservice/structure.html) to design your query. Moreover this registry does answer requests fast which would make a direct connection from the validation package to the registry possible. We created an [example Python notebook](SDMX_Global_Registry/read_validation_metadata.ipynb) to show how the codelists and structures can be queried and this serves as an example to implement similar functionality in R to connect the R validate package directly with the SDMX global registry.


#### Eurostat SDMX registry
Automated access to artefacts from the Euro registry is also very well possible. It does support SDMX 2.1 but it seems not to have implemented SDMX-JSON.
The registry is not as fast as the global registry, even queries to smaller metadata volumes need seconds.
We created an [example Python notebook](ESTAT_SDMX_Registry/read_validation_metadata.ipynb) to show how the codelists and structures can be queried and this serves as an example to implement similar functionality in R to connect the R validate package directly with the SDMX global registry.


#### Other registries
The [IMF SDMX Central](https://sdmxcentral.imf.org/overview.html) seems to offer exactly the same SDMX 2.1 REST implementation as the global registry does. It performs well and also offers SDMX-JSON via the *format* querystring parameter. There are lots over artefacts that seem to be shared among these registries but there is also some different contents. We conclude that if we develop an automated R-validate <-> global registry access, this will probably also work for the IMF registry, thus widening the possibilities for international data validation.

The same holds for the [UNICEF registry](https://sdmx.data.unicef.org/overview.html). It is clearly based on the same regisrty software and thus our automated connection will work for the contents contained in this registry as well. Moreover it offers additional international metadata which again widens the effectiveness of such generic solution.

All in all, our analysis shows that three out of the 4 registries that we found can be accessed via SDMX-JSON and one - the Euro registry - cannot (at the moment.)
Because of the importance of the Euro registry for the ESS and international data validation and since we opt for a generic approach where we implement one type of access to be used on as many endpoints as possible, we decide that for the moment we have to query SDMX 2.1 for XML from R.
Since the Euro registry does have some delay and datavalidation ractices require immediate access to rules and rule metadata, we will design our datavalidation approach in R using an automated cache. 

#### Overlap in content
Looking at the contents of the 4 registres we see that they show some overlap.
Especially the global regisrty and the SDMX regisrty ..... <TODO: overlap analysis  >


### Design

**This has to be rewritten later**

As we have seen, it is not possible to create a generic client that works
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










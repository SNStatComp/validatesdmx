## Introduction

This repo contains project results from the international **ValidatFOSS2** project: *Validation with Free and Open Source Software*, supported by the EU under Grant Agreement 882817 - 2019-NL-Validation.

This repo specifically addresses the issue of performing data validation from R using the [validate](https://cran.r-project.org/package=validate) extended with facilities to hande SDMX metadata. The aim of this work is to make it easier to use [SDMX](https://sdmx.org/) metadata, such as code list or field types or field limits from within the validate package. 

> The aim of this work is to make it possible to re-use internationally-agreed SDMX metadata, specified in SDMX registries or local DSD files, for data validation.


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

It is also possible for organizations to create their own (internal) SDMX registry. For the goal of re-using international metadata for data validation this is less of our interest.

In addition there are several organisations that offer automated access to their dissemination database via an SDMX API, including access to the metadata:
- [ECB](https://sdw-wsrest.ecb.europa.eu/help/): access to the ECB SDMX web services
- [OECD](https://data.oecd.org/api/): access to OECD statistics via [SDMX-JSON](https://data.oecd.org/api/sdmx-json-documentation/) or [SDMX-ML](https://data.oecd.org/api/sdmx-ml-documentation/).
- [Eurostat](https://ec.europa.eu/eurostat/web/sdmx-web-services/rest-sdmx-2.1): SDMX REST (2.1) API for accessing the Eurostat dissemination database (https://ec.europa.eu/eurostat/data/database)
- [ILO](https://www.ilo.org/sdmx/index.html): SDMX REST (2.1) API ([doc](https://www.ilo.org/ilostat-files/Documents/SDMX_User_Guide.pdf)) to [ILOstat](https://ilostat.ilo.org/) 
- [FAO](http://api.data.fao.org/1.0/esb-rest/sdmx/introduction.html): access to data from the FAO 
- [Worldbank](https://datahelpdesk.worldbank.org/knowledgebase/articles/1886701-sdmx-api-queries): SDMX access to World Development indicators 
- [BIS](https://www.bis.org/statistics/sdmx_techspec.htm?accordion1=1&m=6%7C346%7C718): SDMX access to [BIS statistics](https://www.bis.org/statistics/index.htm)
- [ISTAT](https://www.istat.it/it/metodi-e-strumenti/web-service-sdmx): access to data from the Italian statistical institute.

Unfortunately the SDMX consortium does not maintain a list of active SDMX endpoints. The [rsdmx R package](https://cran.r-project.org/package=rsdmx) maintains such a list based on an earlier inventory of Data Sources. Inspecting the [endpoint links](https://github.com/opensdmx/rsdmx/wiki#success_stories) shows that some are not active or legacy. The [pandasSDMX Python package](https://pandasdmx.readthedocs.io) also maintains such a [list of data sources](https://pandasdmx.readthedocs.io/en/v1.0/sources.html). The same applies here. All in all we think that the above lists pretty well summarizes the active SDMX providers.

We explicitly categorised the SDMX endpoints above into two distinct categories:

- endpoints of registries providing metadata for the exchange of statistics in the European Statistical System (ESS)
- endpoints of dissemination databases providing official statistics

We recall that our goal is to re-use internationally agreed metadata for data validation.
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

Automated access to artefacts from the global registry is relatively simple because this registry supports many of the SDMX 2.1 resources from the standard including codelists. It is convenient that it not only allows these artefacts to be queried in XML but also in [JSON](https://www.json.org/json-en.html) format and that this doesn't even has to be specified via content-negotiation but can be done via a *format* querystring parameter. It offers a REST [web service playing area for structures](https://registry.sdmx.org/webservice/structure.html) to design your query. Moreover this registry does answer requests fast which would make a direct connection from the validation package to the registry possible. We created a [Python notebook](test_registries/Python/global_registry.ipynb) and an [R script](test_registries/R/global_registry.R)to show how the codelists and structures can be queried and this serves as an example to implement the needed functionality in this R validate package.


#### Eurostat SDMX registry
Automated access to artefacts from the Euro registry is also very well possible. It does support SDMX 2.1 but it seems not to have implemented SDMX-JSON.
The registry is not as fast as the global registry, even queries to smaller metadata volumes need seconds.
We created  a [Python notebook](test_registries/Python/euro_registry.ipynb) and an [R script](test_registries/R/euro_registry.R) to show how the codelists and structures can be queried and this serves as an example to implement the needed functionality in this R validate package.


#### Other registries
The [IMF SDMX Central](https://sdmxcentral.imf.org/overview.html) seems to offer exactly the same SDMX 2.1 REST implementation as the global registry does. It performs well and also offers SDMX-JSON via the *format* querystring parameter. There are lots over artefacts that seem to be shared among these registries but there is also some different contents. We conclude that if we develop an automated R-validate <-> global registry access, this will probably also work for the IMF registry, thus widening the possibilities for international data validation.

The same holds for the [UNICEF registry](https://sdmx.data.unicef.org/overview.html). It is clearly based on the same regisrty software and thus our automated connection will work for the contents contained in this registry as well. Moreover it offers additional international metadata which again widens the effectiveness of such generic solution.

All in all, our analysis shows that three out of the 4 registries that we found can be accessed via SDMX-JSON and one - the Euro registry - cannot (at the moment.)
Because of the importance of the Euro registry for the ESS and international data validation and since we opt for a generic approach where we implement one type of access to be used on as many endpoints as possible, we decide that for the moment we have to query SDMX 2.1 for XML from R.
Since the Euro registry does have some delay and datavalidation ractices require immediate access to rules and rule metadata, we will design our datavalidation approach in R using an automated cache. 

#### Overlap analysis
Looking at the contents of the 4 registres we see that they show some overlap.
Especially the global registry and the SDMX registry seems to overlap in contents from ESTAT.
However each of the registries does offer organisation-specific metadata that is not contained in any of the other registries which makes the use case for the generic validatesdmx package valid.
We plan to do an overlap analysis later.


### Design

As mentioned in the introduction the aim of this work is to facilitate data validation based on Internationally agreed metadata as specified in SDMX from the R validate package. The above analyses show that to create a generic client that works out-of-the-box for every registry we have to use  the SDMX 2.1 REST API.
This is shown in the example R scripts in this registry. They also show that the use of the generic rsdmx package for parsing SDMX-ML responses results in similar S4 objects for both registries tested and presumably all registries since the other two are based on the same backend as the global registry.
Happily this conforms to the  
[SDMX API cheet sheet](https://raw.githubusercontent.com/sdmx-twg/sdmx-rest/master/v2_1/ws/rest/docs/rest_cheat_sheet.pdf) 
as fas as we can see.

From a user-perspective it is important to have an interface that 

- hides details that are related to a specific SDMX DSD API
- is extensible so that new APIs may be added.
- has speedy performance and avoids unnecessary downloads

We therefore decided to implement the generic connection to a SDMX registry using the  [rsdmx](https://cran.r-project.org/package=rsdmx) package and to hide the details as much as possible from the end-user in the validate package, so that there is one interface / documentation / cookbook that describes it all. Also, since not all registries are blazing fast we plan to add some **caching** in metadata requests in the R-validate implementation.

The results of these design decisions will be avilable in:
 - a new version of the R package validate
 - an extension of the corresponding data validation cookbook with a chapter on how to us registry metadata from R-validate
  - a dedicated vignette on the R-validate SDMX functionality.

When available, links to these three outputs will be posted here as well. 

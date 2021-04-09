## validatesdmx

Data validation using SDMX metadata definition.

This R package extends the
[validate](https://cran.r-project.org/package=validate) package for data
validation. The aim of this package is to make it easier to use SDMX metadata,
such as code list, with the validate package.

> The aim of `validatesdmx` is to provide a generic SDMX client that can access
  metadata from SDMX DSD registries and local DSD files.



### SDMX, registries, and APIs

Statistical Data and Metadata eXchange ([sdmx](https://sdmx.org)) is an
XML-based standard for data exchange. In SDMX, one carefully defines the
metadata, including data structure, variables, and code lists in order to
describe what data is shared in an SDMX file. The metadata is defined in a
so-called Data Structure Definition file, which is also in XML format.

SDMX is used amongst others by the [Official Statistics](https://en.wikipedia.org/wiki/Official_statistics#:~:text=Official%20statistics%20are%20statistics%20published,organizations%20as%20a%20public%20good.) community to exchange statistical data.


In order to facilitate standardized data exchange, DSD files can be published
in central registries that can be accessed through a [REST
API](https://en.wikipedia.org/wiki/Representational_state_transfer), using a
standardized set of parameters.  Some important SDMX registries include the following.

- [Global SDMX Registry](https://registry.sdmx.org/). This is owned by the SDMX consortium.
- [OECD SDMX Registry](https://data.oecd.org/api/sdmx-ml-documentation/)
- [Eurostat SDMX Registry](https://webgate.ec.europa.eu/sdmxregistry/)


It is also possible for organizations to create their own (internal) SDMX
registry.

Although the SDMX standard prescribes the set of parameters that need to be
present in an API that offers access to an SDMX registry, the actual name of
those parameters is not fixed. Moreover, depending on the registry an
organization may decide which elements of the API are exposed. For example, the
API standard defines methods to retrieve code lists from a DSD, but this
functionality may or may not be offered by an API instance. If it is not
offered, this means that client software needs to make assumptions and extract
code lists locally from a DSD file. Indeed, on a technical level the API of the
Global, OECD, or Eurostat registries differ considerably.

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

From a user-perspective is is important to have an interface that 

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










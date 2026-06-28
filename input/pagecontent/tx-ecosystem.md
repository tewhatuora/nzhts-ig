## NZHTS & the HL7 FHIR terminology ecosystem

### Overview of Tx Ecosystem main components / actors

```mermaid
flowchart LR
    IGSource["IG source"]
    FHIRPackages["FHIR packages<br/>(local cache, registry, FHIR Core,<br/>THO, FHIR extensions,<br/>dependencies)"]

    Publisher["IG Publisher /<br/>Validator"]

    Coordinator["Co-ordination service<br/>(tx.fhir.org/tx-reg)"]
    Registry["Terminology ecosystem<br/>registry (server registrations,<br/>authority declarations)"]

    subgraph RegisteredServers["Registered terminology servers"]
        direction TB

        ServerGateway[" "]

        SharedHL7["Shared HL7<br/>terminology server<br/>(tx.fhir.org/r4)"]

        NZHTS["NZHTS<br/>(nzhts.digital.health.<br/>nz/fhir)"]

        OtherServers["AU, CA, DE, EU, etc."]

        ServerGateway ~~~ SharedHL7
        SharedHL7 ~~~ NZHTS
        NZHTS ~~~ OtherServers
    end

    IGSource -->|"Inputs"| Publisher
    FHIRPackages --> Publisher

    Publisher <-->|"Look up terminology server to use for each<br/>$expand, $validate-code, $lookup, etc."| Coordinator

    Coordinator <--> Registry

    Publisher <-->|"Terminology requests routed to the appropriate server<br/>($expand, $validate-code, $lookup)"| ServerGateway

    style RegisteredServers fill:none,stroke:#333,stroke-width:2px,stroke-dasharray: 8 6
    style ServerGateway fill:none,stroke:none,color:transparent
```

### FHIR IG publisher terminology validation routing

```mermaid
---
title: IG Publisher terminology validation  
---
flowchart LR
  A["Need terminology decision<br/>system/valueSet/version"] --> B{"Already in<br/>tx cache?"}
  B -- yes --> C["Use cached Parameters<br/>or expansion"]
  B -- no --> D{"Can local/package<br/>artifacts answer safely?"}
  D -- yes --> E["Validate locally<br/>or use local expansion"]
  D -- no --> F["Ask tx-reg<br/>resolve(fhirVersion, url/valueSet, usage=publication)"]

  F --> G{"Authoritative<br/>server returned?"}
  G -- yes --> H["Use authoritative endpoint"]
  G -- no --> I{"Candidate servers<br/>returned?"}
  I -- yes --> J["Choose candidate<br/>often primary tx.fhir.org"]
  I -- no --> K["Use configured primary tx server<br/>or report unresolved terminology"]

  H --> L["Call FHIR terminology operation"]
  J --> L
  K --> L

  L --> M{"Operation type"}

  subgraph Ops[" "]
    direction TB
    M --> N["ValueSet/$validate-code"]
    M --> O["CodeSystem/$validate-code"]
    M --> P["ValueSet/$expand"]
    M --> Q["CodeSystem/$lookup"]
  end

  N --> R["Result, messages, display"]
  O --> R
  P --> S["Expansion or too-costly/error"]
  Q --> T["Display, version, properties"]

  R --> U["Cache result + emit QA issues"]
  S --> U
  T --> U
```

End to end terminology flow for an IG build

```mermaid
sequenceDiagram
  autonumber
  participant Author as IG author / CI
  participant Pub as IG Publisher
  participant Pkg as FHIR package cache / package registry
  participant TxReg as tx.fhir.org/tx-reg
  participant Tx as tx.fhir.org primary endpoint
  participant Other as Authoritative/candidate ecosystem server
  participant QA as QA outputs

  Author->>Pub: Run _genonce / CI build<br/>-ig ig.json -tx tx.fhir.org
  Pub->>Pkg: Load core + dependency packages
  Pkg-->>Pub: StructureDefinitions, ValueSets, CodeSystems, etc.
  Pub->>Pub: Generate snapshots, narratives, indexes
  Pub->>Pub: Validate profiles and resources

  loop For bound coded content / ValueSets
    Pub->>Pub: Check local tx cache
    alt Cache miss and local artifacts insufficient
      Pub->>TxReg: Resolve CodeSystem/ValueSet<br/>FHIR version + usage=publication
      TxReg-->>Pub: authoritative/candidate server choices
      alt Authoritative/candidate selected
        Pub->>Other: $validate-code / $expand / $lookup
        Other-->>Pub: Parameters / ValueSet / OperationOutcome
      else Use primary
        Pub->>Tx: $validate-code / $expand / $lookup
        Tx-->>Pub: Parameters / ValueSet / OperationOutcome
      end
      Pub->>Pub: Cache response
    end
    Pub->>Pub: Convert tx result into errors/warnings/info
  end

  Pub->>QA: Generate qa.html
  Pub->>QA: Generate qa-tx.html
  Pub->>QA: Generate qa-txservers.html
```


NZ edition SNOMED CT ValueSet Expansion via Tx-ecosystem/NZHTS

```mermaid
sequenceDiagram
    autonumber
    participant IG as IG source
    participant Pub as FHIR IG Publisher<br/>WorkerContext / Tx Manager
    participant Cache as Local tx cache
    participant Reg as tx.fhir.org/tx-reg<br/>coordination service
    participant NZHTS as NZHTS<br/>authoritative NZ SCT server
    participant Page as Generated ValueSet page

    IG->>Pub: Load local ValueSet<br/>includes NZ edition refset URI
    Pub->>Cache: Look up prior expansion

    alt Expansion is cached and still accepted
        Cache-->>Pub: Cached ValueSet.expansion
    else Cache miss / reset
        Pub->>Reg: Resolve NZ-qualified terminology context<br/>FHIR version + usage=publication
        Note over Reg: NZHTS registered as authoritative<br/>for NZ SCT edition
        Reg-->>Pub: NZHTS endpoint selected

        Pub->>NZHTS: ValueSet/$expand
        Note over Pub,NZHTS: Request contains either:<br/>• the implicit SNOMED ValueSet URL, or<br/>• the local ValueSet definition in Parameters.valueSet<br/>plus related tx-resource artifacts where needed

        NZHTS->>NZHTS: Evaluate NZ refset against<br/>the requested NZ SCT edition/release
        NZHTS-->>Pub: Expanded ValueSet<br/>contains code, display, system,<br/>used SCT version/provenance

        Pub->>Cache: Store expansion result
    end

    Pub->>Page: Render ValueSet definition<br/>and expansion table
```

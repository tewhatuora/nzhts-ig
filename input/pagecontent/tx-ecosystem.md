## NZHTS & the HL7 FHIR terminology ecosystem

NZHTS is a registered participant in the HL7 FHIR terminology ecosystem, and can be declared as the authoritative server for terminology artifacts used in NZ such as the NZ edition of SNOMED CT. That declaration allows the IG publisher to resolve NZ terminology against NZHTS automatically.

This page describes how that works: the actors involved, how the IG Publisher decides which terminology server to call, and what happens end to end during a build.

### Overview of Tx Ecosystem main components / actors

The diagram below shows the moving parts and how they relate to each other.

* **IG source and FHIR packages** are the inputs to a build — your own profiles, value sets and examples, plus the core FHIR, THO and dependency packages resolved from the local package cache or the package registry.
* **The IG Publisher / Validator** is the client. It needs to make terminology decisions (is this code valid? what does it display as? what is in this value set?).
* **The co-ordination service** (`tx.fhir.org/tx-reg`) is the directory/lookup service. Given a code system or value set URL and a FHIR version, it answers the question *"which server should I ask?"*
* **The terminology ecosystem registry** holds the underlying data — which servers exist, what they support, and which of them have declared authority over particular terminologies.
* **The registered terminology servers** respond to the actual terminology service queries. These include the shared HL7 server (`tx.fhir.org/r4`), NZHTS, and the equivalent national and regional servers for AU, CA, DE, the EU and others.

The important consequence is that the Publisher talks to the co-ordination service *about* terminology, and to the registered servers *for* terminology. NZHTS sits in the second group, and is reached because the registry points to it.

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

Whenever the Publisher hits coded content it needs to make a decision about, it works through the sequence below. The key point for IG authors is that **calling a terminology server is the last resort, not the first step** — the Publisher tries progressively more expensive options in order:

1. **Local tx cache.** If the same question has been answered before, the cached result is reused. This is why a warm cache makes builds dramatically faster, and why clearing the cache forces a full round of server calls.
2. **Local and package artifacts.** If the code system is small, complete and present in the build (a local code system, or one supplied by a dependency package), the Publisher can answer safely without any server at all.
3. **Ask the co-ordination service.** Otherwise the Publisher calls `tx-reg` with the FHIR version, the code system or value set URL, and `usage=publication`, asking which server to use.

The response then determines routing. If a server has declared **authority** for that terminology, its endpoint is used — this is the path NZ SNOMED CT and NZ code systems take to NZHTS. If there is no authoritative server but there are **candidates**, one is chosen, typically the primary `tx.fhir.org`. If neither is returned, the Publisher falls back to whatever primary tx server the build was configured with, or reports the terminology as unresolved.

Once an endpoint is selected, the actual FHIR operation is issued — `ValueSet/$validate-code`, `CodeSystem/$validate-code`, `ValueSet/$expand` or `CodeSystem/$lookup` — and the result is cached and turned into QA output. Note that `$expand` can return a "too costly" response rather than an expansion for a large or open-ended value set.

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

### End to end terminology flow for an IG build

The previous diagram showed the decision logic in isolation. This sequence diagram shows it in the context of a complete build.

The build starts with package loading and the structural work — snapshot generation, narratives, indexes and profile validation. Terminology resolution then runs as a **loop over every piece of bound coded content**, applying the cache / local / registry sequence described above. A single IG can generate a very large number of these checks, which is why cache behaviour has such a visible effect on build times.

Each terminology response is converted into errors, warnings or informational messages, and surfaced in three QA artefacts worth knowing about:

* **`qa.html`** — the overall build QA report, including terminology-derived errors and warnings alongside everything else.
* **`qa-tx.html`** — the terminology-specific report. This is the file to open when you are debugging why a code will not validate or a value set will not expand.
* **`qa-txservers.html`** — a summary of *which* terminology servers were actually contacted during the build. For an NZ IG, this is the quickest way to confirm that NZ content genuinely resolved to NZHTS rather than silently falling back to the primary server.

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


### NZ edition SNOMED CT ValueSet Expansion via Tx-ecosystem/NZHTS

This final diagram is the NZ-specific case, and shows a value set that draws on the New Zealand edition of SNOMED CT via an NZ reference set.

The flow follows the same general pattern, but with one difference. When the Publisher asks the co-ordination service to resolve NZ-qualified terminology, the registry returns **NZHTS as the authoritative server**, because NZHTS has declared authority for the NZ SNOMED CT edition. The expansion is therefore evaluated by NZHTS against the correct NZ edition and release — something the shared HL7 server cannot do, since it does not carry the NZ edition.

Two details are worth calling out:

* **What gets sent.** The request may carry either the implicit SNOMED CT value set URL, or the local `ValueSet` definition supplied inline in `Parameters.valueSet`, along with any related `tx-resource` artefacts the server needs to evaluate it. The second form is what allows a value set defined in your own IG — one that has never been published to NZHTS — to still be expanded correctly against NZ content.
* **What comes back.** The expansion includes the codes and displays, and also records the SNOMED CT version actually used. That provenance is what makes the rendered value set page reproducible and traceable to a specific NZ release.

The result is cached like any other terminology response, and then rendered into the generated value set page in the published IG.

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

## FHIR Terminology primer for NZ FHIR

FHIR treats coded data as a combination of a code and the code system that
defines it. The `system` is not a label for a local list or a value set. It is
the canonical URI for the code system that gives the code its meaning. This
distinction is important for New Zealand implementations because a single value
set may include codes from SNOMED CT, LOINC, NZ-specific code systems and local
code systems.

### Core terminology resources

The main FHIR terminology resources used with NZHTS are:

* `CodeSystem` - defines a namespace of concepts and codes.
* `ValueSet` - defines a set of codes for use in a specific context. It may
  include codes from one or many code systems.
* `ConceptMap` - describes mappings between concepts or value sets.
* `NamingSystem` - records identifiers for code systems and other naming
  schemes.
* `TerminologyCapabilities` - describes the code systems, value sets and
  terminology features a server supports.

NZHTS exposes FHIR R4 terminology resources through the production endpoint
`https://nzhts.digital.health.nz/fhir`. The local CapabilityStatement indicates
that NZHTS supports the main terminology resource types and common terminology
operations.

### Coded datatypes

FHIR resources carry terminology content using datatypes such as `code`,
`Coding` and `CodeableConcept`.

Use `Coding` when a single code from a single system is needed. Use
`CodeableConcept` when the data element may carry one or more codings plus human
text. In practice, many clinical FHIR elements use `CodeableConcept` so that a
standard coding can be sent with display text, and sometimes with an additional
local coding.

For interoperable exchange, populate at least:

* `system` with the correct code system URI.
* `code` with the code from that system.
* `display` when a display term is known and current.
* `version` when the code system requires version-specific interpretation or
  when the implementation agreement requires it.

### Bindings and value sets

FHIR profiles bind coded elements to value sets. The binding strength describes
how tightly an instance must follow that value set:

* `required` - one of the codings must be from the bound value set.
* `extensible` - use the value set when it has a suitable concept; otherwise a
  different coding or text may be used.
* `preferred` - the value set is recommended for interoperability.
* `example` - the value set is illustrative only.

New Zealand FHIR profiles should bind to stable canonical value set URLs. A
terminology server such as NZHTS resolves those definitions into expansions at a
particular point in time, optionally using parameters such as filter text,
display language, code system version or expansion size limits.

### Common NZHTS operations

Common FHIR terminology operations include:

* `ValueSet/$expand` - return the current expansion for a value set definition.
* `ValueSet/$validate-code` - check whether a code is in a value set.
* `CodeSystem/$lookup` - look up display text, properties and designations for a
  code.
* `CodeSystem/$validate-code` - check whether a code is valid in a code system.
* `CodeSystem/$subsumes` - test whether one code is more general or more
  specific than another.
* `ConceptMap/$translate` - map a coding from one terminology context to
  another where a ConceptMap is available.

For SNOMED CT, NZHTS also supports SNOMED CT Expression Constraint Language
(ECL) in FHIR value set expansion patterns. This is useful for defining
intensional value sets such as "all descendants of this concept" rather than
maintaining a fixed list of codes.

### Design guidance for NZ FHIR

Use coded data where systems need to validate, query, aggregate, decision-support
or analyse the information. Use plain text where the data is only narrative and
there is no agreed coded representation.

When defining NZ-specific content:

* Do not use a value set URL as a `Coding.system`.
* Prefer canonical URLs that are stable over time.
* Avoid copying expanded lists into profiles unless the list is intentionally
  fixed.
* Use NZHTS for national code systems, value sets and concept maps that are
  expected to be reused across implementations.
* Record local code systems clearly when local codes must be exchanged.

See also the [FHIR R4 Terminology Module](https://hl7.org/fhir/R4/terminology-module.html),
[FHIR R4 Using Codes in Resources](https://hl7.org/fhir/R4/terminologies.html),
and the [Health New Zealand NZHTS overview](https://www.healthnz.govt.nz/health-professionals/guidance-standards/topic/data-and-standards/health-information-standards/nz-health-terminology-service-nzhts).

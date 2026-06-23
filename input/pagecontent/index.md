
## NZHTS

The New Zealand Health Terminology Service (NZHTS) is the national health terminology service run by Health New Zealand \| Te Whatu Ora. It is an instance of Ontoserver, publishing and serving terminology as a FHIR R4 terminology service API. 

This IG provides guidance to NZHTS FHIR users. It focuses on the FHIR usage patterns and integration with FHIR tooling rather than the clinical governance of individual terminologies. For more general NZHTS information, see the [NZHTS home page](https://www.healthnz.govt.nz/health-professionals/guidance-standards/topic/data-and-standards/health-information-standards/nz-health-terminology-service-nzhts).

This guide covers:

* A primer for the FHIR terminology concepts that matter when using NZHTS
* how to use NZHTS as part of the wider HL7 FHIR terminology ecosystem including with terminology for which NZHTS is declared as the authoratitive server
* how to to use NZHTS authentication with the IG Publisher 
* architecture guidance on consuming NZHTS and production terminology service usage

The production FHIR terminology endpoint is `https://nzhts.digital.health.nz/fhir`. The included [NZHTS CapabilityStatement](CapabilityStatement-NZHTS-CapabilityStatement.html) describes the server's supported functionality. 

## Guide pages

* [FHIR Terminology primer for NZ FHIR](fhir-terminology-primer.html)
* [NZHTS and the HL7 FHIR terminology ecosystem](tx-ecosystem.html)
* [Using NZHTS with authentication and the IG Publisher](auth.html)

## References

* [Health New Zealand NZHTS overview](https://www.healthnz.govt.nz/health-professionals/guidance-standards/topic/data-and-standards/health-information-standards/nz-health-terminology-service-nzhts)
* [NZHTS API examples on GitHub](https://github.com/hiso-nz/nzhts/wiki)
* [HNZ Digital Services Hub](https://www.healthnz.govt.nz/health-professionals/guidance-standards/topic/digital-technologies/digital-services-hub)


## Version

{% include cross-version-analysis.xhtml %}

## Dependencies

{% include dependency-table.xhtml %}

## Intellectual property

{% include ip-statements.xhtml %}

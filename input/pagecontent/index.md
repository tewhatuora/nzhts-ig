
## NZHTS

The New Zealand Health Terminology Service (NZHTS) is the national health terminology service run by Health New Zealand \| Te Whatu Ora. It is an instance of Ontoserver, publishing and serving terminology as an FHIR R4 terminology service API. 

This IG provides guidance to NZHTS FHIR users. It focuses only on the FHIR usage patterns and integration with FHIR tooling rather than the clinical governance of individual terminologies or other capabilities (such as the authoring platform) of NZHTS. For more general NZHTS information, see the [NZHTS home page](https://www.healthnz.govt.nz/health-professionals/guidance-standards/topic/data-and-standards/health-information-standards/nz-health-terminology-service-nzhts).

This guide covers:

* How to use NZHTS as part of the wider HL7 FHIR terminology ecosystem including with terminology for which NZHTS is declared as the authoratitive server. See the [Tx-ecosystem page](tx-ecosystem.html). 
* How to to use [authentication with the IG Publisher](auth.html) to access licenced content on NZHTS (incl. NZ edition SNOMED CT). 
* Guidance on using the [NZ Edition of SNOMED in FHIR IGs](nz-snomed.html). 
* architectural guidance on expected [NZHTS usage patterns](nzhts-usage.html).

The production FHIR terminology endpoint is `https://nzhts.digital.health.nz/fhir`. The included [NZHTS CapabilityStatement](CapabilityStatement-NZHTS-CapabilityStatement.html) describes the server's supported functionality. This can also be retreived directly from `https://nzhts.digital.health.nz/fhir/metadata`

## References

* [Health New Zealand NZHTS overview](https://www.healthnz.govt.nz/health-professionals/guidance-standards/topic/data-and-standards/health-information-standards/nz-health-terminology-service-nzhts)
* [NZHTS API examples on GitHub](https://github.com/hiso-nz/nzhts/wiki)
* [HNZ Digital Services Hub](https://www.healthnz.govt.nz/health-professionals/guidance-standards/topic/digital-technologies/digital-services-hub)
* [FHIR R4 Terminology module documentation](https://hl7.org/fhir/R4/terminology-module.html)
* [FHIR R4 Terminology service documentation](https://hl7.org/fhir/R4/terminology-service.html)


## Version

{% include cross-version-analysis.xhtml %}

## Dependencies

{% include dependency-table.xhtml %}

## Intellectual property

{% include ip-statements.xhtml %}

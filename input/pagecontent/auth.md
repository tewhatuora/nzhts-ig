## Using authenticated terminology servers with the IG Publisher

The IG Publisher and FHIR validator do not only talk to the single terminology server named on the command line. In the HL7 terminology ecosystem, the tooling can use a terminology coordination service to decide which terminology server is appropriate for a given code system or value set. This matters for NZHTS because New Zealand national content may be served by NZHTS as an authoritative server, while other FHIR terminology content is still resolved elsewhere.

This page is about that publisher workflow: how an IG build can validate content when the terminology coordination service routes a request to an authenticated server such as NZHTS.

### Coordination server workflow

The HL7 terminology ecosystem defines a coordination server API. For the HL7 ecosystem the root is:

```text
http://tx.fhir.org/tx-reg
```

A client can ask the coordination server to resolve a code system or value set:

```text
GET {root}/resolve?fhirVersion={version}&url={canonical}
GET {root}/resolve?fhirVersion={version}&valueSet={canonical}
```

The response can include one or more authoritative endpoints. Each endpoint entry identifies:

* the FHIR endpoint URL to use
* the FHIR version supported by that endpoint
* whether the endpoint is open or requires authentication
* whether token authentication is required
* any `access_info` text supplied by the server registry

The publisher can then use the selected endpoint for terminology operations such as `$expand`, `$validate-code`, `$lookup`, `$subsumes` or `$translate`.

### NZHTS as an authoritative endpoint

When a build references terminology that NZHTS is authoritative for, the coordination server may direct tooling to the NZHTS FHIR endpoint:

```text
https://nzhts.digital.health.nz/fhir
```

Examples include New Zealand national value sets and code systems, and New Zealand edition SNOMED CT content. In SNOMED CT, the code system URI used in FHIR instances remains the SNOMED CT URI, while edition and release context may be expressed through the version or through SNOMED implicit value set URLs. The important point for the IG Publisher is that the terminology request is resolved to a server that has the relevant New Zealand content and is recognised as the appropriate source for it.

If that selected server requires authentication, the publisher must be able to send credentials when it follows the coordination result. Otherwise terminology validation may fail even though the value set or code system is correctly published by NZHTS.

### What needs access

There are two distinct access paths:

* The coordination server needs enough access to inspect registered servers. The ecosystem documentation notes that it uses `/metadata`, `/metadata?mode=terminology` and `/ValueSet?_summary=true` when scanning servers.
* The IG Publisher or validator needs access to the endpoint selected for the actual terminology operation during a build.

For authenticated servers, both access paths need to be considered. Giving the coordination service access lets it know what the server supports; giving the publisher access lets the build use the server after resolution.

### Publisher configuration

The IG source should not contain credentials. Authentication for terminology servers is a local build environment concern. The FHIR Java tooling used by the IG Publisher can read server credentials from `fhir-settings.json`.

By default this file is located at:

```text
Windows:         C:\Users\<username>\.fhir\fhir-settings.json
Unix/Linux/Mac:  ~/.fhir/fhir-settings.json
```

The IG Publisher can also be pointed at a different settings file using the `-fhir-settings` command line option. This is useful for CI, release builds or local testing where the settings file should be outside the user's normal home directory.

```text
java -jar publisher.jar -ig . -fhir-settings path/to/fhir-settings.json
```

At a high level, a build environment needs:

* a terminology server configuration that allows use of the HL7 terminology coordination service
* credentials for each authenticated endpoint that may be selected by coordination, including NZHTS where required
* a way to refresh or replace credentials without changing IG source files
* logging that makes it clear whether a terminology failure is caused by missing content, missing authority, or failed authentication

### Supplying an NZHTS token

The `servers` array in `fhir-settings.json` is used to configure additional servers, including private or authenticated FHIR servers. FHIR terminology servers use `type: "fhir"`.

For NZHTS publisher access, use `authenticationType: "token"`. Configure the NZHTS FHIR endpoint like this:

```json
{
  "servers": [
    {
      "url": "https://nzhts.digital.health.nz/fhir",
      "type": "fhir",
      "authenticationType": "token",
      "token": "<access-token>"
    }
  ]
}
```

The `url` should match the FHIR endpoint that the tooling will call after terminology coordination resolves a request to NZHTS. If the coordination server returns `https://nzhts.digital.health.nz/fhir` for New Zealand content, that is the URL that needs a matching server entry.

Do not commit this file when it contains real credentials. For CI, generate the settings file during the build from secure variables, or store it as a protected secret file. The IG repository should only document the expected shape of the file.

This guide only describes token authentication for NZHTS. Other authentication types supported by the FHIR Java tools are outside the scope of NZHTS publisher access.

### Failure modes

When the publisher cannot access an authenticated authoritative server, errors can be misleading. A build may report that a value set cannot be expanded, a code cannot be validated, or a code system is unknown, even though the underlying problem is that the selected server returned an authentication or authorization failure.

For NZHTS-backed terminology, check:

* whether the canonical URL resolves to NZHTS through the coordination server
* whether the coordination response marks the NZHTS endpoint as requiring authentication
* whether the local publisher/validator environment has credentials for that endpoint
* whether the credentials cover the operations needed by the build, such as `$expand` and `$validate-code`
* whether the settings file is in the default location or has been supplied with `-fhir-settings`
* whether the build is accidentally running with `-tx n/a`, which disables live terminology server use

### Guidance for this IG

This IG should describe the expected publisher behaviour, not store operational secrets. Keep examples focused on the terminology routing pattern and on the canonical URLs being resolved. Any real NZHTS tokens belong in the user's local environment or in CI secret storage.

See the [FHIR Terminology Ecosystem IG](https://build.fhir.org/ig/HL7/fhir-tx-ecosystem-ig/ecosystem.html) for the coordination server registry and resolution model, and the [HL7 documentation for `fhir-settings.json`](https://confluence.hl7.org/spaces/FHIR/pages/161072808/Using+fhir-settings.json) for the settings file format.

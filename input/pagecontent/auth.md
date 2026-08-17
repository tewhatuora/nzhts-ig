## Using authenticated terminology servers with the IG Publisher

In the HL7 terminology ecosystem, the IG publisher and validation tooling uses a terminology coordination service (an API exposed at `http://tx.fhir.org/tx-reg`) to decide which terminology server is appropriate to use for a given terminology resource (CodeSystem, ValueSet and so on). NZHTS has been registered to participate in this ecosystem to make available content relevant/specific to New Zealand users. NZHTS is registered as the authoritative server for the SNOMED NZ edition, and others may be added in the future (e.g. NZMT). The full details of how this process of terminology validation is routed and managed by the IG publisher are described in the [FHIR terminology ecosystem page](/Tx-ecosystem.html)

Because some of the content in NZHTS is licensed, access to the licensed content is available only to registered users and requires a bearer token to be provided in requests from the IG publisher. This page provides guidance on how this can be configured. 

### NZHTS as an authoritative endpoint

When a build references terminology that NZHTS is authoritative for, the coordination server may direct tooling to the NZHTS FHIR endpoint:

```text
https://nzhts.digital.health.nz/fhir
```

Examples include the New Zealand edition SNOMED CT content. In SNOMED CT, the code system URI used in FHIR instances remains the SNOMED CT URI, while edition and release context may be expressed through the version or through SNOMED implicit value set URLs. 

If that selected server requires authentication, the publisher must be able to send credentials when it follows the coordination result. Otherwise terminology validation may fail even though the value set or code system is correctly published by NZHTS.

### Publisher configuration

The IG source should not contain credentials. Authentication for terminology servers is a local build environment concern. The FHIR Java tooling used by the IG Publisher can read server credentials from `fhir-settings.json`.

By default this file is located in the .fhir directory in the user / home directory. i.e.:

```text
Windows:         C:\Users\<username>\.fhir\fhir-settings.json
Unix/Linux/Mac:  ~/.fhir/fhir-settings.json
```

The IG Publisher can also be pointed at a different settings file using the `-fhir-settings` command line option. This is useful for CI, release builds or local testing where the settings file should be outside the user's normal home directory.

```text
java -jar publisher.jar -ig . -fhir-settings path/to/fhir-settings.json
```

The build environment requires: 

* credentials for each authenticated endpoint that may be selected by coordination, in this case NZHTS
* a way to refresh or replace credentials

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

### Failure modes

When the publisher cannot access an authenticated authoritative server, errors can be misleading. A build may report that a value set cannot be expanded, a code cannot be validated, or a code system is unknown, even though the underlying problem is that the selected server returned an authentication or authorization failure.

For NZHTS-backed terminology, check:

* whether the canonical URL resolves to NZHTS through the coordination server
* whether the coordination response marks the NZHTS endpoint as requiring authentication
* whether the local publisher/validator environment has credentials for that endpoint
* whether the credentials cover the operations needed by the build, such as `$expand` and `$validate-code`
* whether the settings file is in the default location or has been supplied with `-fhir-settings`
* whether the build is accidentally running with `-tx n/a`, which disables live terminology server use



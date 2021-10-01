# RestConnect

Module used for managing REST api connections and executing requests.
It is designed as a component together with AutoRest-generated code.

## Installation

To install the module, run this line:

```powershell
Install-Module RestConnect -Scope CurrentUser
```

## Use

To use this module you need to first connect to a service.
For example, to connect to the Microsoft Graph API's beta version use this code:

```powershell
$paramConnectRestService = @{
	TenantID			  = '01234567-0123-0123-0123-012345678910'
	ClientID			  = '91234567-0123-0123-0123-012345678919'
	Service			      = 'graph'
	ServiceUrl		      = 'https://graph.microsoft.com/beta'
	CertificateThumbprint = '12345F0544D9D0EB7376B11FAAECBF9BECEC3754'
}
Connect-RestService @paramConnectRestService
```

The `Service` parameter is used to differentiate between multiple parallel open connections.
It is arbitrary, however the same name must be used when using `Invoke-RestRequest`.

> Note: The Connect-RestService supports multiple authentication workflows, this only shows the certificate-based mode.

Once connected, use the `Invoke-RestRequest` command to actually execute against the connected api:

```powershell
# List all users in the current tenant
Invoke-RestRequest -Service graph -Query users -Method Get
```

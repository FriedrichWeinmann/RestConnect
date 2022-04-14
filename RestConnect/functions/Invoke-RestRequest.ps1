function Invoke-RestRequest
{
<#
	.SYNOPSIS
		Executes a web request against a rest API.
	
	.DESCRIPTION
		Executes a web request against a rest API.
		Handles all the authentication details once connected using Connect-RestService.
	
	.PARAMETER Path
		The relative path of the endpoint to query.
	
	.PARAMETER Body
		Any body content needed for the request.

    .PARAMETER Query
        Any query content to include in the request.
        In opposite to -Body this is attached to the request Url and usually used for filtering.
	
	.PARAMETER Method
		The Rest Method to use.
		Defaults to GET
	
	.PARAMETER RequiredScopes
		NOT IMPLEMENTED YET
		Any authentication scopes needed.
		When connected as a user, it will automatically try to re-authenticate with the correct scopes if they are missing in the current session.
	
	.PARAMETER Service
		Which service to execute against.

	.PARAMETER Header
		Additional header data to include.
	
	.EXAMPLE
		PS C:\> Invoke-RestRequest -Path 'alerts' -RequiredScopes 'Alert.Read' -Service mde
	
		Executes a GET request against the "mde" service's alerts endpoint.
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Path,
		
		[Hashtable]
		$Body = @{ },

        [Hashtable]
        $Query = @{ },
		
		[string]
		$Method = 'GET',
		
		[string[]]
		$RequiredScopes,
		
		[Parameter(Mandatory = $true)]
		[string]
		$Service,

		[Hashtable]
		$Header = @{ }
	)
	
	begin{
		Assert-RestConnection -Service $Service -Cmdlet $PSCmdlet
		$token = Get-Token -Service $Service -RequiredScopes $RequiredScopes -Cmdlet $PSCmdlet
		$baseUri = $token.ServiceUrl
	}
	process
	{
        $parameters = @{
            Method = $Method
            Uri = "$($baseUri)/$($Path.TrimStart('/'))"
            Headers = $token.GetHeader() + $Header
        }
		if ($Path -match '^http://|^https://') { $parameters.Uri = $Path }
		
        if ($Body.Count -gt 0) {
            $parameters.Body = $Body | ConvertTo-Json -Compress
        }
        if ($Query.Count -gt 0) {
            $parameters.Uri += ConvertTo-QueryString -QueryHash $Query
        }
		while ($parameters.Uri) {
			try { $result = Invoke-RestMethod @parameters -ErrorAction Stop }
			catch {
				Write-Error $_
				break
			}
			if ($result.Value) { $result.Value }
			else { $result }
			$parameters.Uri = $result.'@odata.nextLink'
		}
	}
}
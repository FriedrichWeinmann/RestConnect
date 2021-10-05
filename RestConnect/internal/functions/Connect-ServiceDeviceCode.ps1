function Connect-ServiceDeviceCode {
	<#
	.SYNOPSIS
		Connects to Azure AD using the Device Code authentication workflow.
	
	.DESCRIPTION
		Connects to Azure AD using the Device Code authentication workflow.
	
	.PARAMETER ServiceUrl
		The base url to the service connecting to.
		Used for authentication, scopes and executing requests.

	.PARAMETER ClientID
		The ID of the registered app used with this authentication request.
	
	.PARAMETER TenantID
		The ID of the tenant connected to with this authentication request.
	
	.PARAMETER Scopes
		The scopes to request.
		Automatically scoped to the service specified via Service Url.
		Defaults to ".Default"
	
	.EXAMPLE
		PS C:\> Connect-ServiceDeviceCode -ServiceUrl $url -ClientID '<ClientID>' -TenantID '<TenantID>'
	
		Connects to the specified tenant using the specified client, prompting the user to authorize via Browser.
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[uri]
		$ServiceUrl,

		[Parameter(Mandatory = $true)]
		[string]
		$ClientID,
        
		[Parameter(Mandatory = $true)]
		[string]
		$TenantID,
        
		[string[]]
		$Scopes = '.default'
	)

	$actualScopes = foreach ($scope in $Scopes) {
		if ($scope -like 'https://*/*') { $scope }
		else { "{0}://{1}/{2}" -f $ServiceUrl.Scheme, $ServiceUrl.Host, $scope }
	}

	try {
		$initialResponse = Invoke-RestMethod -Method POST -Uri "https://login.microsoftonline.com/$TenantID/oauth2/v2.0/devicecode" -Body @{
			client_id = $ClientID
			scope     = $actualScopes -join " "
		} -ErrorAction Stop
	}
	catch {
		throw
	}

	Write-Host $initialResponse.message

	$paramRetrieve = @{
		Uri    = "https://login.microsoftonline.com/$TenantID/oauth2/v2.0/token"
		Method = "POST"
		Body   = @{
			grant_type  = "urn:ietf:params:oauth:grant-type:device_code"
			client_id   = $ClientID
			device_code = $initialResponse.device_code
		}
		ErrorAction = 'Stop'
	}
	$limit = (Get-Date).AddSeconds($initialResponse.expires_in)
	while ($true) {
		if ((Get-Date) -gt $limit) {
			Invoke-TerminatingException -Cmdlet $PSCmdlet -Message "Timelimit exceeded, device code authentication failed" -Category AuthenticationError
		}
		Start-Sleep -Seconds $initialResponse.interval
		try { $authResponse = Invoke-RestMethod @paramRetrieve }
		catch { continue }
		if ($authResponse) {
			break
		}
	}

	[pscustomobject]@{
		AccessToken = $authResponse.access_token
		ValidAfter  = (Get-Date -Date '1970-01-01').AddSeconds($authResponse.not_before).ToLocalTime()
		ValidUntil  = (Get-Date -Date '1970-01-01').AddSeconds($authResponse.expires_on).ToLocalTime()
		Scopes      = $authResponse.scope -split " "
	}
}
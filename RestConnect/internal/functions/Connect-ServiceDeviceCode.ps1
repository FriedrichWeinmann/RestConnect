function Connect-ServiceDeviceCode {
	<#
	.SYNOPSIS
		Connects to Azure AD using the Device Code authentication workflow.
	
	.DESCRIPTION
		Connects to Azure AD using the Device Code authentication workflow.
	
	.PARAMETER Resource
		The resource to authenticate to.

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
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "")]
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Resource,

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
		if ($scope -like 'https://*/*') { $scope; continue }
		if ($scope -like "$Resource/*") { $scope; continue }
		"$Resource/$scope"
	}
	if (@($actualScopes).Count -gt 1 -and ($actualScopes | Where-Object { $_ -like '*/.default' })) {
		$actualScopes = $actualScopes | Where-Object { $_ -notlike '*/.default' }
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
		Uri         = "https://login.microsoftonline.com/$TenantID/oauth2/v2.0/token"
		Method      = "POST"
		Body        = @{
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

	$notBefore = Get-Date
	if ($authResponse.not_before) {
		$notBefore = (Get-Date -Date '1970-01-01').AddSeconds($authResponse.not_before).ToLocalTime()
	}
	$notAfter = (Get-Date).AddHours(1)
	if ($authResponse.expires_on) {
		$notAfter = (Get-Date -Date '1970-01-01').AddSeconds($authResponse.expires_on).ToLocalTime()
	}
	if ($authResponse.expires_in) {
		$notAfter = (Get-Date).AddSeconds($authResponse.expires_in).ToLocalTime()
	}
	

	[pscustomobject]@{
		AccessToken = $authResponse.access_token
		ValidAfter  = $notBefore
		ValidUntil  = $notAfter
		Scopes      = $authResponse.scope -split " "
	}
}
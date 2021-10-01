function Connect-ServicePassword {
	<#
    .SYNOPSIS
        Connect to graph using username and password.
    
    .DESCRIPTION
        Connect to graph using username and password.
        This logs into graph as a user, not as an application.
        Only cloud-only accounts can be used for this workflow.
        Consent to scopes must be granted before using them, as this command cannot show the consent prompt.
    
	.PARAMETER Service
		The name of the service to connect to.
		Label associated with the token generated, the same must be used when
		callng the Invoke-RestCommand command to associate the request with the connection.
	
	.PARAMETER ServiceUrl
		The base url to the service connecting to.
		Used for authentication, scopes and executing requests.

    .PARAMETER Credential
        Credentials of the user to connect as.
        
    .PARAMETER TenantID
        The Guid of the tenant to connect to.

    .PARAMETER ClientID
        The ClientID / ApplicationID of the application to use.
    
    .PARAMETER Scopes
        The permission scopes to request.
    
    .EXAMPLE
        PS C:\> Connect-GraphCredential -Service MyAPI -ServiceUrl $url -Credential max@contoso.com -ClientID $client -TenantID $tenant -Scopes 'user.read','user.readbasic.all'
        
        Connect as max@contoso.com with the rights to read user information.
    #>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Service,

		[Parameter(Mandatory = $true)]
		[uri]
		$ServiceUrl,

		[Parameter(Mandatory = $true)]
		[System.Management.Automation.PSCredential]
		$Credential,
        
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
    
	$request = @{
		client_id  = $ClientID
		scope      = $actualScopes -join " "
		username   = $Credential.UserName
		password   = $Credential.GetNetworkCredential().Password
		grant_type = 'password'
	}
    
	try { $authResponse = Invoke-RestMethod -Method POST -Uri "https://login.microsoftonline.com/$TenantID/oauth2/v2.0/token" -Body $request -ErrorAction Stop }
	catch { throw }
	
	[pscustomobject]@{
		AccessToken = $authResponse.access_token
		ValidAfter  = (Get-Date).AddMinutes(-5)
		ValidUntil  = (Get-Date).AddSeconds($authResponse.expires_in)
		Scopes      = @($scope -split " ")
	}
}
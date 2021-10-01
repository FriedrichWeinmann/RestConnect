function Set-RestConnection {
	<#
	.SYNOPSIS
		Register an externally provided authenticated connection.
	
	.DESCRIPTION
		Register an externally provided authenticated connection.
		Use this to connect to services not covered behind Azure AD authentication.
	
	.PARAMETER Service
		Name of the service to configure.
		Creates a new service/connection registration if the name doesn't exist yet.
	
	.PARAMETER ServiceUrl
		Url used to connect to the service.
		For example, "https://graph.microsoft.com/beta" is the ServiceUrl for the beta version of the MS graph api.
	
	.PARAMETER ValidAfter
		Starting when the token is valid
	
	.PARAMETER ValidUntil
		Until when the token is valid
	
	.PARAMETER AccessToken
		The token string used for authentication.
		Optional if your connection is established via data provided in -Data
	
	.PARAMETER Scopes
		The scopes/permissions applicable to your session.
		For documentation purposes only at the moment.
	
	.PARAMETER GetHeaderCode
		A scriptblock that will return a hashtable used as header in each webrequest.
		This is generally the "Authorization" header used to authenticate individual requests.
		Receives the token object as argument.
	
	.PARAMETER RefreshTokenCode
		Logic used to refresh the connection.
		Receives the token object as argument.
	
	.PARAMETER Data
		A hashtable of additional data to store in the token object.
		Use this for any data needed by the scriptblock logic for producing the header or refreshing the connection.
	
	.EXAMPLE
		PS C:\> Set-RestConnection -Service MyService -ServiceUrl "https://MyService.contoso.com/api" -Data $data -GetHeaderCode $headerCode -RefreshTokenCode $refreshCode

		Registers a new service connection to the MyService API
	#>
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Service,

		[string]
		$ServiceUrl,

		[DateTime]
		$ValidAfter,

		[datetime]
		$ValidUntil,

		[string]
		$AccessToken,

		[string[]]
		$Scopes,

		[scriptblock]
		$GetHeaderCode,

		[scriptblock]
		$RefreshTokenCode,

		[hashtable]
		$Data
	)
	$commonParameters = 'Verbose','Debug','ErrorAction','WarningAction','InformationAction','ErrorVariable','WarningVariable','InformationVariable','OutVariable','OutBuffer','PipelineVariable'
	$token = $script:tokens[$Service]
	if (-not $token) {
		$token = [Token]::new()
		$token.Type = 'Custom'
		$script:tokens[$Service] = $token
	}

	foreach ($key in $PSBoundParameters.Keys) {
		if ($key -eq 'Service') { continue }
		if ($key -in $commonParameters) { continue }
		$token.$key = $PSBoundParameters.$key
	}
}
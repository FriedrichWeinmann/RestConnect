function Get-Token {
<#
	.SYNOPSIS
		Retrieve the OAuth token to use for rest queries.
	
	.DESCRIPTION
		Retrieve the OAuth token to use for rest queries.
	
	.PARAMETER Service
		The service for which the token should be returned.
	
	.PARAMETER RequiredScopes
		Which scopes are needed for the token.
		In user-delegate authentication workflows, it will automatically try to add thoose scopes if not present yet.
		NOT YET IMPLEMENTED (no user-delegate authentication workflows implemented yet)
	
	.PARAMETER Cmdlet
		The $PSCmdlet variable of the caller.
		Used to kill the caller with in case of error.
	
	.EXAMPLE
		PS C:\> Get-Token -Service Endpoint -Cmdlet $PSCmdlet
	
		Retrieve the current access token for defender for endpoint.
#>
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSReviewUnusedParameter", "")]
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Service,
		
		[string[]]
		$RequiredScopes = @(),
		
		[Parameter(Mandatory = $true)]
		$Cmdlet
	)
	
	begin {
		#region Utility Functions
		function Update-Token {
			[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
			[CmdletBinding()]
			param (
				[string]
				$Service
			)
			
			$token = $script:tokens[$Service]
			$param = @{
				Service = $Service
				Resource = $token.Resource
				ClientID = $token.ClientID
				TenantID = $token.TenantID
			}
			switch ($token.Type) {
				'Certificate' {
					try { Connect-RestService @param -Certificate $token.Certificate }
					catch { throw }
				}
				'ClientSecret' {
					try { Connect-RestService @param -ClientSecret $token.ClientSecret }
					catch { throw }
				}
				'UsernamePassword' {
					try { Connect-RestService @param -Credential $token.Credential }
					catch { throw }
				}
				'DeviceCode' {
					try { Connect-RestService @param -Scopes $token.Scopes -DeviceCode }
					catch { throw }
				}
				default {
					if (-not $token.RefreshTokenCode) { throw "Unable to refresh connection to $Service - no refresh logic registered!" }
					try { & $token.RefreshTokenCode $token }
					catch { throw }
				}
			}
		}
		#endregion Utility Functions
	}
	process {
		$token = $script:tokens[$Service]
		if (-not $token) {
			Invoke-TerminatingException -Cmdlet $Cmdlet -Message "No token found for Service $Service. Establish a connection first!"
		}
		if ($token.ValidUntil -gt (Get-Date).AddMinutes(2)) {
			return $token
		}
		
		try { Update-Token -Service $Service -ErrorAction Stop }
		catch {
			Invoke-TerminatingException -Cmdlet $Cmdlet -Message "Failed to refresh the access token" -ErrorRecord $_
		}
		
		$script:tokens[$Service]
	}
}
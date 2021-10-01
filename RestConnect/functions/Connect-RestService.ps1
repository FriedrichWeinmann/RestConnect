function Connect-RestService {
	<#
		.SYNOPSIS
			Establish a connection to a REST API.
		
		.DESCRIPTION
			Establish a connection to a REST API.
			Prerequisite before executing any requests / commands.
			
			Note:
			Used for authenticating against Microsoft Authentication services.
			For other authentication services, use "Set-RestServiceConnection" instead.

		.PARAMETER Service
			The name of the service to connect to.
			Label associated with the token generated, the same must be used when
			callng the Invoke-RestCommand command to associate the request with the connection.
		
		.PARAMETER ServiceUrl
			The base url to the service connecting to.
			Used for authentication, scopes and executing requests.

		.PARAMETER ClientID
			ID of the registered/enterprise application used for authentication.
		
		.PARAMETER TenantID
			The ID of the tenant/directory to connect to.
		
		.PARAMETER Scopes
			Any scopes to include in the request.
			Only used for interactive/delegate workflows, ignored for Certificate based authentication or when using Client Secrets.
		
		.PARAMETER Certificate
			The Certificate object used to authenticate with.
			
			Part of the Application Certificate authentication workflow.
		
		.PARAMETER CertificateThumbprint
			Thumbprint of the certificate to authenticate with.
			The certificate must be stored either in the user or computer certificate store.
			
			Part of the Application Certificate authentication workflow.
		
		.PARAMETER CertificateName
			The name/subject of the certificate to authenticate with.
			The certificate must be stored either in the user or computer certificate store.
			The newest certificate with a private key will be chosen.
			
			Part of the Application Certificate authentication workflow.
		
		.PARAMETER CertificatePath
			Path to a PFX file containing the certificate to authenticate with.
			
			Part of the Application Certificate authentication workflow.
		
		.PARAMETER CertificatePassword
			Password to use to read a PFX certificate file.
			Only used together with -CertificatePath.
			
			Part of the Application Certificate authentication workflow.
		
		.PARAMETER ClientSecret
			The client secret configured in the registered/enterprise application.
			
			Part of the Client Secret Certificate authentication workflow.

		.PARAMETER Credential
			The credentials to use to authenticate as a user.

			Part of the Username and Password delegate authentication workflow.
			Note: This workflow only works with cloud-only accounts and requires scopes to be pre-approved.
		
		.EXAMPLE
			PS C:\> Connect-RestService -Service MyAPI -ServiceUrl $url -ClientID $clientID -TenantID $tenantID -Certificate $cert
		
			Establish a connection to a rest API using the provided certificate.
		
		.EXAMPLE
			PS C:\> Connect-RestService -Service MyAPI -ServiceUrl $url -ClientID $clientID -TenantID $tenantID -CertificatePath C:\secrets\certs\mde.pfx -CertificatePassword (Read-Host -AsSecureString)
		
			Establish a connection to a rest API using the provided certificate file.
			Prompts you to enter the certificate-file's password first.
		
		.EXAMPLE
			PS C:\> Connect-RestService -Service MyAPI -ServiceUrl $url -ClientID $clientID -TenantID $tenantID -ClientSecret $secret
		
			Establish a connection to a rest API using a client secret.
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Service,

		[Parameter(Mandatory = $true)]
		[string]
		$ServiceUrl,

		[Parameter(Mandatory = $true)]
		[string]
		$ClientID,
			
		[Parameter(Mandatory = $true)]
		[string]
		$TenantID,
			
		[string[]]
		$Scopes,
			
		[Parameter(ParameterSetName = 'AppCertificate')]
		[System.Security.Cryptography.X509Certificates.X509Certificate2]
		$Certificate,
			
		[Parameter(ParameterSetName = 'AppCertificate')]
		[string]
		$CertificateThumbprint,
			
		[Parameter(ParameterSetName = 'AppCertificate')]
		[string]
		$CertificateName,
			
		[Parameter(ParameterSetName = 'AppCertificate')]
		[string]
		$CertificatePath,
			
		[Parameter(ParameterSetName = 'AppCertificate')]
		[System.Security.SecureString]
		$CertificatePassword,
			
		[Parameter(Mandatory = $true, ParameterSetName = 'AppSecret')]
		[System.Security.SecureString]
		$ClientSecret,

		[Parameter(Mandatory = $true, ParameterSetName = 'UsernamePassword')]
		[PSCredential]
		$Credemtial
	)
	
	process {
		switch ($PSCmdlet.ParameterSetName) {
			'AppSecret' {
				$serviceToken = [Token]::new($ClientID, $TenantID, $ClientSecret, $ServiceUrl)
				try { $authToken = Connect-ServiceClientSecret -Service $Service -ServiceUrl $ServiceUrl -ClientID $ClientID -TenantID $TenantID -ClientSecret $ClientSecret -ErrorAction Stop }
				catch {
					Invoke-TerminatingException -Cmdlet $PSCmdlet -ErrorRecord $_
				}
				$serviceToken.SetTokenMetadata($authToken)
				$script:tokens[$Service] = $serviceToken
			}
			'AppCertificate' {
				try { $cert = Resolve-Certificate -BoundParameters $PSBoundParameters }
				catch {
					throw
				}
				if (-not $cert) {
					Invoke-TerminatingException -Cmdlet $PSCmdlet -Message "No certificate found to authenticate with!"
				}
				if (-not $cert.HasPrivateKey) {
					Invoke-TerminatingException -Cmdlet $PSCmdlet -Message "Certificate has no private key: $($cert.Thumbprint)"
				}
				if (-not $cert.PrivateKey) {
					Invoke-TerminatingException -Cmdlet $PSCmdlet -Message "Failed to access private key on Certificate $($cert.Thumbprint)"
				}
				
				$serviceToken = [Token]::new($ClientID, $TenantID, $cert, $ServiceUrl)
				try { $authToken = Connect-ServiceCertificate -Service $Service -ServiceUrl $ServiceUrl -ClientID $ClientID -TenantID $TenantID -Certificate $cert -ErrorAction Stop }
				catch {
					Invoke-TerminatingException -Cmdlet $PSCmdlet -ErrorRecord $_
				}
				$serviceToken.SetTokenMetadata($authToken)
				$script:tokens[$Service] = $serviceToken
			}
			'UsernamePassword' {
				$serviceToken = [Token]::new($ClientID, $TenantID, $Credential, $ServiceUrl)
				try { $authToken = Connect-ServicePassword -Service $Service -ServiceUrl $ServiceUrl -ClientID $ClientID -TenantID $TenantID -Credential $Credential -ErrorAction Stop }
				catch {
					Invoke-TerminatingException -Cmdlet $PSCmdlet -ErrorRecord $_
				}
				$serviceToken.SetTokenMetadata($authToken)
				$script:tokens[$Service] = $serviceToken
			}
		}
	}
}
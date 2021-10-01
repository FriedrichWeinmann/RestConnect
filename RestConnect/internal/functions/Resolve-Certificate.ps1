function Resolve-Certificate {
	<#
	.SYNOPSIS
		Resolves the certificate to use for authentication.
	
	.DESCRIPTION
		Resolves the certificate to use for authentication.
		Offers a centralized way to resolve certificate based on parameters passed through.

		Silently returns nothing if no match was found, which needs to be handled by the caller.
	
	.PARAMETER BoundParameters
		The parameters passed to the calling command.
		Will pick certificate-related parameters and figure out the cert to use from that.

		- Certificate: Assumes a full certificate specified and returns it
		- CertificateThumbprint: Searches current user and system cert store for a matching cert to use
		- CertificateName: Searches current user and system cert store for a matching cert to use (based on subject)
		- CertificatePath & CertificatePassword: Loads certificate from file

		Will be processed in the order above if multiple options are specified.
	
	.EXAMPLE
		PS C:\> Resolve-Certificate -BoundParameters $PSBoundParameters

		Resolves the certificate to use for authentication.
	#>
	[CmdletBinding()]
	param (
		$BoundParameters
	)
		
	if ($BoundParameters.Certificate) { return $BoundParameters.Certificate }
	if ($BoundParameters.CertificateThumbprint) {
		if (Test-Path -Path "cert:\CurrentUser\My\$($BoundParameters.CertificateThumbprint)") {
			return Get-Item "cert:\CurrentUser\My\$($BoundParameters.CertificateThumbprint)"
		}
		if (Test-Path -Path "cert:\LocalMachine\My\$($BoundParameters.CertificateThumbprint)") {
			return Get-Item "cert:\LocalMachine\My\$($BoundParameters.CertificateThumbprint)"
		}
	}
	if ($BoundParameters.CertificateName) {
		if ($certificate = (Get-ChildItem 'Cert:\CurrentUser\My\').Where{ $_.Subject -eq $BoundParameters.CertificateName -and $_.HasPrivateKey }) {
			return $certificate | Sort-Object NotAfter -Descending | Select-Object -First 1
		}
		if ($certificate = (Get-ChildItem 'Cert:\LocalMachine\My\').Where{ $_.Subject -eq $BoundParameters.CertificateName -and $_.HasPrivateKey }) {
			return $certificate | Sort-Object NotAfter -Descending | Select-Object -First 1
		}
	}
	if ($BoundParameters.CertificatePath) {
		try { [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($BoundParameters.CertificatePath, $BoundParameters.CertificatePassword) }
		catch {
			Invoke-TerminatingException -Cmdlet $PSCmdlet -Message "Unable to load certificate from file '$($BoundParameters.CertificatePath)': $_" -ErrorRecord $_
		}
	}
}
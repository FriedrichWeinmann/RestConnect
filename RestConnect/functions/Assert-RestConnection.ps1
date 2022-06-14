function Assert-RestConnection
{
<#
	.SYNOPSIS
		Asserts a connection to the specified rest api has been established.
	
	.DESCRIPTION
		Asserts a connection to the specified rest api has been established.
		Fails the calling command in a terminating exception if not connected yet.
		
	.PARAMETER Service
		The service to which a connection needs to be established.
	
	.PARAMETER Cmdlet
		The $PSCmdlet variable of the calling command.
		Used to execute the terminating exception in the caller scope if needed.
	
	.EXAMPLE
		PS C:\> Assert-Connection -Service 'Endpoint' -Cmdlet $PSCmdlet
	
		Silently does nothing if already connected to the service 'Endpoint'.
		Kills the calling command if not yet connected.
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Service,
		
		[Parameter(Mandatory = $true)]
		$Cmdlet
	)
	
	process
	{
		if ($script:tokens[$Service]) { return }
		
		$message = "Not connected yet! Use Connect-RestService (or a service specific connection method) to establish a connection first."
		if ($script:serviceMetadata.$Service.NotConnectedMessage) {
			$message = $script:serviceMetadata.$Service.NotConnectedMessage
		}

		Invoke-TerminatingException -Cmdlet $Cmdlet -Message $message -Category ConnectionError
	}
}
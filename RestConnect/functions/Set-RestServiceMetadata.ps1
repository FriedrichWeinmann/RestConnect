function Set-RestServiceMetadata {
	<#
	.SYNOPSIS
		Define service metadata for a connected service.
	
	.DESCRIPTION
		Define service metadata for a connected service.
		This allows defining some behavior around a registered service, even before connection is established.
	
	.PARAMETER Service
		The name of the service to configure.
	
	.PARAMETER NotConnectedMessage
		The message to display when trying to execute over a service not yet connected to.
		Allows overriding the default "Please run Connect-RestService" message.
	
	.EXAMPLE
		PS C:\> Set-RestServiceMetadata -Service AzureDevOps -NotConnectedMessage $message
		
		Override the default error message when trying to run AzureDevOps commands before connecting.
	#>
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Service,

		[string]
		$NotConnectedMessage
	)

	if (-not $script:serviceMetadata[$Service]) {
		$script:serviceMetadata[$Service] = @{
			Name = $Service
			NotConnectedMessage = ''
		}
	}

	if ($PSBoundParameters.Keys -contains 'NotConnectedMessage') {
		$script:serviceMetadata[$Service].NotConnectedMessage = $NotConnectedMessage
	}
}
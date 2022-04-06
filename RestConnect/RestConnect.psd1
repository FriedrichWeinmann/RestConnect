@{

	# Script module or binary module file associated with this manifest.
	RootModule        = 'RestConnect.psm1'

	# Version number of this module.
	ModuleVersion     = '1.0.4'

	# Supported PSEditions
	# CompatiblePSEditions = @()

	# ID used to uniquely identify this module
	GUID              = '4e9d2f0a-86e4-4d80-a7f3-de8b8686f100'

	# Author of this module
	Author            = 'Friedrich Weinmann'

	# Company or vendor of this module
	CompanyName       = 'Microsoft'

	# Copyright statement for this module
	Copyright         = '(c) Friedrich Weinmann# . All rights reserved.'

	# Description of the functionality provided by this module
	Description       = 'Authentication and request execution for API clients generated from AutoRest'

	# Type files (.ps1xml) to be loaded when importing this module
	# TypesToProcess = @()

	# Format files (.ps1xml) to be loaded when importing this module
	# FormatsToProcess = @()

	# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
	FunctionsToExport = @(
		'Assert-RestConnection'
		'Connect-RestService'
		'Invoke-RestRequest'
		'Set-RestConnection'
	)

	# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
	PrivateData       = @{

		PSData = @{

			# Tags applied to this module. These help with module discovery in online galleries.
			Tags       = @('rest')

			# A URL to the license for this module.
			LicenseUri = 'https://github.com/FriedrichWeinmann/RestConnect/blob/master/LICENSE'

			# A URL to the main website for this project.
			ProjectUri = 'https://github.com/FriedrichWeinmann/RestConnect'

			# A URL to an icon representing this module.
			# IconUri = ''

			# ReleaseNotes of this module
			# ReleaseNotes = ''

			# Prerelease string of this module
			# Prerelease = ''

		} # End of PSData hashtable

	} # End of PrivateData hashtable
}
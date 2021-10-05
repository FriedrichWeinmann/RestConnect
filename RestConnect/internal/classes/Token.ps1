class Token {
	#region Token Data
	[string]$AccessToken
	[System.DateTime]$ValidAfter
	[System.DateTime]$ValidUntil
	[string[]]$Scopes
	#endregion Token Data
	
	#region Connection Data
	[string]$Type
	[string]$ClientID
	[string]$TenantID
	[string]$ServiceUrl
	
	# Workflow: Client Secret
	[System.Security.SecureString]$ClientSecret
	
	# Workflow: Certificate
	[System.Security.Cryptography.X509Certificates.X509Certificate2]$Certificate

	# Workflow: Username & Password
	[PSCredential]$Credential
	#endregion Connection Data
	
	#region Extension Data
	[hashtable]$Data = @{ }
	[scriptblock]$GetHeaderCode
	[scriptblock]$RefreshTokenCode
	#endregion Extension Data

	#region Constructors
	Token([string]$ClientID, [string]$TenantID, [Securestring]$ClientSecret, [string]$ServiceUrl) {
		$this.ClientID = $ClientID
		$this.TenantID = $TenantID
		$this.ClientSecret = $ClientSecret
		$this.ServiceUrl = $ServiceUrl
		$this.Type = 'ClientSecret'
	}

	Token([string]$ClientID, [string]$TenantID, [pscredential]$Credential, [string]$ServiceUrl) {
		$this.ClientID = $ClientID
		$this.TenantID = $TenantID
		$this.Credential = $Credential
		$this.ServiceUrl = $ServiceUrl
		$this.Type = 'UsernamePassword'
	}

	Token([string]$ClientID, [string]$TenantID, [bool]$DeviceCode, [string]$ServiceUrl) {
		$this.ClientID = $ClientID
		$this.TenantID = $TenantID
		$this.ServiceUrl = $ServiceUrl
		$this.Type = 'DeviceCode'
	}
	
	Token([string]$ClientID, [string]$TenantID, [System.Security.Cryptography.X509Certificates.X509Certificate2]$Certificate, [string]$ServiceUrl) {
		$this.ClientID = $ClientID
		$this.TenantID = $TenantID
		$this.Certificate = $Certificate
		$this.ServiceUrl = $ServiceUrl
		$this.Type = 'Certificate'
	}
	#endregion Constructors

    [void]SetTokenMetadata([PSObject] $AuthToken) {
        $this.AccessToken = $AuthToken.AccessToken
        $this.ValidAfter = $AuthToken.ValidAfter
        $this.ValidUntil = $AuthToken.ValidUntil
        $this.Scopes = $AuthToken.Scopes
    }

	[hashtable]GetHeader() {
		if ($this.GetHeaderCode) { return & $this.GetHeaderCode $this }
		return @{ Authorization = "Bearer $($this.AccessToken)" }
	}
}
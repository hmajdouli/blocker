using namespace System.Collections.Generic

function ConvertTo-MetadataJson {
    param (
        [Parameter(Mandatory)]
        [string]$Endpoint,

        [Parameter(Mandatory)]
        [string]$CodeSigningAccountName,

        [Parameter(Mandatory)]
        [string]$CertificateProfileName,

        [Parameter()]
        [switch]$ExcludeEnvironmentCredential = $false,

        [Parameter()]
        [switch]$ExcludeManagedIdentityCredential = $false,

        [Parameter()]
        [switch]$ExcludeSharedTokenCacheCredential = $false,

        [Parameter()]
        [switch]$ExcludeVisualStudioCredential = $false,

        [Parameter()]
        [switch]$ExcludeVisualStudioCodeCredential = $false,

        [Parameter()]
        [switch]$ExcludeAzureCliCredential = $false,

        [Parameter()]
        [switch]$ExcludeAzurePowerShellCredential = $false,

        [Parameter()]
        [switch]$ExcludeInteractiveBrowserCredential = $false
    )

    $exclusions = [List[string]]::new()

    if ($ExcludeEnvironmentCredential) {
        $exclusions.Add("EnvironmentCredential")
    }

    if ($ExcludeManagedIdentityCredential) {
        $exclusions.Add("ManagedIdentityCredential")
    }

    if ($ExcludeSharedTokenCacheCredential) {
        $exclusions.Add("SharedTokenCacheCredential")
    }

    if ($ExcludeVisualStudioCredential) {
        $exclusions.Add("VisualStudioCredential")
    }

    if ($ExcludeVisualStudioCodeCredential) {
        $exclusions.Add("VisualStudioCodeCredential")
    }

    if ($ExcludeAzureCliCredential) {
        $exclusions.Add("AzureCliCredential")
    }

    if ($ExcludeAzurePowerShellCredential) {
        $exclusions.Add("AzurePowerShellCredential")
    }

    if ($ExcludeInteractiveBrowserCredential) {
        $exclusions.Add("InteractiveBrowserCredential")
    }

    $metadata = [ordered]@{
        Endpoint = $Endpoint
        CodeSigningAccountName = $CodeSigningAccountName
        CertificateProfileName = $CertificateProfileName
        ExcludeCredentials = $exclusions
    }

    return $metadata | ConvertTo-Json -Compress
}

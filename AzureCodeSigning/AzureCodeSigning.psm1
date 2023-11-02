using namespace System.Collections.Generic
using namespace System.IO

function Invoke-AzureCodeSigning {
    param (
        [Parameter(Mandatory)]
        [string]$Endpoint,

        [Parameter(Mandatory)]
        [string]$CodeSigningAccountName,

        [Parameter(Mandatory)]
        [string]$CertificateProfileName,

        [Parameter()]
        [AllowEmptyString()]
        [string]$FilesFolder,

        [Parameter()]
        [AllowEmptyString()]
        [string]$FilesFolderFilter,

        [Parameter()]
        [switch]$FilesFolderRecurse = $false,

        [Parameter()]
        [AllowNull()]
        [int]$FilesFolderDepth,

        [Parameter()]
        [AllowEmptyString()]
        [string]$FilesCatalog,

        [Parameter(Mandatory)]
        [string]$FileDigest,

        [Parameter()]
        [AllowEmptyString()]
        [string]$TimestampRfc3161,

        [Parameter()]
        [AllowEmptyString()]
        [string]$TimestampDigest,

        [Parameter()]
        [switch]$AppendSignature = $false,

        [Parameter()]
        [AllowEmptyString()]
        [string]$Description,

        [Parameter()]
        [AllowEmptyString()]
        [string]$DescriptionUrl,

        [Parameter()]
        [AllowEmptyString()]
        [string]$GenerateDigestPath,

        [Parameter()]
        [switch]$GenerateDigestXml = $false,

        [Parameter()]
        [AllowEmptyString()]
        [string]$IngestDigestPath,
		
		[Parameter()]
        [AllowEmptyString()]
		[string]$Pkcs7Path,
		
        [Parameter()]
        [switch]$SignDigest = $false,

        [Parameter()]
        [switch]$GeneratePageHashes = $false,

        [Parameter()]
        [switch]$SuppressPageHashes = $false,

        [Parameter()]
        [switch]$GeneratePkcs7 = $false,

        [Parameter()]
        [AllowEmptyString()]
        [string]$Pkcs7Options,

        [Parameter()]
        [AllowEmptyString()]
        [string]$Pkcs7Oid,

        [Parameter()]
        [AllowEmptyString()]
        [string]$EnhancedKeyUsage,

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
        [switch]$ExcludeInteractiveBrowserCredential = $false,

        [Parameter()]
        [int]$Timeout = 300
    )

    # Install signtool.exe and the Azure Code Signing binaries.
    $packageSource = Get-NugetV2PackageSource
    $signToolFolderPath = Install-BuildToolsPackage -PackageSource $PackageSource
	Write-Host "signToolFolderPath"
	Write-Host $signToolFolderPath

    $dlibFolderPath = Install-AzureCodeSigningPackage -PackageSource $PackageSource
	Write-Host "dlibFolderPath"
	Write-Host $dlibFolderPath
	
    # Create the Azure Code Signing metadata.json file that is passed to signtool.exe.
    $metadataFilePath = Join-Path -Path $dlibFolderPath -ChildPath "metadata.json"
    $convertToMetadataJsonParams = @{
        Endpoint = $Endpoint
        CodeSigningAccountName = $CodeSigningAccountName
        CertificateProfileName = $CertificateProfileName
        ExcludeEnvironmentCredential = $ExcludeEnvironmentCredential
        ExcludeManagedIdentityCredential = $ExcludeManagedIdentityCredential
        ExcludeSharedTokenCacheCredential = $ExcludeSharedTokenCacheCredential
        ExcludeVisualStudioCredential = $ExcludeVisualStudioCredential
        ExcludeVisualStudioCodeCredential = $ExcludeVisualStudioCodeCredential
        ExcludeAzureCliCredential = $ExcludeAzureCliCredential
        ExcludeAzurePowerShellCredential = $ExcludeAzurePowerShellCredential
        ExcludeInteractiveBrowserCredential = $ExcludeInteractiveBrowserCredential
    }
    $metadataJson = ConvertTo-MetadataJson @convertToMetadataJsonParams
    [File]::WriteAllLines($metadataFilePath, $metadataJson)

    # Get the list of files to be signed from the files folder and the catalog file.
    if ([string]::IsNullOrWhiteSpace($FilesFolder)) {
        $filteredFiles = [List[string]]::new()
    } else {
        $getFilteredFileListParams = @{
            Path = $FilesFolder
            Filter = $FilesFolderFilter
            Recurse = $FilesFolderRecurse
            Depth = $FilesFolderDepth
        }
        $filteredFiles = Get-FilteredFileList @getFilteredFileListParams
    }

    if ([string]::IsNullOrWhiteSpace($FilesCatalog)) {
        $catalogFiles = [List[string]]::new()
    } else {
        $catalogFiles = Get-CatalogFileList -Path $FilesCatalog
    }

    $formattedFileList = Format-FileList -FilteredFiles $filteredFiles -CatalogFiles $catalogFiles

    # Format the arguments that will be passed to signtool.exe.
    $dlibFilePath = Join-Path -Path $dlibFolderPath -ChildPath "Azure.CodeSigning.Dlib.dll"
    $formatSignToolArgumentListParams = @{
        FileList = $formattedFileList
        FileDigest = $FileDigest
        TimestampRfc3161 = $TimestampRfc3161
        TimestampDigest = $TimestampDigest
        DlibFilePath = $dlibFilePath
        MetadataFilePath = $metadataFilePath
        AppendSignature = $AppendSignature
        Description = $Description
        DescriptionUrl = $DescriptionUrl
        GenerateDigestPath = $GenerateDigestPath
        GenerateDigestXml = $GenerateDigestXml
        IngestDigestPath = $IngestDigestPath
		Pkcs7Path = $Pkcs7Path
        SignDigest = $SignDigest
        GeneratePageHashes = $GeneratePageHashes
        SuppressPageHashes = $SuppressPageHashes
        GeneratePkcs7 = $GeneratePkcs7
        Pkcs7Options = $Pkcs7Options
        Pkcs7Oid = $Pkcs7Oid
        EnhancedKeyUsage = $EnhancedKeyUsage
    }
    $signToolArguments = Format-SignToolArgumentList @formatSignToolArgumentListParams

    # Run signtool.exe.
    $invokeSignToolParams = @{
        SignToolFolderPath = $signToolFolderPath
        SignToolArguments = $signToolArguments
        Timeout = $Timeout
    }
    return Invoke-SignTool @invokeSignToolParams
}

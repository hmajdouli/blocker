using namespace System
using namespace System.Collections.Generic

function Format-SignToolArgumentList {
    param (
        [Parameter(Mandatory)]
        [List[string]]$FileList,

        [Parameter(Mandatory)]
        [string]$FileDigest,

        [Parameter()]
        [AllowEmptyString()]
        [string]$TimestampRfc3161,

        [Parameter()]
        [AllowEmptyString()]
        [string]$TimestampDigest,

        [Parameter(Mandatory)]
        [string]$DlibFilePath,

        [Parameter(Mandatory)]
        [string]$MetadataFilePath,

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
        [string]$EnhancedKeyUsage
    )

    $result = [List[string]]::new()
    $result.Add("sign")
    $result.Add("/v")
    $result.Add("/debug")

    $result.Add("/fd")
    $result.Add($FileDigest)

    if ($TimestampRfc3161) {
        $result.Add("/tr")
        $result.Add($TimestampRfc3161)
    }

    if ($TimestampDigest) {
        $result.Add("/td")
        $result.Add($TimestampDigest)
    }

    $result.Add("/dlib")
    $result.Add("`"$DlibFilePath`"")

    $result.Add("/dmdf")
    $result.Add("`"$MetadataFilePath`"")

    if ($AppendSignature) {
        $result.Add("/as")
    }

    if ($Description) {
        $result.Add("/d")
        $result.Add("`"$Description`"")
    }

    if ($DescriptionUrl) {
        $result.Add("/du")
        $result.Add("`"$DescriptionUrl`"")
    }

    if ($GenerateDigestPath) {
        $result.Add("/dg")
        $result.Add("`"$GenerateDigestPath`"")
    }

    if ($GenerateDigestXml) {
        $result.Add("/dxml")
    }

    if ($IngestDigestPath) {
        $result.Add("/di")
        $result.Add("`"$IngestDigestPath`"")
    }

    if ($SignDigest) {
        $result.Add("/ds")
    }

    if ($GeneratePageHashes) {
        $result.Add("/ph")
    }

    if ($SuppressPageHashes) {
        $result.Add("/nph")
    }

    if ($GeneratePkcs7) {
        $result.Add("/p7")
        $result.Add("`"$Pkcs7Path`"")
    }

    if ($Pkcs7Options) {
        $result.Add("/p7ce")
        $result.Add("`"$Pkcs7Options`"")
    }

    if ($Pkcs7Oid) {
        $result.Add("/p7co")
        $result.Add("`"$Pkcs7Oid`"")
    }

    if ($EnhancedKeyUsage) {
        $result.Add("/u")
        $result.Add("`"$EnhancedKeyUsage`"")
    }

    $result.AddRange($FileList)

    return $result
}

function Invoke-SignTool {
    param (
        [Parameter(Mandatory)]
        [string]$SignToolFolderPath,

        [Parameter(Mandatory)]
        [List[string]]$SignToolArguments,

        [Parameter(Mandatory)]
        [int]$Timeout
    )

    $signToolPath = Join-Path -Path $SignToolFolderPath -ChildPath "signtool.exe"

    $startProcessParams = @{
        FilePath = $signToolPath
        ArgumentList = $SignToolArguments
        NoNewWindow = $true
        PassThru = $true
    }
    $process = Start-Process @startProcessParams

    try {
        Wait-Process -InputObject $process -Timeout $Timeout
    } catch [TimeoutException] {
        throw "Request to the Azure Code Signing service timed out after $Timeout seconds"
    }

    if ($process.ExitCode -eq 0) {
        return "Azure Code Signing completed successfully"
    } else {
        throw "SignTool failed with exit code $($process.ExitCode)"
    }
}

function Get-NugetV2PackageSource {
    $location = "https://www.nuget.org/api/v2/"

    try {
        $source = Get-PackageSource -Location $location -ErrorAction Stop
        $source = $source | Select-Object -First 1
        return $source.Name
    } catch {
        $registerPackageSourceParams = @{
            Name = "azure-code-signing-ps"
            Location = $location
            ProviderName = "NuGet"
        }
        $source = Register-PackageSource @registerPackageSourceParams
        return $source.Name
    }
}

function Install-BuildToolsPackage {
    param (
        [Parameter(Mandatory)]
        [string]$PackageSource
    )

    $buildToolsPackageInfo = Get-BuildToolsPackageInfo
    $installNugetPackageParams = @{
        PackageName = $buildToolsPackageInfo.PackageName
        PackageVersion = $buildToolsPackageInfo.PackageVersion
        ContentPath = $buildToolsPackageInfo.ContentPath
        PackageSource = $PackageSource
    }
    return Install-NugetPackage @installNugetPackageParams
}

function Get-BuildToolsPackageInfo {
    return @{
        PackageName = "Microsoft.Windows.SDK.BuildTools"
        PackageVersion = "10.0.22621.755"
        ContentPath = "bin\10.0.22621.0\x64"
    }
}

function Install-AzureCodeSigningPackage {
    param (
        [Parameter(Mandatory)]
        [string]$PackageSource
    )

    $azureCodeSigningPackageInfo = Get-AzureCodeSigningPackageInfo
    $installNugetPackageParams = @{
        PackageName = $azureCodeSigningPackageInfo.PackageName
        PackageVersion = $azureCodeSigningPackageInfo.PackageVersion
        ContentPath = $azureCodeSigningPackageInfo.ContentPath
        PackageSource = $PackageSource
    }
    return Install-NugetPackage @installNugetPackageParams
}

function Get-AzureCodeSigningPackageInfo {
    return @{
        PackageName = "Azure.CodeSigning.Client"
        PackageVersion = "1.0.34"
        ContentPath = "bin\x64"
    }
}

function Install-NugetPackage {
    param (
        [Parameter(Mandatory)]
        [string]$PackageName,

        [Parameter(Mandatory)]
        [string]$PackageVersion,

        [Parameter(Mandatory)]
        [string]$ContentPath,

        [Parameter(Mandatory)]
        [string]$PackageSource
    )

    $appDataPath = $env:localappdata
    $azureCodeSigningPath = Join-Path -Path $appDataPath -ChildPath "AzureCodeSigning"

    $packageFolderPath = Join-Path -Path $azureCodeSigningPath -ChildPath $PackageName
    if (-Not (Test-Path -Path $packageFolderPath)) {
        New-Item -Path $packageFolderPath -ItemType Directory | Out-Null
    }

    $packageInstallPath = Join-Path -Path $packageFolderPath -ChildPath "$PackageName.$PackageVersion"
    if (-Not (Test-Path -Path $packageInstallPath)) {
        Remove-Item -Path "$packageFolderPath\*" -Recurse -Force

        $installPackageParams = @{
            Name = $PackageName
            RequiredVersion = $PackageVersion
            Source = $PackageSource
            Destination = $packageFolderPath
            Force = $true
        }
        Install-Package @installPackageParams | Out-Null
    }

    return Join-Path -Path $packageInstallPath -ChildPath $ContentPath
}

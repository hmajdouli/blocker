using namespace System.Collections.Generic

function Get-FilteredFileList {
    param (
        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter()]
        [AllowEmptyString()]
        [string]$Filter,

        [Parameter()]
        [switch]$Recurse = $false,

        [Parameter()]
        [AllowNull()]
        [int]$Depth
    )

    $filteredFiles = [List[string]]::new()

    # Get the List of files from the specified folder path.
    $getChildItemParams = @{
        Path = $Path
        File = $true
    }

    if ($Recurse) {
        $getChildItemParams["Recurse"] = $Recurse
    }

    if ($Depth) {
        $getChildItemParams["Depth"] = $Depth
    }

    $fileList = Get-ChildItem @getChildItemParams

    # Parse the List of comma-separated file extensions into a HashSet.
    $filterExtensions = [HashSet[string]]::new()

    if ($Filter) {
        foreach ($extension in $Filter.Split(",")) {
            $filterExtensions.Add($extension) | Out-Null
        }
    }

    # If any file has an extension that is contained in the filterExtensions HashSet, add it to the
    # List. If the HashSet is empty, add all the files to the List.
    foreach ($file in $fileList) {
        $extension = $file.extension
        if (-not [string]::IsNullOrEmpty($extension)) {
            # Remove the starting period from the extension string.
            $extension = $extension.substring(1)
        }

        if (($filterExtensions.Count -eq 0) -or ($filterExtensions.Contains($extension))) {
            $fullPath = Join-Path -Path $file.DirectoryName -ChildPath $file.Name
            $filteredFiles.Add($fullPath)
        }
    }

    return , $filteredFiles
}

function Get-CatalogFileList {
    param (
        [Parameter(Mandatory)]
        [string]$Path
    )

    $fileList = [List[string]]::new()

    $folderPath = Split-Path -Parent $Path
    foreach ($line in Get-Content (Resolve-Path $Path)) {
        $filePath = Join-Path -Path $folderPath -ChildPath $line
        $filePath = Resolve-Path $filePath
        $fileList.Add($filePath)
    }

    return , $fileList
}

function Format-FileList {
    param (
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [List[string]]$FilteredFiles,

        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [List[string]]$CatalogFiles
    )

    $formattedFileList = [List[string]]::new()

    $printMsixWarning = $true
    $fileList = $FilteredFiles + $CatalogFiles
    foreach ($file in $fileList) {
        if (($file.EndsWith(".msix")) -and $printMsixWarning) {
            Write-Warning (-join @(
                "To successfully sign an .msix/.appx package using an Azure Code"
                " Signing certificate, the certificate's subject name must be the"
                " same as the 'Publisher' listed in the app's manifest."
            ))
            $printMsixWarning = $false
        }

        $formattedFileList.Add("`"${file}`"")
    }

    return , $formattedFileList
}

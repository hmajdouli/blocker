#
# Module manifest for module "SignTool"
#
# Generated by: James Parsons
#
# Generated on: 8/7/2022
#

@{

    # Script module or binary module file associated with this manifest.
    RootModule = "SignTool.psm1"

    # Version number of this module.
    ModuleVersion = "0.0.0"

    # ID used to uniquely identify this module
    GUID = "1FFEB28D-5410-4D0D-81CA-84E82CE3559B"

    # Author of this module
    Author = "James Parsons"

    # Company or vendor of this module
    CompanyName = "Microsoft"

    # Copyright statement for this module
    Copyright = "MIT License, Copyright (c) Microsoft Corporation"

    # Description of the functionality provided by this module
    Description = "Enables formatting of signtool.exe command line arguments."

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    NestedModules = @()

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @(
        "Format-SignToolArgumentList",
        "Invoke-SignTool"
    )

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport = @()

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport = @()

    # List of all modules packaged with this module
    ModuleList = @()

    # List of all files packaged with this module
    FileList = @()

    # HelpInfo URI of this module
    HelpInfoURI = "https://github.com/Azure/azure-code-signing-powershell"

    }

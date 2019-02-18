[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

Trace-VstsEnteringInvocation $MyInvocation

try {
        
    Import-VstsLocStrings "$PSScriptRoot\Task.json"
    
    <#
     # INPUT VARIABLES: Inputs based on the variables that have been defined within the Azure DevOps task parameter values
    #>

    [string]$TFE_HOST = Get-VstsInput -Name tfe_host
    [string]$TFE_TOKEN = Get-VstsInput -Name tfe_token
    [string]$TFE_WORKSPACE = Get-VstsInput -Name tfe_workspace
    [bool]$TFE_WORKSPACE_SPEC = Get-VstsInput -Name tfe_workspace_spec -AsBool
    [string]$TFE_ORGANIZATION = Get-VstsInput -Name tfe_organization
    [bool]$TFE_VARIABLES_SPEC = Get-VstsInput -Name tfe_variables_spec -AsBool
    [string]$TFE_VARIABLES = Get-VstsInput -Name tfe_variables
    [string]$TFE_TEMPLATE_PATH = Get-VstsInput -Name tfe_template_path


    <#
     # MAIN
    #>

    Import-Module "$PSScriptRoot\ps_modules\HashiCorp\HashiHelper.psm1" -Force

    Get-TerraformWorkspace -Hostname $TFE_HOST -Organization $TFE_ORGANIZATION -WorkSpaceName $TFE_WORKSPACE -Token $TFE_TOKEN -OutVariable TW

    if($TW -eq $null)
    {

        New-TerraformWorkspace -Hostname $TFE_HOST -Organization $TFE_ORGANIZATION -WorkSpaceName $TFE_WORKSPACE -Token $TFE_TOKEN -OutVariable TW | Out-Null

    } 
    
    # else {

    #     Get-TerraformWorkspace -Hostname $TFE_HOST -Organization $TFE_ORGANIZATION -WorkSpaceName $TFE_WORKSPACE -Token $TFE_TOKEN -OutVariable TW | Out-Null

    # }

    New-TerraformConfigurationVersion -Hostname $TFE_HOST -WorkSpaceID $TW.id -Token $TFE_TOKEN -OutVariable TCV | Out-Null

    If($TFE_VARIABLES_SPEC)
    {

        Write-TerraformVariableFile -Value $TFE_VARIABLES -Path $TFE_TEMPLATE_PATH -OutVariable TVF | Out-Null
    
    }

    Push-TerraformWorkspaceContent -Uri $TCV.attributes.'upload-url' -Path $TFE_TEMPLATE_PATH -ToolPath $PSScriptRoot | Out-Null

    Add-TerraformWorkspaceRun -Hostname $TFE_HOST -WorkSpaceID $TW.id -ConfigVersionID $TCV.id -Token $TFE_TOKEN -OutVariable TWR | Out-Null

    Watch-TerraformWorkspaceRun -Hostname $TFE_HOST -RunID $TWR.id -Token $TFE_TOKEN

} finally {
    Trace-VstsLeavingInvocation $MyInvocation
}
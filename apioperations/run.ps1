[CmdletBinding()]
param()

$global:ErrorActionPreference = 'Continue'

Trace-VstsEnteringInvocation $MyInvocation

try {
        
    Import-VstsLocStrings "$PSScriptRoot\Task.json"
    
    <#
     # INPUT VARIABLES: Inputs based on the variables that have been defined within the Azure DevOps task parameter values
    #>

    [string]$TFE_HOST = Get-VstsInput -Name tfe_host
    [string]$TFE_TOKEN = Get-VstsInput -Name tfe_token
    [string]$TFE_WORKSPACE = Get-VstsInput -Name tfe_workspace
    [string]$TFE_ORGANIZATION = Get-VstsInput -Name tfe_organization
    [bool]$TFE_VARIABLES_SPEC = Get-VstsInput -Name tfe_variables_spec -AsBool
    [string]$TFE_VARIABLES = Get-VstsInput -Name tfe_variables
    [string]$TFE_TEMPLATE_PATH = Get-VstsInput -Name tfe_template_path


    <#
     # MAIN
    #>

    Import-Module "$PSScriptRoot\ps_modules\HashiCorp\HashiHelper.psm1" -Force

    New-TerraformWorkspace -Hostname $TFE_HOST -Organization $TFE_ORGANIZATION -WorkSpaceName $TFE_WORKSPACE -Token $TFE_TOKEN -OutVariable TW -ErrorVariable errTW | Out-Null

    If($TW)
    {

        New-TerraformConfigurationVersion -Hostname $TFE_HOST -WorkSpaceID $TW.data.id -Token $TFE_TOKEN -OutVariable TCV -ErrorVariable errTCV | Out-Null    

    }
    else
    {
    
        Write-Error "$($MyInvocation.MyCommand.Name): An error ocurred while attempting to create the Terraform workspace. Please ensure that the hostname, organization, workspace name and token values are valid"

        Return 1
    
    }


    If($TFE_VARIABLES_SPEC)
    {

        Write-TerraformVariableFile -Value $TFE_VARIABLES -Path $TFE_TEMPLATE_PATH -OutVariable TVF -ErrorVariable errTVF | Out-Null
    
    }

    if($TCV)
    {
    
        Push-TerraformWorkspaceContent -Uri $TCV.attributes.'upload-url' -Path $TFE_TEMPLATE_PATH -ToolPath $PSScriptRoot | Out-Null

    }
    else
    {
    
        Write-Error "$($MyInvocation.MyCommand.Name): An error ocurred while attempting to create the Terraform Configuration Version. Please ensure that the workspace has been created."

        Return 1
    
    }

    Add-TerraformWorkspaceRun -Hostname $TFE_HOST -WorkSpaceID $TW.data.id -ConfigVersionID $TCV.id -Token $TFE_TOKEN -OutVariable TWR -ErrorVariable errTWR | Out-Null

    if($TWR)
    {
    
        Watch-TerraformWorkspaceRun -Hostname $TFE_HOST -RunID $TWR.id -Token $TFE_TOKEN
    
    }
    else
    {
    
        Write-Error "$($MyInvocation.MyCommand.Name): An error ocurred while attempting to add a run on the Terraform workspace. Please ensure that the Configuration Version and Workspace have been created."

        Return 1    
    
    }

} finally {

    Trace-VstsLeavingInvocation $MyInvocation

}
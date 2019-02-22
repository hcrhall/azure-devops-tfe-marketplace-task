# -----------------------------------------------
# PowerShell Classes
# -----------------------------------------------

# -----------------------------------------------
# PowerShell Functions
# -----------------------------------------------

<#
.DESCRIPTION
   Allows operators to get Terraform Workspace configuration from Terraform Enterprise via the API using PowerShell. 
   
   To successfully execute this script you will need to provide the following:
    
    1. Hostname
    2. Organization name (case-sensitive)
    2. Workspace name 
    3. TFE token

.EXAMPLE
   Get-TerraformWorkspace -Hostname "app.terraform.io" -Organization demo -WorkSpaceName "My Workspace" -Token <Token>
#>

function Get-TerraformWorkspace {
    [CmdletBinding()]
    [Alias()]
    [OutputType([PSCustomObject])]
    Param
    (

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Hostname,

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        $Organization,

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        $WorkSpaceName,

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=3)]
        $Token

    )

    Begin
    {

        Write-Host "$($MyInvocation.MyCommand.Name): Script execution started"

    }
    Process
    {

        Write-Host "$($MyInvocation.MyCommand.Name): Getting workspace ID."
            
        try
        {
            $Get = @{

                Uri         = "https://$Hostname/api/v2/organizations/$Organization/workspaces/$WorkSpaceName"
                Headers     = @{"Authorization" = "Bearer $Token" } 
                ContentType = 'application/vnd.api+json'
                Method      = 'Get'
                ErrorAction = 'stop'
    
            }
                    
            Return (Invoke-RestMethod @Get).data  
        }
        catch
        {
            $ErrorID = ($Error[0].ErrorDetails.Message | ConvertFrom-Json).errors.status
            $Message = ($Error[0].ErrorDetails.Message | ConvertFrom-Json).errors.detail
            $Exception = ($Error[0].ErrorDetails.Message | ConvertFrom-Json).errors.title
            
            Write-Error -Exception $Exception -Message $Message -ErrorId $ErrorID

        }
        finally
        {

            Write-Host "$($MyInvocation.MyCommand.Name): Script execution complete"

        }
    }
    End
    {
    }
}

<#
.DESCRIPTION
   Allows operators to create Terraform Workspaces in Terraform Enterprise via the API using PowerShell. 
   
   To successfully execute this script you will need to provide the following:
    
    1. Hostname
    2. Organization name (case-sensitive)
    2. Workspace name 
    3. TFE token

.EXAMPLE
   New-TerraformWorkspace -Hostname "app.terraform.io" -Organization demo -WorkSpaceName "My Workspace" -Token <Token>
#>

function New-TerraformWorkspace {

    [CmdletBinding()]
    [Alias()]
    [OutputType([object])]
    Param
    (

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Hostname,

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        $Organization,

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        $WorkSpaceName,

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=3)]
        $Token


    )

    Begin
    {
        Write-Host "$($MyInvocation.MyCommand.Name): Script execution started"

        $Json = @{ 

            "data"= @{ 
    
                "attributes"= @{ 
        
                    "name"="$WorkSpaceName"
                    "auto-apply"=$true
                    
                }
            "type"="workspaces"
    
            } 

        } | ConvertTo-Json

        $Post = @{

            Uri         = "https://$Hostname/api/v2/organizations/$Organization/workspaces"
            Headers     = @{"Authorization" = "Bearer $Token" } 
            ContentType = 'application/vnd.api+json'
            Method      = 'Post'
            Body        = $Json
            ErrorAction = 'stop'
            OutVariable   = 'PTW'
            ErrorVariable = 'errPTW'
    
        }

        $Get = @{

            Uri           = "https://$Hostname/api/v2/organizations/$Organization/workspaces/$WorkSpaceName"
            Headers       = @{"Authorization" = "Bearer $Token" } 
            ContentType   = 'application/vnd.api+json'
            Method        = 'Get'
            ErrorAction   = 'stop'
            OutVariable   = 'GTW'
            ErrorVariable = 'errGTW'
    
        }

    }
    Process
    {

        try
        {
            
            Write-Host "$($MyInvocation.MyCommand.Name): Getting workspace configuration"
        
            Invoke-RestMethod @Get

        }
        catch
        {
        
            Write-Error "$($MyInvocation.MyCommand.Name): Error encountered while attempting to get workspace configuration"        
        
        }
        finally
        {
        
            Write-Host "$($MyInvocation.MyCommand.Name): Get workspace configuration finished"
        
        }

        if($errGTW)
        {
            
            [int]$Status = ($errGTW.message | convertfrom-json).errors.status

            If($Status -eq 404)
            {

                try
                {
                    
                    Write-Host "$($MyInvocation.MyCommand.Name): Creating remote workspace"

                    Invoke-RestMethod @Post

                }
                catch
                {

                    Write-Error "$($MyInvocation.MyCommand.Name): Error encountered while attempting to create the remote workspace" 

                }
                finally
                {

                    Write-Host "$($MyInvocation.MyCommand.Name): Create workspace finished"
                    
                }

                
                if($PTW)
                {
                
                    Return $PTW.data
                                
                }

            }
            else
            {

                Write-Error "$($MyInvocation.MyCommand.Name): Unknown Error - $($errGTW.message)"

            }               
    
        }
        else
        {

            Return $GTW.data

        }

    }
    End
    {

        Write-Host "$($MyInvocation.MyCommand.Name): Script execution complete"

    }
}

<#
.DESCRIPTION
   Allows operators to create Terraform Configuration Version in a Terraform Enterprise workspace via the API using PowerShell. 
   
   To successfully execute this script you will need to provide the following:
    
    1. Hostname
    2. Workspace Identifier
    3. TFE token

.EXAMPLE
   New-TerraformConfigurationVersion -Hostname "app.terraform.io" -WorkSpaceID "wn-XXXXXXX" -Token <Token>
#>

function New-TerraformConfigurationVersion {
    [CmdletBinding()]
    [Alias()]
    [OutputType([string])]
    Param
    (

        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   Position=0)]
        $Hostname,

        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   Position=1)]
        $WorkSpaceID,

        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   Position=2)]
        $Token

    )

    Begin
    {
        Write-Host "$($MyInvocation.MyCommand.Name): Script execution started"
        
        $Json = @{

            "data"= @{
    
                "type"="configuration-version"
                "attributes"= @{
                  "auto-queue-runs"=$false
                }
            }

        } | ConvertTo-Json

        $Post = @{

            Uri         = "https://$Hostname/api/v2/workspaces/$WorkSpaceID/configuration-versions"
            Headers     = @{"Authorization" = "Bearer $Token" } 
            ContentType = 'application/vnd.api+json'
            Method      = 'Post'
            Body        = $Json
            ErrorAction = 'stop'
    
        }

    }
    Process
    {

        try
        {

            Return (Invoke-RestMethod @Post).data

        }
        catch
        {

            $ErrorID = ($Error[0].ErrorDetails.Message | ConvertFrom-Json).errors.status
            $Message = ($Error[0].ErrorDetails.Message | ConvertFrom-Json).errors.detail
            $Exception = ($Error[0].ErrorDetails.Message | ConvertFrom-Json).errors.title
            
            Write-Error -Exception $Exception -Message $Message -ErrorId $ErrorID

        }
        finally
        {

            Write-Host "$($MyInvocation.MyCommand.Name): Script execution complete"

        }

    }
    End
    {
    }
}

<#
.DESCRIPTION
   Allows operators to upload Terraform template tar ball to Terraform Enterprise Configuration Version upload url via the API using PowerShell. 
   
   To successfully execute this script you will need to provide the following:
    
    1. Hostname
    2. Workspace Identifier
    3. TFE token

.EXAMPLE
   Push-TerraformWorkspaceContent -Uri "https://hostname.com/..." -Path "/tmp/templates.tar.gz"
#>

function Push-TerraformWorkspaceContent {
    [CmdletBinding()]
    [Alias()]
    Param
    (

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Uri,

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [ValidateScript({Test-Path -Path $_})]                   
        $Path,

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        [ValidateScript({Test-Path -Path $_})]                   
        $ToolPath        

    )

    Begin
    {
        Write-Host "$($MyInvocation.MyCommand.Name): Script execution started"
        
        Start-Process -FilePath "$ToolPath\tools\7z.exe" -WorkingDirectory $env:AGENT_WORKFOLDER -ArgumentList "a -ttar templates.tar $Path\*" -Wait -NoNewWindow

        Start-Process -FilePath "$ToolPath\tools\7z.exe" -WorkingDirectory $env:AGENT_WORKFOLDER -ArgumentList "a -tgzip templates.tar.gz templates.tar" -Wait -NoNewWindow

        $Put = @{

            Uri         = $Uri
            Method      = 'Put'
            InFile      = "$($env:AGENT_WORKFOLDER)\templates.tar.gz"
            ErrorAction = 'Stop'
    
        }

    }
    Process
    {

        try
        {

            Invoke-RestMethod @Put

        }
        catch
        {

            $ErrorID = ($Error[0].ErrorDetails.Message | ConvertFrom-Json).errors.status
            $Message = ($Error[0].ErrorDetails.Message | ConvertFrom-Json).errors.detail
            $Exception = ($Error[0].ErrorDetails.Message | ConvertFrom-Json).errors.title
            
            Write-Error -Exception $Exception -Message $Message -ErrorId $ErrorID

        }
        finally
        {

            Write-Host "$($MyInvocation.MyCommand.Name): Script execution complete"

        }

    }
    End
    {
    }
}

<#
.DESCRIPTION
   Allows operators to write variables to Terraform Enterprise workspace via the API using PowerShell. 
   
   To successfully execute this script you will need to provide the following:
    
    1. Workspace Identifier
    2. Variable Prefix (for filtering)
    3. TFE token

.EXAMPLE
   Push-TerraformWorkspaceVariable -WorkSpaceID "ws-XXXX" -Prefix "TFE" -Token <Token>
#>

function Push-TerraformWorkspaceVariable {
    [CmdletBinding()]
    [Alias()]
    [OutputType([array])]
    Param
    (

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Hostname,

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        $WorkSpaceID,

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        $Prefix,

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=3)]
        $Token,

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=4)]
        $Sensitive        



    )

    Begin
    {

        Write-Host "$($MyInvocation.MyCommand.Name): Script execution started"

        $Variables = Get-ChildItem -Path "env:$Prefix*"

        $varIDs = @()

    }
    Process
    {

        ForEach($Variable in $Variables)
        {

            Write-Host "$($MyInvocation.MyCommand.Name): Pushing $($Variable.Key) variable to Terraform Enterprise Workspace (ID:$WorkSpaceID)"

            try
            {
                $Json = @{
                  "data"= @{
                    "type"="vars"
                    "attributes"= @{
                      "key"=$Variable.Key
                      "value"=$Variable.Value
                      "category"="env"
                      "hcl"=$false
                      "sensitive"=$Sensitive
                    }
                    "relationships"= @{
                      "workspace"= @{
                        "data"= @{
                          "id"="$WorkSpaceID"
                          "type"="workspaces"
                        }
                      }
                    }
                  }
                } | ConvertTo-Json -Depth 5

                $Post = @{

                    Uri         = "https://$Hostname/api/v2/vars"
                    Headers     = @{"Authorization" = "Bearer $Token" } 
                    ContentType = 'application/vnd.api+json'
                    Method      = 'Post'
                    Body        = $Json
                    ErrorAction = 'stop'

                }

                $varIDs += (Invoke-RestMethod @Post).data.id

            }
            catch
            {

                $ErrorID = ($Error[0].ErrorDetails.Message | ConvertFrom-Json).errors.status
                $Message = ($Error[0].ErrorDetails.Message | ConvertFrom-Json).errors.detail
                $Exception = ($Error[0].ErrorDetails.Message | ConvertFrom-Json).errors.title

                Write-Host "$($MyInvocation.MyCommand.Name): $Message"

            }
            finally
            {
            
                Write-Host "$($MyInvocation.MyCommand.Name): Variable push complete"

            }

        }

        return $varIDs
    }
    End
    {

        Write-Host "$($MyInvocation.MyCommand.Name): Script execution complete"

    }    
}

<#
.DESCRIPTION
   Allows operators to write variables to a local template file at a given path. 
   
   To successfully execute this script you will need to provide the following:
    
    1. Variables string value
    2. Path where the randomly named tf file will be written

.EXAMPLE
   Write-TerraformVariableFile -Value 'environment="Staging"' -Path "C:\Temp"
#>
function Write-TerraformVariableFile {
    [CmdletBinding()]
    [Alias()]
    Param
    (

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]$Value,

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [ValidateScript({Test-Path -Path $_})] 
        [string]$Path      

    )

    Begin
    {

        Write-Host "$($MyInvocation.MyCommand.Name): Script execution started"

    }
    Process
    {

        try
        {

            Write-Host "$($MyInvocation.MyCommand.Name): Writing Terraform variable template"

            New-Item -Path "$Path\$(Get-Random).auto.tfvars" -ItemType File -Value $Value -Force -ErrorAction Stop
        
        }
        catch
        {
        
            Write-Error "$($MyInvocation.MyCommand.Name): An error occured while writing template to the specified path."
        
        }
        finally
        {
            
            Write-Host "$($MyInvocation.MyCommand.Name): Closing"
        
        }        

    }
    End
    {

        Write-Host "$($MyInvocation.MyCommand.Name): Script execution complete"

    }    
}

<#
.DESCRIPTION
   Allows operators to write variables to Terraform Enterprise workspace via the API using PowerShell. 
   
   To successfully execute this script you will need to provide the following:
    
    1. Workspace Identifier
    2. Variable Prefix (for filtering)
    3. TFE token

.EXAMPLE
   Add-TerraformWorkspaceRun -Hostname "app.terraform.io" -WorkSpaceID "ws-XXXX" -ConfigVersionID "cv-XXXX" -Token <Token>
#>

function Add-TerraformWorkspaceRun {
    [CmdletBinding()]
    [Alias()]
    [OutputType([PSCustomObject])]
    Param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Hostname,

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        $WorkSpaceID,

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        $ConfigVersionID,

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=3)]
        $Token

    )

    Begin
    {

        Write-Host "$($MyInvocation.MyCommand.Name): Script execution started"

        $Comment = "$($env:BUILD_SOURCEVERSIONMESSAGE)"
        
        $Json = @{
          "data"= @{
            "attributes"= @{
              "is-destroy"=$false
              "message"= $Comment
            }
            "type"="runs"
            "relationships"= @{
              "workspace"= @{
                "data"= @{
                  "type"= "workspaces"
                  "id"= "$WorkSpaceID"
                }
              }
              "configuration-version"= @{
                "data"= @{
                  "type"= "configuration-versions"
                  "id"= "$ConfigVersionID"
                }
              }
            }
          }
        } | ConvertTo-Json -Depth 5

        $Post = @{

            Uri         = "https://$Hostname/api/v2/runs"
            Headers     = @{"Authorization" = "Bearer $Token" } 
            ContentType = 'application/vnd.api+json'
            Method      = 'Post'
            Body        = $Json
            ErrorAction = 'stop'
    
        }

    }
    Process
    {

        try
        {

            return (Invoke-RestMethod @Post).data

        }
        catch
        {

            $ErrorID = ($Error[0].ErrorDetails.Message | ConvertFrom-Json).errors.status
            $Message = ($Error[0].ErrorDetails.Message | ConvertFrom-Json).errors.detail
            $Exception = ($Error[0].ErrorDetails.Message | ConvertFrom-Json).errors.title
            
            Write-Error -Exception $Exception -Message $Message -ErrorId $ErrorID

        }
        finally
        {

            Write-Host "$($MyInvocation.MyCommand.Name): Script execution complete"

        }

    }
    End
    {
    }
}

<#
.DESCRIPTION
   Allows operators to write variables to Terraform Enterprise workspace via the API using PowerShell. 
   
   To successfully execute this script you will need to provide the following:
    
    1. Workspace Identifier
    2. Variable Prefix (for filtering)
    3. TFE token

.EXAMPLE
   Watch-TerraformWorkspaceRun -Hostname "app.terraform.io" -WorkSpaceID "ws-XXXX" -ConfigVersionID "cv-XXXX" -Token <Token>
#>

function Watch-TerraformWorkspaceRun {
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Hostname,        

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        $RunID,

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        $Token

    )

    Begin
    {

        Write-Host "$($MyInvocation.MyCommand.Name): Script execution started"

        $Get = @{

            Uri         = "https://$Hostname/api/v2/runs/$RunID"
            Headers     = @{"Authorization" = "Bearer $Token" } 
            ContentType = 'application/vnd.api+json'
            Method      = 'Get'
            ErrorAction = 'stop'

        }

        $State = @("applying","canceled","confirmed","discarded","pending","planning","policy_checked","policy_checking","policy_override")

    }
    Process
    {

        try
        {

            do
            {

                $Result = (Invoke-RestMethod @Get).data

                $Status = $Result.attributes.status

                Write-Host "$($MyInvocation.MyCommand.Name): Terraform workspace in '$Status' state"

            }
            while ($Status -in $State)


            switch ($Status)
            {
                'applied'{ Return 0 }
                'planned'{ Return 0 }
                'errored'{ Return 1 }
            }

        }
        catch
        {

            $ErrorID = ($Error[0].ErrorDetails.Message | ConvertFrom-Json).errors.status
            $Message = ($Error[0].ErrorDetails.Message | ConvertFrom-Json).errors.detail
            $Exception = ($Error[0].ErrorDetails.Message | ConvertFrom-Json).errors.title

            Write-Error -Exception $Exception -Message $Message -ErrorId $ErrorID

        }
        finally
        {

            Write-Host "$($MyInvocation.MyCommand.Name): Script execution complete"

        }

    }
    End
    {
    }
}



class Workspace {
    [string]$WorkspaceID
    [string]$Name
	[string]$TerraformVersion
    [string] hidden $Hostname
    [bool]$AutoApply

    Workspace(){}
    
    [string]Create([string]$Hostname, [string]$Token, [string]$Organization){
            
        $Payload = '{{"data":{{"attributes":{{"name":"{0}","terraform_version":"{1}","auto-apply":{2}}},"type":"workspaces"}}}}' -f $this.Name, $this.TerraformVersion, $this.AutoApply

        $Post = @{

            Uri         = "https://$Hostname/api/v2/organizations/$Organization/workspaces"
            Headers     = @{"Authorization" = "Bearer $Token" } 
            ContentType = 'application/vnd.api+json'
            Method      = 'Post'
            Body        = $Payload.ToLower()
            ErrorAction = 'stop'
        
        }

        $Response = (Invoke-RestMethod @Post).data

        $this.WorkspaceID = $Response.id
        $this.TerraformVersion = $Response.attributes."terraform-version"

        return $this.WorkspaceID
    }
    
    [string]Get([string]$Name, [string]$Hostname, [string]$Token, [string]$Organization){

        $Get = @{

            Uri         = "https://$Hostname/api/v2/organizations/$Organization/workspaces/$Name"
            Headers     = @{"Authorization" = "Bearer $Token" } 
            ContentType = 'application/vnd.api+json'
            Method      = 'Get'
            ErrorAction = 'stop'
        
        }

        $Response = (Invoke-RestMethod @Get).data

        $this.WorkspaceID = $Response.id
        $this.Name = $Response.attributes.name
        $this.TerraformVersion = $Response.attributes."terraform-version"

        return $this.WorkspaceID
    
    }
}


<#
 #  MAIN
#>

$Token = $env:ATLAS_TOKEN
$Organization = "AQIT"
$Hostname = "app.terraform.io"

$WorkspaceSpec = @{
    Name = "Nikki"
    TerraformVersion = "0.11.11"
    AutoApply = $true
}


<#
 # WORKSPACE INSTANTIATION
#>

$Workspace = New-Object -TypeName Workspace -Property $WorkspaceSpec

$Workspace.Create($Hostname,$Token,$Organization)

$Workspace

$Workspace.Get('Kubernetes-Cluster-GKE', $Hostname, $Token, $Organization)

$Workspace

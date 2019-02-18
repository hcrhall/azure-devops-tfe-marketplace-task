class Configuration {
    [string]$ConfigurationID
    [string] hidden $URL
    [string]$Status

    Configurationn(){}
    
    [string]Create([string]$Hostname, [string]$Token, [string]$WorkspaceID){
            
        $Payload = '{"data":{"type":"configuration-versions"}}'

        $Post = @{

            Uri         = "https://$Hostname/api/v2/workspaces/$WorkspaceID/configuration-versions"
            Headers     = @{"Authorization" = "Bearer $Token" } 
            ContentType = 'application/vnd.api+json'
            Method      = 'Post'
            Body        = $Payload.ToLower()
            ErrorAction = 'stop'
        
        }

        $Response = (Invoke-RestMethod @Post).data

        $this.ConfigurationID = $Response.id
        $this.URL = $Response.attributes."upload-url"
        $this.Status = $Response.attributes.status

        return $this.ConfigurationID
    }
}


<#
 #  MAIN
#>

$Token = $env:ATLAS_TOKEN
$WorkspaceID = "ws-R12zPy1wZ8rj8Caf"
$Hostname = "app.terraform.io"

<#
 # WORKSPACE INSTANTIATION
#>

$Configuration = New-Object -TypeName Configuration

$Configuration.Create($Hostname,$Token,$WorkspaceID)
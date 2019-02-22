# Terraform Enterprise Market Place task for Azure DevOps

HashiCorp Terraform Enterprise integration for Azure DevOps. Customers can manually build this task and upload it to their Azure DevOps (aka VSTS) subscription. 

## Prerequisites

  - Azure DevOps Organization
  - Terraform Enterprise Organization
  - Node CLI for Azure DevOps
  - Azure DevOps Personal Access Token
  - Terraform API Token

## Step 1 - Install TFS Extensions Command Line Utility (tfx-cli)
Tfx-cli is a command utility for interacting with Microsoft Team Foundation Server and Azure DevOps Services (formerly VSTS). It is cross platform and supported on Windows, OS X, and Linux and can be installed as follows:

##### Linux / OSX

```sh
$ sudo npm install -g tfx-cli
```

##### Windows

```sh
$ npm install -g tfx-cli
```

## Step 2 - Login to Azure DevOps using CLI
To login using the command-line tool you will need the following: 
- An Azure DevOps Personal Access Token (PAT). You can create a PAT by editing your profile in Azure DevOps and selecting the Security tab.
- An Azure DevOps Service URL (i.e. https://<OrganisationName>.visualstudio.com/DefaultCollection)

##### Login

```sh
$ tfx login -u <ServiceURL> -t <PersonalAccessToken>
```

## Step 3 - Upload Task to Azure DevOps
To upload the custom task you will need the following: 
- Local copy of the apioperations directory (git clone this repo )

##### Build 

```sh
$ tfx build tasks upload --task-path ./apioperations
```

## Step 4 - Azure DevOps validation
Confirm that the custom task has been uploaded to the Azure DevOps organisation

##### Validate 

```sh
$ tfx build tasks list
```

## Step 5 - Create a build pipeline
Review the following for guidance on creating your first pipeline in Azure DevOps:
https://docs.microsoft.com/en-us/azure/devops/pipelines/get-started-designer?view=azure-devops&tabs=new-nav#create-a-build-pipeline

##### Note: 
The example in the link uses a PowerShell task to run a script but in your pipeline configuration you will be adding a "Terraform Enterprise API Integration" task.

![Marketplace](https://github.com/hashicorp/azure-devops-tfe-marketplace-task/blob/master/apioperations/images/marketplace.jpg)

Once you have added the new task you can configure the step as follows.

![Configuration](https://github.com/hashicorp/azure-devops-tfe-marketplace-task/blob/master/apioperations/images/configuration.jpg)



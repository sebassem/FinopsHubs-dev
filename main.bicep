// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

//==============================================================================
// Parameters
//==============================================================================

targetScope = 'resourceGroup'

@description('Optional. Name of the hub. Used to ensure unique resource names. Default: "finops-hub".')
param hubName string

@description('Optional. Azure location where all resources should be created. See https://aka.ms/azureregions. Default: Same as deployment.')
param location string = resourceGroup().location

@allowed([
  'Premium_LRS'
  'Premium_ZRS'
])
@description('Optional. Storage SKU to use. LRS = Lowest cost, ZRS = High availability. Note Standard SKUs are not available for Data Lake gen2 storage. Allowed: Premium_LRS, Premium_ZRS. Default: Premium_LRS.')
param storageSku string = 'Premium_LRS'

@description('Optional. Tags to apply to all resources. We will also add the cm-resource-parent tag for improved cost roll-ups in Cost Management.')
param tags object = {}

@description('Optional. Tags to apply to resources based on their resource type. Resource type specific tags will be merged with tags for all resources.')
param tagsByResource object = {}

@description('Optional. List of scope IDs to create exports for.')
param exportScopes array = []

@description('The name of the container used for configuration settings.')
param configContainer string = 'config'

@description('The name of the container used for Cost Management exports.')
param exportContainer string = 'exports'

@description('The name of the container used for normalized data ingestion.')
param ingestionContainer string = 'ingestion'

@description('Optional. To use Private Endpoints, add target subnet resource Id.')
param subnetResourceId string = ''

//==============================================================================
// Resources
//==============================================================================

module hub 'modules/hub.bicep' = {
  name: 'hub'
  params: {
    hubName: hubName
    location: location
    storageSku: storageSku
    tags: tags
    tagsByResource: tagsByResource
    exportScopes: exportScopes
    configContainer: configContainer
    exportContainer: exportContainer
    ingestionContainer: ingestionContainer
    subnetResourceId: empty(subnetResourceId) ? '' : vnet.properties.subnets[0].id
    scriptsSubnetResourceId: empty(subnetResourceId) ? '' : vnet.properties.subnets[1].id
    vnetName: vnet.name
  }
}

//To be deleted

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = if (!empty(subnetResourceId)) {
  name: 'vnet001'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.200.0.0/16'
      ]
    }
    subnets: !empty(subnetResourceId) ? [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.200.20.0/24'
        }
      }
      {
        name: 'scripts'
        properties: {
          addressPrefix: '10.200.30.0/24'
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
          ]
          delegations: [
            {
              name: 'Microsoft.ContainerInstance.containerGroups'
              properties: {
                serviceName: 'Microsoft.ContainerInstance/containerGroups'
              }
            }
          ]
        }
      }
    ] : [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.200.20.0/24'
        }
      }
    ]
  }
}

//==============================================================================
// Outputs
//==============================================================================

@description('The name of the resource group.')
output name string = hubName

@description('The location the resources wer deployed to.')
output location string = location

@description('Name of the Data Factory.')
output dataFactorytName string = hub.outputs.dataFactorytName

@description('The resource ID of the deployed storage account.')
output storageAccountId string = hub.outputs.storageAccountId

@description('Name of the storage account created for the hub instance. This must be used when connecting FinOps toolkit Power BI reports to your data.')
output storageAccountName string = hub.outputs.storageAccountName

@description('URL to use when connecting custom Power BI reports to your data.')
output storageUrlForPowerBI string = hub.outputs.storageUrlForPowerBI

using './main.bicep'

param hubName = 'hub013'
param location = 'eastus'
param storageSku = 'Premium_LRS'
param tags = {}
param tagsByResource = {}
param exportScopes = []
param configContainer = 'config'
param exportContainer = 'exports'
param ingestionContainer = 'ingestion'
//param subnetResourceId = '/subscriptions/e3b447fd-b561-4fa4-a821-4f90799ba35d/resourceGroups/finops-hub/providers/Microsoft.Network/virtualNetworks/vnet001/subnets/scripts'
param subnetResourceId = ''

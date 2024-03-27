using './main.bicep'

param hubName = 'hub016'
param location = 'eastus'
param storageSku = 'Premium_LRS'
param tags = {}
param tagsByResource = {}
param exportScopes = []
param configContainer = 'config'
param exportContainer = 'exports'
param ingestionContainer = 'ingestion'

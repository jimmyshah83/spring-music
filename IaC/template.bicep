param serverGroupName string
param location string

@secure()
param administratorLoginPassword string
param previewFeatures bool
param postgresqlVersion string
param coordinatorVcores int
param coordinatorStorageSizeMB int
param numWorkers int
param workerVcores int
param workerStorageSizeMB int
param enableHa bool
param enablePublicIpAccess bool
param serverGroupTags object
param firewallRules object

var firewallRules_var = firewallRules.rules

resource serverGroup 'Microsoft.DBforPostgreSQL/serverGroupsv2@2020-10-05-privatepreview' = {
  name: serverGroupName
  kind: 'CosmosDBForPostgreSQL'
  location: location
  tags: serverGroupTags
  properties: {
    createMode: 'Default'
    administratorLogin: 'citus'
    administratorLoginPassword: administratorLoginPassword
    backupRetentionDays: 35
    enableMx: false
    enableZfs: false
    previewFeatures: previewFeatures
    postgresqlVersion: postgresqlVersion
    serverRoleGroups: [
      {
        name: ''
        role: 'Coordinator'
        serverCount: 1
        serverEdition: 'GeneralPurpose'
        vCores: coordinatorVcores
        storageQuotaInMb: coordinatorStorageSizeMB
        enableHa: enableHa
      }
      {
        name: ''
        role: 'Worker'
        serverCount: numWorkers
        serverEdition: 'MemoryOptimized'
        vCores: workerVcores
        storageQuotaInMb: workerStorageSizeMB
        enableHa: enableHa
        enablePublicIpAccess: enablePublicIpAccess
      }
    ]
  }
  dependsOn: []
}

@batchSize(1)
module serverGroupName_firewallRules './nested_serverGroupName_firewallRules.bicep' = [for i in range(0, ((length(firewallRules_var) > 0) ? length(firewallRules_var) : 1)): {
  name: '${serverGroupName}-firewallRules-${i}'
  scope: resourceGroup('1d8a3971-973e-4b52-841b-16614e79c84f', 'containers-rg')
  params: {
    variables_firewallRules_copyIndex_name: firewallRules_var
    variables_firewallRules_copyIndex_startIPAddress: firewallRules_var
    variables_firewallRules_copyIndex_endIPAddress: firewallRules_var
    serverGroupName: serverGroupName
  }
  dependsOn: [
    serverGroup
  ]
}]
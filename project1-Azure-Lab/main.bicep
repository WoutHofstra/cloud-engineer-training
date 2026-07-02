param location string = resourceGroup().location

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: 'Azure-Lab-VNET'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'Azure-Lab-Subnet-VM'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
      {
        name: 'Azure-Lab-Subnet-Bastion'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]
  }
}

resource nsgWorkload 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: 'nsg-workload'
  location: location
  properties: {
    securityRules: [
      {
        name: 'allow-ssh'
        properties: {
          description: 'description'
          protocol: 'Tcp'
          sourcePortRange: '22'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource nsgBastion 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: 'nsg-bastion'
  location: location
  properties: {
    securityRules: [
      {
        name: 'intercept-vpn-bastion'
        properties: {
          description: 'description'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '149.40.59.231'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
    ]
  }
}


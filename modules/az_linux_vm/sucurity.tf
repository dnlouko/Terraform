locals {
  inbound_rules = [
    { ##### INBOUND RULES #####
      name                       = "SSH"
      priority                   = 100
      protocol                   = "Tcp"
      destination_address_prefix = "*"
      destination_port_ranges    = ["22"] #The ports that had to be allowed
    },
    { ##### INBOUND RULES #####
      name                       = "SWARM_2377"
      priority                   = 110
      protocol                   = "Tcp"
      destination_address_prefix = "VirtualNetwork"
      destination_port_ranges    = ["2377"] #The ports that had to be allowed
    },
    { ##### INBOUND RULES #####
      name                       = "SWARM_7946"
      priority                   = 120
      protocol                   = "Tcp"
      destination_address_prefix = "VirtualNetwork"
      destination_port_ranges    = ["7946"] #The ports that had to be allowed
    },
    { ##### INBOUND RULES #####
      name                       = "SWARM_UDP_7946"
      priority                   = 130
      protocol                   = "UDP"
      destination_address_prefix = "VirtualNetwork"
      destination_port_ranges    = ["7946"] #The ports that had to be allowed
    },
    { ##### INBOUND RULES #####
      name                       = "SWARM_UDP_4789"
      priority                   = 140
      protocol                   = "Tcp"
      destination_address_prefix = "VirtualNetwork"
      destination_port_ranges    = ["4789"] #The ports that had to be allowed
    },
    {
      name                       = "SWARM_ANY_50"
      priority                   = 150
      protocol                   = "*"
      destination_address_prefix = "VirtualNetwork"
      destination_port_ranges    = ["50"] #The ports that had to be allowed      
    }
  ]
}

resource "azurerm_network_security_group" "security" {
  name                = "NSG-${local.env_and_project}"
  location            = azurerm_resource_group.this_rg.location
  resource_group_name = azurerm_resource_group.this_rg.name
  ### ARRUMAR UMA FORMA DE CONTAR O TAMANHO DAS REGRAS E IR MULTIPLICANDO POR 10 + 100 | Para eliminar a necessidade de ficar contando regras ;)
  dynamic "security_rule" {
    for_each            = local.inbound_rules 
    content {
        name                       = security_rule.value.name
        priority                   = security_rule.value.priority
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = security_rule.value.protocol
        source_address_prefix      = "*"
        source_port_range          = "*"
        destination_address_prefix = security_rule.value.destination_address_prefix
        destination_port_ranges    = security_rule.value.destination_port_ranges
    }
  }
}
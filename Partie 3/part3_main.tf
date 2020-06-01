resource "azurerm_resource_group" "part3_rg_1" {
    name        = var.resource_name_1
    location    = var.location_1
}

resource "azurerm_resource_group" "part3_rg_2" {
    name        = var.resource_name_2
    location    = var.location_2
}

resource "azurerm_virtual_network" "part3_vn_1" {     
    name                = var.virtual_network_name_1
    address_space       = ["10.0.0.0/16"]
    resource_group_name = azurerm_resource_group.part3_rg_1.name
    location            = azurerm_resource_group.part3_rg_1.location

    depends_on          = [azurerm_resource_group.part3_rg_1]
}

resource "azurerm_virtual_network" "part3_vn_2" {          
    name                = var.virtual_network_name_2
    address_space       = ["10.1.0.0/16"]
    resource_group_name = azurerm_resource_group.part3_rg_2.name
    location            = azurerm_resource_group.part3_rg_2.location

    depends_on          = [azurerm_resource_group.part3_rg_2]
}

resource "azurerm_subnet" "part3_subnets_1" {
    count                   = length(var.subnet_names_1)
    name                    = var.subnet_names_1[count.index]
    resource_group_name     = azurerm_resource_group.part3_rg_1.name
    virtual_network_name    = azurerm_virtual_network.part3_vn_1.name
    address_prefix          = "10.0.${count.index + 100}.0/24"

    depends_on              = [azurerm_virtual_network.part3_vn_1]
}

resource "azurerm_subnet" "part3_subnets_2" {
    count                   = length(var.subnet_names_2) 
    name                    = var.subnet_names_2[count.index]
    resource_group_name     = azurerm_resource_group.part3_rg_2.name
    virtual_network_name    = azurerm_virtual_network.part3_vn_2.name
    address_prefix          = "10.1.${count.index + 100}.0/24"

    depends_on              = [azurerm_virtual_network.part3_vn_2]
}

resource "azurerm_virtual_network_peering" "part3_vn_peering_1_to_2" {
    name                            = var.virtual_network_peering_name_1_to_2
    resource_group_name             = azurerm_resource_group.part3_rg_1.name
    virtual_network_name            = azurerm_virtual_network.part3_vn_1.name
    remote_virtual_network_id       = azurerm_virtual_network.part3_vn_2.id
    allow_virtual_network_access    = true
    allow_forwarded_traffic         = true
    allow_gateway_transit           = false
}

resource "azurerm_virtual_network_peering" "part3_vn_peering_2_to_1" {
    name                        = var.virtual_network_peering_name_2_to_1
    resource_group_name         = azurerm_resource_group.part3_rg_2.name
    virtual_network_name        = azurerm_virtual_network.part3_vn_2.name
    remote_virtual_network_id   = azurerm_virtual_network.part3_vn_1.id
    allow_virtual_network_access    = true
    allow_forwarded_traffic         = true
    allow_gateway_transit           = false
}

#resource "azurerm_network_security_group" "part3_nsg" {
#   
#}

resource "azurerm_public_ip" "part3_pip_1" {
    name                = var.public_IP_name_1
    location            = azurerm_resource_group.part3_rg_1.location
    resource_group_name = azurerm_resource_group.part3_rg_1.name
    allocation_method   = "Dynamic"

    depends_on              = [azurerm_subnet.part3_subnets_1]
}

resource "azurerm_public_ip" "part3_pip_2" {
    name                = var.public_IP_name_2
    location            = azurerm_resource_group.part3_rg_2.location
    resource_group_name = azurerm_resource_group.part3_rg_2.name
    allocation_method   = "Dynamic"

    depends_on              = [azurerm_subnet.part3_subnets_2]
}

#Création des cartes réseaux internes pour la région 1
resource "azurerm_network_interface" "part3_nic1_1" {

    count                     = var.total_vm_1 
    name                      = "int_nic-${count.index}"
    location                  = azurerm_resource_group.part3_rg_1.location
    resource_group_name       = azurerm_resource_group.part3_rg_1.name
    #network_security_group_id = azurerm_network_security_group.part1_nsg1.id

    ip_configuration {
        name                          = "int_nic_configuration-${count.index}"
        private_ip_address_allocation = "Dynamic"
        #public_ip_address_id          = azurerm_public_ip.part3_pip.id
        subnet_id                     = "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.part3_rg_1.name}/providers/Microsoft.Network/virtualNetworks/${azurerm_virtual_network.part3_vn_1.name}/subnets/${element(var.set_vm_subnet_id_1, count.index)}"
    }

    depends_on              = [azurerm_subnet.part3_subnets_1]
}

#Création des cartes réseaux internes pour la région 2
resource "azurerm_network_interface" "part3_nic1_2" {

    count                     = var.total_vm_2 
    name                      = "int_nic-${count.index}"
    location                  = azurerm_resource_group.part3_rg_2.location
    resource_group_name       = azurerm_resource_group.part3_rg_2.name
    #network_security_group_id = azurerm_network_security_group.part1_nsg1.id

    ip_configuration {
        name                          = "int_nic_configuration-${count.index}"
        private_ip_address_allocation = "Dynamic"
        #public_ip_address_id          = azurerm_public_ip.part3_pip.id
        subnet_id                     = "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.part3_rg_2.name}/providers/Microsoft.Network/virtualNetworks/${azurerm_virtual_network.part3_vn_2.name}/subnets/${element(var.set_vm_subnet_id_2, count.index)}"
    }

    depends_on              = [azurerm_subnet.part3_subnets_2]
}


#Création des cartes réseaux externes pour la région 1
resource "azurerm_network_interface" "part3_nic2_1" {
    count                     = var.total_vm_1
    name                      = "ext_nic-${count.index}"
    location                  = azurerm_resource_group.part3_rg_1.location
    resource_group_name       = azurerm_resource_group.part3_rg_1.name
    #network_security_group_id = azurerm_network_security_group.part1_nsg1.id

    ip_configuration {
        name                          = "ext_nic_configuration-${count.index}"
        private_ip_address_allocation = "Dynamic"
        #public_ip_address_id          = azurerm_public_ip.part3_pip.id
        #subnet_id                     = element(var.set_vm_subnet_id, count.index)
        subnet_id                     = "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.part3_rg_1.name}/providers/Microsoft.Network/virtualNetworks/${azurerm_virtual_network.part3_vn_1.name}/subnets/${element(var.set_vm_subnet_id_1, count.index)}"
    }
    depends_on              = [azurerm_subnet.part3_subnets_1, azurerm_network_interface.part3_nic1_1]
}

#Création des cartes réseaux externes pour la région 2
resource "azurerm_network_interface" "part3_nic2_2" {
    count                     = var.total_vm_2
    name                      = "ext_nic-${count.index}"
    location                  = azurerm_resource_group.part3_rg_2.location
    resource_group_name       = azurerm_resource_group.part3_rg_2.name
    #network_security_group_id = azurerm_network_security_group.part1_nsg1.id

    ip_configuration {
        name                          = "ext_nic_configuration-${count.index}"
        private_ip_address_allocation = "Dynamic"
        #public_ip_address_id          = azurerm_public_ip.part3_pip.id
        #subnet_id                     = element(var.set_vm_subnet_id, count.index)
        subnet_id                     = "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.part3_rg_2.name}/providers/Microsoft.Network/virtualNetworks/${azurerm_virtual_network.part3_vn_2.name}/subnets/${element(var.set_vm_subnet_id_2, count.index)}"
    }
    depends_on              = [azurerm_subnet.part3_subnets_2, azurerm_network_interface.part3_nic1_2]
}







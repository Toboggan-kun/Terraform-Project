resource "azurerm_resource_group" "part2_rg" {
    name        = var.resource_name
    location    = var.location
}

resource "azurerm_virtual_network" "part2_vn" {
    name                = var.virtual_network_name
    address_space       = ["10.0.0.0/16"]
    resource_group_name = azurerm_resource_group.part2_rg.name
    location            = azurerm_resource_group.part2_rg.location

    depends_on              = [azurerm_resource_group.part2_rg]

}

resource "azurerm_subnet" "part2_subnets" {
    count                   = length(var.subnet_names)              #5
    name                    = var.subnet_names[count.index]
    resource_group_name     = azurerm_resource_group.part2_rg.name
    virtual_network_name    = azurerm_virtual_network.part2_vn.name
    address_prefix          = "10.0.${count.index + 100}.0/24"

    depends_on              = [azurerm_virtual_network.part2_vn]
}
output "subnets_output" {
  value = "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.part2_rg.name}/providers/Microsoft.Network/virtualNetworks/${azurerm_virtual_network.part2_vn.name}/subnets/${element(var.set_vm_subnet_id, 2)}"
}
output "subnets_nic" {
  value = "${azurerm_network_interface.part2_nic1.*}"
}
#resource "azurerm_network_security_group" "part2_nsg" {
#   
#}

resource "azurerm_public_ip" "part2_pip" {
    name                = var.public_IP_name
    location            = azurerm_resource_group.part2_rg.location
    resource_group_name = azurerm_resource_group.part2_rg.name
    allocation_method   = "Dynamic"

    depends_on              = [azurerm_subnet.part2_subnets]
}


#Création des cartes réseaux internes
resource "azurerm_network_interface" "part2_nic1" {

    count                     = var.total_vm
    name                      = "int_nic-${count.index}"
    location                  = azurerm_resource_group.part2_rg.location
    resource_group_name       = azurerm_resource_group.part2_rg.name
    #network_security_group_id = azurerm_network_security_group.part1_nsg1.id

    ip_configuration {
        name                          = "int_nic_configuration-${count.index}"
        private_ip_address_allocation = "Dynamic"
        #public_ip_address_id          = azurerm_public_ip.part2_pip.id
        subnet_id                     = "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.part2_rg.name}/providers/Microsoft.Network/virtualNetworks/${azurerm_virtual_network.part2_vn.name}/subnets/${element(var.set_vm_subnet_id, count.index)}"
    }

    depends_on              = [azurerm_subnet.part2_subnets]
}

#Création des cartes réseaux externes
resource "azurerm_network_interface" "part2_nic2" {
    count                     = var.total_vm
    name                      = "ext_nic-${count.index}"
    location                  = azurerm_resource_group.part2_rg.location
    resource_group_name       = azurerm_resource_group.part2_rg.name
    #network_security_group_id = azurerm_network_security_group.part1_nsg1.id

    ip_configuration {
        name                          = "ext_nic_configuration-${count.index}"
        private_ip_address_allocation = "Dynamic"
        #public_ip_address_id          = azurerm_public_ip.part2_pip.id
        #subnet_id                     = element(var.set_vm_subnet_id, count.index)
        subnet_id                     = "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.part2_rg.name}/providers/Microsoft.Network/virtualNetworks/${azurerm_virtual_network.part2_vn.name}/subnets/${element(var.set_vm_subnet_id, count.index)}"
    }
    depends_on              = [azurerm_subnet.part2_subnets, azurerm_network_interface.part2_nic1]
}
resource "azurerm_application_gateway" "part2_ag" {
    name                    = var.ag_name
    location                = azurerm_resource_group.part2_rg.location
    resource_group_name     = azurerm_resource_group.part2_rg.name

    sku {
        name     = "Standard_Small"
        tier     = "Standard"
        capacity = 2
    }

    gateway_ip_configuration {
        name      = var.gateway_ip_name
        subnet_id = "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.part2_rg.name}/providers/Microsoft.Network/virtualNetworks/${azurerm_virtual_network.part2_vn.name}/subnets/${element(var.set_vm_subnet_id, 0)}"
    }

    frontend_port {
        name = "front_endport"
        port = 80
    }

    frontend_ip_configuration {
        name                 = "front_ipconf"
        public_ip_address_id = azurerm_public_ip.part2_pip.id
    }

    backend_address_pool {
        name = "backend_pool"
    }

    backend_http_settings {
        name                  = "backend_http"
        cookie_based_affinity = "Disabled"
        path                  = "/path1/"
        port                  = 80
        protocol              = "Http"
        request_timeout       = 1
    }

    http_listener {
        name                           = "listener" 
        frontend_ip_configuration_name = "front_ipconf"
        frontend_port_name             = "front_endport"
        protocol                       = "Http"
    }
    
    request_routing_rule {
        name                       = "routing_rule"
        rule_type                  = "Basic"
        http_listener_name         = "listener"
        backend_address_pool_name  = "backend_pool"
        backend_http_settings_name = "backend_http"
    }
    depends_on              = [azurerm_subnet.part2_subnets, azurerm_network_interface.part2_nic1, azurerm_network_interface.part2_nic2]

}


#[id=/subscriptions/5b1a1eeb-7f60-440f-baf1-0ae43fcb3e6d/resourceGroups/RG-2/providers/Microsoft.Network/virtualNetworks/virtual_network-2/subnets/Active_Directory_subnet]
resource "azurerm_virtual_machine" "part2_vm"{

    count                           = var.total_vm
    name                            = element(var.set_vm_names, count.index)
    location                        = azurerm_resource_group.part2_rg.location
    resource_group_name             = azurerm_resource_group.part2_rg.name
    vm_size                         = "Standard_DS1_v2"
    network_interface_ids           = [
        "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.part2_rg.name}/providers/Microsoft.Network/networkInterfaces/int_nic-${count.index}",
        "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.part2_rg.name}/providers/Microsoft.Network/networkInterfaces/ext_nic-${count.index}",
        ]
    primary_network_interface_id    = "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.part2_rg.name}/providers/Microsoft.Network/networkInterfaces/int_nic-${count.index}"
    zones                           = split("", "${element(var.set_zones, count.index)}")
    storage_image_reference {

        publisher       = "MicrosoftWindowsServer"
        offer           = "WindowsServer"
        sku             = "2016-Datacenter"
        version         = "latest"
    }

    storage_os_disk {
        name                = "element(var.set_vm_names, count.index)_OSDisk"
        caching             = "ReadWrite"
        #managed_disk_id     = azurerm_managed_disk.part1_md1.id
        #managed_disk_type   = azurerm_managed_disk.part1_md1.storage_account_type
        create_option       = "FromImage"
        disk_size_gb        = 25
    }

    os_profile {
        computer_name   = element(var.set_vm_names, count.index)
        admin_username  = "element(var.set_vm_names, count.index)_admin"
        admin_password  = var.admin_password
    }
    os_profile_windows_config {
        provision_vm_agent = "true"
        enable_automatic_upgrades = "true"
        winrm {
            protocol = "http"
            certificate_url =""
        }
    }
    
    depends_on              = [azurerm_subnet.part2_subnets, azurerm_network_interface.part2_nic1, azurerm_network_interface.part2_nic2, azurerm_application_gateway.part2_ag]

}

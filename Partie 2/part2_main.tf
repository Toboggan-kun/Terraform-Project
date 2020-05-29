

resource "azurerm_resource_group" "part2_rg" {
    name        = var.resource_name
    location    = var.location
}

resource "azurerm_virtual_network" "part2_vn" {
    name                = var.virtual_network_name
    address_space       = ["192.168.0.0/16"]
    resource_group_name = azurerm_resource_group.part2_rg.name
    location            = azurerm_resource_group.part2_rg.location

}

resource "azurerm_subnet" "part2_subnets" {
    count                   = length(var.subnet_names)              #5
    name                    = var.subnet_names[count.index]
    resource_group_name     = azurerm_resource_group.part2_rg.name
    virtual_network_name    = azurerm_virtual_network.part2_vn.name
    address_prefix          = "192.168.${count.index}.0/24"
}
#resource "azurerm_network_security_group" "part2_nsg" {
#   
#}

resource "azurerm_public_ip" "part2_pip" {
    name                = var.public_IP_name
    location            = azurerm_resource_group.part2_rg.location
    resource_group_name = azurerm_resource_group.part2_rg.name
    allocation_method   = "Dynamic"
}
#Création des cartes réseaux internes
resource "azurerm_network_interface" "part2_nic1" {

    count                     = var.total_vm * var.total_nic / 2
    name                      = "int_nic-${count.index}"
    location                  = azurerm_resource_group.part2_rg.location
    resource_group_name       = azurerm_resource_group.part2_rg.name
    #network_security_group_id = azurerm_network_security_group.part1_nsg1.id

    ip_configuration {
        name                          = "int_nic_configuration-${count.index}"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.part2_pip.id
        #subnet_id                     = element(var.set_vm_subnet_id, count.index)
        subnet_id                     = element(var.set_vm_subnet_id, count.index)
    }
}

#Création des cartes réseaux externes
resource "azurerm_network_interface" "part2_nic2" {
    count                     = var.total_vm * var.total_nic / 2
    name                      = "ext_nic-${count.index}"
    location                  = azurerm_resource_group.part2_rg.location
    resource_group_name       = azurerm_resource_group.part2_rg.name
    #network_security_group_id = azurerm_network_security_group.part1_nsg1.id

    ip_configuration {
        name                          = "ext_nic_configuration-${count.index}"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.part2_pip.id
        subnet_id                     = element(var.set_vm_subnet_id, count.index)
    }
}

resource "azurerm_virtual_machine" "part2_vm"{

    count                           = var.total_vm
    name                            = element(var.set_vm_names, count.index)
    location                        = azurerm_resource_group.part2_rg.location
    resource_group_name             = azurerm_resource_group.part2_rg.name
    vm_size                         = "Standard_DS1_v2"
    network_interface_ids           = [
        "azurerm_network_interface.part2_nic1[${count.index}].id",
        "azurerm_network_interface.part2_nic2[${count.index}].id",
        ]
    primary_network_interface_id    = azurerm_network_interface.part2_nic1[count.index].id
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

}

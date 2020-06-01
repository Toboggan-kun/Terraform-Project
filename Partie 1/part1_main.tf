provider "azurerm" {
  # Whilst version is optional, we /strongly recommend/ using it to pin the version of the Provider being used
  version = "=2.4.0"

  subscription_id = "5b1a1eeb-7f60-440f-baf1-0ae43fcb3e6d"
  client_id       = "70077815-81e2-4ae1-89f0-43c411ac7ead"
  client_secret   = "325f0be8-9180-4394-9db5-9483786576a1"
  tenant_id       = "06d52c87-b8fc-4a5c-810d-e91af17dd2f4"

  features {}
}
#MISE EN PLACE DE L'INFRASTRUCTURE N°1 MICROSOFT AZURE SUR TERRAFORM
#COMPREND LA MISE EN PLACE :
#           1 - D'UN GROUPE DE RESSOURCES NOMME : "RGMonoVM"
#           2 - D'UN RESEAU VIRTUEL DE CLASSE 192.168.0.0/16
#           3 - D'UN SOUS RESEAU VIRTUEL DE CLASSE 192.168.1.0/24
#           4 - D'UNE MACHINE VIRTUELLE WINDOWS NOMME : "VMAZ"


#           1 - CREATION D'UN GROUPE DE RESSOURCE NOMME : "RGMonoVM"

resource "azurerm_resource_group" "part1_rg1" {
    name     = "RGMonoVM"
    location = "France Central"

}

#           2 - D'UN RESEAU VIRTUEL DE CLASSE 192.168.0.0/16
resource "azurerm_virtual_network" "part1_vn1" {
    name                = "virtualnetwork1"
    address_space       = ["192.168.0.0/16"]
    resource_group_name = azurerm_resource_group.part1_rg1.name
    location            = azurerm_resource_group.part1_rg1.location

}

#           3 - D'UN SOUS RESEAU VIRTUEL DE CLASSE 192.168.1.0/24
resource "azurerm_subnet" "part1_subnet1" {
    name                    = "subnet1"
    resource_group_name     = azurerm_resource_group.part1_rg1.name
    virtual_network_name    = azurerm_virtual_network.part1_vn1.name
    address_prefix          = "192.168.1.0/24"
}

#           4 - D'UNE MACHINE VIRTUELLE WINDOWS NOMME : "VMAZ"
#           4.1 - CREATION D'UN GROUPE DE SECURITE RESEAU

resource "azurerm_network_security_group" "part1_nsg1" {
    name                = "nsg1"
    location            = azurerm_resource_group.part1_rg1.location
    resource_group_name = azurerm_resource_group.part1_rg1.name
    
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "HTTP"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "HTTPS"
        priority                   = 1003
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}
#           4.2 - CREATION D'UNE IP PUBLIQUE
resource "azurerm_public_ip" "part1_publicIP1" {
    name                = "publicIP1"
    location            = azurerm_resource_group.part1_rg1.location
    resource_group_name = azurerm_resource_group.part1_rg1.name
    allocation_method   = "Dynamic"
}

#           4.3 - CREATION D'UN CARTE RESEAU
resource "azurerm_network_interface" "part1_nic1" {
  name                      = "nic1"
  location                  = azurerm_resource_group.part1_rg1.location
  resource_group_name       = azurerm_resource_group.part1_rg1.name
  #network_security_group_id = azurerm_network_security_group.part1_nsg1.id

  ip_configuration {
    name                          = "nic1_configuration"
    subnet_id                     = azurerm_subnet.part1_subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.part1_publicIP1.id
  }
}

#           4.4 - LIAISON DU GROUPE DE SECURITE A LA CARTE RESEAU
resource "azurerm_network_interface_security_group_association" "part1_nsg1_nic1" {
  network_interface_id      = azurerm_network_interface.part1_nic1.id
  network_security_group_id = azurerm_network_security_group.part1_nsg1.id
}

#           4.5 - CREATION D'UN DISQUE MANAGE

resource "azurerm_managed_disk" "part1_md1" {
    name                 = "VMAZ_Data2"
    location             = azurerm_resource_group.part1_rg1.location
    resource_group_name  = azurerm_resource_group.part1_rg1.name
    storage_account_type = "Standard_LRS"
    create_option        = "Empty"
    disk_size_gb         = "2"

}
#resource "azurerm_virtual_machine_data_disk_attachment" "part1_vmdda1" {
#    managed_disk_id     = azurerm_managed_disk.part1_md1.id
#    #virtual_machine_id  = azurerm_virtual_machine.part1_vm1.id
#    lun                 = "1"
#    caching             = "ReadWrite"
#    create_option       = "Attach"
#}
#           4.6 -  CREATION DE LA MACHINE VIRTUELLE WINDOWS
resource "azurerm_virtual_machine" "part1_vm1"{

    name                    = "VMAZ"
    location                = azurerm_resource_group.part1_rg1.location
    resource_group_name     = azurerm_resource_group.part1_rg1.name
    network_interface_ids   = [azurerm_network_interface.part1_nic1.id]
    vm_size                 = "Standard_DS1_v2"

    storage_image_reference {

        publisher       = "MicrosoftWindowsServer"
        offer           = "WindowsServer"
        sku             = "2016-Datacenter"
        version         = "latest"
    }

    storage_os_disk {
        name                = "VMAZ_Data1_OS"
        caching             = "ReadWrite"
        #managed_disk_id     = azurerm_managed_disk.part1_md1.id
        managed_disk_type   = azurerm_managed_disk.part1_md1.storage_account_type
        create_option       = "FromImage"
    }

    storage_data_disk {
        name                = "VMAZ_Data2"
        caching             = "ReadWrite"
        managed_disk_id     = azurerm_managed_disk.part1_md1.id
        managed_disk_type   = azurerm_managed_disk.part1_md1.storage_account_type
        create_option       = "Attach"
        lun                 = 1
        disk_size_gb        = 2
    }

    os_profile {
        computer_name   = "VMAZ"
        admin_username  = "vmaz_admin"
        admin_password  = "Admin!123"
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
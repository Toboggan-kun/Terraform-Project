resource "azurerm_resource_group" "part3_rg" {
    name        = var.resource_name
    location    = var.location
}

resource "azurerm_virtual_network" "part3_vn" {     
    count               = length(var.virtual_network_name)          #2
    name                = var.virtual_network_name
    address_space       = ["10.0.0.0/16"]
    resource_group_name = azurerm_resource_group.part3_rg.name
    location            = azurerm_resource_group.part3_rg.location

    depends_on              = [azurerm_resource_group.part3_rg]
}

resource "azurerm_subnet" "part3_subnets_1" {
    count                   = length(var.subnet_names) / 2             #10 / 2 = 5 1er sous-réseaux
    name                    = var.subnet_names[count.index]
    resource_group_name     = azurerm_resource_group.part3_rg.name
    virtual_network_name    = azurerm_virtual_network.part3_vn.name
    address_prefix          = "10.0.${count.index + 100}.0/24"

    depends_on              = "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.part3_rg.name}/providers/Microsoft.Network/virtualNetworks/${element(var.virtual_network_name, 0)}"
}

resource "azurerm_subnet" "part3_subnets_1" {
    count                   = length(var.subnet_names) / 2             #10 / 2 = 2eme sous-réseaux
    name                    = var.subnet_names[count.index]
    resource_group_name     = azurerm_resource_group.part3_rg.name
    virtual_network_name    = azurerm_virtual_network.part3_vn.name
    address_prefix          = "10.0.${count.index + 105}.0/24"

    depends_on              = "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.part3_rg.name}/providers/Microsoft.Network/virtualNetworks/${element(var.virtual_network_name, 1)}"
}

#resource "azurerm_network_security_group" "part3_nsg" {
#   
#}

resource "azurerm_public_ip" "part3_pip" {
    name                = var.public_IP_name
    location            = azurerm_resource_group.part3_rg.location
    resource_group_name = azurerm_resource_group.part3_rg.name
    allocation_method   = "Dynamic"

    depends_on              = [azurerm_subnet.part3_subnets]
}

#Création des cartes réseaux internes
resource "azurerm_network_interface" "part3_nic1" {

    count                     = var.total_vm 
    name                      = "int_nic-${count.index}"
    location                  = azurerm_resource_group.part3_rg.location
    resource_group_name       = azurerm_resource_group.part3_rg.name
    #network_security_group_id = azurerm_network_security_group.part1_nsg1.id

    ip_configuration {
        name                          = "int_nic_configuration-${count.index}"
        private_ip_address_allocation = "Dynamic"
        #public_ip_address_id          = azurerm_public_ip.part3_pip.id
        subnet_id                     = "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.part3_rg.name}/providers/Microsoft.Network/virtualNetworks/${azurerm_virtual_network.part3_vn.name}/subnets/${element(var.set_vm_subnet_id, count.index)}"
    }

    depends_on              = [azurerm_subnet.part3_subnets]
}

#Création des cartes réseaux externes
resource "azurerm_network_interface" "part3_nic2" {
    count                     = var.total_vm
    name                      = "ext_nic-${count.index}"
    location                  = azurerm_resource_group.part3_rg.location
    resource_group_name       = azurerm_resource_group.part3_rg.name
    #network_security_group_id = azurerm_network_security_group.part1_nsg1.id

    ip_configuration {
        name                          = "ext_nic_configuration-${count.index}"
        private_ip_address_allocation = "Dynamic"
        #public_ip_address_id          = azurerm_public_ip.part3_pip.id
        #subnet_id                     = element(var.set_vm_subnet_id, count.index)
        subnet_id                     = "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.part3_rg.name}/providers/Microsoft.Network/virtualNetworks/${azurerm_virtual_network.part3_vn.name}/subnets/${element(var.set_vm_subnet_id, count.index)}"
    }
    depends_on              = [azurerm_subnet.part3_subnets, azurerm_network_interface.part3_nic1]
}
############################################################################
#                      AZURE APPLICATION GATEWAY                           #
############################################################################
resource "azurerm_application_gateway" "part3_ag" {
    name                    = var.ag_name
    location                = azurerm_resource_group.part3_rg.location
    resource_group_name     = azurerm_resource_group.part3_rg.name

    sku {
        name     = "Standard_Small"
        tier     = "Standard"
        capacity = 2
    }

    gateway_ip_configuration {
        name                    = var.gateway_ip_name
        subnet_id = "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.part3_rg.name}/providers/Microsoft.Network/virtualNetworks/${azurerm_virtual_network.part3_vn.name}/subnets/${element(var.subnet_names, 0)}"
    }

    frontend_port {
        name = "front_endport"
        port = 80
    }

    frontend_ip_configuration {
        name                 = "front_ip_conf"
        public_ip_address_id    = azurerm_public_ip.part3_pip.id
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
        frontend_ip_configuration_name = "front_ip_conf"
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
    depends_on              = [azurerm_subnet.part3_subnets, azurerm_network_interface.part3_nic1, azurerm_network_interface.part3_nic2, azurerm_public_ip.part3_pip]

}

#resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "part3_ag_nic" {
#    network_interface_id    = "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.part3_rg.name}/providers/Microsoft.Network/networkInterfaces/int_nic-${length(var.set_vm_subnet_id)}"
#    ip_configuration_name   = "ag_ip_conf"
#    backend_address_pool_id = azurerm_application_gateway.part3_ag.backend_address_pool[0].id
#    depends_on              = [azurerm_network_interface.part3_nic1, azurerm_application_gateway.part3_ag]
#}
############################################################################
#                           AZURE LOAD BALANCER                            #
############################################################################
resource "azurerm_lb" "part3_lb" {
    count                       = var.total_lb
    name                        = "load_balancer-${count.index + 1}"
    location                    = azurerm_resource_group.part3_rg.location
    resource_group_name         = azurerm_resource_group.part3_rg.name

    frontend_ip_configuration {
        name                                    = "frontend_ip-${count.index + 1}"
        zones                                   = split("", "${element(var.set_zones, 1)}")
        subnet_id                               = "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.part3_rg.name}/providers/Microsoft.Network/virtualNetworks/${azurerm_virtual_network.part3_vn.name}/subnets/${element(var.subnet_names, count.index + 1)}"
        private_ip_address_allocation           = "Dynamic"
    }
    depends_on                  = [azurerm_subnet.part3_subnets]
}
resource "azurerm_lb_backend_address_pool" "part3_lb_backend" {
    count                       = var.total_lb
    name                        = "load_balancer_backend-${count.index + 1}"
    resource_group_name         = azurerm_resource_group.part3_rg.name
    loadbalancer_id             = "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.part3_rg.name}/providers/Microsoft.Network/loadBalancers/load_balancer-${count.index + 1}"
    depends_on                  = [azurerm_lb.part3_lb]
}
resource "azurerm_lb_probe" "part3_lb_probe" {
    count                           = var.total_lb
    resource_group_name             = azurerm_resource_group.part3_rg.name
    loadbalancer_id                 = "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.part3_rg.name}/providers/Microsoft.Network/loadBalancers/load_balancer-${count.index + 1}"
    name                            = "tcp_probe-${count.index + 1}"
    protocol                        = "tcp"
    port                            = 80
    interval_in_seconds             = 5
    number_of_probes                = 2
}
resource "azurerm_lb_rule" "part3_lb_rule" {
    count                           = var.total_lb
    resource_group_name             = azurerm_resource_group.part3_rg.name
    loadbalancer_id                 = "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.part3_rg.name}/providers/Microsoft.Network/loadBalancers/load_balancer-${count.index + 1}"

    name                           = "http_rule-${count.index + 1}"
    protocol                       = "Tcp"
    frontend_port                  = 80
    backend_port                   = 80
    frontend_ip_configuration_name = "frontend_ip-${count.index + 1}"
    backend_address_pool_id        = "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.part3_rg.name}/providers/Microsoft.Network/loadBalancers/load_balancer-${count.index + 1}/backendAddressPools/load_balancer_backend-${count.index + 1}"
    probe_id                       = "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.part3_rg.name}/providers/Microsoft.Network/loadBalancers/load_balancer-${count.index + 1}/probes/tcp_probe-${count.index + 1}"
    depends_on                     = [azurerm_lb_probe.part3_lb_probe]
}
    #Pour le load balancer 1, association sur :
    # - les cartes int_nic-[3-5] appartenant au sous-réseau BusinesstierSubnet (backend)
    # - la carte ext_nic[1] appartenant au sous-réseau WebtierSubnet (frontend)
    #Pour le load balancer 2, association sur :
    # - les cartes int-nic-[6-7] appartenant au sous-réseau DatatierSubnet (backend)
    # - la carte ext_nic[4] appartenant au sous-réseau BusinesstierSubnet (frontend)
    #Nombre total d'association d'interfaces réseau en backend : 5
resource "azurerm_network_interface_backend_address_pool_association" "part3_lb_backend_pa1" {

    count                           = 3
    network_interface_id            = "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.part3_rg.name}/providers/Microsoft.Network/networkInterfaces/int_nic-${count.index + 3}"
    ip_configuration_name           = "int_nic_configuration-${count.index}"
    backend_address_pool_id         = "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.part3_rg.name}/providers/Microsoft.Network/loadBalancers/load_balancer-1/backendAddressPools/load_balancer_backend-1"
    depends_on                      = [azurerm_lb_backend_address_pool.part3_lb_backend, azurerm_network_interface.part3_nic1]
}
resource "azurerm_network_interface_backend_address_pool_association" "part3_lb_backend_pa2" {

    count                           = 2
    network_interface_id            = "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.part3_rg.name}/providers/Microsoft.Network/networkInterfaces/int_nic-${count.index + 6}"
    ip_configuration_name           = "int_nic_configuration-${count.index}"
    backend_address_pool_id         = "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.part3_rg.name}/providers/Microsoft.Network/loadBalancers/load_balancer-2/backendAddressPools/load_balancer_backend-2"
    depends_on                      = [azurerm_lb_backend_address_pool.part3_lb_backend, azurerm_network_interface.part3_nic1]
}
resource "azurerm_virtual_machine" "part3_vm"{

    count                           = var.total_vm
    name                            = element(var.set_vm_names, count.index)
    location                        = azurerm_resource_group.part3_rg.location
    resource_group_name             = azurerm_resource_group.part3_rg.name
    vm_size                         = "Standard_B1s"
    network_interface_ids           = [
        "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.part3_rg.name}/providers/Microsoft.Network/networkInterfaces/int_nic-${count.index}",
        "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.part3_rg.name}/providers/Microsoft.Network/networkInterfaces/ext_nic-${count.index}",
        ]
    primary_network_interface_id    = "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.part3_rg.name}/providers/Microsoft.Network/networkInterfaces/int_nic-${count.index}"
    zones                           = split("", "${element(var.set_zones, count.index)}")
    storage_image_reference {

        publisher       = "MicrosoftWindowsServer"
        offer           = "WindowsServer"
        sku             = "2016-Datacenter-Server-Core-smalldisk"
        version         = "latest"
    }

    storage_os_disk {
        name                = "${element(var.set_vm_names, count.index)}_OSDisk"
        caching             = "ReadWrite"
        #managed_disk_id     = azurerm_managed_disk.part1_md1.id
        #managed_disk_type   = azurerm_managed_disk.part1_md1.storage_account_type
        create_option       = "FromImage"
    }

    os_profile {
        computer_name   = element(var.set_vm_names, count.index)
        admin_username  = "${element(var.set_vm_names, count.index)}_admin"
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
    depends_on              = [azurerm_subnet.part3_subnets, azurerm_network_interface.part3_nic1, azurerm_network_interface.part3_nic2, azurerm_application_gateway.part3_ag, azurerm_lb.part3_lb]
}

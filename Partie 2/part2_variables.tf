variable "resource_name" {
    default = "RG-2"
}
variable "app_service_plan_name" {
    default     = "app_service_plan"
}
variable "location" {
    default = "West Europe"
}
variable "subscription_id" {
    description   = "Identifiant de l'abonnement."
    default       = "5b1a1eeb-7f60-440f-baf1-0ae43fcb3e6d"
}
variable "client_id" {
    description   = "Identifiant du client."
    default       = "70077815-81e2-4ae1-89f0-43c411ac7ead"
}
variable "client_secret" {
    description   = "Mot de passe du client."
    default       = "325f0be8-9180-4394-9db5-9483786576a1"
}
variable "tenant_id" {
    description   = "Identifiant du tenant Azure."
    default       = "06d52c87-b8fc-4a5c-810d-e91af17dd2f4"
}

variable "virtual_network_name" {
    description     = "Nom du réseau virtuel."
    default         = "virtual_network-2"
}
variable "subnet_names" {
    description     = "Nom des sous-réseaux."
    default         = ["ApplicationGatewaySubnet", "WebtierSubnet", "BusinesstierSubnet", "DatatierSubnet", "ActiveDirectorySubnet"]
}
variable "nsg_name" {
    default         = "nsg"
}
variable "vm_names" {
    description     = "Nom des machines virtuelles : Web, SQL, Business Tier, Active Directory Services"
    default         = ["WEB", "SQL", "BNS", "ADS"]
}

variable "public_IP_name" {
    default         = "pip-2"
}

variable "total_vm" {

    description     = "Nombre total de machines virtuelles à déployer."
    default         = 10
}

variable "total_nic" {

    description     = "Nombre total de cartes réseau par machine virtuelle."
    default         = 2
}

variable "set_vm_subnet_id" {
    description = "Assigne le bon sous-réseaux pour les chacunes des machines virtuelles."
    type        = list
    default     = [
    "WebtierSubnet", "WebtierSubnet", "WebtierSubnet",
    "BusinesstierSubnet", "BusinesstierSubnet", "BusinesstierSubnet",
    "DatatierSubnet", "DatatierSubnet",
    "ActiveDirectorySubnet", "ActiveDirectorySubnet"
    ]
}

variable "set_vm_names" {
    
    description = "Assigne le bon nom pour les chacunes des machines virtuelles."
    type        = list(string)
    default     = [
    "WEB-01", "WEB-02", "WEB-03", 
    "BNS-01", "BNS-02", "BNS-03", 
    "SQL-01", "SQL-02", 
    "ADS-01", "ADS-02"
    ]
}

variable "admin_password" {
    default     = "Admin!123"
}

variable "set_zones" {
    description = "Assigne une zone à une machine virtuelle."
    type        = list(string)
    default     = [
    "1", "2", "3",
    "1", "2", "3",
    "1", "3",
    "1", "3"
    ]
}

variable "ag_name" {
    description         = "Nom de l'Application Gateway."
    default             = "application_gateway"
}
variable "gateway_ip_name" {
    description         = "Nom de la passerelle IP."
    default             = "gateway_ip_configuration"
}
variable "total_lb" {

    description         = "Nombre total de Load Balancer"
    default             = 2
}
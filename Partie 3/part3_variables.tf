variable "resource_name_1" {
    default = "RG-3-1"
}

variable "resource_name_2" {
    default = "RG-3-2"
}

variable "app_service_plan_name" {
    default     = "app_service_plan"
}

variable "location_1" {
    default = "France Central"
}

variable "location_2" {
    default = "North Europe"
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

variable "virtual_network_name_1" {
    description     = "Nom du réseau virtuel de la région primaire."
    default         = "virtual_network-3_1"
}

variable "virtual_network_name_2" {
    description     = "Nom du réseau virtuel de la région secondaire."
    default         = "virtual_network-3_2"
}

variable "network_security_group_1" {
    description     = "Nom du groupe de sécurité de la région 1"
    default         = "nsg1"
}

variable "network_security_group_2" {
    description     = "Nom du groupe de sécurité de la région 2"
    default         = "nsg2"
}

variable "virtual_network_peering_name_1_to_2" {
    description     = "Peering des deux réseaux virtuels 1 à 2."
    default         = "virtual_network_peering"
}

variable "virtual_network_peering_name_2_to_1" {
    description     = "Peering des deux réseaux virtuels 2 à 1."
    default         = "virtual_network_peering"
}

variable "subnet_names_1" {
    description     = "Nom des sous-réseaux."
    default         = ["ApplicationGatewaySubnet1", "WebtierSubnet1", "BusinesstierSubnet1", "DatatierSubnet1", "ActiveDirectorySubnet1"]
}

variable "subnet_names_2" {
    description     = "Nom des sous-réseaux."
    default         = ["ApplicationGatewaySubnet2", "WebtierSubnet2", "BusinesstierSubnet2", "DatatierSubnet2", "ActiveDirectorySubnet2"]
}

variable "vm_names" {
    description     = "Nom des machines virtuelles : Web, SQL, Business Tier, Active Directory Services"
    default         = ["WEB", "SQL", "BNS", "ADS"]
}

variable "public_IP_name_1" {
    default         = "pip-3_1"
}

variable "public_IP_name_2" {
    default         = "pip-3_2"
}

variable "total_vm_1" {

    description     = "Nombre total de machines virtuelles à déployer pour la région 1."
    default         = 8
}

variable "total_vm_2" {

    description     = "Nombre total de machines virtuelles à déployer pour la région 2."
    default         = 8
}

variable "total_nic" {

    description     = "Nombre total de cartes réseau par machine virtuelle."
    default         = 2
}

variable "set_vm_subnet_id_1" {
    description = "Assigne le bon sous-réseaux pour les chacunes des machines virtuelles de la région 1."
    type        = list
    default     = [
    "WebtierSubnet1", "WebtierSubnet1", "WebtierSubnet1",
    "BusinesstierSubnet1", "BusinesstierSubnet1", "BusinesstierSubnet1",
    "DatatierSubnet1", "DatatierSubnet1",
    "ActiveDirectorySubnet1", "ActiveDirectorySubnet1"
    ]
}

variable "set_vm_subnet_id_2" {
    description = "Assigne le bon sous-réseaux pour les chacunes des machines virtuelles de la région 2."
    type        = list
    default     = [
    "WebtierSubnet2", "WebtierSubnet2", "WebtierSubnet2",
    "BusinesstierSubnet2", "BusinesstierSubnet2", "BusinesstierSubnet2",
    "DatatierSubnet2", "DatatierSubnet2",
    "ActiveDirectorySubnet2", "ActiveDirectorySubnet2"
    ]
}

variable "set_vm_names_1" {
    
    description = "Assigne le bon nom pour les chacunes des machines virtuelles de la région 1."
    type        = list(string)
    default     = [
    "WEB-01", "WEB-02", "WEB-03", 
    "BNS-01", "BNS-02", "BNS-03", 
    "SQL-01", "SQL-02", 
    "ADS-01", "ADS-02",
    ]
}

variable "set_vm_names_2" {
    
    description = "Assigne le bon nom pour les chacunes des machines virtuelles de la région 2."
    type        = list(string)
    default     = [
    "WEB-01", "WEB-02", "WEB-03", 
    "BNS-01", "BNS-02", "BNS-03", 
    "SQL-01", "SQL-02", 
    "ADS-01", "ADS-02",
    ]
}

variable "admin_password" {
    default     = "Admin!123"
}

variable "set_zones_1" {
    description = "Assigne une zone à une machine virtuelle de la région 1."
    type        = list(string)
    default     = [
    "1", "2", "3",
    "1", "2", "3",
    "1", "3",
    "1", "3"
    ]
}

variable "set_zones_2" {
    description = "Assigne une zone à une machine virtuelle de la région 2."
    type        = list(string)
    default     = [
    "1", "2", "3",
    "1", "2", "3",
    "1", "3",
    "1", "3"
    ]
}

variable "traffic_manager_profile_1" {
    description = "Création d'un profil de traffic manager pour la région 1"
    default = "RG3TM1"
}

variable "traffic_manager_profile_2" {
    description = "Création d'un profil de traffic manager pour la région 2"
    default = "RG3TM2"
}

variable "traffic_manager_endpoint_1" {
    description = "Création d'un point de terminaison pour le traffic manager 1"
    default = "Traffic_manager_endpoint_1"
}

variable "traffic_manager_endpoint_2" {
    description = "Création d'un point de terminaison pour le traffic manager 2"
    default = "Traffic_manager_endpoint_2"
}

variable "total_lb" {
    description     = "Nombre total de load balancer par région."
    default         = 3
}
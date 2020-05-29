
provider "azurerm" {
  # Whilst version is optional, we /strongly recommend/ using it to pin the version of the Provider being used
  version = "=2.4.0"

  subscription_id = "5b1a1eeb-7f60-440f-baf1-0ae43fcb3e6d"
  client_id       = "70077815-81e2-4ae1-89f0-43c411ac7ead"
  client_secret   = "325f0be8-9180-4394-9db5-9483786576a1"
  tenant_id       = "06d52c87-b8fc-4a5c-810d-e91af17dd2f4"

  features {}
}


resource "azurerm_resource_group" "rg1" {
    name     = "ressource-group-1"
    location = "France Central"
}   

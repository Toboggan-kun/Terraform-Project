output "subnets_id" {
  value = azurerm_subnets.part2_subnets[*].id
}

variable "prefix" {
  default = "example"
}
variable "location" {
  default = "East US"
}

module "azure-env" {
  source   = "./azure-env"
  prefix   = var.prefix
  location = var.location
}

module "vault-server" {
  source                      = "./vault-server"
  prefix                      = "vault-server"
  resource_group_name         = module.azure-env.azurerm_resource_group_name
  resource_group_location     = module.azure-env.azurerm_resource_group_location
  resource_group_subnet_id    = module.azure-env.azurerm_resource_group_subnet_id
  network_security_group_name = module.azure-env.network_security_group_name
}
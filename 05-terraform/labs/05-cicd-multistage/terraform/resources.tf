resource "azurerm_resource_group" "resourcerg" {
  name     = var.rgname
  location = var.location
}

resource "azurerm_service_plan" "nfasp" {
  name                = var.asp
  location            = var.location
  resource_group_name = azurerm_resource_group.resourcerg.name
  os_type             = "Windows"
  sku_name            = "B1"
}

resource "azurerm_windows_web_app" "nfwebapp" {
  name                = var.webapp
  location            = var.location
  service_plan_id     = azurerm_service_plan.nfasp.id
  resource_group_name = azurerm_resource_group.resourcerg.name
  site_config { always_on = false }
}
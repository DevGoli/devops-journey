terraform {
  required_version = ">=1.14.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.0"
    }
  }


  backend "azurerm" {
    resource_group_name  = "terraformstaterg"
    storage_account_name = "netflixenglishstatesa11"
    container_name       = "statefile"
    key                  = "dev.tfstate"
  }

}

provider "azurerm" {
  features {}
}
variable "rgname" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Location"
  type        = string
  default     = "CanadaCentral"
}

variable "asp" {
  description = "App Service Plan"
  type        = string
}

variable "webapp" {
  description = "Webapp name"
  type        = string
}
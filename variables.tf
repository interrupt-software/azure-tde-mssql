variable "prefix" {
  description = "The prefix which should be used for all resources in this example."
  default     = "eco"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default     = "UK South"
}

variable "allowed_ip_address" {
  description = "Your IP address (`curl ifconfig.me`) if you would like to ensure only your IP address can access the VM."
  default     = "*"
}

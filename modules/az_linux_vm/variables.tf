variable "name" {
  description = "Default Resource Name | O Nome padrão dos recursos que serão criados"
}

variable "userName" {
  description = "Username used on virtual machines | Nomde do usuario das maquinas virtuais"
}

variable "numberOfRes" {
  default     = 1
  description = "Number of resources to be created | Quantos recursos devem ser criados, VM / NIC / IP"
}
variable "environment" {
  description = "Set current environment type | Define o tipo do ambiente atual"
}

variable "location" {
  description = "Azure Resource Region Location | Qual a região do Azure onde os recursos serão dispostos"
}

variable "ip" {
  description = "IP Address list to use in your vms if needed | Quais os Endereços IP que podem ser usados nas VMs"
}

variable "tags" {
  type        = map(string)
  description = "Any tags that should be present on the resources | Quais tags devem pertencer aos recursos"
}

variable "script" {
  type = string
}
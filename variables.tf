variable "vsphere_server" {
  default = "vcelab01.lab"
  type    = string
}

variable "vsphere_user" {
  default = "administrator@vsphere.local"
  type    = string
}

variable "vsphere_password" {
  default   = "PASSWORD"
  type      = string
  sensitive = true
}

variable "datacenter" {
  default = "Datacenter"
  type    = string
}

variable "cluster" {
  default = "LAB"
  type    = string
}

variable "datastore" {
  default = "datastore1"
  type    = string
}

variable "network_name" {
  default = "VLAN_LAB"
  type    = string
}

variable "template_name" {
  default = "TEMPLATE-W2019"
  type    = string
}

variable "VM_Name" {
  description = "VM NAME?"

}
variable "vm_count" {
  description = "Number of instaces"
  type        = number

}
variable "varcountip" {
  default = 0
  type    = number

}

variable "private_IP" {
  description = "Avaliable IP"
  type        = list(string)
  default = [
    "",
    "10.200.43.100",
    "10.200.43.101",
    "10.200.43.111",
    "10.200.43.112",
    "10.200.43.113",
    "10.200.43.114",
    "10.200.43.115",
    "10.200.43.116",
    "10.200.43.102",
    "10.200.43.103",
  ]
}

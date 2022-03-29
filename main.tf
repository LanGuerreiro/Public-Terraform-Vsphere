data "vsphere_datacenter" "datacenter" {
  name = var.datacenter
}
data "vsphere_datastore" "datastore" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.datacenter.id
}
data "vsphere_compute_cluster" "cluster" {
  name          = var.cluster
  datacenter_id = data.vsphere_datacenter.datacenter.id
}
data "vsphere_network" "network" {
  name          = var.network_name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}
data "vsphere_virtual_machine" "template" {
  name          = "/${var.datacenter}/vm/TEMPLATE/${var.template_name}"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

# Tag Categories #
resource "vsphere_tag_category" "tag-environment" {
  name        = "Environment"
  cardinality = "SINGLE"
  associable_types = [
    "VirtualMachine"
  ]
}
# Tag Environment Variables #
resource "vsphere_tag" "tag-environment" {
  name        = "LAB"
  category_id = vsphere_tag_category.tag-environment.id
  description = "LAB TerraForm"
}


resource "vsphere_virtual_machine" "vm" {
  count            = var.vm_count
  name             = "${var.VM_Name}-${count.index + 1}"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  num_cpus         = 4
  memory           = 4096
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  folder           = "LAB"
  scsi_type        = data.vsphere_virtual_machine.template.scsi_type
  firmware         = data.vsphere_virtual_machine.template.firmware


  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]


  }
  wait_for_guest_net_timeout  = 10000000000000000
  wait_for_guest_net_routable = false
  wait_for_guest_ip_timeout   = 10000000000000000
  shutdown_wait_timeout       = 10
  migrate_wait_timeout        = 10000000000000000
  force_power_off             = false




  dynamic "disk" {
    for_each = [for s in data.vsphere_virtual_machine.template.disks : {
      label            = index(data.vsphere_virtual_machine.template.disks, s)
      unit_number      = index(data.vsphere_virtual_machine.template.disks, s)
      size             = s.size
      eagerly_scrub    = s.eagerly_scrub
      thin_provisioned = contains(keys(s), "thin_provisioned") ? s.thin_provisioned : "true"
    }]
    content {
      label            = disk.value.label
      unit_number      = disk.value.unit_number
      size             = disk.value.size
      datastore_id     = data.vsphere_datastore.datastore.id
      eagerly_scrub    = disk.value.eagerly_scrub
      thin_provisioned = disk.value.thin_provisioned
    }
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {

      windows_options {

        computer_name  = "${var.VM_Name}-${count.index + 1}"
        workgroup      = "Terraform"
        admin_password = "Str0ngP@ssw0rd!"

      }
      timeout = 60
      network_interface {

        ipv4_address = var.private_IP[count.index + 1]
        ipv4_netmask = 24


      }
      ipv4_gateway    = "10.200.43.126"
      dns_server_list = ["8.8.8.8", "4.4.4.4"]

    }
  }
  tags = [
    "${vsphere_tag.tag-environment.id}"
  ]

}



//output "vm_ip" {
//  value = vsphere_virtual_machine.vm.guest_ip_addresses

//}

//output "disk_path1" {
//  value = vsphere_virtual_machine.vm.disk[0]
//}



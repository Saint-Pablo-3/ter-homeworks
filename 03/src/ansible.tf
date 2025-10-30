data "template_file" "ansible_inventory" {
  template = file("${path.module}/inventory.tmpl")

  vars = {
    webservers = jsonencode([
      for vm in yandex_compute_instance.web :
      {
        name       = vm.name
        ip         = vm.network_interface[0].nat_ip_address
        fqdn       = vm.fqdn
      }
    ])
    databases = jsonencode([
      for name, vm in yandex_compute_instance.db :
      {
        name       = name
        ip         = vm.network_interface[0].nat_ip_address
        fqdn       = vm.fqdn
      }
    ])
    storage = jsonencode([
      {
        name       = yandex_compute_instance.storage.name
        ip         = yandex_compute_instance.storage.network_interface[0].nat_ip_address
        fqdn       = yandex_compute_instance.storage.fqdn
      }
    ])
  }
}

resource "local_file" "ansible_inventory" {
  content  = data.template_file.ansible_inventory.rendered
  filename = "${path.module}/inventory.ini"
}


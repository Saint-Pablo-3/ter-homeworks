module "vpc_dev" {
  source   = "./vpc"
  env_name = "develop"
  zone     = var.default_zone
  cidr     = "10.0.1.0/24"
}

locals {
  vms_ssh_root_key = file("~/.ssh/yandex-key.pub")
}

data "template_file" "cloudinit" {
  template = file("${path.module}/cloud-init.yml")
  vars = {
    vms_ssh_root_key = local.vms_ssh_root_key
  }
}

module "marketing_vm" {
  source         = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"
  env_name       = "marketing"
  network_id     = module.vpc_dev.subnet.network_id
  subnet_zones   = [module.vpc_dev.subnet.zone]
  subnet_ids     = [module.vpc_dev.subnet.id]
  instance_name  = "marketing"
  instance_count = 1
  image_family   = "ubuntu-2004-lts"
  public_ip      = true

  labels = {
    project = "marketing"
  }

  metadata = {
    user-data = data.template_file.cloudinit.rendered
  }
}

module "analytics_vm" {
  source         = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"
  env_name       = "analytics"
  network_id     = module.vpc_dev.subnet.network_id
  subnet_zones   = [module.vpc_dev.subnet.zone]
  subnet_ids     = [module.vpc_dev.subnet.id]
  instance_name  = "analytics"
  instance_count = 1
  image_family   = "ubuntu-2004-lts"
  public_ip      = true

  labels = {
    project = "analytics"
  }

  metadata = {
    user-data = data.template_file.cloudinit.rendered
  }
}


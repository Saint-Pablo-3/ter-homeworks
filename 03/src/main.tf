# Создание сети
resource "yandex_vpc_network" "develop" {
  name = var.vpc_name
}

# Создание подсети
resource "yandex_vpc_subnet" "develop" {
  name           = var.vpc_name
  zone           = var.default_zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.default_cidr
}

# Поиск последнего образа Ubuntu 22.04 LTS
data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

# Группа безопасности (Security Group)
resource "yandex_vpc_security_group" "default" {
  name        = "default-sg"
  description = "Security group for SSH and HTTP access"
  network_id  = yandex_vpc_network.develop.id

  ingress {
    description    = "Allow SSH"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "Allow HTTP"
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description    = "Allow all outgoing traffic"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# Локальная переменная для SSH-ключа
locals {
  public_key = file("~/.ssh/yandex-key.pub")
}


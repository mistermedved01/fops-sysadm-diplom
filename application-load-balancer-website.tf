data "yandex_compute_image" "ubuntu_image" {
  family = "ubuntu-2204-lts"
}

// Создание группы ВМ
resource "yandex_compute_instance_group" "test-ig" {
  name                = "test-ig"
  service_account_id  = "ajee1lbvpg3isdj555tq"
  
  // Настройка шаблона ВМ
  instance_template {
    name = "ngnix-{instance.index}"
    platform_id = "standard-v1"
    resources {
      memory = 2
      cores  = 2
    }
    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = data.yandex_compute_image.ubuntu_image.id
        size     = 10
      }
    }
    network_interface {
      network_id = yandex_vpc_network.lan01.id
      subnet_ids = [yandex_vpc_subnet.sub01.id,yandex_vpc_subnet.sub02.id]
      nat = true
    }

//Передача ssh-ключа в ВМ
metadata = {
    user-data = "${file("./meta.yml")}"
  }
  }

  // Настройка политики размещения ВМ в разных зонах
  allocation_policy {
    zones = ["ru-central1-a", "ru-central1-b"]
  }

  // Настройка масштабирования и развертывания
  scale_policy {
    fixed_scale {
      size = 2
    }
  }
  
//Политика деплоя
  deploy_policy {
    max_unavailable = 1
    max_creating    = 1
    max_expansion   = 1
    max_deleting    = 1
  }

//Application Load Balancer
  application_load_balancer {
    target_group_name = "alb-tg"
  }
}

//Создаем бэкенд группу
resource "yandex_alb_backend_group" "alb-bg" {
  name                     = "alb-bg"

  http_backend {
    name                   = "backend-1"
    port                   = 80
    target_group_ids       = [yandex_compute_instance_group.test-ig.application_load_balancer.0.target_group_id]
    healthcheck {
      timeout              = "10s"
      interval             = "2s"
      healthcheck_port     = 80
      http_healthcheck {
        path               = "/"
      }
    }
  }
}

//Создаем http_router
resource "yandex_alb_http_router" "alb-router" {
  name   = "alb-router"
}

//Создание виртуального хоста для ALB
resource "yandex_alb_virtual_host" "alb-host" {
  name           = "alb-host"
  http_router_id = yandex_alb_http_router.alb-router.id
  #authority      = [var.domain, "www.${var.domain}"]
  route {
    name = "route-1"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.alb-bg.id
      }
    }
  }
}

resource "yandex_alb_load_balancer" "alb-1" {
  name               = "alb-1"
  network_id         = yandex_vpc_network.lan01.id

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.sub01.id
    }

    location {
      zone_id   = "ru-central1-b"
      subnet_id = yandex_vpc_subnet.sub02.id
    }
  }

  listener {
    name = "alb-listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [ 80 ]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.alb-router.id
      }
    }
  }
}

output "ngnix_IP_NAT" {
  value = [for instance in yandex_compute_instance_group.test-ig.instances[*] : instance.network_interface[0].nat_ip_address]
}
output "ngnix_names" {
  description = "Имена виртуальных машин"
  value       = yandex_compute_instance_group.test-ig.instances[*].name
}
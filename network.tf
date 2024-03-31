// Создание сети lan01
resource "yandex_vpc_network" "lan01" {
  name = "lan01"
}

// Создание подсети в зоне а
resource "yandex_vpc_subnet" "sub01" {
  name           = "sub01"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.lan01.id
  v4_cidr_blocks = ["192.168.0.0/24"]
}

// Создание подсети в зоне b
resource "yandex_vpc_subnet" "sub02" {
  name           = "sub02"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.lan01.id
  v4_cidr_blocks = ["192.168.1.0/24"]
}
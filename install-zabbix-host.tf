resource "yandex_compute_instance" "zabbix-host" {
  name = "zabbix-host"
  zone = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_image.id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.sub01.id
    nat       = true
  }
metadata = {
    user-data = "${file("./meta.yml")}"
  }

#connection {
#      host = yandex_compute_instance.zabbix-host.network_interface.0.nat_ip_address
#      user = "superuser"
#      private_key = "${file("/home/medved/Desktop/id_rsa")}"
#    }

#  provisioner "file" {
#    source = "scripts/zabbix_server.conf"
#    destination = "/tmp/zabbix_server.conf"
#  }  

#  provisioner "file" {
#    source = "scripts/setupzabbix.sh"
#    destination = "/tmp/setupzabbix.sh"
#  }

#provisioner "remote-exec" {
#    inline = [
#      "chmod +x /tmp/setupzabbix.sh",
#      "/tmp/setupzabbix.sh",            
#    ]
#  }
}

output "zabbix_host_ip_address" {
  value = yandex_compute_instance.zabbix-host.network_interface.0.ip_address
}

locals {
  output_file_path = "/home/medved/Desktop/first_project/ansible/zabbix-agent_install/templates/zabbix_agentd.conf.j2"
}

# Это провайдер "null_resource", который будет выполнен только после создания VM.
resource "null_resource" "write_vm_ip_to_file" {
  triggers = {
    zabbix_host_ip_address = yandex_compute_instance.zabbix-host.network_interface.0.ip_address
  }

  provisioner "local-exec" {
    command = "echo '\nServer=${yandex_compute_instance.zabbix-host.network_interface.0.ip_address}' >> ${local.output_file_path}"
  }
}
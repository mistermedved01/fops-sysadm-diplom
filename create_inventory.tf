data "template_file" "inventory" {
    template = file("${path.module}/inventory.tpl")

    vars = {
    #public_ip_address_test-vm = join("\n", [for i, instance in yandex_compute_instance.test-vm : "${instance.name} ansible_host=${instance.network_interface.0.nat_ip_address}"])
    public_ip_address_test-ig = join("\n", [for idx, instance in yandex_compute_instance_group.test-ig.instances : "${instance.name} ansible_host=${instance.network_interface[0].nat_ip_address}"])
    public_ip_address_zabbix-host = "${yandex_compute_instance.zabbix-host.name} ansible_host=${yandex_compute_instance.zabbix-host.network_interface.0.nat_ip_address}"

  filename = "/home/medved/Desktop/fops-sysadm-diplom/inventory.yml"
}
    }
resource "null_resource" "inventories" {
    provisioner "local-exec" {
        command = "echo '${data.template_file.inventory.rendered}' > /home/medved/Desktop/fops-sysadm-diplom/inventory.yml"    
    }

    triggers = {
        template = data.template_file.inventory.rendered
    }
}
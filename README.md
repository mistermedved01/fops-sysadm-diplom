# Задача
Ключевая задача — разработать:
- отказоустойчивую инфраструктуру для сайта (+);
- включающую мониторинг (+);
- сбор логов (-);
- резервное копирование основных данных (-). 

Инфраструктура должна размещаться в Yandex Cloud.

Для развёртки инфраструктуры использованы Terraform и Ansible.

## Сайт

**application-load-balancer-website.tf**

Создана группа VM с распределением машин в разных зонах доступности.

Target Group, добавлены две созданные ВМ.

Backend Group, настроены backends на target group. Настроены healthcheck на корень (/) и порт 80, протокол HTTP.

HTTP router. Путь — /, backend group.

Application load balancer для распределения трафика на веб-сервера.

## Мониторинг

**install-zabbix-host.tf**

На созданную VM копируется конфиг и запускается скрипт установки Zabbix Server.

IP-адрес созданного Zabbix Server копируется в файл шаблон Ansible для последующей раскатки Zabbix Agent.

**create_inventory.tf**

Создание Inventory для Ansible согласно шаблона inventory.tpl

В итоге получаем готовый inventory.yml с созданными VM. Можем запускать плейбуки.

---

Ставим ngnix на VM:

sudo ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.yml /home/medved/Desktop/fops-sysadm-diplom/ansible/ngnix_install.yml --limit ngnix-1,ngnix-2

Ставим Zabbix Agent на VM:

sudo ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.yml /home/medved/Desktop/fops-sysadm-diplom/ansible/zabbix-agent_install/install-zabbix-agent.yml --limit ngnix-1,ngnix-2





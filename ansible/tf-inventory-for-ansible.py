import json
import yaml
import os

def generate_terraform_inventory(tfstate_file):
    with open(tfstate_file, 'r') as f:
        tfstate = json.load(f)

    inventory = {
        'all': {
            'hosts': {},
            'vars': {},
            'children': {}
        }
    }

    for resource in tfstate.get('resources', []):
        if resource['type'] == 'yandex_compute_instance':
            for instance in resource['instances']:
                name = instance['attributes']['name']
                ip_address = instance['attributes']['network_interface'][0]['nat_ip_address']

                inventory['all']['hosts'][name] = {
                    'ansible_host': ip_address,
                    'ansible_user': 'superuser',
                    'ansible_ssh_private_key_file': '/home/medved/Desktop/id_rsa'
                }
        elif resource['type'] == 'yandex_compute_instance_group':
            for instance in resource['instances'][0]['attributes']['instances']:
                name = instance['name']
                ip_address = instance['network_interface'][0]['nat_ip_address']

                inventory['all']['hosts'][name] = {
                    'ansible_host': ip_address,
                    'ansible_user': 'superuser',
                    'ansible_ssh_private_key_file': '/home/medved/Desktop/id_rsa'
                }

    return inventory

if __name__ == '__main__':
    tfstate_file = '/home/medved/Desktop/first_project/terraform.tfstate'
    output_folder = '/home/medved/Desktop/first_project/ansible/'
    inventory = generate_terraform_inventory(tfstate_file)
    
       # Ensure the output folder exists
    os.makedirs(output_folder, exist_ok=True)
    
    # Specify the path for the output file
    output_file = os.path.join(output_folder, 'inventory.yml')
    
    # Open the file for writing
    with open(output_file, 'w') as outfile:
        # Write the generated inventory to the file
        yaml.dump(inventory, outfile, default_flow_style=False)
    
    print("Inventory сохранён в файл 'inventory.yml' в папке", output_folder)
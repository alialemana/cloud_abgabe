# Cloud-Projekt: Bildbeschreibung mit Vertex-AI

## Terraform

Zur Bereitstellung der Infrastruktur wird Terraform verwendet. Dafür muss in examplevariables.tfvars der Pfad zum Credentials-File eingegeben werden und das GCP-Projekt.
Dann mit `terraform init` das Projekt initiieren und mit `terraform apply` anwenden.

## Ansible

Die erstelle GCP-VM wird mit Ansible konfiguriert. Dafür die exampleenv.yaml ausfüllen und in `env.yaml` unbennen. Den AUTH_KEY erhält man durch `gcloud auth print-access-token`.
Außerdem muss man in example_node_inventory.ini die external-ip und den user der VM einfügen.
Dann über `ansible-playbook -i example_node_inventory.ini abgaben_playbook_docker.yaml` das Playbook starten.

## Aufrufen Web-App

Über `http:<external-ip>:5000` kann die App im Browser aufgerufen werden.

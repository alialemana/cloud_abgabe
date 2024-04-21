# Dieser Code ist mit Terraform 4.25.0 und Versionen kompatibel, die mit 4.25.0 abwärtskompatibel sind.
# Informationen zum Validieren dieses Terraform-Codes finden Sie unter https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/google-cloud-platform-build#format-and-validate-the-configuration.

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials_file)
  project = var.project
  region  = var.google-region
  zone    = var.google-zone
}

resource "google_compute_instance" "gcp-vm-abgabe" {
  boot_disk {
    auto_delete = true
    device_name = "gcp-vm-abgabe"

    initialize_params {
      image = "projects/debian-cloud/global/images/debian-12-bookworm-v20240213"
      size  = 10
      type  = "pd-balanced"
    }

    mode = "READ_WRITE"
  }

  can_ip_forward      = false
  deletion_protection = false
  enable_display      = false

  labels = {
    goog-ec-src = "vm_add-tf"
  }

  machine_type = "e2-micro"

  metadata = {
    ssh-keys = "alialemana:${file("~/.ssh/id_rsa.pub")}"
  }

  name = "gcp-vm-abgabe"

  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }

    queue_count = 0
    stack_type  = "IPV4_ONLY"
    subnetwork  = "projects/testprojekt-332515/regions/us-central1/subnetworks/default"
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }

  service_account {
    email  = "521450885800-compute@developer.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }

  tags = ["http-server", "https-server"]
  zone = "us-central1-a"
}

output "ip" {
  value = google_compute_instance.gcp-vm-abgabe.network_interface.0.network_ip
}


resource "google_project_service" "firestore" {
  project = var.project
  service = "firestore.googleapis.com"

  disable_dependent_services = true
}

resource "google_project_service" "iam" {
  project = var.project
  service = "iam.googleapis.com"
}

resource "google_project_iam_binding" "firestore_binding" {
  project = var.project
  role    = "roles/datastore.user"

  members = [
    "serviceAccount:521450885800-compute@developer.gserviceaccount.com"
  ]
  depends_on = [google_project_service.iam]
}

resource "google_firestore_database" "database" {
  project     = var.project
  name        = "firestoredatabase"
  location_id = "eur3"
  type        = "FIRESTORE_NATIVE"

  depends_on = [
    google_project_service.firestore,
    google_project_iam_binding.firestore_binding
    ]
}


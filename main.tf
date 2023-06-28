resource "google_compute_address" "static" {
  name = "firezone-static-ip"
  region = var.region
}

resource "google_compute_instance" "default" {
  name         = "wireguard-vpn"
  machine_type = "e2-medium"
  zone         = var.zone

  tags = ["wireguard-vpn"] 

  boot_disk {
    initialize_params {
      image = "ubuntu-2004-lts"
    }
  }

  network_interface {
    network = "default"

    access_config {
        nat_ip = google_compute_address.static.address
    }
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    echo -e "${var.firezone_admin}\n\n\n\n\n\n" | bash <(curl -fsSL https://github.com/firezone/firezone/raw/master/scripts/install.sh) posthog-blocked 
  EOT

  service_account {
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

resource "google_compute_firewall" "default" {
  name    = "terraform-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  allow {
    protocol = "udp"
    ports    = ["51820"]
  }

  target_tags   = ["wireguard-vpn"]
  source_ranges = ["0.0.0.0/0"]
}

output "instance_ip_address" {
  description = "The static IP of the instance"
  value       = google_compute_address.static.address
}
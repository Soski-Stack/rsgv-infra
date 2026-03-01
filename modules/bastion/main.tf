# modules/bastion/main.tf
# Provisions a minimal e2-micro bastion VM for agent/admin DB access via Cloud SQL Auth Proxy.
# Access is restricted to IAP tunnel on port 22 — no public SSH.
# The VM has no external IP; Cloud SQL is reached via private IP on the shared VPC.

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

locals {
  name   = "rsgv-bastion-${var.environment}"
  labels = merge({ environment = var.environment, managed-by = "terraform" }, var.labels)
}

# ── Startup script ────────────────────────────────────────────────────
# Installs Cloud SQL Auth Proxy and postgresql-client on boot.
locals {
  startup_script = <<-STARTUP
    #!/bin/bash
    set -euo pipefail

    PROXY_VERSION="v2.14.1"
    PROXY_BIN="/usr/local/bin/cloud-sql-proxy"

    echo "[bastion] Installing postgresql-client..."
    apt-get update -qq
    apt-get install -y -qq postgresql-client

    echo "[bastion] Installing Cloud SQL Auth Proxy $${PROXY_VERSION}..."
    curl -sSL \
      "https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/$${PROXY_VERSION}/cloud-sql-proxy.linux.amd64" \
      -o "$${PROXY_BIN}"
    chmod +x "$${PROXY_BIN}"

    echo "[bastion] Writing cloud-sql-proxy systemd unit..."
    cat > /etc/systemd/system/cloud-sql-proxy.service <<UNIT
    [Unit]
    Description=Cloud SQL Auth Proxy
    After=network-online.target
    Wants=network-online.target

    [Service]
    Type=simple
    User=nobody
    ExecStart=$${PROXY_BIN} ${var.cloud_sql_instance} --address 127.0.0.1 --port 5432 --private-ip
    Restart=on-failure
    RestartSec=5

    [Install]
    WantedBy=multi-user.target
    UNIT

    systemctl daemon-reload
    systemctl enable cloud-sql-proxy
    systemctl start cloud-sql-proxy

    echo "[bastion] Setup complete."
  STARTUP
}

# ── Bastion VM ────────────────────────────────────────────────────────
resource "google_compute_instance" "bastion" {
  project      = var.project_id
  name         = local.name
  machine_type = var.machine_type
  zone         = var.zone
  labels       = local.labels

  tags = ["bastion", "rsgv-${var.environment}"]

  boot_disk {
    initialize_params {
      image = var.bastion_image
      size  = 10
      type  = "pd-standard"
    }
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnetwork
    # No access_config block = no external IP (private only)
  }

  service_account {
    email  = var.service_account_email
    scopes = ["cloud-platform"]
  }

  metadata = {
    enable-oslogin         = "TRUE"
    startup-script         = local.startup_script
    block-project-ssh-keys = "true"
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  scheduling {
    # Allow stopping VM to save cost when not needed
    preemptible         = false
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  lifecycle {
    ignore_changes = [metadata["startup-script"]]
  }
}

# ── Firewall: IAP SSH ingress only ────────────────────────────────────
resource "google_compute_firewall" "bastion_iap_ssh" {
  project = var.project_id
  name    = "allow-iap-ssh-${var.environment}"
  network = var.network

  description = "Allow SSH from IAP to bastion VMs only (no public SSH)"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # IAP's IP range — do not widen this
  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["bastion"]
}

# ── IAM: IAP tunnel access for allowed admins ─────────────────────────
resource "google_iap_tunnel_instance_iam_binding" "ssh" {
  count    = length(var.allowed_admins) > 0 ? 1 : 0
  project  = var.project_id
  zone     = var.zone
  instance = google_compute_instance.bastion.name
  role     = "roles/iap.tunnelResourceAccessor"
  members  = var.allowed_admins
}

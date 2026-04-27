resource "google_cloud_run_service" "this" {
  name     = var.service_name
  location = var.region
  project  = var.project_id

  template {
    spec {
      containers {
        # Image is managed by rsgv-crm CI/CD — set a placeholder here;
        # actual deploys update the image via gcloud run deploy, not Terraform.
        image = var.image_placeholder

        resources {
          limits = {
            cpu    = var.cpu
            memory = var.memory
          }
        }

        dynamic "ports" {
          for_each = var.container_port != null ? [var.container_port] : []
          content {
            container_port = ports.value
          }
        }

        dynamic "env" {
          for_each = var.env_vars
          content {
            name  = env.key
            value = env.value
          }
        }
      }
      service_account_name = var.service_account_email
    }

    metadata {
      annotations = merge(
        {
          "autoscaling.knative.dev/minScale" = tostring(var.min_instances)
          "autoscaling.knative.dev/maxScale" = tostring(var.max_instances)
        },
        var.cpu_throttling_disabled ? {
          "run.googleapis.com/cpu-throttling" = "false"
        } : {},
        var.vpc_connector != "" ? {
          "run.googleapis.com/vpc-access-connector" = var.vpc_connector
          "run.googleapis.com/vpc-access-egress"    = var.vpc_egress
        } : {},
      )
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  lifecycle {
    # Image updates come from rsgv-crm — do not let Terraform revert them
    ignore_changes = [
      template[0].spec[0].containers[0].image,
      template[0].metadata[0].annotations["run.googleapis.com/client-name"],
      template[0].metadata[0].annotations["run.googleapis.com/client-version"],
    ]
  }
}

resource "google_cloud_run_service_iam_member" "invoker" {
  count    = var.allow_unauthenticated ? 1 : 0
  service  = google_cloud_run_service.this.name
  location = google_cloud_run_service.this.location
  project  = var.project_id
  role     = "roles/run.invoker"
  member   = "allUsers"
}

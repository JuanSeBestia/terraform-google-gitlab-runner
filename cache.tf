resource "google_storage_bucket" "cache" {
    name          = join("-", [var.ci_runner_instance_name, "cache"])
    location      = "EU"
    force_destroy = true

    lifecycle_rule {
        condition {
            age = "30"
        }
        action {
            type = "Delete"
        }
    }
}

resource "google_service_account" "cache-user" {
    account_id = join("-", [var.ci_runner_instance_name, "sa"])
}

resource "google_service_account_key" "cache-user" {
    service_account_id = google_service_account.cache-user.name
    public_key_type    = "TYPE_X509_PEM_FILE"
}

resource "google_project_iam_member" "project" {
    project = var.gcp_project
    role    = "roles/storage.objectAdmin"

    member = format("serviceAccount:%s", google_service_account.cache-user.email)
}

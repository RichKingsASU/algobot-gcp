provider "google" {
  project = "ttbot-466703"
  region  = "us-central1"
}

resource "google_cloud_run_service" "signal_ingestor" {
  name     = "signal-ingestor"
  location = "us-central1"

  template {
    spec {
      containers {
        image = "gcr.io/cloudrun/hello"
      }
      service_account_name = google_service_account.algobot.email
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [google_project_service.run]
}

resource "google_service_account" "algobot" {
  account_id   = "algobot-runner"
  display_name = "AlgoBot Service Account"
}

resource "google_project_service" "run" {
  service = "run.googleapis.com"
}

resource "google_project_service" "secretmanager" {
  service = "secretmanager.googleapis.com"
}

resource "google_project_service" "sqladmin" {
  service = "sqladmin.googleapis.com"
}

resource "google_project_service" "pubsub" {
  service = "pubsub.googleapis.com"
}

// IAM: Allow Cloud Run to access Secret Manager
resource "google_service_account_iam_member" "secret_accessor" {
  service_account_id = google_service_account.algobot.id
  role               = "roles/secretmanager.secretAccessor"
  member             = "serviceAccount:${google_service_account.algobot.email}"
}

// IAM: Allow Cloud Run to publish to Pub/Sub
resource "google_service_account_iam_member" "pubsub_publisher" {
  service_account_id = google_service_account.algobot.id
  role               = "roles/pubsub.publisher"
  member             = "serviceAccount:${google_service_account.algobot.email}"
}

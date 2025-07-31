terraform {
  backend "gcs" {
    bucket  = "ttbot-466703-terraform-state"
    prefix  = "algobot"
  }
}

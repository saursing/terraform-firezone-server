variable "project_id" {}

variable "region" {
  default = "us-central1"
}

variable "zone" {
  default = "us-central1-a"
}

variable "firezone_admin" {
  description = "The admin email for the Firezone server"
  type        = string
  default     = "admin@firezone.com"
}

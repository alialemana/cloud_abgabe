variable "google-region" {
  description = "google region"
  type        = string
  nullable    = false
  default     = "europe-west1"
}

variable "google-zone" {
  description = "google zone"
  type        = string
  nullable    = false
  default     = "europe-west1-b"
}

variable "credentials_file" {
}

variable "project" {
}
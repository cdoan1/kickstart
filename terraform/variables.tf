variable "prefix" {
  description = "string, prefix of image names"
  default     = "stage-1"
}

variable "hash" {
  description = "integer, prefix of image names"
  default     = 101
}

variable "jobid" {
  description = "integer, prefix of image names"
  default     = 1
}

variable "offline_mode" {
  description = "boolean, provision cluster in airgap mode or not"
  default     = false
}

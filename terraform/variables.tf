######################################### General #########################################
variable "PROJECT_PREFIX" {
  description = "Prefix that is appended to all resources"
  type        = string
  default     = "Plataquery"
}

variable "TEAM" {
  description = "Define team that owns this resource"
  type        = string
  default     = "IncidenResponse"
}

variable "primary_region" {
  description = "Primary region to create resources in"
  type        = string
  default     = "us-east-2"
}

variable "primary_zone" {
  description = "Primary availability zone to create resources in"
  type        = string
  default     = "us-east-2b"
}


######################################### S3 #########################################


######################################### Kinesis #########################################


######################################### Secrets #########################################
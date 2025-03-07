/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */



variable "location" {
  description = "The location where resources are going to be deployed."
  type        = string
}

variable "project_id" {
  description = "The project where cloud run is going to be deployed."
  type        = string
}

variable "service_name" {
  description = "The name of the Cloud Run service to create."
  type        = string
}

variable "image" {
  description = "GAR hosted image URL to deploy."
  type        = string
}

variable "cloud_run_sa" {
  description = "Service account to be used on Cloud Run."
  type        = string
}

variable "vpc_connector_id" {
  description = "VPC Connector id in the format projects/PROJECT/locations/LOCATION/connectors/NAME."
  type        = string
}

variable "encryption_key" {
  description = "CMEK encryption key self-link expected in the format projects/PROJECT/locations/LOCATION/keyRings/KEY-RING/cryptoKeys/CRYPTO-KEY."
  type        = string
}

variable "region" {
  description = "Location for load balancer and Cloud Run resources."
  type        = string
}

variable "domain" {
  description = "Domain name to run the load balancer on. Used if `ssl` is `true`. Modify the default value below for your `domain` name."
  type        = string
}

variable "default_rules" {
  description = "Default rule for Cloud Armor."
  default = {
    default_rule = {
      action         = "allow"
      priority       = "2147483647"
      versioned_expr = "SRC_IPS_V1"
      src_ip_ranges  = ["*"]
      description    = "Default allow all rule"
    }
  }
  type = map(object({
    action         = string
    priority       = string
    versioned_expr = string
    src_ip_ranges  = list(string)
    description    = string
  }))
}

variable "owasp_rules" {
  description = "These are additional Cloud Armor rules for SQLi, XSS, LFI, RCE, RFI, Scannerdetection, Protocolattack and Sessionfixation (requires Cloud Armor default_rule)."
  default = {
    rule_sqli = {
      action     = "deny(403)"
      priority   = "1000"
      expression = "evaluatePreconfiguredExpr('sqli-v33-stable')"
    }
    rule_xss = {
      action     = "deny(403)"
      priority   = "1001"
      expression = "evaluatePreconfiguredExpr('xss-v33-stable')"
    }
    rule_lfi = {
      action     = "deny(403)"
      priority   = "1002"
      expression = "evaluatePreconfiguredExpr('lfi-v33-stable')"
    }
    rule_canary = {
      action     = "deny(403)"
      priority   = "1003"
      expression = "evaluatePreconfiguredExpr('rce-v33-stable')"
    }
    rule_rfi = {
      action     = "deny(403)"
      priority   = "1004"
      expression = "evaluatePreconfiguredExpr('rfi-v33-stable')"
    }
    rule_scannerdetection = {
      action     = "deny(403)"
      priority   = "1005"
      expression = "evaluatePreconfiguredExpr('scannerdetection-v33-stable')"
    }
    rule_protocolattack = {
      action     = "deny(403)"
      priority   = "1006"
      expression = "evaluatePreconfiguredExpr('protocolattack-v33-stable')"
    }
    rule_sessionfixation = {
      action     = "deny(403)"
      priority   = "1007"
      expression = "evaluatePreconfiguredExpr('sessionfixation-v33-stable')"
    }
  }
  type = map(object({
    action     = string
    priority   = string
    expression = string
  }))
}

variable "ssl" {
  description = "Run load balancer on HTTPS and provision managed certificate with provided `domain`."
  type        = bool
  default     = true
}

variable "lb_name" {
  description = "Name for load balancer and associated resources."
  default     = "tf-cr-lb"
}

variable "env_vars" {
  type = list(object({
    value = string
    name  = string
  }))
  description = "Environment variables."
  default     = []
}

variable "members" {
  type        = list(string)
  description = "Users/SAs to be given invoker access to the service with the prefix `serviceAccount:' for SAs and `user:` for users."
  default     = []
}

variable "generate_revision_name" {
  description = "Option to enable revision name generation."
  type        = bool
  default     = true
}

variable "traffic_split" {
  description = "Managing traffic routing to the service."
  type = list(object({
    latest_revision = bool
    percent         = number
    revision_name   = string
  }))
  default = [{
    latest_revision = true
    percent         = 100
    revision_name   = "v1-0-0"
  }]
}

variable "service_labels" {
  description = "A set of key/value label pairs to assign to the service."
  type        = map(string)
  default     = {}
}

// Metadata
variable "template_labels" {
  description = "A set of key/value label pairs to assign to the container metadata."
  type        = map(string)
  default     = {}
}

// template spec
variable "container_concurrency" {
  description = "Concurrent request limits to the service."
  type        = number
  default     = null
}

variable "timeout_seconds" {
  description = "Timeout for each request."
  type        = number
  default     = 120
}

variable "volumes" {
  description = "[Beta] Volumes needed for environment variables (when using secret)."
  type = list(object({
    name = string
    secret = set(object({
      secret_name = string
      items       = map(string)
    }))
  }))
  default = []
}

# template spec container
# resources
# cpu = (core count * 1000)m
# memory = (size) in Mi/Gi
variable "limits" {
  description = "Resource limits to the container."
  type        = map(string)
  default     = null
}
variable "requests" {
  description = "Resource requests to the container."
  type        = map(string)
  default     = {}
}

variable "ports" {
  description = "Port which the container listens to (http1 or h2c)."
  type = object({
    name = string
    port = number
  })
  default = {
    name = "http1"
    port = 8080
  }
}

variable "argument" {
  description = "Arguments passed to the ENTRYPOINT command, include these only if image entrypoint needs arguments."
  type        = list(string)
  default     = []
}

variable "container_command" {
  description = "Leave blank to use the ENTRYPOINT command defined in the container image, include these only if image entrypoint should be overwritten."
  type        = list(string)
  default     = []
}

variable "volume_mounts" {
  type = list(object({
    mount_path = string
    name       = string
  }))
  description = "[Beta] Volume Mounts to be attached to the container (when using secret)."
  default     = []
}

// Domain Mapping
variable "verified_domain_name" {
  description = "Custom Domain Name."
  type        = string
  default     = ""
}

variable "force_override" {
  description = "Option to force override existing mapping."
  type        = bool
  default     = false
}

variable "certificate_mode" {
  description = "The mode of the certificate (NONE or AUTOMATIC)."
  type        = string
  default     = "NONE"
}

variable "domain_map_labels" {
  description = "A set of key/value label pairs to assign to the Domain mapping."
  type        = map(string)
  default     = {}
}

variable "domain_map_annotations" {
  description = "Annotations to the domain map."
  type        = map(string)
  default     = {}
}

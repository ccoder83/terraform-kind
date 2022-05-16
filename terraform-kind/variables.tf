variable "kind_cluster_name" {
  type        = string
  description = "Name of cluster"
  default     = "kind"
}

variable "kind_cluster_config_path" {
  type        = string
  description = "Location where this cluster's kubeconfig will be saved to"
  default     = "~/.kube/config"
}

variable "app_namespace" {
  type        = string
  description = "App namespace (created if it does not exist)"
  default     = "app"
}

variable "kind_registry_port" {
  type        = string
  description = "Localhost port for the kind registry"
  default     = "5003"
}
variable "kind_registry_name" {
  type        = string
  description = "Localhost port for the kind registry"
  default     = "kind-registry"
}

variable "ingress_nginx_helm_version" {
  type        = string
  description = "Helm version of nginx ingress controller"
  default     = "4.1.1"
}

variable "ingress_nginx_namespace" {
  type        = string
  description = "The nginx ingress namespace (created if it does not exist"
  default     = "ingress-nginx"
}

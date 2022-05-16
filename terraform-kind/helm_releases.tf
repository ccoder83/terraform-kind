provider "helm" {
  kubernetes {
    config_path = pathexpand(var.kind_cluster_config_path)
  }
}

resource "helm_release" "redis" {
  name  = "redis"
  chart = "https://charts.bitnami.com/bitnami/redis-10.7.16.tgz"

  namespace        = var.app_namespace
  create_namespace = true

  depends_on = [kind_cluster.kind]
}

resource "helm_release" "nodeapp" {
  name  = "nodeapp"
  chart = "../helm/node-app-chart"

  namespace        = var.app_namespace
  create_namespace = true

  depends_on = [
    helm_release.redis
  ]
}

resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = var.ingress_nginx_helm_version

  namespace        = var.ingress_nginx_namespace
  create_namespace = true

  values = [file("../helm/ingress-nginx/nginx_ingress_values.yaml")]

  depends_on = [kind_cluster.kind]
}

resource "null_resource" "wait_for_ingress_nginx" {
  triggers = {
    key = uuid()
  }

  #ref: https://kind.sigs.k8s.io/docs/user/ingress/
  provisioner "local-exec" {
    command = <<EOF
      printf "\nWaiting for the nginx ingress controller...\n"
      kubectl wait --namespace ${helm_release.ingress_nginx.namespace} \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/component=controller \
        --timeout=90s
    EOF
  }

  depends_on = [helm_release.ingress_nginx]
}

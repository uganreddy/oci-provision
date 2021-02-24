

 /* Load Balancer */

resource "oci_load_balancer" "lb1" {
  shape          = "100Mbps"
  compartment_id = var.compartment_ocid
  display_name = "LoadBalancer1"
  subnet_ids = [
    oci_core_subnet.lb-public-subnet.id,
  ]
}

resource "oci_load_balancer_backend_set" "lb-backend-set1" {
  name             = "bes-helloworld"
  load_balancer_id = oci_load_balancer.lb1.id
  policy           = "ROUND_ROBIN"

  health_checker {
    port                = "80"
    protocol            = "TCP"
    response_body_regex = ".*"
    url_path            = "/"
  }
}

resource "oci_load_balancer_backend_set" "lb-backend-set2" {
  name             = "bes-grafana"
  load_balancer_id = oci_load_balancer.lb1.id
  policy           = "ROUND_ROBIN"

  health_checker {
    port                = "3000"
    protocol            = "TCP"
    response_body_regex = ".*"
    url_path            = "/"
  }
}
resource "oci_load_balancer_backend_set" "lb-backend-set3" {
  name             = "bes-prometheus"
  load_balancer_id = oci_load_balancer.lb1.id
  policy           = "ROUND_ROBIN"

  health_checker {
    port                = "9090"
    protocol            = "TCP"
    response_body_regex = ".*"
    url_path            = "/"
  }
}

resource "oci_load_balancer_backend_set" "lb-backend-set4" {
  name             = "bes-node-explorer"
  load_balancer_id = oci_load_balancer.lb1.id
  policy           = "ROUND_ROBIN"

  health_checker {
    port                = "9100"
    protocol            = "TCP"
    response_body_regex = ".*"
    url_path            = "/"
  }
}
resource "oci_load_balancer_backend_set" "lb-backend-set5" {
  name             = "bes-fibonacci"
  load_balancer_id = oci_load_balancer.lb1.id
  policy           = "ROUND_ROBIN"

  health_checker {
    port                = "81"
    protocol            = "TCP"
    response_body_regex = ".*"
    url_path            = "/"
  }
}




resource "oci_load_balancer_listener" "lb-listener1" {
  load_balancer_id         = oci_load_balancer.lb1.id
  name                     = "http"
  default_backend_set_name = oci_load_balancer_backend_set.lb-backend-set1.name
  port                     = 80
  protocol                 = "HTTP"
  

  connection_configuration {
    idle_timeout_in_seconds = "2"
  }
}

resource "oci_load_balancer_listener" "lb-listener2" {
  load_balancer_id         = oci_load_balancer.lb1.id
  name                     = "grafana"
  default_backend_set_name = oci_load_balancer_backend_set.lb-backend-set2.name
  port                     = 3000
  protocol                 = "HTTP"
  

  connection_configuration {
    idle_timeout_in_seconds = "2"
  }
}

resource "oci_load_balancer_listener" "lb-listener3" {
  load_balancer_id         = oci_load_balancer.lb1.id
  name                     = "prometheus"
  default_backend_set_name = oci_load_balancer_backend_set.lb-backend-set3.name
  port                     = 9090
  protocol                 = "HTTP"
  

  connection_configuration {
    idle_timeout_in_seconds = "2"
  }
}

resource "oci_load_balancer_listener" "lb-listener4" {
  load_balancer_id         = oci_load_balancer.lb1.id
  name                     = "nodeexplorer"
  default_backend_set_name = oci_load_balancer_backend_set.lb-backend-set4.name
  port                     = 9100
  protocol                 = "HTTP"
  

  connection_configuration {
    idle_timeout_in_seconds = "2"
  }
}

resource "oci_load_balancer_listener" "lb-listener5" {
  load_balancer_id         = oci_load_balancer.lb1.id
  name                     = "fibonacci"
  default_backend_set_name = oci_load_balancer_backend_set.lb-backend-set5.name
  port                     = 81
  protocol                 = "HTTP"
  

  connection_configuration {
    idle_timeout_in_seconds = "2"
  }
}
resource "oci_load_balancer_backend" "lb-backend1" {
  load_balancer_id = oci_load_balancer.lb1.id
  backendset_name  = oci_load_balancer_backend_set.lb-backend-set1.name
  ip_address       = oci_core_instance.AppServer.*.private_ip[0]
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

resource "oci_load_balancer_backend" "lb-backend2" {
  load_balancer_id = oci_load_balancer.lb1.id
  backendset_name  = oci_load_balancer_backend_set.lb-backend-set2.name
  ip_address       = oci_core_instance.AppServer.*.private_ip[0]
  port             = 3000
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

resource "oci_load_balancer_backend" "lb-backend3" {
  load_balancer_id = oci_load_balancer.lb1.id
  backendset_name  = oci_load_balancer_backend_set.lb-backend-set3.name
  ip_address       = oci_core_instance.AppServer.*.private_ip[0]
  port             = 9090
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}
resource "oci_load_balancer_backend" "lb-backend4" {
  load_balancer_id = oci_load_balancer.lb1.id
  backendset_name  = oci_load_balancer_backend_set.lb-backend-set4.name
  ip_address       = oci_core_instance.AppServer.*.private_ip[0]
  port             = 9100
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

resource "oci_load_balancer_backend" "lb-backend5" {
  load_balancer_id = oci_load_balancer.lb1.id
  backendset_name  = oci_load_balancer_backend_set.lb-backend-set5.name
  ip_address       = oci_core_instance.AppServer.*.private_ip[0]
  port             = 81
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}













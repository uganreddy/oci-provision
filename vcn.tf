// Copyright (c) 2017, 2021, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Mozilla Public License v2.0


provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

resource "oci_core_vcn" "My-VCN" {
  cidr_blocks    = ["10.0.0.0/16"]
  dns_label      = "terraformvcn"
  compartment_id = var.compartment_ocid
  display_name   = "My-VCN"
}

// SECURITY LISTS

variable "security_list_egress_security_rules_description" {
  default = "description"
}

variable "security_list_ingress_security_rules_description" {
  default = "description"
}

resource "oci_core_security_list" "appserver_security_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.My-VCN.id
  display_name   = "AppserverSecurityList"

  // allow outbound tcp traffic on all ports
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "6"
  }

// allow inbound ssh traffic from a specific port
  ingress_security_rules {
    protocol  = "6" // tcp
    source    = "10.0.2.0/24"
    stateless = false

    tcp_options {
     
      // These values correspond to the destination port range.
      min = 22
      max = 22
    }
  }

  // allow inbound TCP
  ingress_security_rules {
    protocol = "6"
    source   = "10.0.1.0/24"

    tcp_options {
      min = 80
      max = 80
    }
  }
  ingress_security_rules {
    protocol = "6"
    source   = "10.0.1.0/24"

    tcp_options {
      min = 9090
      max = 9090
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "10.0.1.0/24"

    tcp_options {
      min = 3000
      max = 3000
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "10.0.1.0/24"

    tcp_options {
      min = 9100
      max = 9100
    }
  }
  
   ingress_security_rules {
    protocol = "6"
    source   = "10.0.1.0/24"

    tcp_options {
      min = 81
      max = 81
    }
  }
  // allow inbound icmp traffic of a specific type
  ingress_security_rules {
    description = var.security_list_ingress_security_rules_description
    protocol    = 1
    source      = "0.0.0.0/0"
    stateless   = true

    icmp_options {
      type = 3
      code = 4
    }
  }
}




resource "oci_core_security_list" "lb_security_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.My-VCN.id
  display_name   = "LBSecurityList"

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      min = 80
      max = 80
    }
  }
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      min = 9090
      max = 9090
    }
  }
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      min = 3000
      max = 3000
    }
  }
    ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      min = 9100
      max = 9100
    }
  }
   ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      min = 81
      max = 81
    }
  }
  }



// ROUTE TABLES

variable "route_table_route_rules_description" {
  default = "description"
}

resource "oci_core_internet_gateway" "MyvcnInternetGateway" {
  compartment_id = var.compartment_ocid
  display_name   = "Myvcn-Gateway"
  vcn_id         = oci_core_vcn.My-VCN.id
}

resource "oci_core_route_table" "lb_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.My-VCN.id
  display_name   = "LBRouteTable"

  route_rules {
    description       = var.route_table_route_rules_description
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.MyvcnInternetGateway.id
  }
}


resource "oci_core_nat_gateway" "MyvcnNATGateway" {
  compartment_id = var.compartment_ocid
  display_name   = "Myvcn-NATGateway"
  vcn_id         = oci_core_vcn.My-VCN.id
}

resource "oci_core_route_table" "appserver_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.My-VCN.id
  display_name   = "AppServerRouteTable"

  route_rules {
    description       = var.route_table_route_rules_description
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.MyvcnNATGateway.id
  }
}

resource "oci_core_subnet" "lb-public-subnet" {
  cidr_block        = "10.0.1.0/24"
  display_name      = "LBpublicsubnet"
  dns_label         = "lbpublicsubnet"
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.My-VCN.id
  security_list_ids = [oci_core_security_list.lb_security_list.id]
  route_table_id    = oci_core_route_table.lb_route_table.id
  dhcp_options_id   = oci_core_vcn.My-VCN.default_dhcp_options_id
 }

resource "oci_core_subnet" "jumpserver-subnet" {
  cidr_block          = "10.0.2.0/24"
  display_name        = "jumpserverSB"
  dns_label           = "jumpserverSB"
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.My-VCN.id
  security_list_ids   = [oci_core_vcn.My-VCN.default_security_list_id]
  route_table_id      = oci_core_route_table.lb_route_table.id
  dhcp_options_id     = oci_core_vcn.My-VCN.default_dhcp_options_id
}

resource "oci_core_subnet" "appserver-subnet" {
  cidr_block          = "10.0.3.0/24"
  display_name        = "Appserversubnet"
  dns_label           = "Appserversubnet"
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.My-VCN.id
  security_list_ids   = [oci_core_security_list.appserver_security_list.id]
  route_table_id      = oci_core_route_table.appserver_route_table.id
  dhcp_options_id     = oci_core_vcn.My-VCN.default_dhcp_options_id
  prohibit_public_ip_on_vnic = true
}



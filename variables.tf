variable "tenancy_ocid" {
    default = "ocid1.tenancy.oc1..xxxxxx"
                        }
variable "user_ocid" {
    default = "ocid1.user.oc1..xxxxxxxxx"
                        }
variable "fingerprint" {
    default = "7d:c7:b1:2c:79:9a:90:d0:61:4f:27:29:bd:bd:48:05"
                        }
variable "private_key_path" {
    default = "/Users/Desktop/Terraform/api-keys/oci-private.pem"
                        }
variable "region" {
    default = "ap-hyderabad-1"
                        }
variable "compartment_ocid" {
    default = "ocid1.tenancy.oc1..xxxxxxxxxxxxxxxxx"
                        }
variable "ssh_public_key" {
    
    default = "/Users/.ssh/id_rsa.pub"
}

variable "ssh_private_key" {
    
    default = "/Users/.ssh/id_rsa"
}

variable "NumInstances" {
  default = "1"
}

variable "instance_image_ocid" {
   default = "ocid1.xxxxxxxxxxxxxxxxxxxxxxxxx"
  }


variable "instance_shape" {
  default = "VM.Standard2.1"
}


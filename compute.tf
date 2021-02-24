data "oci_identity_availability_domain" "ad" {
  compartment_id = var.tenancy_ocid
  ad_number      = 1
}

resource "oci_core_instance" "BationServer" {
  count               = var.NumInstances
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = var.compartment_ocid
  display_name        = "BationServer"
  shape               = var.instance_shape
  
  create_vnic_details {
    subnet_id        = oci_core_subnet.jumpserver-subnet.id
    display_name     = "primaryvnic"
    assign_public_ip = true
    hostname_label   = "bationserver"
  }

  source_details {
    source_type = "image"
    source_id   = var.instance_image_ocid

    # Apply this to set the size of the boot volume that's created for this instance.
    # Otherwise, the default boot volume size of the image is used.
    # This should only be specified when source_type is set to "image".
    #boot_volume_size_in_gbs = "60"
  }

  # Apply the following flag only if you wish to preserve the attached boot volume upon destroying this instance
  # Setting this and destroying the instance will result in a boot volume that should be managed outside of this config.
  # When changing this value, make sure to run 'terraform apply' so that it takes effect before the resource is destroyed.
  #preserve_boot_volume = true

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key)
  }
}


resource "oci_core_instance" "AppServer" {
  count               = var.NumInstances
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = var.compartment_ocid
  display_name        = "AppServer1"
  shape               = var.instance_shape
  
  create_vnic_details {
    subnet_id        = oci_core_subnet.appserver-subnet.id
    display_name     = "primaryvnic"
    assign_public_ip = false
    hostname_label   = "appserver1"
  }

  source_details {
    source_type = "image"
    source_id   = var.instance_image_ocid

    # Apply this to set the size of the boot volume that's created for this instance.
    # Otherwise, the default boot volume size of the image is used.
    # This should only be specified when source_type is set to "image".
    #boot_volume_size_in_gbs = "60"
  }

  # Apply the following flag only if you wish to preserve the attached boot volume upon destroying this instance
  # Setting this and destroying the instance will result in a boot volume that should be managed outside of this config.
  # When changing this value, make sure to run 'terraform apply' so that it takes effect before the resource is destroyed.
  #preserve_boot_volume = true

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key)
  }

    connection {
    type        = "ssh"
    host        = self.private_ip
    user        = "opc"
    private_key = file(var.ssh_private_key)
    bastion_host        = oci_core_instance.BationServer.*.public_ip[0]
    bastion_user        = "opc"
    bastion_private_key = file(var.ssh_private_key)
  }
  provisioner "remote-exec" {
    inline = [
      "sudo yum install docker -y",
      "sudo yum install java-1.8.0-openjdk -y",
      "wget https://raw.githubusercontent.com/uganreddy/prometheus/master/prometheus.yml",
      "sudo systemctl restart docker",
      "sudo docker run -p 80:8080 -d ugandhar/dropwizardhello",
      "sudo docker run -p 81:8081 -d ugandhar/myfibonacci",
      "sudo docker run -p 9100:9100 -d prom/node-exporter",
      "sudo docker run -p 9090:9090 -v /home/opc/prometheus.yml:/etc/prometheus/prometheus.yml -d prom/prometheus",
      "sudo docker run -p 3000:3000 -d grafana/grafana",
    ]
  }

}























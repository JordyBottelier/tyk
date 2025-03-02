# Generated by: tyk-ci/wf-gen
# Generated on: Fri Dec 17 15:34:43 UTC 2021

# Generation commands:
# ./pr.zsh -p -title sync for m4 templates -branch aws/pkr176 -base aws/pkr176 -repos tyk
# m4 -E -DxREPO=tyk


packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "flavour" {
  description = "OS Flavour"
  type    = string
}

variable "source_ami_owner" {
  type    = string
}

variable "ami_search_string" {
  type    = string
}

variable "geoip_license" {
  type    = string
  default = "${env("GEOIP_LICENSE")}"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "version" {
  type    = string
  default = "${env("VERSION")}"
}

# Latest at this time
data "amazon-ami" "base-os" {
  filters = {
    architecture                       = "x86_64"
    "block-device-mapping.volume-type" = "gp2"
    name                               = "${var.ami_search_string}"
    root-device-type                   = "ebs"
    sriov-net-support                  = "simple"
    virtualization-type                = "hvm"
  }
  most_recent = true
  owners      = ["${var.source_ami_owner}"]
}

# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioner and post-processors on a
# source. Read the documentation for source blocks here:
# https://www.packer.io/docs/from-1.5/blocks/source
source "amazon-ebs" "byol" {
  ami_name              = "BYOL tyk ${var.version} (${var.flavour})"
  ena_support           = true
  force_delete_snapshot = true
  force_deregister      = true
  instance_type         = "t3.micro"
  region                = "${var.region}"
  source_ami            = data.amazon-ami.base-os.id
  sriov_support = true
  ssh_username  = "ec2-user"
  subnet_filter {
    filters = {
      "tag:Class" = "build"
    }
    most_free = true
    random    = false
  }
  tags = {
    Component = "tyk"
    Flavour   = "${var.flavour}"
    Product   = "byol"
    Version   = "${var.version}"
  }
}

# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/from-1.5/blocks/build
build {
  sources = ["source.amazon-ebs.byol"]

  provisioner "file" {
    destination = "/tmp/semver.sh"
    source      = "utils/semver.sh"
  }
  provisioner "file" {
    destination = "/tmp/tyk-gateway.rpm"
    sources     = fileset(".", "rpm/*x86_64.rpm")
  }
  provisioner "file" {
    destination = "/tmp/10-run-tyk.conf"
    source      = "utils/10-run-tyk.conf"
  }
  provisioner "shell" {
    environment_vars = ["VERSION=${var.version}" , "GEOIP_LICENSE=${var.geoip_license}"]
    script           = "byol/install-tyk.sh"
  }
}

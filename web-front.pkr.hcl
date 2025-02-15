# https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/packer
packer {
  required_plugins {
    amazon = {
      version = ">= 1.3"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

# https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/source
source "amazon-ebs" "ubuntu" {
  ami_name      = "web-nginx-aws"
  instance_type = "t2.micro"
  region        = "us-west-2"

  source_ami_filter {
    filters = {
		  # COMPLETE ME complete the "name" argument below to use Ubuntu 24.04
      name = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20240423"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"] 
	}

  ssh_username = "ubuntu"
}

# https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/build
build {
  name = "web-nginx"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]
  
  # https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/build/provisioner
  provisioner "shell" {
    inline = [
      "echo creating directories",
      "sudo mkdir -p /var/www/html",
      "sudo mkdir -p /etc/nginx/sites-available",
      "sudo mkdir -p /etc/nginx/sites-enabled",
      "sudo mkdir -p /web/html",
      "sudo chown -R ubuntu:ubuntu /var/www/html",
      "sudo chown -R ubuntu:ubuntu /etc/nginx",
      "sudo chown -R ubuntu:ubuntu /web/html"
    ]
  }

    # https://developer.hashicorp.com/packer/docs/provisioners/file
  provisioner "file" {
    # COMPLETE ME add the HTML file to your image
    source = "files/index.html"
    destination = "/web/html/index.html"
  }

  provisioner "file" {
    # COMPLETE ME add the nginx.conf file to your image
    source = "files/nginx.conf"
    destination = "/etc/nginx/sites-available/nginx.conf"
  }

  provisioner "file" {
    source = "scripts/install-nginx"
    destination = "~/install-nginx"
  }

  provisioner "file" {
    source = "scripts/setup-nginx"
    destination = "~/setup-nginx"
  }

  provisioner "shell" {
    inline = [
      "chmod +x ~/install-nginx",
      "sudo ~/install-nginx"
    ]
  }

  provisioner "shell" {
    inline = [
      "chmod +x ~/setup-nginx",
      "sudo ~/setup-nginx",
      "sudo systemctl restart nginx"
    ]
  }

}

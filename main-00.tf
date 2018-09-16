## Setup needed variables

variable "master_count" {}
variable "va_count" {}
variable "manage_count" {}
variable "worker_count" {}
variable "proxy_count" {}
variable "vipmaster_count" {}
variable "vipproxy_count" {}
variable "image_name" {}
variable "dc" {}

variable "domain" {
  description = "base domain"
  default     = "example.com"
}

variable "master_vcpu" {
  description = "number of cpu possible values 4, 8, 16"
  default     = "8"
}

variable "master_ram" {
  description = "8192,16384"
  default     = "16384"
}

variable "worker_vcpu" {
  description = "number of cpu possible values 4, 8, 16"
  default     = "8"
}

variable "worker_ram" {
  description = "8192,16384"
  default     = "16384"
}

variable "proxy" {
  description = "internal ip address of the squid3 proxy to use"
  default     = "10.166.30.141"
}

# variable "offline_mode" {}

provider "softlayer" {}

data "template_file" "setup_docker_master" {
  template = "${file("${path.module}/scripts/setup-docker.sh.tpl")}"
  
  vars {
    proxy = "${var.proxy}"
  }
}

resource "softlayer_virtual_guest" "master" {
  count                = "${var.master_count}"
  image                = "${var.image_name}"
  name                 = "${var.prefix}-master-${format("%d",count.index + 1)}"
  domain               = "${var.dc}.${var.domain}"
  ssh_keys             = ["922553"]
  image                = "${var.image_name}"
  region               = "${var.dc}"
  hourly_billing       = true
  private_network_only = false
  cpu                  = "${var.master_vcpu}"
  ram                  = "${var.master_ram}"
  disks                = [100]
  local_disk           = false

  provisioner "local-exec" {
    command = "scp ${path.module}/scripts/setup-docker.sh.tpl root@${self.ipv4_address_private}:/tmp"
  }

  provisioner "local-exec" {
    command = "ssh root@${self.ipv4_address_private} 'chmod 755 /tmp/setup-docker.sh.tpl ; ls -al /tmp/setup-docker.sh.tpl'"
  }

  provisioner "local-exec" {
    command = "ssh root@${self.ipv4_address_private} '/tmp/setup-docker.sh.tpl'"
  }

  # update authorized_keys
  provisioner "local-exec" {
    command = "scp ${path.module}/scripts/id_rsa.pub root@${self.ipv4_address_private}:/root/.ssh"
  }

  provisioner "local-exec" {
    command = "ssh root@${self.ipv4_address_private} 'cd /root/.ssh ; cat id_rsa.pub >> authorized_keys'"
  }

  provisioner "local-exec" {
    command = "ssh root@${self.ipv4_address_private} sed -i 's/127.0.1.1/${self.ipv4_address_private}/g' /etc/hosts"
  }
}

resource "softlayer_virtual_guest" "va" {
  count                = "${var.va_count}"
  image                = "${var.image_name}"
  name                 = "${var.prefix}-va-${format("%d",count.index + 1)}"
  domain               = "${var.dc}.${var.domain}"
  ssh_keys             = ["922553"]
  image                = "${var.image_name}"
  region               = "${var.dc}"
  hourly_billing       = true
  private_network_only = false
  cpu                  = "${var.master_vcpu}"
  ram                  = "${var.master_ram}"
  disks                = [100]
  local_disk           = false

  provisioner "local-exec" {
    command = "scp ${path.module}/scripts/setup-docker.sh.tpl root@${self.ipv4_address_private}:/tmp"
  }

  provisioner "local-exec" {
    command = "ssh root@${self.ipv4_address_private} 'chmod 755 /tmp/setup-docker.sh.tpl ; ls -al /tmp/setup-docker.sh.tpl'"
  }

  provisioner "local-exec" {
    command = "ssh root@${self.ipv4_address_private} '/tmp/setup-docker.sh.tpl'"
  }

  # update authorized_keys
  provisioner "local-exec" {
    command = "scp ${path.module}/scripts/id_rsa.pub root@${self.ipv4_address_private}:/root/.ssh"
  }

  provisioner "local-exec" {
    command = "ssh root@${self.ipv4_address_private} 'cd /root/.ssh ; cat id_rsa.pub >> authorized_keys'"
  }

  provisioner "local-exec" {
    command = "ssh root@${self.ipv4_address_private} sed -i 's/127.0.1.1/${self.ipv4_address_private}/g' /etc/hosts"
  }
}

resource "softlayer_virtual_guest" "manage" {
  count                = "${var.manage_count}"
  image                = "${var.image_name}"
  name                 = "${var.prefix}-manage-${format("%d",count.index + 1)}"
  domain               = "${var.dc}.${var.domain}"
  ssh_keys             = ["922553"]
  image                = "${var.image_name}"
  region               = "${var.dc}"
  hourly_billing       = true
  private_network_only = false
  cpu                  = "${var.master_vcpu}"
  ram                  = "${var.master_ram}"
  disks                = [100,200]
  local_disk           = false

  provisioner "local-exec" {
    command = "scp ${path.module}/scripts/setup-docker.sh.tpl root@${self.ipv4_address_private}:/tmp"
  }

  provisioner "local-exec" {
    command = "ssh root@${self.ipv4_address_private} 'chmod 755 /tmp/setup-docker.sh.tpl ; ls -al /tmp/setup-docker.sh.tpl'"
  }

  provisioner "local-exec" {
    command = "ssh root@${self.ipv4_address_private} '/tmp/setup-docker.sh.tpl'"
  }

  # update authorized_keys
  provisioner "local-exec" {
    command = "scp ${path.module}/scripts/id_rsa.pub root@${self.ipv4_address_private}:/root/.ssh"
  }

  provisioner "local-exec" {
    command = "ssh root@${self.ipv4_address_private} 'cd /root/.ssh ; cat id_rsa.pub >> authorized_keys'"
  }

  provisioner "local-exec" {
    command = "ssh root@${self.ipv4_address_private} sed -i 's/127.0.1.1/${self.ipv4_address_private}/g' /etc/hosts"
  }
}

resource "softlayer_virtual_guest" "worker" {
  count                = "${var.worker_count}"
  name                 = "${var.prefix}-worker-${format("%d",count.index + 1)}"
  image                = "${var.image_name}"
  domain               = "${var.dc}.${var.domain}"
  ssh_keys             = ["922553"]
  region               = "${var.dc}"
  hourly_billing       = true
  private_network_only = false
  cpu                  = "${var.worker_vcpu}"
  ram                  = "${var.worker_ram}"
  disks                = [100]
  local_disk           = false

  provisioner "local-exec" {
    command = "scp ${path.module}/scripts/setup-docker.sh.tpl root@${self.ipv4_address_private}:/tmp"
  }

  provisioner "local-exec" {
    command = "ssh root@${self.ipv4_address_private} 'chmod 755 /tmp/setup-docker.sh.tpl ; ls -al /tmp/setup-docker.sh.tpl'"
  }

  provisioner "local-exec" {
    command = "ssh root@${self.ipv4_address_private} '/tmp/setup-docker.sh.tpl'"
  }

  # update authorized_keys
  provisioner "local-exec" {
    command = "scp ${path.module}/scripts/id_rsa.pub root@${self.ipv4_address_private}:/root/.ssh"
  }

  provisioner "local-exec" {
    command = "ssh root@${self.ipv4_address_private} 'cd /root/.ssh ; cat id_rsa.pub >> authorized_keys'"
  }

  provisioner "local-exec" {
    command = "ssh root@${self.ipv4_address_private} sed -i 's/127.0.1.1/${self.ipv4_address_private}/g' /etc/hosts"
  }
}

resource "softlayer_virtual_guest" "proxy" {
  count                = "${var.proxy_count}"
  name                 = "${var.prefix}-proxy-${format("%d",count.index + 1)}"
  image                = "${var.image_name}"
  domain               = "${var.dc}.${var.domain}"
  ssh_keys             = ["922553"]
  region               = "${var.dc}"
  hourly_billing       = true
  private_network_only = true
  cpu                  = 4
  ram                  = 4096
  disks                = [25]
  local_disk           = false

  provisioner "local-exec" {
    command = "scp ${path.module}/scripts/setup-docker.sh.tpl root@${self.ipv4_address_private}:/tmp"
  }

  provisioner "local-exec" {
    command = "ssh root@${self.ipv4_address_private} 'chmod 755 /tmp/setup-docker.sh.tpl ; ls -al /tmp/setup-docker.sh.tpl'"
  }

  provisioner "local-exec" {
    command = "ssh root@${self.ipv4_address_private} '/tmp/setup-docker.sh.tpl'"
  }

  # update authorized_keys
  provisioner "local-exec" {
    command = "scp ${path.module}/scripts/id_rsa.pub root@${self.ipv4_address_private}:/root/.ssh"
  }

  provisioner "local-exec" {
    command = "ssh root@${self.ipv4_address_private} 'cd /root/.ssh ; cat id_rsa.pub >> authorized_keys'"
  }

  provisioner "local-exec" {
    command = "ssh root@${self.ipv4_address_private} sed -i 's/127.0.1.1/${self.ipv4_address_private}/g' /etc/hosts"
  }
}

resource "softlayer_virtual_guest" "vipmaster" {
  count                = "${var.vipmaster_count}"
  name                 = "${var.prefix}-vipmaster-${format("%d",count.index + 1)}"
  image                = "${var.image_name}"
  domain               = "${var.dc}.${var.domain}"
  ssh_keys             = ["922553"]
  region               = "${var.dc}"
  hourly_billing       = true
  private_network_only = true
  cpu                  = 1
  ram                  = 1024
  disks                = [25]
  local_disk           = false
}

resource "softlayer_virtual_guest" "vipproxy" {
  count                = "${var.vipproxy_count}"
  name                 = "${var.prefix}-vipproxy-${format("%d",count.index + 1)}"
  image                = "${var.image_name}"
  domain               = "${var.dc}.${var.domain}"
  ssh_keys             = ["922553"]
  region               = "${var.dc}"
  hourly_billing       = true
  private_network_only = true
  cpu                  = 1
  ram                  = 1024
  disks                = [25]
  local_disk           = false
}

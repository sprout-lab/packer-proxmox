# Ubuntu Server 24.04 (Noble Numbat)
# ---
# Packer Template to create an Ubuntu Server 24.04 LTS (Noble Numbat) on Proxmox

packer {
  required_plugins {
    name = {
      version = ">= 1.1.2"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

variable "prod" {
  type    = bool
  default = false
}

variable "proxmox_api_url" {
  type    = string
  default = null
}

variable "proxmox_api_token_id" {
  type    = string
  default = null
}

variable "proxmox_api_token_secret" {
  type    = string
  default = null
}

source "proxmox-iso" "ubuntu-server-24" {
    
    # Proxmox Connection Settings
    proxmox_url = var.proxmox_api_url
    username = var.proxmox_api_token_id
    token = var.proxmox_api_token_secret
    insecure_skip_tls_verify = true

    # Template Settings
    vm_id = var.prod ? 100 : 200
    node = "proxmox-forest"
    vm_name = var.prod ? "ubuntu-24-prod" : "ubuntu-24"
    template_description = "Ubuntu Server Noble Numbat"
    tags = "${var.prod ? "prod" : "non-prod"};ubuntu"

    # VM Settings
    iso_file = "local:iso/ubuntu-24.04-live-server-amd64.iso"
    iso_storage_pool = "local"
    unmount_iso = true
    template_name = "ubuntu-24-${var.prod ? "prod" : "non-prod"}"
    scsi_controller = "virtio-scsi-pci"
    disks {
        disk_size = "20G"
        format = "raw"
        storage_pool = "app_data_pool"
        type = "virtio"
    }
    cores = var.prod ? "2" : "1"
    cpu_type = var.prod ? "host" : "kvm64"
    memory = var.prod ? "4096" : "2048"
    network_adapters {
        model = "virtio"
        bridge = "vmbr0"
    }
    qemu_agent = true

    # Cloud-init
    cloud_init = true
    cloud_init_storage_pool = "vm_pool"

    # Boot
    boot_command = [
        "<esc><wait>",
        "e<wait>",
        "<down><down><down><end>",
        "<bs><bs><bs><bs><wait>",
        "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
        "<f10><wait>"
    ]
    boot = "c"
    boot_wait = "2s"

    # Autoinstall
    http_directory = "ubuntu/http" 

    # SSH
    ssh_username = "ubuntu"
    ssh_private_key_file = "~/.ssh/id_rsa_ubuntu"
    ssh_timeout = "10m"

}

build {
    sources = ["source.proxmox-iso.ubuntu-server-24"]
    
    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #1
    provisioner "shell" {
        inline = [
            "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
            "echo '🪵 sprout-log: VM created using sprout-lab/packer-proxmox'",
            "ls /"
        ]
    }

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #2
    provisioner "file" {
        source = "ubuntu/files/99-pve.cfg"
        destination = "/tmp/99-pve.cfg"
    }

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #3
    provisioner "shell" {
        inline = [ "sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg" ]
    }
}
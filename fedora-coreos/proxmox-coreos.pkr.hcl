packer {
  required_plugins {
    name = {
      version = ">= 1.1.2"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

variable "ignition_path" {
  type    = string
  default = "http/bootstrap.ign"
}

locals {
  ignition_content = file(var.ignition_path)
  ignition_hash    = sha512(local.ignition_content)
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

source "proxmox-iso" "fedora-coreos" {
  http_directory = "http"
  boot_wait      = "2s"
  boot_command = [
    "<spacebar><wait><spacebar><wait><spacebar><wait><spacebar><wait><spacebar><wait>",
    "<tab><wait>",
    "<down><down><end>",
    " ignition.config.url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/bootstrap.ign",
    "<enter>"
  ]
  disks {
    disk_size    = "20G"
    storage_pool = "vm_pool"
  }
  memory = 2048
  cores = 2
  efi_config {
    efi_storage_pool  = "vm_pool"
    efi_type          = "4m"
    pre_enrolled_keys = true
  }
  insecure_skip_tls_verify = true
  iso_checksum             = "90edf8a7e06ffe8217cb09d3b9a26846fae53c2537f36c525c4b782d4092c550"
  iso_file                 = "cephfs:iso/fedora-coreos-40.20240504.3.0-live.x86_64.iso"
  network_adapters {
    bridge = "vmbr0"
    model  = "virtio"
  }
  node                 = "proxmox-forest"
  
  proxmox_url = var.proxmox_api_url
  username = var.proxmox_api_token_id
  token = var.proxmox_api_token_secret


  ssh_timeout          = "15m"
  ssh_username         = "core"
  ssh_private_key_file = "~/.ssh/id_rsa_fedora_coreos"
  template_description = "Fedora CoreOS 40.2, generated on ${timestamp()}"
  template_name        = "coreos-40"
}

build {
  sources = ["source.proxmox-iso.fedora-coreos"]

  provisioner "shell" {
    inline = [
      "sudo shutdown -h +1"
    ]
  }
}

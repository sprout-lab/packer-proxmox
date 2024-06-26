# 🌱 packer-proxmox

VM Templates for Sprout Lab, made with [Hashicorp Packer](https://developer.hashicorp.com/packer) and the [proxmox plugin](https://developer.hashicorp.com/packer/integrations/hashicorp/proxmox/latest/components/builder/iso).

### Prerequisites

#### Dependencies
```
brew tap hashicorp/tap
brew install hashicorp/tap/packer
brew install just
```
#### Environment Variables
Create `.auto.pkrvars.hcl` files in each OS:

`ubuntu/.auto.pkrvars.hcl`
```
proxmox_api_url          = "https://proxmox-forest:8006/api2/json"
proxmox_api_token_id     = "packer@pve!packerToken"
proxmox_api_token_secret = "...Stored in Bitwarden..."
```
#### SSH Key
Generate the public and private key that each OS will use:
```
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_ubuntu
```

### VM's Supported

| OS            | Version | Support |
|---------------|---------|---------|
| Ubuntu        | 24.04   | Full    |
| Fedora CoreOS | 40      | Hobby   |

### Create VM Templates in Proxmox
Create's all of the VM templates. 
```
just build
```
Or, to create a specific template:

```
just build-ubuntu
```
Or, to create prodction-workload VM templates:
```
just build-prod
```
> [!NOTE] 
> [https://just.systems/](https://just.systems/) is used for the cli tasks.

### Environment Templates
Each template can produce both Production and Preview (default) VM templates, with more memory and CPU being dedicated to prod VMs.

| Resource | Preview (default) | Production |
|----------|-------------------|------------|
| CPUs     | 1                 | 2          |
| CPU Type | kvm64             | host       |
| Memory   | 2048              | 4096       |

#### 100 - Production
VM ID between 100-199.

#### 200 - Preview
VM ID between 200-299.

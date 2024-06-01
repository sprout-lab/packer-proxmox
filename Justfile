default:
    just --list

ubuntu_dir := "ubuntu"
coreos_dir := "fedora-coreos"

# Build all OS templates
build: build-ubuntu build-coreos

build-prod: build-ubuntu-prod

# Build Ubuntu template
build-ubuntu:
    @echo "Building Ubuntu 24.04"
    packer init {{ubuntu_dir}}
    packer fmt .
    packer validate {{ubuntu_dir}}
    packer build {{ubuntu_dir}}

# Build Ubuntu template
build-ubuntu-prod:
    @echo "Building Ubuntu 24.04"
    packer init {{ubuntu_dir}}
    packer fmt .
    packer validate {{ubuntu_dir}}
    packer build -var "prod=true" {{ubuntu_dir}}

# Build Fedora CoreOS template
build-coreos:
    @echo "Building Fedora CoreOS"
    @packer init {{coreos_dir}}
    packer fmt .
    @butane --pretty --strict fedora-coreos/http/bootstrap.bu > fedora-coreos/http/bootstrap.ign
    @packer validate {{coreos_dir}}
    packer build {{coreos_dir}}
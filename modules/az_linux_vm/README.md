AZ_LINUX_VM Module
An Azure terraform module to setup a Linux VM in azure.
    It Includes the following resources:
      -  A Resource-Group
      -  One or more Linux VMs (based on the numberOfRes variable)
      -  A Virtual Network
      -  A Subnet into the Virtual Network
      -  One NIC for each VM created with a public and private IP Addresses
      -  One Public IP for Each VM
      -  A security Group With a set of Rules, that is associated with all NICs
      -  Runs a custom script or a set of commands into the machines as a BOOTSTRAP process
      - Generates a local SSH key into the current directory with the name of the variable "NAME", this is used to connect into the vms

Module Input Variables
    name        = The Name of your Deployment / Project
    userName    = User name to be used into the machines
    numberOfRes = Number of VMs that you need to setup
    environment = The current environment: Dev / Test / Prod and etc.
    location    = The Azure region you want the resources to be created
    ip          = The IP Addresses you want into your machines, in form of a list, example: ["10.0.2.5", "10.0.2.6", "10.0.2.7", "10.0.2.8", "10.0.2.9", "10.0.2.10"]
    script      = A bootstrap script to run into each VM, must be inside of double quotes
    tags        = All tags you want must be passed as key value pairs like the example bellow
    {
      "project"     = "SAMPLE"
      "environment" = "SAMPLE"
    }

Usage
    module "az_linux_vm" {
        source      = "../modules/az_linux_vm"
        name        = "NAME"
        userName    = "USERNAME"
        numberOfRes = NUMBER
        environment = "ENVIRONMENT"
        location    = "East US 2"
        ip          = ["10.0.2.5", "10.0.2.6", "10.0.2.7", "10.0.2.8", "10.0.2.9", "10.0.2.10"]
        tags        = {
                        "project"     = "DockerSwarm"
                        "environment" = "test"
        }
        script      = "curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh && sudo usermod -aG docker daniel"
    }

Outputs
    rg_name      = The name of your Resource Group
    vm_data      = All data about your VMS
    vnet_data    = All data about the Vnet
    subenet_data = All data about te subnet

Authors
    https://github.com/dnlouko
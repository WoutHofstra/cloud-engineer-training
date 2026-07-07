# Different versions of the same project

I am making different versions of this simple project to practice different ways to configure this kind of setup. This will be a fairly simple setup with 1 VM, where I will be able to connect to the VM. Since many companies use different setups regarding this, I wanted to expose myself to various ways to do this. For every version I will list the resources and show the architecture. In the project1-Azure-Lab folder you will find the different terraform files that are relevant to these (main.tf, mainv2.tf, etc.)

## Version 1

The first version of this project deploys the following:

* Resource group
* Virtual network
* Subnet for the VM
* Subnet for bastion
* NSG
* Network Security Rule
* Network Security Rule Association
* Network Interface
* Linux VM
* Public IP
* Bastion Host

With those resources the following architecture is achieved:  
![image](../images/Screenshot%202026-07-06%20145313.png)

## Version 2

### Changes I will make:

I will:
* Remove Bastion, as I have noticed it is quite expensive for my budget
* Make sure I can connect to the VM with RDP

That way, these will be the used resources and architecture:

* Resource group
* Virtual network
* Subnet for the VM
* Subnet for bastion
* NSG
* Network Security Rule
* Network Security Rule Association
* Network Interface
* Linux VM
* Public IP
* Bastion Host

![image](../images/Screenshot%202026-07-07%20131027.png)
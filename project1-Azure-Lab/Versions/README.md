# Version 1

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

# Version 2

## Changes I will make:

I will:
* Remove Bastion, as I have noticed it is quite expensive for my budget
* Make sure I can connect to the VM with RDP
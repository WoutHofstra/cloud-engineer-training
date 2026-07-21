# project2-Containers-In-Azure (WORK IN PROGRESS)

In this project I will learn how containers work in Azure. I will make a very minimal Docker image, and make sure that gets to Azure and is accessible (securely) to me. I will learn about Dockerfile basics (Even though I have done some in the past), port mapping, environment variables, and volumes. 


## Part 1: the app and dockerfile

First I am defining what the app will do exactly. I have decided that I want it to just return 'pong' when it is pinged. Also it checks a password. I do this to practice how secrets are stored best in Azure. 

Below is the dockerfile with comments to explain each step

![image](./images/image.png)


## Part 2: Terraform

The terraform for this project was surprisingly simple. I discovered that a lot of the configuration (Like networking) is done automatically. In the terraform file you will only find an Azure Container Registry, Azure Kubernetes Service, Resource Group and a role assignment, that gives AKS permission to pull a container from ACR. 


## Part 3: Deployment yaml for Azure DevOps

This part is similar to my deployment yaml in project 1. The difference is mostly that I want to push the docker image into the deployed ACR automatically. This took some figuring out but I did it in the end. 


## Part 4: Deployment yaml for Kubernetes

Apparently kubernetes also needs some deployment files to work. These can be found in /kubernetes. The 2 files in there basically define:

deployment.yaml: What should be running (Also adds my environment variable, which is the password: supersecret)
service.yaml: How that can be reached


## Part 5: testing

The test for this project is again really simple. I just curl to the service. I used 'kubectl get services' to get the external ip for the service. Then I just ran "curl "http://48.199.106.252/ping?password=supersecret" in my terminal. This returns 'pong':

![image](images/Screenshot%202026-07-21%20133816.png)

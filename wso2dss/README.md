# Mesos Artifacts for WSO2 Data Services Server

These Mesos Artifacts provide the resources and instructions to deploy WSO2 Data Services Server on Mesos DC/OS.

## Getting Started

To deploy a WSO2 product on Mesos DC/OS, follow the below steps:

* Build WSO2 Data Services Server Docker images using [WSO2 Dockerfiles](https://github.com/wso2/dockerfiles).
* Load above Docker images to Mesos slave nodes or import them to a central Docker registry.
* If a central Docker registry is used, update Docker image tags accordingly in WSO2 Data Services Server Marathon applications.
* Run `deploy.sh` found inside this folder. It will deploy following containers:
   * Marathon load balancer container
   * WSO2 Governance Registry database container
   * WSO2 User Management database container
   * WSO2 Data Services Server Configuration Registry database container
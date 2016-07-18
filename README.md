# WSO2 Mesos Artifacts

WSO2 Mesos Artifacts enables you to run WSO2 middleware seamlessly on [Mesos DC/OS](https://dcos.io/) using Docker. This
repository contains Carbon Mesos membership scheme, Marathon applications and deployment automation scripts required for
executing a complete WSO2 middleware deployment on Mesos DC/OS.

## Getting Started

To deploy a WSO2 product on Mesos DC/OS, follow the below steps:
* Build WSO2 product Docker images using [WSO2 Dockerfiles](https://github.com/wso2/dockerfiles).
* Load above Docker images to Mesos slave nodes or import them to a central Docker registry.
* If a central Docker registry is used, update Docker image tags accordingly in WSO2 Marathon applications.
* Run `deploy.sh` inside the relevant product folder. This will deploy following containers:
   * Marathon load balancer container
   * Registry database containers
   * User management database container
   * Product specific database containers
   * Product profile containers

>In the context of this document, `MESOS_HOME`, `DOCKERFILES_HOME` and `PUPPET_HOME` will refer to local copies of [`wso2/mesos-artifacts`](https://github.com/wso2/mesos-artifacts/), [`wso2/dockcerfiles`](https://github.com/wso2/dockerfiles/) and [`wso2/puppet-modules`](https://github.com/wso2/puppet-modules) repositories respectively.

##### 1. Build Docker Images

To manage configurations and artifacts when building Docker images, WSO2 recommends to use [`wso2/puppet-modules`](https://github.com/wso2/puppet-modules) as the provisioning method. A specific data set for Mesos platform is available in WSO2 Puppet Modules. It's possible to use this data set to build Dockerfiles for wso2 products for Mesos with minimum configuration changes.

Building WSO2 Docker images using Puppet for Mesos:

  1. Clone `wso2/puppet-modules` and `wso2/dockerfiles` repositories (alternatively you can download the released artifacts using the release page of the GitHub repository).
  2. Copy the Mesos membership scheme jar file to `PUPPET_HOME/modules/<product>/files/configs/repository/components/dropins` location.
  3. If WSO2 product is based on Carbon Kernel versions 4.2.0 and 4.4.1, add relevant Kernel patches for clustering to `PUPPET_HOME/modules/<product>/files/configs/repository/components/patches` location.
     - For Carbon Kernel version 4.2.0 based products, add Kernel patches [upto patch0012](http://maven.wso2.org/nexus/content/groups/wso2-public/org/wso2/carbon/WSO2-CARBON-PATCH-4.2.0/) which are not present there in product pack.
     - For Carbon Kernel version 4.4.1 based products, add Kernel patch [patch0005](http://product-dist.wso2.com/downloads/carbon/4.4.1/patch0005/WSO2-CARBON-PATCH-4.4.1-0005.zip)
  3. Copy the JDK [`jdk-7u80-linux-x64.tar.gz`](http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html) to `PUPPET_HOME/modules/wso2base/files` location.
  4. Copy the [`mysql-connector-java-5.1.36-bin.jar`](http://mvnrepository.com/artifact/mysql/mysql-connector-java/5.1.36) file to `PUPPET_HOME/modules/<product>/files/configs/repository/components/lib` location.
  5. Copy the product zip file to `PUPPET_HOME/modules/wso2{product}/files` location.
  6. Set the environment variable `PUPPET_HOME` pointing to location of the puppet modules in local machine.
  7. Navigate to the relevant product directory in the dockerfiles repository; `DOCKERFILES_HOME/<product>`.
  8. Build the Dockerfile with the following command:

    **`./build.sh -v [product-version] -s mesos -r puppet`**

  Note that `-s mesos` and `-r puppet` flags denotes the Mesos platform and Puppet provisioning method.

  This will build the standalone product for Mesos platform, using configuration specified in Puppet. Please note it's possible to build relevant profiles of the products similarly. Refer `build.sh` script usage (`./build.sh -h`).

##### 2. Load the Docker Images to Mesos slave nodes/ Import them to Central Docker Registry

Load the required Docker images to Mesos slave nodes(ex: use `docker save` to create a tarball of the required image, `scp` the tarball to each node, and use `docker load` to reload the images from the copied tarballs on the nodes). Alternatively, if a private Docker registry is used, transfer the images there.

You can make use of the `load-images.sh` helper script to transfer images to the Mesos slave nodes. It will search for any Docker images with `mesos` as a part of its name on your local machine, and ask for verification to transfer them to the Mesos slave nodes. `DCOS CLI` has to be functioning on your local machine in order for the script to retrieve the list of Mesos slave nodes. You can optionally provide a search pattern if you want to override the default `mesos` string.

**`load-images.sh`
Usage**
```
Usage: ./load-images.sh [OPTIONS]

Transfer Docker images to Mesos Nodes
Options:

  -u	[OPTIONAL] Username to be used to connect to Mesos Nodes. If not provided, default "centos" is used.
  -p	[OPTIONAL] Optional search pattern to search for Docker images. If not provided, default "mesos" is used.
  -k	[OPTIONAL] Optional key file location. If not provided, key file will not be used.
  -h	[OPTIONAL] Show help text.

Ex: ./load-images.sh
Ex: ./load-images.sh -u centos -p wso2is -k /home/ssh_key.pem
```


##### 3. Deploy WSO2 Product on Mesos DC/OS
  1. Navigate to relevant product directory in mesos-artifacts repository; `MESOS_HOME/<product>` location.
  2. run the deploy.sh script:

    **`./deploy.sh`**

      This will deploy the standalone product in Mesos DC/OS, using the image available in Mesos slave nodes, and notify once the intended Marathon application starts running on the container. Additionally if `-d` flag is provided when running `deploy.sh`, it will deploy the product's distributed setup.

##### 4. Access Management Console
  Access the Carbon Management Console URL using `https://<marathon-lb-host-ip>:<service-port>/carbon/`

##### 5. Undeploy WSO2 Product from Mesos DC/OS
  1. Navigate to relevant product directory in mesos-artifacts repository; `MESOS_HOME/<product>` location.
  2. run the `undeploy.sh` script:

    **`./undeploy.sh`**

      This will undeploy the product specific DB and product Marathon applications. Additionally if `-f` flag is provided when running `undeploy.sh`, it will also undeploy the shared Governance DB, User DB and Marathon LB applications.
      **`./undeploy.sh -f`**

> For more detailed instructions on deploying a particular WSO2 product on Mesos DC/OS, refer to the README file in the relevant product folder.

# Documentation
* [WSO2 Mesos Artifacts Wiki](https://docs.wso2.com/display/MA100/WSO2+Mesos+Artifacts+Documentation)

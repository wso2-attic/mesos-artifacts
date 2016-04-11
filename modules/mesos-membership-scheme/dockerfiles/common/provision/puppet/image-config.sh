#!/bin/bash
# ------------------------------------------------------------------------
#
# Copyright 2016 WSO2, Inc. (http://wso2.com)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License

# ------------------------------------------------------------------------

set -e

# Export facter variables
export FACTER_product_name=${WSO2_SERVER}
export FACTER_product_version=${WSO2_SERVER_VERSION}
export FACTER_product_profile=${WSO2_SERVER_PROFILE}
export FACTER_environment=${WSO2_ENVIRONMENT}
export FACTER_vm_type=docker

mkdir -p /etc/puppet
pushd /etc/puppet > /dev/null
getent group wso2 > /dev/null 2>&1 || addgroup wso2
id -u wso2user > /dev/null 2>&1 || adduser --system --shell /bin/bash --gecos 'WSO2User' --ingroup wso2 --disabled-login wso2user
apt-get update && apt-get install -y wget puppet
wget -nH -e robots=off --reject "index.html*" -nv ${HTTP_PACK_SERVER}/hiera.yaml
wget -rnH -e robots=off --reject "index.html*" -nv ${HTTP_PACK_SERVER}/hieradata/
wget -rnH -e robots=off --reject "index.html*" -nv ${HTTP_PACK_SERVER}/manifests/
wget -rnH --level=10 -e robots=off --reject "index.html*" -nv ${HTTP_PACK_SERVER}/modules/wso2base/
wget -rnH --level=10 -e robots=off --reject "index.html*" -nv ${HTTP_PACK_SERVER}/modules/${WSO2_SERVER}/
puppet module install puppetlabs/stdlib
puppet module install 7terminals-java
puppet apply -e "include ${WSO2_SERVER}" --hiera_config=/etc/puppet/hiera.yaml
apt-get purge -y --auto-remove puppet wget
rm -rfv /etc/puppet/*
rm -rfv /var/lib/apt/lists/*
chown wso2user:wso2 /usr/local/bin/*
chown -R wso2user:wso2 /mnt
popd > /dev/null

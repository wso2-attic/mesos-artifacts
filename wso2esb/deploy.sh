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
self_path=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
product_name="wso2esb"
product_version="4.9.0"

source "${self_path}/../common/scripts/deploy_incl.sh"

# Get arguments
get_opts $@

if [ ${docker_build} == true ]; then
    echoBold "Copying artifacts needed to build Docker images..."
    cp "${self_path}/wso2esb-manager-init.sh" "${self_path}/scripts/"
    cp "${self_path}/wso2esb-worker-init.sh" "${self_path}/scripts/"

    mkdir -p "${self_path}/artifacts/configs/repository/conf"
    cp -a "${self_path}/../../src/test/esb/configs/repository/conf" "${self_path}/artifacts/configs/repository/"

    mkdir -p "${self_path}/artifacts/configs/bin"
    cp -a "${self_path}/../../src/test/esb/configs/bin" "${self_path}/artifacts/configs/"

    mkdir -p "${self_path}/artifacts/configs/repository/components/dropins"
    cp "${self_path}/../../target/${mesos_membership_scheme_jar}" "${self_path}/artifacts/configs/repository/components/dropins/"

    mkdir -p "${self_path}/artifacts/configs/repository/deployment/server/"
    cp -a "${self_path}/../../src/test/esb/synapse-configs" "${self_path}/artifacts/configs/repository/deployment/server/"

    build_docker_image $product_name "manager" $product_version $self_path
    build_docker_image $product_name "worker" $product_version $self_path
fi

if [ ${export_docker_image} == true ]; then
   mkdir -p ${docker_image_export_path}
   echoBold "Exporting Docker image wso2esb-manager:${product_version} to ${docker_image_export_path}..."
   docker save wso2esb-manager:${product_version} > ${docker_image_export_path}/wso2esb-manager-${product_version}.tar

   echoBold "Exporting Docker image wso2esb-worker:${product_version} to ${docker_image_export_path}..."
   docker save wso2esb-worker:${product_version} > ${docker_image_export_path}/wso2esb-worker-${product_version}.tar
fi


if [ ${deploy_marathon_app} == true ]; then
   echoBold "Deploying Apache Mesos Marathon application for WSO2 ESB 4.9.0..."
   curl -X POST -H "Content-Type: application/json" -d@${self_path}/marathon-v${marathon_version}/marathon-app-wso2esb-manager.json -i "${marathon_endpoint}/apps"
   curl -X POST -H "Content-Type: application/json" -d@${self_path}/marathon-v${marathon_version}/marathon-app-wso2esb-worker.json -i "${marathon_endpoint}/apps"
fi
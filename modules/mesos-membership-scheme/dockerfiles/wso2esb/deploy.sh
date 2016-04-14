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
product_name=wso2esb
marathon_endpoint="http://mesos:8080/v2"
common_folder=$(cd "${self_path}/../common/scripts/"; pwd)
docker_build=false
deploy_marathon_app=false
export_docker_image=false
docker_image_export_path=/tmp/mesos-artifacts/esb
marathon_version="0.5.13"
source "${self_path}/../common/scripts/base.sh"

# Show usage and exit
function showUsageAndExit() {
    echoError "Insufficient or invalid options provided!"
    echo
    echoBold "Usage: ./build.sh -v [product-version]"
    echo
    exit 1
}

while getopts ":v:o:e:t:r:m:qbdEy" FLAG; do
    case ${FLAG} in
        b)            
            docker_build=true
            ;;
        d)
            deploy_marathon_app=true
            ;;
        E)
            export_docker_image=true
            ;;
        v)
            product_version=$OPTARG
            ;;
        m)
            marathon_version=$OPTARG
            ;;
        \?)
            showUsageAndExit
            ;;
    esac
done

if [ ${docker_build} == true ]; then
   echo "Building Docker images..."

    # Copy common files to Dockerfile context
    echo "Creating Dockerfile context..."
    cp "${self_path}/wso2esb-manager-init.sh" "${self_path}/scripts/"
    cp "${self_path}/wso2esb-worker-init.sh" "${self_path}/scripts/"
    mkdir -p "${self_path}/artifacts/configs/repository/deployment/server/"
    cp -a "${self_path}/../../src/test/esb/synapse-configs" "${self_path}/artifacts/configs/repository/deployment/server/"

    echo "Building docker images..."
    build_cmd="docker build --no-cache=true \
        -t \"wso2esb-manager:${product_version}\" \"${self_path}\""
    eval $build_cmd

    build_cmd="docker build --no-cache=true \
        -t \"wso2esb-worker:${product_version}\" \"${self_path}\""
    eval $build_cmd
fi

if [ ${export_docker_image} == true ]; then
   echo "Exporting Docker images to ${docker_image_export_path}..."
   mkdir -p ${docker_image_export_path}
   docker save ${product_name}-manager:${product_version} > ${docker_image_export_path}/${product_name}-manager-${product_version}.tar
   docker save ${product_name}-worker:${product_version} > ${docker_image_export_path}/${product_name}-worker-${product_version}.tar
fi


if [ ${deploy_marathon_app} == true ]; then
   echo "Deploying Apache Mesos Marathon application..."
   curl -X POST -H "Content-Type: application/json" -d@${self_path}/marathon-v${marathon_version}/marathon-app-wso2esb-manager.json -i "${marathon_endpoint}/apps"
   curl -X POST -H "Content-Type: application/json" -d@${self_path}/marathon-v${marathon_version}/marathon-app-wso2esb-worker.json -i "${marathon_endpoint}/apps"
fi
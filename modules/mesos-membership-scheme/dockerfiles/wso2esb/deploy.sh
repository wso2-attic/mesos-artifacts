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

product_name=wso2esb
marathon_endpoint="http://mesos:8080/v2"
prgdir=$(dirname "$0")
script_path=$(cd "$prgdir"; pwd)
common_folder=$(cd "${script_path}/../common/scripts/"; pwd)
docker_build=false
deploy_marathon_app=false
export_docker_image=false
docker_image_export_path=/tmp/mesos-artifacts/esb
marathon_version="0.5.13"
overwrite_v=""
provision_method=""
organization_name=""
product_env=""
tag_name=""
verbose=""

self_path=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${self_path}/../common/scripts/base.sh"

# Show usage and exit
function showUsageAndExit() {
    echoError "Insufficient or invalid options provided!"
    echo
    echoBold "Usage: ./build.sh -v [product-version]"
    echo

    available_provisioning=$(listFiles ${self_path}/../provision)
    available_provisioning=$(echo $available_provisioning | tr ' ' ', ')

    echoBold "Options:"
    echo
    echo -en "  -v\t"
    echo "[REQUIRED] Product version of $(echo $product_name | awk '{print toupper($0)}')"
    echo -en "  -l\t"
    echo "[OPTIONAL] '|' separated $(echo $product_name | awk '{print toupper($0)}') profiles to build. \"default\" is selected if no value is specified."
    echo -en "  -i\t"
    echo "[OPTIONAL] Docker image version."
    echo -en "  -e\t"
    echo "[OPTIONAL] Product environment. If not specified this is defaulted to \"dev\"."
    echo -en "  -o\t"
    echo "[OPTIONAL] Preferred organization name. If not specified, will be kept empty."
    echo -en "  -q\t"
    echo "[OPTIONAL] Quiet flag. If used, the docker build run output will be suppressed."
    echo -en "  -r\t"
    echo "[OPTIONAL] Provisioning method. If not specified this is defaulted to \"default\". Available provisioning methods are ${available_provisioning//,/, }."
    echo

    echoBold "Ex: ./build.sh -v 1.10.0 -l worker|manager -o myorganization -i 1.0.0"
    echo
    exit 1
}

while getopts ":v:o:e:t:r:m:qbdEy" FLAG; do
    case $FLAG in
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
        r)
            provision_method="-r ${OPTARG}"
            ;;
        y)
            overwrite_v="-y"
            ;;
        o)
            organization_name="-o ${OPTARG}"
            ;;
        e)
            product_env="-e ${OPTARG}"
            ;;
        t)
            tag_name="-t ${OPTARG}"
            ;;
        q)
            verbose="-q"
            ;;
        \?)
            showUsageAndExit
            ;;
    esac
done

if [ $docker_build == true ]; then
   echo "Building Docker images..."  
   bash ${common_folder}/docker-build.sh -n ${product_name} -d ${script_path} -l manager -v ${product_version} ${overwrite_v} \
        ${provision_method} ${organization_name} ${product_env} ${tag_name} ${verbose}
   bash ${common_folder}/docker-build.sh -n ${product_name} -d ${script_path} -l worker  -v ${product_version} ${overwrite_v} \
        ${provision_method} ${organization_name} ${product_env} ${tag_name} ${verbose}
fi

if [ $export_docker_image == true ]; then
   echo "Exporting Docker images to ${docker_image_export_path}..."
   mkdir -p $docker_image_export_path
   docker save ${product_name}-manager:${product_version} > ${docker_image_export_path}/${product_name}-manager-${product_version}.tar
   docker save ${product_name}-worker:${product_version} > ${docker_image_export_path}/${product_name}-worker-${product_version}.tar
fi


if [ $deploy_marathon_app == true ]; then
   echo "Deploying Apache Mesos Marathon application..."
   curl -X POST -H "Content-Type: application/json" -d@${script_path}/marathon-v${marathon_version}/marathon-app-wso2esb-manager.json -i "${marathon_endpoint}/apps"
   curl -X POST -H "Content-Type: application/json" -d@${script_path}/marathon-v${marathon_version}/marathon-app-wso2esb-worker.json -i "${marathon_endpoint}/apps"
fi



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
self_path=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
mesos_artifacts_home="${self_path}/.."
source "${mesos_artifacts_home}/common/scripts/base.sh"

wso2am_default_service_port=10202
wso2am_api_key_manager_service_port=10204
wso2am_api_publisher_service_port=10206
wso2am_api_store_service_port=10208
wso2am_gateway_manager_service_port=10212
wso2am_gateway_worker_service_port=10216
mysql_apim_db_host_port=10006

function deploy_distributed() {
  echoBold "Deploying WSO2 APIM distributed cluster on Mesos..."
  deploy_common_services
  deploy_service 'mysql-apim-db' $mysql_apim_db_host_port
  deploy_service 'wso2am-api-key-manager' $wso2am_api_key_manager_service_port
  echoBold "wso2am-api-key-manager management console: http://${marathonlb_host_ip}:${wso2am_api_key_manager_service_port}/carbon"
  deploy_service 'wso2am-api-store' $wso2am_api_store_service_port
  echoBold "wso2am-api-store management console: http://${marathonlb_host_ip}:${wso2am_api_store_service_port}/store"
  deploy_service 'wso2am-api-publisher' $wso2am_api_publisher_service_port
  echoBold "wso2am-api-publisher management console: http://${marathonlb_host_ip}:${wso2am_api_publisher_service_port}/publisher"
  deploy_service 'wso2am-gateway-manager' $wso2am_gateway_manager_service_port
  echoBold "wso2am-gateway-manager management console: http://${marathonlb_host_ip}:${wso2am_gateway_manager_service_port}/carbon"
  # deploy_service 'wso2am-gateway-worker' $wso2am_gateway_worker_service_port
  # echoSuccess "Successfully deployed WSO2 APIM distributed cluster on Mesos"
}

function deploy_default() {
  echoBold "Deploying WSO2 APIM default setup on Mesos..."
  deploy_common_services
  deploy_service 'mysql-apim-db' $mysql_apim_db_host_port
  deploy_service 'wso2am-default' $wso2am_default_service_port
  echoBold "wso2am-default management console: http://${marathonlb_host_ip}:${wso2am_default_service_port}/carbon"
  echoSuccess "Successfully deployed WSO2 APIM default setup on Mesos"
}

function main () {
  while getopts :dh FLAG; do
      case $FLAG in
          d)
              deployment_pattern="distributed"
              ;;
          h)
              showUsageAndExitDistributed
              ;;
          \?)
              showUsageAndExitDistributed
              ;;
      esac
  done

  if [[ $deployment_pattern == "distributed" ]]; then
      deploy_distributed
  else
      deploy_default
  fi
}
main "$@"

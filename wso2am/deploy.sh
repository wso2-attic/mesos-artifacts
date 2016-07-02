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

mysql_am_db_service_port=10006
wso2am_default_service_port=10010
wso2am_api_key_manager_service_port=10008
wso2am_api_publisher_service_port=10010
wso2am_api_store_service_port=10012
wso2am_gateway_manager_service_port=10016
wso2am_gateway_worker_service_port=10020

function deploy_distributed() {
  echoBold "Deploying WSO2 APIM distributed cluster on Mesos..."
  deploy_common_services
  deploy_wso2_service 'mysql-am-db' $mysql_am_db_service_port
  deploy_wso2_service 'wso2am-api-key-manager' $wso2am_api_key_manager_service_port
  echoBold "wso2am-api-key-manager management console: https://${marathon_lb_host_ip}:${wso2am_api_key_manager_service_port}/carbon"
  deploy_wso2_service 'wso2am_api_store' $wso2am_api_store_service_port
  echoBold "wso2am_api_store management console: https://${marathon_lb_host_ip}:${wso2am_api_store_service_port}/store"
	deploy_wso2_service 'wso2am_api_publisher' $wso2am_api_publisher_service_port
	echoBold "wso2am_api_publisher management console: https://${marathon_lb_host_ip}:${wso2am_api_publisher_service_port}/publisher"
	deploy_wso2_service 'wso2am_gateway_manager' $wso2am_gateway_manager_service_port
	echoBold "wso2am_gateway_manager management console: https://${marathon_lb_host_ip}:${wso2am_gateway_manager_service_port}/carbon"
	deploy_wso2_service 'wso2am_gateway_worker' $wso2am_gateway_worker_service_port
  echoSuccess "Successfully deployed WSO2 APIM distributed cluster on Mesos"
}

function deploy_default() {
  echoBold "Deploying WSO2 APIM default setup on Mesos..."
  deploy_common_services
  deploy_wso2_service 'mysql-am-db' $mysql_am_db_service_port
  deploy_wso2_service 'wso2am-default' $wso2am_default_service_port
  echoBold "wso2am-default management console: https://${marathon_lb_host_ip}:${wso2am_default_service_port}/carbon"
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

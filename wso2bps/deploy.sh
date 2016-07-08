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

mysql_bps_db_host_port=10031
wso2bps_manager_service_port=10033
wso2bps_worker_service_port=10034
wso2bps_default_service_port=10033

function deploy_distributed() {
  echoBold "Deploying WSO2 BPS distributed cluster on Mesos..."
  deploy_common_services
  deploy_service 'mysql-bps-db' $mysql_bps_db_host_port
  sleep 10s
  deploy_service 'wso2bps-manager' $wso2bps_manager_service_port
  echoBold "wso2bps-manager management console: https://${marathonlb_host_ip}:${wso2bps_manager_service_port}/carbon"
  deploy_service 'wso2bps-worker' $wso2bps_worker_service_port
  echoSuccess "Successfully deployed WSO2 BPS distributed cluster on Mesos"
}

function deploy_default() {
  echoBold "Deploying WSO2 BPS default setup on Mesos..."
  deploy_common_services
  deploy_service 'mysql-bps-db' $mysql_bps_db_host_port
  sleep 10s
  deploy_service 'wso2bps-default' $wso2bps_default_service_port
  echoBold "wso2bps-default management console: https://${marathonlb_host_ip}:${wso2bps_default_service_port}/carbon"
  echoSuccess "Successfully deployed WSO2 BPS default setup on Mesos"
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

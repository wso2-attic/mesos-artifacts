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

mysql_dss_db_host_port=10071
wso2dss_manager_service_port=10073
wso2dss_worker_service_port=10075
wso2dss_default_service_port=10073

function deploy_distributed() {
  echoBold "Deploying WSO2 DSS distributed cluster on Mesos..."
  deploy_common_services
  deploy_service 'mysql-dss-db' $mysql_dss_db_host_port 'mysql-dss-db'
  deploy_service 'wso2dss-manager' $wso2dss_manager_service_port 'marathon-lb'
  echoBold "wso2dss-manager management console: https://${host_ip}:${wso2dss_manager_service_port}/carbon"
  deploy_service 'wso2dss-worker' $wso2dss_worker_service_port 'marathon-lb'
  echoSuccess "Successfully deployed WSO2 DSS distributed cluster on Mesos"
}

function deploy_default() {
  echoBold "Deploying WSO2 DSS default setup on Mesos..."
  deploy_common_services
  deploy_service 'mysql-dss-db' $mysql_dss_db_host_port 'mysql-dss-db'
  deploy_service 'wso2dss-default' $wso2dss_default_service_port 'marathon-lb'
  echoBold "wso2dss-default management console: https://${host_ip}:${wso2dss_default_service_port}/carbon"
  echoSuccess "Successfully deployed WSO2 DSS default setup on Mesos"
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

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

mysql_cep_db_host_port=10091
# wso2cep_presenter_service_port=10093
# wso2cep_worker_service_port=10095
wso2cep_default_service_port=10052

function deploy_distributed() {
  echoError "CEP ha/distributed deployment not supported!"
  # echoBold "Deploying WSO2 CEP distributed cluster on Mesos..."
  # deploy_common_services
  # deploy_service 'mysql-cep-db' $mysql_cep_db_host_port
  # deploy_service 'wso2cep-presenter' $wso2cep_presenter_service_port
  # echoBold "wso2cep-presenter management console: https://${host_ip}:${wso2cep_presenter_service_port}/carbon"
  # deploy_service 'wso2cep-worker' $wso2cep_worker_service_port 'marathon-lb'
  # echoSuccess "Successfully deployed WSO2 CEP distributed cluster on Mesos"
}

function deploy_default() {
  echoBold "Deploying WSO2 CEP default setup on Mesos..."
  deploy_common_services
  deploy_service 'mysql-cep-db' $mysql_cep_db_host_port
  deploy_service 'wso2cep-default' $wso2cep_default_service_port
  echoBold "wso2cep-default management console: http://${marathonlb_host_ip}:${wso2cep_default_service_port}/carbon"
  echoSuccess "Successfully deployed WSO2 CEP default setup on Mesos"
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

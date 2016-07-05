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

mysql_es_db_service_port=10081
wso2es_store_service_port=10085
wso2es_publisher_service_port=10083
wso2es_default_service_port=10085

function deploy_distributed() {
  echoBold "Deploying WSO2 ES distributed cluster on Mesos..."
  deploy_common_services
  deploy_service 'mysql-es-db' $mysql_es_db_service_port
  deploy_service 'wso2es-store' $wso2es_store_service_port
  echoBold "wso2es-store management console: https://${host_ip}:${wso2es_store_service_port}/store"
  deploy_service 'wso2es-publisher' $wso2es_publisher_service_port
  echoBold "wso2es-publisher management console: https://${host_ip}:${wso2es_publisher_service_port}/publisher"
  echoSuccess "Successfully deployed WSO2 ES distributed cluster on Mesos"
}

function deploy_default() {
  echoBold "Deploying WSO2 ES default setup on Mesos..."
  deploy_common_services
  deploy_service 'mysql-es-db' $mysql_es_db_service_port
  deploy_service 'wso2es-default' $wso2es_default_service_port
  echoBold "wso2es-default management console: https://${host_ip}:${wso2es_default_service_port}/carbon"
  echoSuccess "Successfully deployed WSO2 ES default setup on Mesos"
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

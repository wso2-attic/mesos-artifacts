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
mysql_gov_db_service_port=10000
mysql_user_db_service_port=10001
mysql_am_db_service_port=10006

function deploy_base_services() {
  if ! bash ${mesos_artifacts_home}/common/marathon-lb/deploy.sh; then
    echoError "Non-zero exit code returned when deploying marathon-lb"
    exit 1
  fi
  if ! bash ${mesos_artifacts_home}/common/wso2-shared-dbs/deploy.sh; then
    echoError "Non-zero exit code returned when deploying WSO2 shared databases"
    exit 1
  fi
  if ! deploy 'mysql-apim-db' ${self_path}/mysql-apim-db.json; then
    echoError "Non-zero exit code returned when deploying mysql-apim-db"
    exit 1
  fi

  waitUntilServiceIsActive 'mysql-gov-db' $mysql_gov_db_service_port
  waitUntilServiceIsActive 'mysql-user-db' $mysql_user_db_service_port
  waitUntilServiceIsActive 'mysql-apim-db' $mysql_am_db_service_port
}

function deploy_default() {
  echoBold "Deploying WSO2 AM default setup on Mesos..."
  deploy_base_services
  if ! deploy 'wso2am-default' $self_path/wso2am-default.json; then
    echoError "Non-zero exit code returned when deploying wso2am-default"
    exit 1
  fi
  echoBold "wso2am-default management console: https://${marathon_lb_host_ip}:${wso2am_default_service_port}/carbon"
  waitUntilServiceIsActive 'wso2am-default' $wso2am_default_service_port
  echoSuccess "Successfully deployed WSO2 AM default setup on Mesos"
}

function deploy_distributed() {
  echoBold "Deploying WSO2 AM distributed cluster on Mesos..."
  deploy_base_services
  if ! deploy 'wso2am-api-key-manager' $self_path/wso2am-api-key-manager.json; then
    echoError "Non-zero exit code returned when deploying wso2am-api-key-manager"
    exit 1
  fi
  waitUntilServiceIsActive 'wso2am-api-key-manager' $wso2am_api_key_manager_service_port
  echoBold "wso2am-api-key-manager successfully started"

  if ! deploy 'wso2am-api-store' $self_path/wso2am-api-store.json; then
    echoError "Non-zero exit code returned when deploying wso2am-api-store"
    exit 1
  fi
  waitUntilServiceIsActive 'wso2am-api-store' $wso2am_api_store_service_port
  echoBold "wso2am-api-store successfully started"

  if ! deploy 'wso2am-api-publisher' $self_path/wso2am-api-publisher.json; then
    echoError "Non-zero exit code returned when deploying wso2am-api-publisher"
    exit 1
  fi
  waitUntilServiceIsActive 'wso2am-api-publisher' $wso2am_api_publisher_service_port
  echoBold "wso2am-api-publisher successfully started"

  if ! deploy 'wso2am-gateway-manager' $self_path/wso2am-gateway-manager.json; then
    echoError "Non-zero exit code returned when deploying wso2am-gateway-manager"
    exit 1
  fi
  waitUntilServiceIsActive 'wso2am-gateway-manager' $wso2am_gateway_manager_service_port
  echoBold "wso2am-gateway-manager successfully started"

 # if ! deploy 'wso2am-gateway-worker' $self_path/wso2am-gateway-worker.json; then
 #   echoError "Non-zero exit code returned when deploying wso2am-gateway-worker"
 #   exit 1
 # fi
 # waitUntilServiceIsActive 'wso2am-gateway-worker' $wso2am_gateway_worker_service_port
 # echoBold "wso2am-gateway-worker successfully started"

  echoSuccess "Successfully deployed WSO2 AM distributed cluster on Mesos"
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

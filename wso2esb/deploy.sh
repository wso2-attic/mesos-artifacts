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

wso2esb_manager_service_port=10093
wso2esb_worker_service_port=10095
wso2esb_default_service_port=10095
mysql_gov_db_service_port=10000
mysql_user_db_service_port=10001
mysql_esb_db_service_port=10091

function deploy_base_services() {
  if ! bash ${mesos_artifacts_home}/common/marathon-lb/deploy.sh; then
    echoError "Non-zero exit code returned when deploying marathon-lb"
    exit 1
  fi
  if ! bash ${mesos_artifacts_home}/common/wso2-shared-dbs/deploy.sh; then
    echoError "Non-zero exit code returned when deploying WSO2 shared databases"
    exit 1
  fi
  if ! deploy 'mysql-esb-db' ${self_path}/mysql-esb-db.json; then
    echoError "Non-zero exit code returned when deploying mysql-esb-db"
    exit 1
  fi

  waitUntilServiceIsActive 'mysql-gov-db' $mysql_gov_db_service_port
  waitUntilServiceIsActive 'mysql-user-db' $mysql_user_db_service_port
  waitUntilServiceIsActive 'mysql-esb-db' $mysql_esb_db_service_port
}

function deploy_distributed() {
  echoBold "Deploying WSO2 ESB distributed cluster on Mesos..."
  deploy_base_services
  if ! deploy 'wso2esb-manager' $self_path/wso2esb-manager.json; then
    echoError "Non-zero exit code returned when deploying wso2esb-manager"
    exit 1
  fi
  waitUntilServiceIsActive 'wso2esb-manager' $wso2esb_manager_service_port
  echoBold "wso2esb-manager management console: https://${marathon_lb_host_ip}:${wso2esb_manager_service_port}/carbon"

  if ! deploy 'wso2esb-worker' $self_path/wso2esb-worker.json; then
      echoError "Non-zero exit code returned when deploying wso2esb-worker"
      exit 1
  fi
  waitUntilServiceIsActive 'wso2esb-worker' $wso2esb_worker_service_port
  echoSuccess "Successfully deployed WSO2 ESB distributed cluster on Mesos"
}

function deploy_default() {
  echoBold "Deploying WSO2 ESB default setup on Mesos..."
  deploy_base_services
  if ! deploy 'wso2esb-default' $self_path/wso2esb-default.json; then
    echoError "Non-zero exit code returned when deploying wso2esb-default"
    exit 1
  fi
  echoBold "wso2esb-default management console: https://${marathon_lb_host_ip}:${wso2esb_default_service_port}/carbon"
  waitUntilServiceIsActive 'wso2esb-default' $wso2esb_default_service_port
  echoSuccess "Successfully deployed WSO2 ESB default setup on Mesos"
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

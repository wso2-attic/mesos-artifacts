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

mysql_greg_db_host_port=10101
wso2greg_default_service_port=10103

function deploy_default() {
  echoBold "Deploying WSO2 GREG default setup on Mesos..."
  deploy_common_services
  deploy_service 'mysql-greg-db' $mysql_greg_db_host_port
  deploy_service 'wso2greg-default' $wso2greg_default_service_port
  echoBold "wso2greg-default management console: https://${marathonlb_host_ip}:${wso2greg_default_service_port}/carbon"
  echoSuccess "Successfully deployed WSO2 GREG default setup on Mesos"
}

function main () {
  while getopts :dh FLAG; do
      case $FLAG in
          h)
              showUsageAndExitDistributed
              ;;
          \?)
              showUsageAndExitDistributed
              ;;
      esac
  done

  deploy_default

}
main "$@"

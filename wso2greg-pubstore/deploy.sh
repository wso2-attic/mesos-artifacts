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

mysql_greg_db_host_port=10131
mysql_greg_apim_db_service_port=10132
wso2greg_pubstore_default_service_port=10134

function deploy_default() {
  echoBold "Deploying WSO2 GREG-PUBSTORE default setup on Mesos..."
  deploy_common_services
  deploy_service 'mysql-greg-db' $mysql_greg_db_host_port 'mysql-greg-db'
  deploy_service 'mysql-greg-apim-db' $mysql_greg_apim_db_service_port 'mysql-greg-apim-db'
  deploy_service 'wso2greg-pubstore-default' $wso2greg_pubstore_default_service_port 'marathon-lb'
  echoBold "wso2greg-pubstore-default management console: https://${host_ip}:${wso2greg_pubstore_default_service_port}/carbon"
  echoSuccess "Successfully deployed WSO2 GREG-PUBSTORE default setup on Mesos"
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

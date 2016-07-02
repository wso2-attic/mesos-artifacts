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

function undeploy_product() {
  undeploy wso2is_km-default
  undeploy mysql-is-db
}

function full_purge() {
  undeploy_product
  bash ${self_path}/../common/wso2-shared-dbs/undeploy.sh
  bash ${self_path}/../common/marathon-lb/undeploy.sh
}

function main() {
  full_purge=false
  while getopts :f FLAG; do
      case $FLAG in
          f)
              full_purge=true
              ;;
      esac
  done

  if [[ $full_purge == true ]]; then
    echo "Purging WSO2 IS KM deployment..."
    full_purge
  else
    echo "Undeploying WSO2 IS KM product..."
    undeploy_product
  fi
}
main "$@"

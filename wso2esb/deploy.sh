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

manager_service_port=32095
worker_service_port=32093
default_service_port=32093
marathon_lb_port=9090
marathon_endpoint="http://m1.dcos:8080/v2"

self_path=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${self_path}/../common/scripts/base.sh"

bash ${self_path}/../common/marathon-lb/deploy.sh
echo "Waiting for marathon-lb to launch on a1.dcos:9090..."
while ! nc -z a1.dcos 9090; do
  sleep 0.1
done
echo "marathon-lb started successfully"

bash ${self_path}/../common/wso2-shared-dbs/deploy.sh
deploy ${marathon_endpoint} ${self_path}/mysql-esb-db.json

echo "Waiting for mysql-gov-db to launch on a1.dcos:10000..."
while ! nc -z a1.dcos 10000; do
  sleep 0.1
done
echo "mysql-gov-db started successfully"

echo "Waiting for mysql-user-db to launch on a1.dcos:10001..."
while ! nc -z a1.dcos 10001; do
  sleep 0.1
done
echo "mysql-user-db started successfully"

echo "Waiting for mysql-esb-db to launch on a1.dcos:10002..."
while ! nc -z a1.dcos 10002; do
  sleep 0.1
done
echo "mysql-esb-db started successfully"

deploy ${marathon_endpoint} ${self_path}/wso2esb-manager.json
echo "Waiting for wso2esb-manager to launch on a1.dcos:10096..."
while ! nc -z a1.dcos 10096; do
  sleep 0.1
done
echo "wso2esb-manager started successfully: https://wso2esb-manager:10096/carbon"

deploy ${marathon_endpoint} ${self_path}/wso2esb-worker.json
echo "Waiting for wso2esb-worker to launch on a1.dcos:10094..."
while ! nc -z a1.dcos 10091; do
  sleep 0.1
done
echo "wso2esb-worker started successfully: http://wso2esb-worker:10091/services/"

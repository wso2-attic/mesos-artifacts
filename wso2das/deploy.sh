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
self_path=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

marathon_endpoint="http://m1.dcos:8080/v2"
source "${self_path}/../common/scripts/base.sh"

bash ${self_path}/../common/marathon-lb/deploy.sh
echo "Waiting for marathon-lb to launch on a1.dcos:9090..."
while ! nc -z a1.dcos 9090; do
  sleep 0.1
done
echo "marathon-lb started successfully"

bash ${self_path}/../common/wso2-shared-dbs/deploy.sh
deploy ${marathon_endpoint} ${self_path}/mysql-das-db.json

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

echo "Waiting for mysql-das-db to launch on a1.dcos:10002..."
while ! nc -z a1.dcos 10002; do
  sleep 0.1
done
echo "mysql-das-db started successfully"

deploy ${marathon_endpoint} ${self_path}/wso2das-default.json
echo "Waiting for wso2das-default to launch on a1.dcos:10092..."
while ! nc -z a1.dcos 10092; do
 sleep 0.1
done
echo "wso2das-default started successfully: https://wso2das-default:10092/carbon"


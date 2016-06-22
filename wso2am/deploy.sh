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
deploy ${marathon_endpoint} ${self_path}/mysql-apim-db.json

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

echo "Waiting for mysql-apim-db to launch on a1.dcos:10002..."
while ! nc -z a1.dcos 10002; do
  sleep 0.1
done
echo "mysql-apim-db started successfully"

deploy ${marathon_endpoint} ${self_path}/wso2am-api-key-manager.json
echo "Waiting for api-key-manager to launch on a1.dcos:10007..."
while ! nc -z a1.dcos 10007; do
sleep 0.1
done
echo "wso2am-api-key-manager started successfully: https://wso2am-api-key-manager:10007/carbon"

deploy ${marathon_endpoint} ${self_path}/wso2am-api-publisher.json
echo "Waiting for wso2am-api-publisher to launch on a1.dcos:10009..."
while ! nc -z a1.dcos 10009; do
 sleep 0.1
done
echo "wso2am-api-publisher started successfully: https://wso2am-api-publisher:10009/publisher"

deploy ${marathon_endpoint} ${self_path}/wso2am-api-store.json
echo "Waiting for wso2am-api-store to launch on a1.dcos:10011..."
while ! nc -z a1.dcos 10011; do
 sleep 0.1
done
echo "wso2am-api-store started successfully: https://wso2am-api-store:10011/store"

deploy ${marathon_endpoint} ${self_path}/wso2am-gateway-manager.json
echo "Waiting for wso2am-gateway-manager to launch on a1.dcos:10015..."
while ! nc -z a1.dcos 10015; do
 sleep 0.1
done
echo "wso2am-gateway-manager started successfully: https://wso2am-gateway-manager:10015/carbon"

deploy ${marathon_endpoint} ${self_path}/wso2am-gateway-worker.json
echo "Waiting for wso2am-gateway-worker to launch on a1.dcos:10019..."
while ! nc -z a1.dcos 10019; do
 sleep 0.1
done
echo "wso2am-gateway-worker started successfully: https://wso2am-gateway-worker:10019/"

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

FROM wso2esb:4.9.0
MAINTAINER dev@wso2.org
USER wso2user
# Override startup scripts. Need to replace localMemberPort with dynamic Hazelcast proxy port
COPY scripts/wso2esb-manager-init.sh /usr/local/bin/
COPY scripts/wso2esb-worker-init.sh /usr/local/bin/
COPY artifacts/configs/bin/wso2server.sh /mnt/wso2esb-4.9.0/bin/

# Add kernel patch to support custom membership schemes
COPY artifacts/patches/ /mnt/wso2esb-4.9.0/repository/components/patches

# Configure axis2.xml to enable Mesos clustering scheme
COPY artifacts/configs/repository/conf/axis2/axis2.xml /mnt/wso2esb-4.9.0/repository/conf/axis2/
COPY artifacts/configs/repository/components/dropins/mesos-membership-scheme-1.0.0-SNAPSHOT.jar /mnt/wso2esb-4.9.0/repository/components/dropins

# Copy Synapse artifacts
COPY artifacts/configs/repository/deployment/server/synapse-configs /mnt/wso2esb-4.9.0/repository/deployment/server/synapse-configs

USER root
RUN chown -R wso2user /mnt/wso2esb-4.9.0
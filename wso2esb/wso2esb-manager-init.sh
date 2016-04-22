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
axis2_xml_file_path=${CARBON_HOME}/repository/conf/axis2/axis2.xml

# replace localMemberHost with Apache Mesos host IP
function replace_local_member_host_with_mesos_host_ip {
    sed -i "s/\(<parameter\ name=\"localMemberHost\">\).*\(<\/parameter*\)/\1${HOST}\2/" "${axis2_xml_file_path}"
    if [[ $? == 0 ]];
        then
        echo "successfully updated localMemberHost with IP: ${HOST}"
    else
        echo "error occurred in updating localMemberHost with IP: ${HOST}"
    fi
}

# replace localMemberPort with Mesos dynamic port
function replace_local_member_port {
    sed -i "s/\(<parameter\ name=\"localMemberPort\">\).*\(<\/parameter*\)/\1${PORT0}\2/" "${axis2_xml_file_path}"
    if [[ $? == 0 ]]; then
        echo "Successfully updated localMemberPort with port ${PORT0}"
    else
        echo "Error occurred while updating localMemberPort with port ${PORT0}"
    fi
}

replace_local_member_host_with_mesos_host_ip
replace_local_member_port

echo "Starting ${CARBON_HOME}..."
${CARBON_HOME}/bin/wso2server.sh
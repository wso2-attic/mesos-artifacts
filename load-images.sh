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
self_path=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "${self_path}/common/scripts/base.sh"

function showUsageAndExit() {
  echoBold "Usage: ./load-images.sh [OPTIONS]"
  echo
  echo "Transfer Docker images to Mesos Nodes"

  echoBold "Options:"
  echo
  echo -en "  -u\t"
  echo "[OPTIONAL] Username to be used to connect to Mesos Nodes. If not provided, default \"centos\" is used."
  echo -en "  -p\t"
  echo "[OPTIONAL] Optional search pattern to search for Docker images. If not provided, default \"mesos\" is used."
  echo -en "  -k\t"
  echo "[OPTIONAL] Optional key file location. If not provided, key file will not be used."
  echo -en "  -h\t"
  echo "[OPTIONAL] Show help text."
  echo

  echoBold "Ex: ./load-images.sh"
  echoBold "Ex: ./load-images.sh -u centos -p wso2is -k /home/ssh_key.pem"
  echo
  exit 1
}

mesos_username="centos"
search_pattern="mesos"

# TODO: handle flag provided, but no value
while getopts :u:p::k:h FLAG; do
    case $FLAG in
        u)
            mesos_username=$OPTARG
            ;;
        p)
            search_pattern=$OPTARG
            ;;
        k)
            key_file_path=$OPTARG
            ;;
        h)
            showUsageAndExit
            ;;
    esac
done

if ! validateDCOSCLI; then
    echoError "DCOS CLI validation failed"
    echoError "Please check whether DCOS CLI is properly installed and configured in your system"
    return 1
fi

IFS=$'\n'

# Get Mesos nodes from CLI
mesos_nodes=($(getMesosNodes))
if [ "${#mesos_nodes[@]}" -lt 1 ]; then
    echoError "No Mesos Nodes found."
    exit 1
fi

# Check conectivity with provided credentials
if [[ -z "$key_file_path" ]]; then
  (ssh $mesos_username@${mesos_nodes[0]} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -t "exit 0")
else
  (ssh -i ${key_file_path} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $mesos_username@${mesos_nodes[0]} -t "exit 0") >> /dev/null
fi

if [ $? -ne 0 ]; then
  echoError "Unable to connect to mesos node with provided credentials"
  echoError "Exiting."
  exit 1
fi

wso2_docker_images=($(docker images | grep "${search_pattern}" | awk '{print $1 ":" $2}'))

if [ "${#wso2_docker_images[@]}" -lt 1 ]; then
  echo "No Docker images with name \"${search_pattern}\" found."
  exit 1
fi

transfer_all=false

for wso2_image_name in "${wso2_docker_images[@]}"
do
  if [ "${wso2_image_name//[[:space:]]/}" != "" ]; then
    wso2_image=$(docker images $wso2_image_name | awk '{if (NR!=1) print}')
    echo -n $(echo $wso2_image | awk '{print $1 ":" $2, "(" $3 ")"}') " - "

    if !($transfer_all) ; then
        askBold "Transfer? ( [a]yes to all [y]es / [n]o / [e]xit ): "
        read input
    else
        input=y
    fi

    if [ "$input" == "y" ]; then
      image_id=$(echo $wso2_image | awk '{print $3}')
      echoDim "Saving image ${wso2_image_name}..."
      docker save ${wso2_image_name} > /tmp/$image_id.tar

      for mesos_node in "${mesos_nodes[@]}"
      do
        echoDim "Copying saved image to ${mesos_node}..."
        echoDim "Copying Docker Image to Node ${mesos_node}..."
        if [[ -z "$key_file_path" ]]; then
            scp /tmp/$image_id.tar -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $mesos_username@$mesos_node:. &
        else
            scp -i ${key_file_path} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null /tmp/$image_id.tar  $mesos_username@$mesos_node:. &
        fi
      done
      wait
      echo "Image transfer completed."

      echo "Starting to load images ..."
      for mesos_node in "${mesos_nodes[@]}"
      do
        echoDim "Loading saved image in ${mesos_node}"
        if [[ -z "$key_file_path" ]]; then
          ssh $mesos_username@$mesos_node -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -t -t "sudo docker load < ${image_id}.tar && rm -rf ${image_id}.tar" &
        else
          ssh -i ${key_file_path} $mesos_username@$mesos_node -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -t -t "sudo docker load < ${image_id}.tar && rm -rf ${image_id}.tar" &
        fi
      done
      wait
      echo "Image loading completed."

      echoDim "Cleaning..."
      rm /tmp/$image_id.tar
      echoBold "Done"

    elif [ "$input" == "e" ]; then
      echoBold "Done"
      exit 0
    elif [ "$input" == "a" ]; then
      transfer_all=true
      echoBold "All the images will be transferred."
    fi
  fi
done

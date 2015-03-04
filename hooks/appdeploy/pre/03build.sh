#!/bin/bash
#==============================================================================
# Copyright 2012 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Amazon Software License (the "License"). You may not use
# this file except in compliance with the License. A copy of the License is
# located at
#
#       http://aws.amazon.com/asl/
#
# or in the "license" file accompanying this file. This file is distributed on
# an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, express or
# implied. See the License for the specific language governing permissions
# and limitations under the License.
#==============================================================================

. /opt/elasticbeanstalk/hooks/common.sh

cd $EB_CONFIG_APP_CURRENT

# Dockerrun.aws.json verson checking
# right now only one valid version "1"
if [ -f Dockerrun.aws.json ]; then
	[ "`cat Dockerrun.aws.json | jq -r .AWSEBDockerrunVersion`" = "1" ] || error_exit "Invalid Dockerrun.aws.json version, abort deployment" 1
fi

# if we don't have a Dockerfile, generate a simple one with FROM and EXPOSE only
if [ ! -f Dockerfile ]; then
	if [ ! -f Dockerrun.aws.json ]; then
		error_exit "Dockerfile and Dockerrun.aws.json are both missing, abort deployment" 1
	fi

	IMAGE=`cat Dockerrun.aws.json | jq -r .Image.Name`
	PORT=`cat Dockerrun.aws.json | jq -r .Ports[0].ContainerPort`

	touch Dockerfile
	echo "FROM $IMAGE" >> Dockerfile
	echo "EXPOSE $PORT" >> Dockerfile
fi

# download auth credentials for private repo

S3_BUCKET=`cat Dockerrun.aws.json | jq -r .Authentication.Bucket`
S3_KEY=`cat Dockerrun.aws.json | jq -r .Authentication.Key`
if [ -n "$S3_BUCKET" ] && [ "$S3_BUCKET" != "null" ]; then
	$EB_SUPPORT_FILES/download_auth.py "$S3_BUCKET" "$S3_KEY"
	[ $? -eq 0 ] || error_exit "Failed to download authentication credentials $S3_KEY from $S3_BUCKET" 1
fi

# update "FROM" image

NEED_PULL=`cat Dockerrun.aws.json | jq -r .Image.Update`
if [ "$NEED_PULL" != "false" ]; then
	FROM_IMAGE=`cat Dockerfile | grep -i ^FROM | head -n 1 | awk '{ print $2 }'`

	if ! echo $FROM_IMAGE | grep -q ^aws_beanstalk; then
		# when no tags are specified, pull the latest
		if ! echo $FROM_IMAGE | grep -q ':'; then
			FROM_IMAGE="$FROM_IMAGE:latest"
		fi

		HOME=/root docker pull "$FROM_IMAGE" 2>&1 | tee /tmp/docker_pull.log

		DOCKER_PULL_EXIT_CODE=${PIPESTATUS[0]}
		if [ $DOCKER_PULL_EXIT_CODE -eq 0 ]; then
		    trace "Successfully pulled $FROM_IMAGE"
		else
		    LOG_TAIL=`cat /tmp/docker_pull.log | tail -c 200`
		    rm -f /root/.dockercfg
		    error_exit "Failed to pull Docker image $FROM_IMAGE: $LOG_TAIL. Check snapshot logs for details." $DOCKER_PULL_EXIT_CODE
		fi
	fi
fi

docker build -t $EB_CONFIG_DOCKER_IMAGE_STAGING . 2>&1 | tee /tmp/docker_build.log

DOCKER_BUILD_EXIT_CODE=${PIPESTATUS[0]}
if [ $DOCKER_BUILD_EXIT_CODE -eq 0 ]; then
    trace "Successfully built $EB_CONFIG_DOCKER_IMAGE_STAGING"
else
    LOG_TAIL=`cat /tmp/docker_build.log | tail -c 200`
    rm -f /root/.dockercfg
    error_exit "Failed to build Docker image $EB_CONFIG_DOCKER_IMAGE_STAGING: $LOG_TAIL. Check snapshot logs for details." $DOCKER_BUILD_EXIT_CODE
fi

# no need for the auth file to hang around
rm -f /root/.dockercfg

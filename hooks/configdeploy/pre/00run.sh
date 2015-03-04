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

set -e

. /opt/elasticbeanstalk/hooks/common.sh

# tag current as STAGING
EB_CONFIG_DOCKER_IMAGE_ID_CURRENT=`docker images | grep ^$EB_CONFIG_DOCKER_IMAGE_CURRENT | awk '{ print $3 }'`
docker tag $EB_CONFIG_DOCKER_IMAGE_ID_CURRENT $EB_CONFIG_DOCKER_IMAGE_STAGING

# go through docker run again, picking up config updates
/opt/elasticbeanstalk/hooks/appdeploy/pre/04run.sh

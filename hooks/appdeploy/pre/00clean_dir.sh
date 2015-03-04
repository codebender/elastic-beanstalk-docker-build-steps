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

rm -rf $EB_CONFIG_APP_CURRENT
mkdir -p $EB_CONFIG_APP_CURRENT

mkdir -p $EB_CONFIG_DOCKER_LOG_HOST_DIR
# need chmod since customer app may run as non-root and the user they run as is undeterminstic
chmod 777 $EB_CONFIG_DOCKER_LOG_HOST_DIR

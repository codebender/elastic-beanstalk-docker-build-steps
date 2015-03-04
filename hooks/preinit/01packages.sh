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

chkconfig_on() {
	if is_rhel; then
		# enable cfn-hup and nginx on boot
		chkconfig cfn-hup on
		chkconfig nginx on
	fi
}

if [ -x "`which docker`" ]; then # baked AMI
	echo "Running on baked AMI, skipping package install."
	chkconfig_on
	exit 0
fi

if is_rhel; then
	yum install -y jq nginx sqlite3

	curl -o /tmp/docker.rpm `cat $EB_CONFIG_FILE | jq -r .docker.rpm`
	yum install -y /tmp/docker.rpm

	service docker start

	chkconfig_on
elif is_debian; then
	apt-get update
	# Docker dependencies, nginx
	apt-get install -y --force-yes jq linux-image-extra-`uname -r` nginx aufs-tools git git-man liberror-perl sqlite3

	# install docker from deb
	curl -o /tmp/docker.deb `cat $EB_CONFIG_FILE | jq -r .docker.deb`
	dpkg --install /tmp/docker.deb
else
	error_exit "Unknown package management system" 1
fi

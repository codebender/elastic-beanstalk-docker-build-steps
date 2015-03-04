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

# User can upload either a zip or simply a Dockerfile
if [ "`file -b --mime-type $EB_CONFIG_APP_SOURCE`" = "application/zip" ]; then
	unzip -o -d $EB_CONFIG_APP_CURRENT $EB_CONFIG_APP_SOURCE || error_exit "Failed to unzip source bundle, abort deployment" 1
else
	# unfortunately "file" won't be able to tell Dockerfile from JSON file (they're simply both "text/plain")
	# try to parse as JSON, the fall back to treat it as Dockerfile

	# jq 1.2 has a bug where parse error will return 0 instead of 1, thus we need the additional grep test
	if cat $EB_CONFIG_APP_SOURCE | jq . && ! cat $EB_CONFIG_APP_SOURCE | jq . 2>&1 | grep -q 'parse error'; then
		cp -f $EB_CONFIG_APP_SOURCE $EB_CONFIG_APP_CURRENT/Dockerrun.aws.json
	else
		cp -f $EB_CONFIG_APP_SOURCE $EB_CONFIG_APP_CURRENT/Dockerfile
	fi
fi

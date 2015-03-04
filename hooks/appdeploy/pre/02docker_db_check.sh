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

# under certain unknown circumstances (stopping/starting daemon too frequently?),
# the docker SQLite database becomes corrupted.

RETRY=0
while ! sqlite3 /var/lib/docker/linkgraph.db 'SELECT * FROM edge'; do
	if [ $RETRY -gt 10 ]; then
		error_exit "Corrupted Docker database; attempts to fix the database have failed." 1
	fi

	rm -f /var/lib/docker/linkgraph.db
	service docker restart
	sleep 5
	RETRY=$((RETRY + 1))
done

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

# docker daemon log

if is_rhel; then
	EB_CONFIG_DOCKER_DAEMON_LOG='/var/log/docker'	
elif is_debian; then
	mkdir -p /var/log/upstart
	EB_CONFIG_DOCKER_DAEMON_LOG='/var/log/upstart/docker.log'
fi

echo "$EB_CONFIG_DOCKER_DAEMON_LOG" >> /opt/elasticbeanstalk/tasks/taillogs.d/docker.conf
echo "$EB_CONFIG_DOCKER_DAEMON_LOG" >> /opt/elasticbeanstalk/tasks/systemtaillogs.d/docker.conf
echo "$EB_CONFIG_DOCKER_DAEMON_LOG" >> /opt/elasticbeanstalk/tasks/bundlelogs.d/docker.conf
echo "$EB_CONFIG_DOCKER_DAEMON_LOG*.gz" >> /opt/elasticbeanstalk/tasks/bundlelogs.d/docker.conf
echo "$EB_CONFIG_DOCKER_DAEMON_LOG*.gz" >> /opt/elasticbeanstalk/tasks/publishlogs.d/docker.conf

# log rotate

cat > /etc/logrotate.conf.elasticbeanstalk <<EOF
su root root
$EB_CONFIG_DOCKER_LOG_HOST_DIR/*.log $EB_CONFIG_DOCKER_DAEMON_LOG $EB_CONFIG_DOCKER_EVENTS_LOG $EB_CONFIG_DOCKER_PS_LOG /var/log/nginx/*.log {
	size 1M
	missingok
	rotate 5
	compress
	notifempty
	copytruncate
	dateext
	dateformat -%s
}
EOF

cat > /etc/cron.hourly/logrotate-elasticbeanstalk <<EOF
#!/bin/sh
[ -x /usr/sbin/logrotate ] || exit 0
/usr/sbin/logrotate -f /etc/logrotate.conf.elasticbeanstalk
EOF
chmod 755 /etc/cron.hourly/logrotate-elasticbeanstalk

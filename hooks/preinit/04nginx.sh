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

if is_rhel; then
	cat > /etc/nginx/nginx.conf <<"EOF"
# Elastic Beanstalk Nginx Configuration File

user  nginx;
worker_processes  1;

error_log  /var/log/nginx/error.log;

pid        /var/run/nginx.pid;

events {
    worker_connections  1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    access_log    /var/log/nginx/access.log;

    include       /etc/nginx/conf.d/*.conf;
    include       /etc/nginx/sites-enabled/*;
}
EOF
	
	mkdir -p /etc/nginx/sites-available
	mkdir -p /etc/nginx/sites-enabled
elif is_debian; then
	rm -f /etc/nginx/sites-enabled/default
else
	error_exit "Unknown nginx distribution" 1
fi

mkdir -p /var/log/nginx

if is_rhel; then
	chown -R nginx:nginx /var/log/nginx
elif is_debian; then
	chown -R www-data:www-data /var/log/nginx
else
	error_exit "Unknown nginx distribution" 1
fi

service nginx stop

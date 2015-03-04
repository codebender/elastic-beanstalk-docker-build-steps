#/bin/bash

EB_ROOT=/opt/elasticbeanstalk
EB_SUPPORT_FILES=$EB_ROOT/containerfiles/support

EB_CONFIG_APP_CURRENT=/var/app/current
EB_CONFIG_APP_SOURCE=$EB_ROOT/deploy/appsource/source_bundle
EB_CONFIG_FILE=$EB_ROOT/deploy/configuration/containerconfiguration

EB_CONFIG_DOCKER_IMAGE_CURRENT="aws_beanstalk/current-app"
EB_CONFIG_DOCKER_IMAGE_STAGING="aws_beanstalk/staging-app"

EB_CONFIG_DOCKER_CURRENT_APP_FILE="/etc/elasticbeanstalk/.aws_beanstalk.current-container-id"
EB_CONFIG_DOCKER_STAGING_APP_FILE="/etc/elasticbeanstalk/.aws_beanstalk.staging-container-id"

EB_CONFIG_DOCKER_CURRENT_PORT_FILE="/etc/elasticbeanstalk/.aws_beanstalk.current-container-port"
EB_CONFIG_DOCKER_STAGING_PORT_FILE="/etc/elasticbeanstalk/.aws_beanstalk.staging-container-port"

EB_CONFIG_DOCKER_LOG_HOST_DIR=/var/log/eb-docker/containers/eb-current-app
EB_CONFIG_DOCKER_EVENTS_LOG=/var/log/docker-events.log
EB_CONFIG_DOCKER_PS_LOG=/var/log/docker-ps.log

trace() {
	echo "$1" # echo so it will be captured by logs
    eventHelper.py --msg "$1" --severity TRACE || true
}

warn() {
	echo "$1" # echo so it will be captured by logs
    eventHelper.py --msg "$1" --severity WARN || true
}

error_exit() {
	echo "$1" # echo so it will be captured by logs
    eventHelper.py --msg "$1" --severity ERROR || true
    #service nginx stop # stop nginx so env turns RED
    exit $2
}

is_debian() {
	[ -f /usr/bin/apt-get ]
}

is_rhel() {
	[ -f /usr/bin/yum ]
}

control_upstart_service() {
	if is_debian; then
		service $1 $2 || true
	elif is_rhel; then
		initctl $2 $1
	else
		error_exit "Unknown upstart manager" 1
	fi
}

start_upstart_service() {
	control_upstart_service $1 start
}

stop_upstart_service() {
	control_upstart_service $1 stop
}

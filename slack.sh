#!/bin/bash

containerName=slack
containerRepo=mf/slack
runOptions=(
-v /home/support/slack:/home/node/slack
-e SLACK_URL=https://example.com
--restart always
-p 8090:3000
--health-cmd "curl -sf http://127.0.0.1:3000 || exit 1"
--health-interval 30s
--health-timeout 10s
--health-retries 3
--health-start-period 30s
)

checkContainerRuntime() {
    printf "Checking Container Runtime...\n\n"
    containerRuntime=$(which docker 2>/dev/null) ||
        containerRuntime=$(which podman 2>/dev/null) ||
        {
            printf "!!!No docker or podman executable found in your PATH!!!\n\n"
            exit 1
        }
    printf "Using Container Runtime - ${containerRuntime}\n\n"
}

removeContainer() {
    if [[ -n "$(sudo ${containerRuntime} ps -a -q -f name=${containerName})" ]]; then
        printf "Removing Container...\n\n"
        sudo ${containerRuntime} stop ${containerName} >/dev/null
        sudo ${containerRuntime} wait ${containerName} >/dev/null
        sudo ${containerRuntime} rm ${containerName} >/dev/null
    fi
}

updateContainer() {
    printf "Updating Container...\n\n"
    sudo ${containerRuntime} pull node
}

buildContainer() {
    printf "Building Container...\n\n"
    sudo ${containerRuntime} build --tag ${containerRepo} -f $(dirname "$0")/slack/Dockerfile
}

startContainer() {
    printf "Starting Container...\n\n"
    sudo ${containerRuntime} run -d --name ${containerName} "${runOptions[@]}" ${containerRepo} 
}

checkContainerRuntime
removeContainer
if [[ $1 == 'update' ]]; then
    updateContainer
fi
buildContainer
startContainer

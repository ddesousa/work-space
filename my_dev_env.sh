#!/bin/bash

MY_DEV_PROJECTS=$MY_DEV_WORKSPACE/projects
MY_DEV_SCRIPTS=$MY_DEV_WORKSPACE/scripts

export MY_DEV_PROJECTS MY_DEV_SCRIPTS

# Start the ssh-agent for my github repo
eval $(ssh-agent -s)

ssh-add ~/.ssh/github.key

echo "*******************My Personal Development Environment***************"

source $MY_DEV_SCRIPTS/load_base_environment.sh
echo ""
echo "Changing directory to $MY_DEV_WORKSPACE"
echo "*********************************************************************"
echo
cd $MY_DEV_PROJECTS/$PROJECT

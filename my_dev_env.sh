#!/bin/bash

MY_DEV_PROJECTS=$MY_DEV_WORKSPACE/Projects
MY_DEV_SCRIPTS=$MY_DEV_WORKSPACE/Scripts

export MY_DEV_PROJECTS MY_DEV_SCRIPTS

echo "*******************My Personal Development Environment***************"
source $MY_DEV_SCRIPTS/load_base_environment.sh
echo ""
echo "Changing directory to $MY_DEV_WORKSPACE"
echo "*********************************************************************"
echo
cd $MY_DEV_PROJECTS/$PROJECT

#!/bin/bash

export WORKSPACE_FOLDER=$1

### Functions Here ###
function SetGroupPermissions()
{
    local group=$1
    local permission=$2
    local file=$3

    if [ ! -e $file ]; then
        echo "Error: $file does not exist"
    fi

    if [ $group == "root" ]; then
        if [ $OSTYPE == "cygwin" ]; then
            setfacl -m g:root:$permission $file
            setfacl -m g:SYSTEM:$permission $file
        else
            echo "Error: SetPermissions not supported for this platform"
        fi
    elif [ $group == "users" ]; then
        if [ $OSTYPE == "cygwin" ]; then
            setfacl -m g:Users:$permission $file
        else
            echo "Error: SetPermissions not supported for this platform"
        fi
    fi
}

### Main Entry ###

if [ ! -d $HOME/.ssh ]; then
    echo "Error: A $HOME/.ssh directory needs to be created and populated."
fi
touch $HOME/.ssh/known_hosts

# Set the permissions for the .ssh folder and it's contents
if [ -d $HOME/.ssh ]; then
    for file in $HOME/.ssh $HOME/.ssh/id_rsa; do
        SetGroupPermissions root rwx $file
        SetGroupPermissions users r-x $file
    done
    SetGroupPermissions users rwx $HOME/.ssh/known_hosts
fi

# Test a connection to tht GIT Server
export TEST_RESULT=`ssh git@172.16.157.129 | grep workspace-env`
if [ -n "$TEST_RESULT" ]; then
    if [ -d $WORKSPACE_FOLDER ]; then
        echo "ERROR: $WORKSPACE_FOLDER already exists. Can not create workspace."
    else
        git clone git@172.16.157.129:/workspace-env $WORKSPACE_FOLDER
        if [ "$OSTYPE" == "cygwin" ]; then
            ln -s $WORKSPACE_FOLDER $HOME/Workspace
        fi
    fi
fi

# Append to the user's .bash_profile to call-up the workspace scripts

if [ ! -f $HOME/.bash_profile ]; then
    echo "#bin/bash" > $HOME/.bash_profile
fi

echo "export MY_DEV_WORKSPACE=${HOME}/Workspace">>$HOME/.bash_profile
echo "if [ -f "\${MY_DEV_WORKSPACE}/my_dev_env.sh" ]; then">>$HOME/.bash_profile
echo "    source \${MY_DEV_WORKSPACE}/my_dev_env.sh">>$HOME/.bash_profile
echo "fi">>$HOME/.bash_profile

touch $HOME/absolute_first_time

#!/bin/bash

# Import common variables
source $MY_DEV_SCRIPTS/common_paths.sh
source $MY_DEV_SCRIPTS/common_functions.sh
source $MY_DEV_SCRIPTS/common_aliases.sh
source $MY_DEV_SCRIPTS/common_variables.sh
source $MY_DEV_SCRIPTS/git_aliases.sh

if [ ! -f $MY_DEV_SCRIPTS/set_environment.sh ]; then
    SwitchOver sandbox
fi

source $MY_DEV_SCRIPTS/set_environment.sh
source $MY_DEV_SCRIPTS/project_scripts.sh

if [ "$OSTYPE" == "cygwin" ]; then
    # This plays havoc with the %CD% varaiable when invoking cmd.exe
    unset CD
fi

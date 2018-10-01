#!/bin/bash

if [ -f $MY_DEV_SCRIPTS/.projects/$PROJECT.sh ]; then
    source $MY_DEV_SCRIPTS/.projects/$PROJECT.sh
fi

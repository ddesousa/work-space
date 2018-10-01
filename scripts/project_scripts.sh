#!/bin/bash

PROJECT_SCRIPT=

case $PROJECT in
    lumerical-products)
        PROJECT_SCRIPT=lumerical-products.sh
        ;;
esac

if [ -f $MY_DEV_SCRIPTS/.projects/$PROJECT_SCRIPT ]; then
    source $MY_DEV_SCRIPTS/.projects/$PROJECT_SCRIPT
fi

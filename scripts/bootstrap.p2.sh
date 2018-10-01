#/bin/bash

d2u $1
source $1

export OPTIONS="--wait --no-shortcuts --no-startmenu --quiet-mode"
export LOCAL_INSTALL="--local-install --local-package-dir $PACKAGES_FOLDER"
export ROOT="--root $CYGWIN_FOLDER"
export PACKAGES=`cat $PACKAGES_TXT`
export PACKAGES_OPTIONS="--packages $PACKAGES"

$SETUP_X86 $OPTIONS $LOCAL_INSTALL $ROOT $PACKAGES_OPTIONS

cp /tmp/create_workspace.sh $HOME

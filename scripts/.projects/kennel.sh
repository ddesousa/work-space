export PROJECT_PATH=$MY_DEV_PROJECTS/$PROJECT
export FRAMEWORK_VERSION=`cat $PROJECT_PATH/masterconfig.xml | /usr/bin/grep "<package name=\"Framework\" version=\"[.=0-9]*\"" | cut -d"=" -f3 | tr -d "\"" | tr -d "\/" | tr -d ">"`

if [ -d /cygdrive/d/packages/Framework/$FRAMEWORK_VERSION ]; then
    echo "Setting Framework version to $FRAMEWORK_VERSION"
    export PATH=$PATH:/cygdrive/d/packages/Framework/$FRAMEWORK_VERSION/bin
fi


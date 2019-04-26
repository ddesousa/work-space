#!/bin/bash

function GetParentBranch()
{
    git show-branch | ack '\*' | ack -v \"$branch\" | head -n10 | tail -n1 |sed 's/.*\[\(.*\)\].*/\1/' | sed 's/[\^~].*//'
}
function ReadProjectFile()
{
    RETVAL=1
    WORKSPACE=$MY_DEV_WORKSPACE
    if [ ! "${@: -1}" == "$MY_DEV_WORKSPACE" ]; then
        WORKSPACE=${@: -1}
    fi
    exec 10<&0
    exec < $WORKSPACE/projects/.projects
    while read LINE; do
        PROJECT=`echo $LINE | cut -d ',' -f1`
        if [ "$PROJECT" == "" ]; then
            PROJECT="<empty>"
        fi
        PROJECT_SCRIPT=`echo $LINE | cut -d ',' -f2`
        if [ "$PROJECT_SCRIPT" == "" ]; then
            PROJECT_SCRIPT="<empty>"
        fi
        REPO_LOC=`echo $LINE | cut -d ',' -f3`
        if [ "$REPO_LOC" == "" ]; then
            REPO_LOC="<empty>"
        fi
        $1 $2 $PROJECT $PROJECT_SCRIPT $REPO_LOC $WORKSPACE
        if [ $? == 0 ]; then
            RETVAL=0
        fi
    done
    exec 0<&10 10<&-

    return $RETVAL
}
function ListProjectDetails()
{
    PROJECT_TO_LIST=$1
    PROJECT=$2
    PROJECT_SCRIPT=$3
    PROJECT_LOC=$4
    if [ "$PROJECT_TO_LIST" == "$PROJECT" ]; then
        echo "Project Details"
        echo "---------------"
        echo "PROJECT: $PROJECT"
        echo "PROJECT SCRIPT: $PROJECT_SCRIPT"
        echo "PROJECT LOC: $PROJECT_LOC"
    fi
}
function ListProject()
{
    WORKSPACE=$MY_DEV_WORKSPACE
    if [ ! "$2" == "" ]; then
        WORKSPACE=$2
    fi
    COMPONENT_TO_LIST=$1
    ReadProjectFile ListProjectDetails $COMPONENT_TO_LIST $WORKSPACE
}
function ListProjectNames()
{
    PROJECT=$2
    echo $PROJECT
}
function ListAllProjectNames()
{
    WORKSPACE=$MY_DEV_WORKSPACE
    if [ ! "$1" == "" ]; then
        WORKSPACE=$1
    fi
    ReadProjectFile ListProjectNames "<empty>" $WORKSPACE
}
function Checkout()
{
    PROJECT_TO_CHECKOUT=$1
    PROJECT=$2
    REPO_LOC=$4
    WORKSPACE=$5
    if [ "$PROJECT_TO_CHECKOUT" == "$PROJECT" ]; then
        if [ ! -e $WORKSPACE/projects/$PROJECT_TO_CHECKOUT ]; then
            local REPO=`eval echo $REPO_LOC`
            git clone $REPO $WORKSPACE/projects/$PROJECT_TO_CHECKOUT
        else
            echo "Error: $PROJECT already checked-out"
            return 1
        fi
    else
        return 1
    fi
}
function CheckoutProject()
{
    WORKSPACE=$MY_DEV_WORKSPACE
    if [ ! "$2" == "" ]; then
        WORKSPACE=$2
    fi
    COMPONENT_TO_CHECKOUT=$1
    ReadProjectFile Checkout $COMPONENT_TO_CHECKOUT $WORKSPACE
    if [ $? == 1 ]; then
        echo "Error: Failed to checkout project."
    fi
}
function GetDotCount()
{
    local LenWithDots=`echo $1 | wc -m`
    local LenWithoutDots=`echo $1 | tr --delete . | wc -m`
    echo $(($LenWithDots - $LenWithoutDots))
}
function GetSuffix()
{
    local FieldToGet=$(($(GetDotCount $1) + 1))
    echo `echo $1 | cut -d '.' -f$FieldToGet`
}
function up 
{
    [ $(( $1 + 0 )) -gt 0 ] && cd $(eval "printf '../'%.0s {1..$1}"); 
}
function SwitchOver()
{
    WORKSPACE=$MY_DEV_WORKSPACE
    PROJECT_TO_SWITCH=$1
    if [ ! "$2" == "" ]; then
        WORKSPACE=$2
    fi
    ReadProjectFile CreateEnvironment $PROJECT_TO_SWITCH $WORKSPACE
}
function CreateEnvironment()
{
    PROJECT_TO_SWITCH=$1
    PROJECT=$2
    WORKSPACE=$5
    if [ "$PROJECT_TO_SWITCH" == "$PROJECT" ]; then
        if [ -e $MY_DEV_PROJECTS/$PROJECT_TO_SWITCH ]; then
            PROJECT_SCRIPT=$3
            REPO_LOC=$4
            echo "#!/bin/bash" > $WORKSPACE/scripts/set_environment.sh
            echo "export PROJECT=$PROJECT" >>  $WORKSPACE/scripts/set_environment.sh
            echo "echo Loading $PROJECT" >> $WORKSPACE/scripts/set_environment.sh
            if [ ! "$PROJECT_SCRIPT" == "" ]; then
                if [ -f $MY_DEV_PROJECTS/$PROJECT/$PROJECT_SCRIPT ]; then
                    echo "source $MY_DEV_PROJECTS/$PROJECT/$PROJECT_SCRIPT" >> $WORKSPACE/scripts/set_environment.sh
                fi
            fi
            ResetProject
        else
            echo "Error: Project is not in the workspace. Checkout project first."
            return 1
        fi
    fi
}
function ResetProject()
{
    cygstart /bin/mintty -;exit
}
function Gvim()
{
    if [ "$OSTYPE" == "cygwin" ]; then
        local VIM_PROFILE=`cygpath -w $MY_DEV_WORKSPACE/config/vim/profiles/_vimrc.$USER`
    else
        local VIM_PROFILE=$MY_DEV_WORKSPACE/config/vim/profiles/_vimrc.$USER
    fi
    if [ ! "$DEV_EDITOR" == "" ]; then
        VIM_PROFILE_WITH_SLASHES=$(echo $VIM_PROFILE | sed -e 's/\\/\\\\/g')
        local CMD=$DEV_EDITOR
        if [ "$OSTYPE" == "cygwin" ]; then
            while [ -n "$1" ]; do
                case "$1" in
                    [+-]*) ARG=$1;;
                    *) ARG=\"`cygpath -w "$1"`\";;
                esac
                CMD="$CMD $ARG";
                shift;
            done
        else
            CMD="$CMD $1"
        fi
        eval "$CMD -u $VIM_PROFILE_WITH_SLASHES" & 2>/dev/null
    else
        echo "Error: You must set DEV_EDITOR to the path of your environment."
    fi
}
function Xxd()
{
    local CMD="/cygdrive/c/Program\ Files\ \(x86\)/Vim/vim74/xxd.exe"
    if [ "$OSTYPE" == "cygwin" ]; then
        while [ -n "$1" ]; do
            case "$1" in
                [+-]*) ARG=$1;;
                *) ARG=\"`cygpath -w "$1"`\";;
            esac
            CMD="$CMD $ARG";
            shift;
        done
    else
        CMD="$CMD $1"
    fi
    eval "$CMD" & 2>/dev/null
}
function Python()
{
    if [ ! "$PYTHON_FOLDER" == "" ]; then
        local CMD
        if [ ! "$OSTYPE" == "cygwin" ]; then
            CMD=$PYTHON_FOLDER/python.exe
        else
            CMD=$PYTHON_FOLDER/python.exe
        fi
        while [ -n "$1" ]; do
            if [[ "$1" =~ ^/* ]]; then
                ARG=$1
            else
                ARG=\"`cygpath -w "$1"`\"
            fi
            CMD="$CMD $ARG";
            shift;
        done
        eval "${CMD}"
    else
        echo "Error: You must set PYTHON_FOLDER to the path of your environment."
    fi
}
function Msbuild()
{
    if [ ! "$MSBUILD_FOLDER" == "" ]; then
        local CMD=$MSBUILD_FOLDER/12.0/Bin/MSBuild.exe
        while [ -n "$1" ]; do
            if [[ "$1" =~ ^/* ]]; then
                ARG=$1
            else
                ARG=\"`cygpath -w "$1"`\"
            fi
            CMD="$CMD $ARG";
            shift;
        done
        eval "${CMD}"
    else
        echo "Error: You must set MSBUILD_FOLDER to the path of your environment."
    fi
}
function DevEnv()
{
    if [ ! "$VS2008_FOLDER" == "" ]; then
        local CMD="${VS2008_FOLDER}/Common7/IDE/devenv.exe"
        while [ -n "$1" ]; do
            if [[ "$1" =~ ^/* ]]; then
                ARG=$1
            else
                ARG=\"`cygpath -w "$1"`\"
            fi
            CMD="$CMD $ARG";
            shift;
        done
        eval "${CMD}"
    else
        echo "Error: You must set VS2008_FOLDER to the path of your environment."
    fi
}
function CloneRepo()
{
    if [ "$1" == "" ]; then
        echo "Error: requires project parameter name"
    fi

    git clone git@git.lcs.local:$1
}
function FindDerivedClasses()
{
    egrep -R --include=*.h "[ :]*public[ ]*$1" . | cut  -d: -f2 | sort | uniq
}
function DisplayHelp()
{
    echo "This is the first time that this work environment has been loaded."
    echo
    echo "Available Commands: "
    echo 
    echo " TODO: "
    echo "  lsproj: List all of the projects in the .project file."
    echo "  lsprojinfo <project name> : List the project details which are the details in the .project file."
    echo "  checkout <project name>: Checkouts the project into the Projects directory."
    echo "  swproj <project name>: Switches the environment."
    echo "  reproj: Restarts the environment."
    echo
}

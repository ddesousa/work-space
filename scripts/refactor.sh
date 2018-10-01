#!/bin/bash

function contains_element()
{
  local e
  for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
  return 1
}
function find_all_references()
{
    local SRC_DIR=$1
    local COMPONENT=$2
    local REF_STORE=$LUMERICAL_PRODUCTS/.ReferenceStore

    for F in `find $SRC_DIR/$COMPONENT -iname *.h -type f -printf "%f\n"`; do
        find_reference $SRC_DIR $COMPONENT $F
    done
}
function find_reference()
{
    local SRC_DIR=$1
    local COMPONENT=$2
    local HDR=$3
    local REF_STORE=$LUMERICAL_PRODUCTS/.ReferenceStore
    local COMPONENT_REF_STORE=$REF_STORE/$SRC_DIR/$COMPONENT

    if [ "$#" -ne 3 ]; then 
        echo "Error: Illegal number of parameters"
        echo "Parameters:"
        echo "      <search dir>    this is the folder to search in"
        echo "      <component>     the component from which the header resides in"
        echo "      <header>        the header to look for"
        return 10
    fi

    if [ ! -d $COMPONENT_REF_STORE ]; then mkdir -p $COMPONENT_REF_STORE; fi
    ## If there's a copy there already then delete it first
    if [ -f $COMPONENT_REF_STORE/$HDR.ref ]; then rm $COMPONENT_REF_STORE/$HDR.ref; fi

    ## Find all references to $HDR
    grep -R -i --color=auto --include=*.{h,cpp} "#include[ \"<]*$HDR[ \">]*" $SRC_DIR | cut -d':' -f1 > $COMPONENT_REF_STORE/$HDR.ref

    local LINE_COUNT=`wc -l $COMPONENT_REF_STORE/$HDR.ref | cut -d' ' -f1`
    if [ $LINE_COUNT -eq 0 ];then 
        echo "Did not find any references"
        rm $COMPONENT_REF_STORE/$HDR.ref
    else
        echo "Identified `wc -l $COMPONENT_REF_STORE/$HDR.ref`"
    fi
}
function gen_dot()
{
    local REF_FILE=$1
    local REF_STORE=$2
    local HDR_COMPONENT=`echo $REF_FILE | cut -d'.' -f1`

    if [ "$#" -ne 2 ]; then echo "Illegal number of parameters"; return 10; fi

    echo "digraph {" > $REF_STORE/$REF_FILE.dot

    local KNOWN_COMPONENTS

    while read LINE
    do
        local DIR_NAME=`dirname $LINE`
        local COMPONENT_NAME=`basename $DIR_NAME`

        contains_element $COMPONENT_NAME $KNOWN_COMPONENTS

        if [ "$?" -ne 0 ]; then
            echo $COMPONENT_NAME -\> $HDR_COMPONENT >> $REF_STORE/$REF_FILE.dot
            KNOWN_COMPONENTS="$KNOWN_COMPONENTS $COMPONENT_NAME"
        fi

    done < $REF_FILE

    echo "}" >> $REF_STORE/$REF_FILE.dot
}
function rename_hdr()
{
    local REF_FILE=`basename $1`
    local NEW_COMPONENT=`echo $2 | tr '[:upper:]' '[:lower:]'`
    local HDR_FILE=`echo $REF_FILE | cut -d'.' -f1`

    local ALL=0
    while read LINE
    do
        local NEW_HDR_PATH=$(echo $NEW_COMPONENT/$HDR_FILE.h | sed -e 's/\//\\\//g')

        sed "s/\#include[ <\"]*$HDR_FILE.h[ >\"]*/#include \"$NEW_HDR_PATH\"/I" $LINE > $LINE.new

        echo "********************************************************************"
        echo "Renaming $LINE..."

        if [ $ALL -eq 0 ]; then
            diff $LINE.new $LINE

            echo "Do you wish to make the change?"
            select yn in "Yes" "No" "All"; do
                case $yn in
                    Yes ) mv $LINE.new $LINE; break;;
                    No  ) rm $LINE.new;break;;
                    All ) ALL=1; break;;
                esac
            done <&4
        fi
    done 4<&0 <$1
}
function count_components()
{
    local COMPONENT_PATH=$1

    local COUNT=${COMPONENT_PATH//[^\/]}

    echo ${#COUNT}
}
function available_subsystems()
{
    echo "shared-components/api fdtd-solutions mode-solutions spirit system"
}
function move_and_rename_hdr()
{
    if [ "$?" -ne 0 ]; then
        echo "Unrecognized subsystem"
        return 10
    fi

    if [ "$#" -ne 3 ]; then 
        echo "Error: Illegal number of parameters"
        echo "Parameters:"
        echo "      <reference store> path to reference store"
        echo "      <source>          source from where the move will happen from (type available_subsystems for a listing)"
        echo "      <destination>     destination to where the move will conclude"
        return 10
    fi

    contains_element $2 $(available_subsystems)

    local REF_STORE=$1
    local SUBSYSTEM=$2
    local DST_COMPONENT=`dirname $3`
    local DST_SUBCOMPONENT=$3
    local DST_COMPONENT_PATH=$MY_DEV_PROJECTS/$PROJECT/$BRANCH/$SUBSYSTEM/$DST_COMPONENT
    local SUBSYSTEM_PATH=$MY_DEV_PROJECTS/$PROJECT/$BRANCH/$SUBSYSTEM

    ## Create the directory
    if [ ! -d $DST_COMPONENT_PATH ]; then
        mkdir -p $DST_COMPONENT_PATH/include/$DST_SUBCOMPONENT
        mkdir -p $DST_COMPONENT_PATH/src/product/$DST_SUBCOMPONENT
    fi

    ## Copy the files
    if [ -d $REF_STORE ]; then
        for F in `ls -1 $REF_STORE`; do
            SRC_COMPONENT=`echo $F | cut -d'.' -f1`
            SRC_HDR_FILE=`echo $F | cut -d'.' -f2`.h
            SRC_CPP_FILE=`echo $F | cut -d'.' -f2`.cpp
            if [ -f $SUBSYSTEM_PATH/$SRC_COMPONENT/$SRC_HDR_FILE ]; then
                mv $SUBSYSTEM_PATH/$SRC_COMPONENT/$SRC_HDR_FILE $DST_COMPONENT_PATH/include/$DST_SUBCOMPONENT
            else
                echo "Error: Missing $SUBSYSTEM/$SRC_COMPONENT/$SRC_HDR_FILE"
            fi
            if [ -f $SUBSYSTEM_PATH/$SRC_COMPONENT/$SRC_CPP_FILE ]; then
                mv $SUBSYSTEM_PATH/$SRC_COMPONENT/$SRC_CPP_FILE $DST_COMPONENT_PATH/src/product/$DST_SUBCOMPONENT
            fi
        done
    else
        echo "Error: no ref store is available."
    fi
    ## Search and replace
}

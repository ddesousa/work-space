#!/bin/bash

export CTP_ROOT=`cygpath -w $MY_DEV_PROJECTS/CommonThirdParty | tr '\\\' '/'`
export COMMON_DIR=$MY_DEV_PROJECTS/CommonThirdParty/Components/Common

alias ctp='cd $MY_DEV_PROJECTS/CommonThirdParty'
alias ctpcommon='cd $MY_DEV_PROJECTS/CommonThirdParty/Components/Common'
alias ctppoco='cd $MY_DEV_PROJECTS/CommonThirdParty/ThirdParty/Poco'
alias ctpopenssl='cd $MY_DEV_PROJECTS/CommonThirdParty/ThirdParty/OpenSSL'
alias targetcommon='ctpcommon;cd target'
alias cpcommonlibr='if ! [ -d $COMMON_DIR/lib/Release ]; then mkdir $COMMON_DIR/lib/Release; fi; cp $COMMON_DIR/target/Windows/product/Release/libs/Release/Common.lib $COMMON_DIR/lib/Release/Common.lib'
alias cpcommonlibd='if ! [ -d $COMMON_DIR/lib/Debug ]; then mkdir $COMMON_DIR/lib/Debug; fi; cp $COMMON_DIR/target/Windows/product/Debug/libs/Debug/Common.lib $COMMON_DIR/lib/Debug/Common.lib'
alias gencommon='ctpcommon; if ! [ -d target ]; then mkdir target; fi; cd target; cmake -D"ABS_CTP_ROOT:STRING=$CTP_ROOT" -G "Visual Studio 12 2013" ..'
alias buildcommonr='targetcommon; gencommon; msbuild Common.vcxproj /p:Configuration=Release /t:Build; cpcommonlibr'
alias cleancommonr='targetcommon; gencommon; msbuild Common.vcxproj /p:Configuration=Release /t:Clean'
alias buildcommond='targetcommon; gencommon; msbuild Common.sln /p:Configuration=Debug /t:Build; cpcommonlibd'
alias cleancommond='targetcommon; gencommon; msbuild Common.sln /p:Configuration=Debug /t:Clean'
alias startcommonvs='targetcommon; start Common.sln'

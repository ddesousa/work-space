#!/bin/bash

# directory navigation primitives
alias +='pushd'
alias _='popd'
alias work='cd $MY_DEV_WORKSPACE'
alias project='cd $MY_DEV_PROJECTS/$PROJECT'
alias projects='cd $MY_DEV_PROJECTS'
alias scripts='cd $MY_DEV_SCRIPTS'
alias sandbox='cd $MY_DEV_PROJECTS/Sandbox'
alias current='echo $PROJECT'
alias swproj='SwitchOver'
alias reproj='ResetProject'
alias proj='python proj.py'
alias tree="ls -R | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'"
alias grep='grep --color=always'
if [ "$OSTYPE" == "cygwin" ]; then
    alias gvim='Gvim'
    alias cmake='/cygdrive/c/Program\ Files/CMake/bin/cmake.exe'
    alias cpack='/cygdrive/c/Program\ Files/CMake/bin/cpack.exe'
    alias start='cygstart'

fi
alias xxd='Xxd'
alias lsprojs='ListAllProjectNames'
alias lsprojinfo='ListProject'
alias checkout='CheckoutProject'
alias find_derived='FindDerivedClasses'
alias cloc='cloc-1.80'
alias lsrepo='ssh git@git.lcs.local'
alias clonerepo='CloneRepo'
alias build='cmd /c "build.bat build"'
alias clean='cmd /c "build.bat clean"'
alias buildd='cmd /c "build.bat build_debug"'
alias rebuild='cmd /c "build.bat rebuild"'
alias buildt='cmd /c "build.bat build $1"'
alias rebuildt='cmd /c "build.bat rebuild $1"'
alias dos='start cmd /c "$1"'
alias dosk='start cmd /k "$1"'
alias gvim=Gvim

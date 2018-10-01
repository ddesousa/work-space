#!/bin/bash

echo "Loading lumerical-products environment"

export LUMERICAL_PRODUCTS=$MY_DEV_PROJECTS/lumerical-products/$BRANCH
export SHARED_COMPONENTS=$LUMERICAL_PRODUCTS/shared-components
export INTEROPAPI_OUT_PATH=$SHARED_COMPONENTS/applications/interopapi/debug-gcc/x64
export LD_LIBRARY_PATH=/usr/local/mpich2/nemesis/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$LUMERICAL_PRODUCTS/debug/x64:$LD_LIBRARY_PATH

alias fdtd='cd $LUMERICAL_PRODUCTS/fdtd-solutions'
alias spirit='cd $LUMERICAL_PRODUCTS/spirit'
alias icc='cd $LUMERICAL_PRODUCTS/system'
alias mode='cd $LUMERICAL_PRODUCTS/mode-solutions'
alias shared='cd $LUMERICAL_PRODUCTS/shared-components'
alias messaging='cd $LUMERICAL_PRODUCTS/shared-components/api/messaging'
alias interop='cd $LUMERICAL_PRODUCTS/shared-components/applications/interop'
alias verilog='cd $LUMERICAL_PRODUCTS/system/verilog-api'
alias layoutwindow='cd $SHARED_COMPONENTS/api/layoutwindow'

export PATH=$LUMERICAL_PRODUCTS/debug/x64:$PATH

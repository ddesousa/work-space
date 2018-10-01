#!/bin/bash

alias git-parent='GetParentBranch'
alias git-delta='git log origin/$1 ^$1'
alias git-conflicts='git diff --name-only --diff-filter=U'
alias git-merge-dry='git merge --no-commit --no-ff $1'
alias git-help='alias | grep git-'

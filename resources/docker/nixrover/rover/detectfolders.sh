#!/bin/bash

###
# this script compares current branch to main and generaets a json  of all the
# folders that contain file updates so builds can be selectively run
###

# set defaults
BASEREF='main'
CICD='gha'
curref=$(git branch --show-current)
DEPTH=1
INITPATH=$(pwd)
homedir=$INITPATH
JSONMATRIX="{\"folder\":["
changesfound='false'
#PROJECT=$(basename -s .git `git config --get remote.origin.url 2>/dev/null` 2>/dev/null)

while getopts "b:c:d:p:" arg; do
  case $arg in
    b) BASEREF=${OPTARG};;
    c) CICD=${OPTARG};;
    d) DEPTH=${OPTARG};;
    p) INITPATH=${OPTARG};;
  esac
done

###
# get changes when compared to target branch
###
if [[ $curref == $BASEREF ]]; then
  gitchanges=$(git diff --name-only HEAD^ HEAD 2>/dev/null)
else
  gitchanges=$(git diff --name-only origin/$BASEREF 2>/dev/null)
fi

###
# get folder list and compare to HEAD
###
cd $INITPATH
searchdepth=$(for ((c=1; c<=$DEPTH; c++)); do echo -n '*/'; done)
for dir in $searchdepth; do
  echo "checking folder ${dir%/} ..."
  if [[ $gitchanges == *"$dir"* ]]; then
    changesfound='true'
    path_full=${dir%/}
    path_curr=${path_full##*/}
    JSONMATRIX=$JSONMATRIX"\"$path_full\","
  fi
done
if [[ $changesfound == 'true' ]]; then
  JSONMATRIX="${JSONMATRIX::-1}]}"
else
  JSONMATRIX="$JSONMATRIX]}"
fi
cd $homedir

###
# echo the constructed json for pipeline
###
echo "final value: $JSONMATRIX"
case $CICD in
  "azdo") echo "##vso[task.setvariable variable=matrix;isOutput=true]$JSONMATRIX" && echo "##vso[task.setvariable variable=matrix;]$JSONMATRIX";;
  "gha") echo ::set-output name=matrix::$JSONMATRIX;;
  *) echo "CICD pipeline '$CICD' is not recognized, nothing set";;
esac

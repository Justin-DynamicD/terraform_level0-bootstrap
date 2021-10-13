#!/bin/bash

source /rover/banner.sh

# set defaults
CLOUD='azure'
TFPATH=$(pwd)
HOMEDIR=$TFPATH
ENVNAME='sandpit'
PROJECT=$(basename -s .git `git config --get remote.origin.url 2>/dev/null` 2>/dev/null)
STATEBUCKET=''
STATETABLE=''
TAG='tfstate'
UPGRADE='false'

###
# look for defaults from .roverconfig file
###

# accend directory looking for .roverconfig file
count=$(echo "$HOMEDIR" | tr -cd '/' | wc -c)
for ((n=1; n < (count+1); n++)); do 
  if (ls .roverconfig 1>/dev/null 2>/dev/null); then 
    roverconfig=$(pwd)/.roverconfig
    break
  fi
  cd ..
done
cd $HOMEDIR

# apply user defaults
echo "loading global defaults from ~/.roverconfig"
if [[ -f ~/.roverconfig ]]; then
  source ~/.roverconfig
else
  touch ~/.roverconfig
fi
# apply any discovered configs in path or parent
if [ $roverconfig ]; then
  echo "updating vars from $roverconfig"
  source $roverconfig
fi

###
# load user-defined args and override where needed
###

while getopts ":c:e:f:ip:t:u" arg; do
  case $arg in
    c) CLOUD=${OPTARG};;
    e) ENVNAME=${OPTARG};;
    f) TFPATH=${OPTARG};;
    i) INIT=true;;
    p) PROJECT=${OPTARG};;
    t) TAG=${OPTARG};;
    u) UPGRADE=true;;
  esac
done

###
# generate state filename
# uses the basename of git if found, then reverse-adds folder path
# cleanup path then count folder levels
###

# TODO: need some kind of error correction here if a bad path is given
cd $TFPATH

# count how many parent folders exist
trimmedpath=$(pwd)
count=$(echo "$trimmedpath" | tr -cd '/' | wc -c)

# crawl up folder path looking for .git folder
# return $home when search is complete
for ((n=1; n < (count+1); n++)); do 
  if (ls -d .git 1>/dev/null 2>/dev/null); then 
    reporoot=$(pwd)
    break
  fi
  cd ..
done
cd $HOMEDIR

# use discovered reporoot to build final folder list
# by trimming out excess folders
if [ $reporoot ]; then
  trimlength=$(echo $reporoot | wc -c)
  WDFIXED=/${trimmedpath:$trimlength}
else
  WDFIXED=$trimmedpath
fi

# finally parse the reduced paths to build a filename
count=$(echo "$WDFIXED" | tr -cd '/' | wc -c)
for ((n=1; n < (count+1); n++)); do 
  if [[ $PROJECT == '' ]]; then
    PROJECT=$(echo $WDFIXED | rev | cut -d/ -f$n | rev)
  else
    PATHDETAILS+=-$(echo $WDFIXED | rev | cut -d/ -f$n | rev)
  fi
done
STATEFILE=$PROJECT$PATHDETAILS.tfstate

###
# backend is cloud specific, jump into approipriate section to generate
# the backend configs for use
###

case $CLOUD in
  "azure") source /rover/azure.sh;;
  "aws") source /rover/aws.sh;;
  *) echo "cloud provider '$CLOUD' is not recognized, exiting." && exit;;
esac

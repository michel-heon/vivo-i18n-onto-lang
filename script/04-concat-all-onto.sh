#!/bin/bash 

###################################################################
# Script Name   :
# Description   :
# Args          : 
# Author        : Michel Héon PhD
# Institution   : Université du Québec à Montréal
# Copyright     : Université du Québec à Montréal (c) 2022
# Email         : heon.michel@uqam.ca
###################################################################
export SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd -P)"
source $SCRIPT_DIR/../00-env.sh
cd $ONTO_DATA
find . -name "*.nt" -exec cat {}  \; > $DATA/all.nt
echo "Done creation of $DATA/all.nt" 
$LIB/func_nt2ttl.sh < $DATA/all.nt > $DATA/all.ttl
echo "Done creation of $DATA/all.ttl" 
echo "Done !" 


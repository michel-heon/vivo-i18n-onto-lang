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
find . -name "*.n3" -exec cat {}  \; > $DATA/all.n3
echo "Done creation of $DATA/all.n3"
$LIB/func_nt2ttl.sh < $DATA/all.n3 > $DATA/all.ttl
echo "Done creation of $DATA/all.ttl"
echo "Done !"


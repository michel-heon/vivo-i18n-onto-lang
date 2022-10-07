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
export LOC_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd -P)"
source $LOC_SCRIPT_DIR/../00-env.sh
NBR_FILE=$(ls -al $PROPERTIES_DATA/*| wc -l) 
for file in $PROPERTIES_DATA/*-langu*
do
    ((LOOP_CTR=LOOP_CTR+1))
    func_prop2rdf.sh  $file &
    echo "################ ($LOOP_CTR/$NBR_FILE)  $(basename $file)"  
    ((j=j+1))
    if [ $j = "20" ]
    then
        wait; ((j=0)) ;  echo "################ New cycle"
    else
        sleep .5
    fi
done


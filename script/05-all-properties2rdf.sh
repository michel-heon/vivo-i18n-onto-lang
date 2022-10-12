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
for file in $PROPERTIES_DATA/*
#VIVO-languages,ru_RU,webapp,src,main,webapp,i18n,vivo_all_ru_RU*
#VIVO-languages,en_CA,webapp,src,main,webapp,i18n,vivo_all_en_CA*
#VIVO-languages,en_CA,webapp,src,main,webapp,themes,wilma,i18n,all_en_CA*
#VIVO,webapp,src,main,webapp,themes,nemo,i18n,all*
do
    ((LOOP_CTR=LOOP_CTR+1))
    (echo "start for $file ";func_prop2rdf.sh  $file ; echo "done $file" ) &
    echo "################ ($LOOP_CTR/$NBR_FILE)  $(basename $file)"  
    ((j=j+1))
    if [ $j = "17" ]
    then
        sleep 1; echo "Waiting end of tasks" ; wait; ((j=0)) ;  echo "################ New cycle"
    else
        sleep .5
    fi
done
wait
echo "These files are deleted since they are empty"
find $PROPERTIES_ONTO_DATA -type f -empty -print -delete
echo "DONE !"

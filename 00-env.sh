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
export ROOT_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd -P)"
export GIT_HOME=$(cd $ROOT_SCRIPT_DIR/../../ ; pwd -P)
export PATH=$PATH:$ROOT_SCRIPT_DIR/script
source $ROOT_SCRIPT_DIR/script/cleanup.sh
source ~/VIVO_UQAM_PRE_PROD/translator/00-env.sh ~/VIVO_UQAM_PRE_PROD/translator
export DATA=$ROOT_SCRIPT_DIR/data
export PROPERTIES_DATA=$ROOT_SCRIPT_DIR/data/properties
export ONTO_DATA=$ROOT_SCRIPT_DIR/data/ontologies
export LANG=C.UTF-8
export BASE_IRI="http://vivoweb.org/ontology/core/properties"
export LIST_OF_KEYS_FN=$ROOT_SCRIPT_DIR/data/ListOfKeys.txt
export LIST_OF_PROPERTIES_FN=$ROOT_SCRIPT_DIR/data/ListOfPropFn.txt
export LIST_OF_ftl_FN=$ROOT_SCRIPT_DIR/data/ListOfFtlFn.txt


PRODUCTS_LIST=( \
VIVO \
VIVO-languages \
Vitro \
Vitro-languages \
vitro-languages-uqam \
vivo-languages-uqam \
vivo-uqam \
 )



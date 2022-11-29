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
export GIT_HOME=$(cd $ROOT_SCRIPT_DIR/../ ; pwd -P)
export TRANSLATOR_HOME=~/translator
source $TRANSLATOR_HOME/00-env.sh 2>/dev/null # clone and install
# git@bitbucket.org:vivo-workspace/data-format-translator.git for jena-sparql access
export LANG=C.UTF-8
export PATH=$PATH:$ROOT_SCRIPT_DIR/script
export BATCH_DIR=$ROOT_SCRIPT_DIR/script
export LIB=$BATCH_DIR/lib
export DATA=$ROOT_SCRIPT_DIR/data
export SPARQL_HEADER=$BATCH_DIR/sparql/header.sparql
export PROPERTIES_DATA=$ROOT_SCRIPT_DIR/data/properties
export PROPERTIES_ONTO_DATA=$ROOT_SCRIPT_DIR/data/properties_onto
export ONTO_DATA=$ROOT_SCRIPT_DIR/data/ontologies
export ONTO_DATA_TTL=$ROOT_SCRIPT_DIR/data/ontologies_ttl
export SEMANTIC_BASE_IRI="http://vivoweb.org/ontology/core/properties/vocabulary"
export BASE_IRI="http://vivoweb.org/ontology/core/properties/individual"
export PATH=$ROOT_SCRIPT_DIR:$LIB:$PATH:./

###################################################################
# Documents/Working directories
export LIST_OF_KEYS_FN=$ROOT_SCRIPT_DIR/data/ListOfKeys.txt
export LIST_OF_PROPERTIES_FN=$ROOT_SCRIPT_DIR/data/ListOfPropFn.txt
export LIST_OF_ftl_FN=$ROOT_SCRIPT_DIR/data/ListOfFtlFn.txt
###################################################################
# Directory containing the transformation target
export TARGET_HOME=$ROOT_SCRIPT_DIR/target
export UI_LABELS_VOCAB="$TARGET_HOME/Vitro/home/src/main/resources/rdf/tbox/firsttime/UiLabelsVocabulary.n3"
export UI_LABELS_VOCAB_TTL=$(echo $UI_LABELS_VOCAB | sed 's/n3/ttl/g')

###################################################################
# generic for VIVO
export PRODUCTS_LIST=( \
        VIVO-languages \
        Vitro-languages \
    )
#VIVO \
    #Vitro \

    ###################################################################
# specific for VIVO overlay by UQAM packages
#export PRODUCTS_LIST=( VIVO VIVO-languages Vitro Vitro-languages vitro-languages-uqam vivo-languages-uqam vivo-uqam )


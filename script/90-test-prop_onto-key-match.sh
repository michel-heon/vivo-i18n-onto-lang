#!/bin/bash

###################################################################
# Script Name   :
# Description   : This script is useful to validate the accuracy of the correspondence between
#     the key-values of the original property files and the key-values of the generated ontological individuals
# Args          : no-args
# Author        : Michel Héon PhD
# Institution   : Université du Québec à Montréal
# Copyright     : Université du Québec à Montréal (c) 2022
# Email         : heon.michel@uqam.ca
###################################################################
export TEST_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd -P)"
cd $TEST_SCRIPT_DIR
source ../00-env.sh
source $LIB/func_cleanup.sh
export LANG_LIST=( $(cd $GIT_HOME/VIVO-languages ; ls -d */ | grep '_' | tr -d '/') )
export KEYS_QUERY=$TMPDIR/getKeys.sparql
function build_list_keys_query () {
    cat << EOF > $KEYS_QUERY
    prefix rdfs:  <http://www.w3.org/2000/01/rdf-schema#>
    prefix obo:   <http://purl.obolibrary.org/obo/>
    prefix skos:  <http://www.w3.org/2004/02/skos/core#>
    prefix vivo:  <http://vivoweb.org/ontology/core#>
    prefix rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
    prefix rdp: <http://uqam.ca/data/rdp#>
    prefix owl:   <http://www.w3.org/2002/07/owl#>
    prefix prop: <http://vivoweb.org/ontology/core/properties/vocabulary#>
    select distinct ?key
    WHERE {
        ?s prop:hasKey  ?key .
        FILTER EXISTS {
            ?s rdfs:label ?label .
    }

    }
EOF
}

function match_prop_to_onto () {
    #    cd $TARGET_HOME/$A_PRODUCT ; find . -name "*.ttl" | grep fr_CA
    #    find . -name '*.properties' | grep -v target > $TMPDIR/f2.txt
    #    cat $TMPDIR/f2.txt $TMPDIR/f1.txt | sort | uniq -c
    REGION=$(echo $A_PROPERTY | cut -f 2 -d '/')
    THEME=$(echo $A_PROPERTY | grep theme | sed  's/.*themes\///g' | cut -f 1 -d '/')
    if [ -n "${THEME}" ]; then
        UI_ONTO_FN=${APP}_UiLabel_${REGION}_${THEME}.ttl
    else
        UI_ONTO_FN=${APP}_UiLabel_${REGION}.ttl
    fi
    MATCH_ONTO=$(cd $TARGET_HOME/$A_PRODUCT ; find . -name "*$UI_ONTO_FN" )
    compare_prop_and_onto
}

function compare_prop_and_onto () {
    export KEY_LIST_ONTO=$TMPDIR/$(basename $MATCH_ONTO .ttl).txt
    export KEY_LIST_PROP=$TMPDIR/$(basename $A_PROPERTY .properties).txt

    # echo "compare"
    # echo " $TARGET_HOME/$A_PRODUCT/$MATCH_ONTO"
    # echo " $GIT_HOME/$A_PRODUCT/$A_PROPERTY"
    sparql --results=TSV --query=$KEYS_QUERY --data=$TARGET_HOME/$A_PRODUCT/$MATCH_ONTO | tail -n +2 | sort | tr -d '"'> $KEY_LIST_ONTO
    java $TEST_SCRIPT_DIR/ParseAndCleanProperties.java < $GIT_HOME/$A_PRODUCT/$A_PROPERTY | cut -f 1 -d '=' | sort> $KEY_LIST_PROP
    # echo "=$KEY_LIST_ONTO==================================================="
    # cat $KEY_LIST_ONTO | head -5
    # echo "=$KEY_LIST_PROP==================================================="
    # cat $KEY_LIST_PROP | head -5
    print_report
}

function print_report () {
    echo "============================================================"
    echo "===================== REPORT ==============================="
    echo "= EVALUATION FOR $(basename $KEY_LIST_ONTO) AND $(basename $KEY_LIST_PROP) in theme ($_THEME)================"
    echo "Processing $A_PRODUCT"
    echo "A_PRODUCT   = [$A_PRODUCT]"
    echo "A_PROPERTY  = [$A_PROPERTY]"
    echo "MATCH_ONTO  = [$MATCH_ONTO]"
    echo "UI_ONTO_FN  = [$UI_ONTO_FN]"
    echo "THEME       = [$THEME]"
    echo "REGION      = [$REGION]"
    if [ ! -n "$THEME" ]; then _THEME="no-theme"; else _THEME="$THEME" ; fi
    TOTAL_ONTO_COUNT=$(cat $KEY_LIST_ONTO | wc -l )
    TOTAL_KEY_COUNT=$(cat  $KEY_LIST_PROP |wc -l)
    echo "Total words is [$TOTAL_ONTO_COUNT] for [$UI_ONTO_FN]"
    echo "Total words is [$TOTAL_KEY_COUNT] for [$(basename $A_PROPERTY)]"
    echo "=========================DIFF Report ========================"
    [ "$TOTAL_ONTO_COUNT" == "$TOTAL_KEY_COUNT" ] && echo "      If the list is empty, it means that the keys of the property file and the ontology match"
    #cat $KEY_LIST_ONTO $KEY_LIST_PROP | sort | uniq -u
    diff  --suppress-common-lines -y -W 120 $KEY_LIST_ONTO $KEY_LIST_PROP
    echo "=========================DIFF Report END====================="
    if [ "$TOTAL_ONTO_COUNT" == "$TOTAL_KEY_COUNT" ]
    then
        export MESSAGE="TEST_PASSED for the files: [$(basename $A_PROPERTY)] and [$UI_ONTO_FN]. The test indicates that there is an identical number [$TOTAL_ONTO_COUNT] of keys between the property file and the ontology."
    else
        export MESSAGE="TEST_FAILED for the files: [$(basename $A_PROPERTY)] and [$UI_ONTO_FN]. The test indicates that there is a different number of keys between the ontology [$UI_ONTO_FN = ($TOTAL_ONTO_COUNT)] and the property $(basename $A_PROPERTY)= ($TOTAL_KEY_COUNT) files"
    fi
    echo "===================== SUMMARY =============================="
    echo "SUMMARY: $MESSAGE"
    echo "===================== SUMMARY END==========================="
    echo "===================== REPORT END============================"
    echo "============================================================"
    echo ""

}

###################################################################
# main
#
export PRODUCTS_LIST=( VIVO-languages ) # for small test
build_list_keys_query
for A_PRODUCT in "${PRODUCTS_LIST[@]}"
do
    cd $GIT_HOME/$A_PRODUCT
    PROP_LIST=( $(find . -name '*.properties' | grep i18n | grep -v target | grep -v bin | grep -v core ) )
    for A_PROPERTY in "${PROP_LIST[@]}"
    do
        match_prop_to_onto
    done
done


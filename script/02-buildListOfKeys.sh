#!/bin/bash 

###################################################################
# Script Name   :
# Description   : Ce script permet d'extraire la liste des clés dans
# tous les fichiers de propriétés i18n
# Args          : 
# Author        : Michel Héon PhD
# Institution   : Université du Québec à Montréal
# Copyright     : Université du Québec à Montréal (c) 2022
# Email         : heon.michel@uqam.ca
###################################################################
export LOC_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd -P)"
source $LOC_SCRIPT_DIR/../00-env.sh
source $LOC_SCRIPT_DIR/func_cleanup.sh
export TMP_LIST_OF_KEYS_FN=$TMPDIR/tmp_ListOfKeys.txt
export TMP_LIST_OF_PROPERTIES_FN=$TMPDIR/tmp_ListOfPropFn.txt
function list_properties_fn () {
    find . -name '*.properties' | grep i18n | grep -v target | grep -v bin
}
function store_properties_files () {
    for PROPERTIES_URL in $(cat $TMP_LIST_OF_PROPERTIES_FN)
    do
        PROPERTIES_FN="$PRODUCTS,$(echo $PROPERTIES_URL | sed 's/\.\///g' |tr -s '/' ',')"
        echo $PROPERTIES_URL $PROPERTIES_FN
        java $LOC_SCRIPT_DIR/ParseAndCleanProperties.java < $PROPERTIES_URL  > $PROPERTIES_DATA/$PROPERTIES_FN
    done
}

function extract_prop_keys () {
    cd $PROPERTIES_DATA
    cat $(ls *.properties) | grep = | cut -f 1 -d '=' | sort | uniq | grep -Ev "^$" > $LIST_OF_KEYS_FN
}


###################################################################
# Retrieve all property files and extract the key list
for PRODUCTS in "${PRODUCTS_LIST[@]}"
do
    echo "$PRODUCTS"
    cd $GIT_HOME/$PRODUCTS
    list_properties_fn > $TMP_LIST_OF_PROPERTIES_FN
    store_properties_files 
done
find $PROPERTIES_DATA -type f -empty -print -delete
###################################################################
# extraire la liste des clés
extract_prop_keys



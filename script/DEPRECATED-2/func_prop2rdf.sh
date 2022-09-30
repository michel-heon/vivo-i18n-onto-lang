#!/bin/bash 

###################################################################
# Script Name   :
# Description   :
# Args          : properties file name
# Author        : Michel Héon PhD
# Institution   : Université du Québec à Montréal
# Copyright     : Université du Québec à Montréal (c) 2022
# Email         : heon.michel@uqam.ca
###################################################################
export SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd -P)"
source $SCRIPT_DIR/../00-env.sh
source $SCRIPT_DIR/func_cleanup.sh

export PROPFN=$1
export REGION="en_US"

function extract_region() {
    lang_pkg=$(echo $PROPFN | cut -d ',' -f 1)
    if [[ $lang_pkg == *"languages"* ]]; then
        REGION=$(echo $PROPFN | cut -d ',' -f 2)
    fi

}


function extract_vars() {
        VALUE="$(echo $PROPFN_VAL | cut -f 2- -d '=')"
        predicateValue="$(echo $PROPFN_VAL | cut -f 1- -d '=')"
        PROP_FN_KEY=$(echo $PROPFN_VAL | cut -f 1 -d '=')
        PROP_FN=$(echo $PROP_FN_KEY | cut -f 1 -d ':')
        PROP_KEY=$(echo $PROP_FN_KEY | cut -f 2 -d ':')
        BN=$(basename $PROP_FN .properties | tr -s ',' '/')
#        THEME=$(echo $BN | grep theme | sed  's/.*themes\///g' | cut -f 1 -d '/')
#        if [ -n "${THEME}" ]; then predicateValue=$PROP_KEY.$PKG.$THEME; else predicateValue=$PROP_KEY.$PKG; fi
}


function print_values () {
printf "PROPFN_VAL=($PROPFN_VAL) \n \
\t VALUE=($VALUE) \n\
\t PROP_FN_KEY=($PROP_FN_KEY) \n\
\t PROP_FN=($PROP_FN) \n\
\t PROP_KEY=($PROP_KEY) \n\
\t BN=($BN) \n\
\t REGION=($REGION) \n\
\t NT_FN=($NT_FN)\n\
\t $BN\n\t\t PKG=$PKG\n\
\t THEME=($THEME) \n\
\t predicateValue=$predicateValue \n"
}

function to_rdf() {
            cat << EOF 
<$BASE_IRI#$predicateValue> <http://www.w3.org/2004/02/skos/core#prefLabel> "$VALUE"@$REGION .
<$BASE_IRI#$predicateValue> <http://www.w3.org/2000/01/rdf-schema#label> "$predicateValue" .
<$BASE_IRI#$predicateValue> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2002/07/owl#NamedIndividual> .
<$BASE_IRI#$predicateValue> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <$SEMANTIC_BASE_IRI#PropertyKey> . 
EOF
}
###################################################################
# Traduire la clé-valeurs en RDF

while IFS= read -r line; do
    PROPFN_VAL=$line
    echo $PROPFN_VAL
    echo ========================
    extract_region
    extract_vars
    to_rdf    
exit 0
    
done < "$PROPFN"

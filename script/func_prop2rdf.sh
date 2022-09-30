#!/bin/bash

###################################################################
# Script Name   :
# Description   : Traduit chaque ligne du fichiers de propriétés en triplets rdf
# Args          : properties file name
# Author        : Michel Héon PhD
# Institution   : Université du Québec à Montréal
# Copyright     : Université du Québec à Montréal (c) 2022
# Email         : heon.michel@uqam.ca
###################################################################
export PROP_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd -P)"
SPARQL_SCRIPT_DIR=$PROP_SCRIPT_DIR/sparql
source $PROP_SCRIPT_DIR/func_cleanup.sh

export PROPFN=$1

export ONTOFN=$PROPERTIES_ONTO_DATA/$(basename $PROPFN .properties).nt
echo "" >$ONTOFN

export REGION="en_US" # Default Value

function extract_region() {
    lang_pkg=$(echo $PROPFN | cut -d ',' -f 1)
    if [[ $lang_pkg == *"languages"* ]]; then
        REGION=$(echo $PROPFN | cut -d ',' -f 2)
    fi

}


function extract_vars() {
        QUOTE_VALUE="$(echo $PROPFN_VAL | cut -f 2- -d '=')"
        VALUE=${QUOTE_VALUE//\"/\\\"} # replace " by \" in value
        PROP_FN_KEY=$(echo $PROPFN_VAL | cut -f 1 -d '=')
        PROP_FN=$(echo $PROP_FN_KEY | cut -f 1 -d ':')
        PROP_KEY=$(echo $PROP_FN_KEY | cut -f 2 -d ':')
        BN=$(basename $PROPFN .properties | tr -s ',' '/')
        REGION=$(basename $BN | cut -f 2- -d '_' | tr -s '_' '-'| sed 's/all-//g')
        NT_FN=$KEY.nt
        PKG=$(echo $BN | cut -f 1 -d '/')
        THEME=$(echo $PROPFN | grep themes | sed  's/.*themes,//g'| cut -d ',' -f 1)
        if [ -n "${THEME}" ]; then predicateValue=$PROP_KEY.$PKG.$THEME; else predicateValue=$PROP_KEY.$PKG; fi
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

function to_rdf () {
cat << EOF > $TMPDIR/describe.sparql
$(cat $SPARQL_SCRIPT_DIR/header.sparql)
construct {
    prop-data:$predicateValue ?p ?o .
    prop-data:$predicateValue skos:prefLabel ?label .
    prop-data:$predicateValue prop:ftlUrl ?url .
} 
WHERE {
    prop-data:$predicateValue ?p ?o 
    filter(!regex(str(?p),"propertiesUrl")) .
    filter(!regex(str(?p),"prefLabel")) .
    prop-data:$predicateValue skos:prefLabel ?label
    FILTER (lang(?label) = '$REGION') 
    prop-data:$PROP_KEY prop:ftlUrl ?url .
}
EOF
sparql --results=TURTLE --query=$TMPDIR/describe.sparql --data=$DATA/all.ttl --base "http://vivoweb.org/ontology/core/properties/individual" --results=ntriples >> $ONTOFN
}

###################################################################
# Traduire la clé-valeurs en RDF
NBR_LINE=$(cat $PROPFN | wc -l )
while IFS= read -r line; do
    ((LOOP_CTR=LOOP_CTR+1))
    PROPFN_VAL=$line
    echo "($LOOP_CTR/$NBR_LINE) PROCESS $PROPFN_VAL"
    extract_region
    extract_vars
    to_rdf   
done < "$PROPFN"

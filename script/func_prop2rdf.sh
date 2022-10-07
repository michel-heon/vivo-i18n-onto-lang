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
    [ "$REGION" = "all" ] && REGION='en-US'
    BN=$(basename $PROPFN .properties | tr -s ',' '/')
    PKG=$(echo $BN | cut -f 1 -d '/')
    THEME=$(echo $PROPFN | grep themes | sed  's/.*themes,//g'| cut -d ',' -f 1)
}

function print_values () {
printf "PROPFN_VAL=($PROPFN_VAL) \n \
\t BN=($BN) \n\
\t REGION=($REGION) \n\
\t PKG=$PKG\n\
\t THEME=($THEME) \n\
\t ONTOFN=$ONTOFN\n"
}

function to_rdf () {
cat << EOF > $TMPDIR/describe.sparql
$(cat $SPARQL_SCRIPT_DIR/header.sparql)
construct {
    ?s ?p ?o .
    ?s rdfs:label ?label .
} 
WHERE {
    ?s ?p ?o 
    FILTER(!regex(str(?p),"label")) .
    ?s rdfs:label ?label .
    FILTER (lang(?label) = 'fr-CA') .
    ?s prop:hasTheme "$THEME" .
    ?s prop:hasPackage "$PKG" .
    FILTER(regex(str(?s),"properties")) .
}
EOF

sparql --results=TURTLE --query=$TMPDIR/describe.sparql \
    --data=$DATA/all.ttl \
    --base "$BASE_IRI" \
    --results=ntriples >> $ONTOFN
}

###################################################################
# Traduire la clé-valeurs en RDF
NBR_LINE=$(cat $PROPFN | wc -l )
PROPFN=$1
extract_region
print_values
to_rdf
exit 0

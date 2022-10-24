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
export SPARQL_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd -P)"
source $SPARQL_SCRIPT_DIR/../../00-env.sh
source $SPARQL_SCRIPT_DIR/func_cleanup.sh
TMP_DATA_ONTO=$TMPDIR/$$.nt
TMP_SPARQL=$TMPDIR/$$.sparql
cat - > $TMP_DATA_ONTO
cat << EOF > $TMP_SPARQL
$(cat $SPARQL_HEADER)
construct {
    ?s ?p ?o .
} 
WHERE {
    ?s ?p ?o 
}
EOF
sparql --results=TURTLE --query=$TMP_SPARQL --data=$TMP_DATA_ONTO --base "http://vivoweb.org/ontology/core/properties/individual" | turtle --output=ttl 2> /dev/null
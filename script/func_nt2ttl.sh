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
source $SPARQL_SCRIPT_DIR/../00-env.sh
source $SPARQL_SCRIPT_DIR/func_cleanup.sh
cat - > $TMPDIR/data.nt
cat << EOF > $TMPDIR/construct.sparql
$(cat $SPARQL_SCRIPT_DIR/sparql/header.sparql)
construct {
    ?s ?p ?o .
} 
WHERE {
    ?s ?p ?o 
}
EOF
sparql --results=TURTLE --query=$TMPDIR/construct.sparql --data=$TMPDIR/data.nt --base "http://vivoweb.org/ontology/core/properties/individual" | turtle --output=ttl 2> /dev/null
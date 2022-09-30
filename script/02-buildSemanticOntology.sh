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
export TBOX_FT_REP=${UI_LABELS_VOCAB%/*}
mkdir -p $TBOX_FT_REP

function build_semantic() {
cat << EOF >> $UI_LABELS_VOCAB
<$SEMANTIC_BASE_IRI#PropertyKey> <http://www.w3.org/2000/01/rdf-schema#subClassOf> <http://www.w3.org/2004/02/skos/core#Concept> .
<$SEMANTIC_BASE_IRI#PropertyKey> <http://www.w3.org/2000/01/rdf-schema#subClassOf> <http://www.w3.org/2002/07/owl#Thing> .
<$SEMANTIC_BASE_IRI#PropertyKey> <http://www.w3.org/2000/01/rdf-schema#label> <http://www.w3.org/2004/02/skos/core#Concept> .
<$SEMANTIC_BASE_IRI#PropertyKey> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2002/07/owl#Class> .
<$SEMANTIC_BASE_IRI#ftlUrl> <http://www.w3.org/2000/01/rdf-schema#label> "ftl file url" .
<$SEMANTIC_BASE_IRI#ftlUrl> <http://www.w3.org/2000/01/rdf-schema#range> <http://www.w3.org/2001/XMLSchema#anyURI> .
<$SEMANTIC_BASE_IRI#ftlUrl> <http://www.w3.org/2000/01/rdf-schema#comment> "Points to the FTL file containing the key" .
<$SEMANTIC_BASE_IRI#ftlUrl> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2002/07/owl#DatatypeProperty> .
<$SEMANTIC_BASE_IRI#propertiesUrl> <http://www.w3.org/2000/01/rdf-schema#label> "Propertie file url " .
<$SEMANTIC_BASE_IRI#propertiesUrl> <http://www.w3.org/2000/01/rdf-schema#range> <http://www.w3.org/2001/XMLSchema#anyURI> .
<$SEMANTIC_BASE_IRI#propertiesUrl> <http://www.w3.org/2000/01/rdf-schema#comment> "Points to the property file containing the defined key" .
<$SEMANTIC_BASE_IRI#propertiesUrl> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2002/07/owl#DatatypeProperty> .
<$SEMANTIC_BASE_IRI#hasTheme> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2002/07/owl#DatatypeProperty> .
<$SEMANTIC_BASE_IRI#hasTheme> <http://www.w3.org/2000/01/rdf-schema#label> "has theme" .
<$SEMANTIC_BASE_IRI#hasTheme> <http://www.w3.org/2000/01/rdf-schema#range> <http://www.w3.org/2001/XMLSchema#string> .
<$SEMANTIC_BASE_IRI#hasPackage> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2002/07/owl#DatatypeProperty> .
<$SEMANTIC_BASE_IRI#hasPackage> <http://www.w3.org/2000/01/rdf-schema#label> "has package" .
<$SEMANTIC_BASE_IRI#hasPackage> <http://www.w3.org/2000/01/rdf-schema#range> <http://www.w3.org/2001/XMLSchema#string> .
EOF
}

###################################################################
# extraire la liste des clés
cd $PROPERTIES_DATA
build_semantic

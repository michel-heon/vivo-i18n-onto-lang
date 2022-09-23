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
TMP_PROP_FN=$TMPDIR/propFn.txt
export ONTO_FN=""
function extract_vars() {
        VALUE="$(echo $PROPFN_VAL | cut -f 2- -d '=')"
        PROP_FN_KEY=$(echo $PROPFN_VAL | cut -f 1 -d '=')
        PROP_FN=$(echo $PROP_FN_KEY | cut -f 1 -d ':')
        PROP_KEY=$(echo $PROP_FN_KEY | cut -f 2 -d ':')
        BN=$(basename $PROP_FN .properties | tr -s ',' '/')
        REGION=$(basename $BN | cut -f 2- -d '_' | tr -s '_' '-'| sed 's/all-//g')
        NT_FN=$KEY.nt
        PKG=$(echo $BN | cut -f 1 -d '/')
        THEME=$(echo $BN | grep theme | sed  's/.*themes\///g' | cut -f 1 -d '/')
        if [ -n "${THEME}" ]; then predicateValue=$PROP_KEY.$PKG.$THEME; else predicateValue=$PROP_KEY.$PKG; fi
}

function build_semantic() {
cat << EOF >> $TMP_ONTO_RESULT
<$BASE_IRI#PropertyKey> <http://www.w3.org/2000/01/rdf-schema#subClassOf> <http://www.w3.org/2004/02/skos/core#Concept> .
<$BASE_IRI#PropertyKey> <http://www.w3.org/2000/01/rdf-schema#subClassOf> <http://www.w3.org/2002/07/owl#Thing> .
<$BASE_IRI#PropertyKey> <http://www.w3.org/2000/01/rdf-schema#label> <http://www.w3.org/2004/02/skos/core#Concept> .
<$BASE_IRI#ftlUrl> <http://www.w3.org/2000/01/rdf-schema#label> "ftl file url" .
<$BASE_IRI#ftlUrl> <http://www.w3.org/2000/01/rdf-schema#range> <http://www.w3.org/2001/XMLSchema#anyURI> .
<$BASE_IRI#ftlUrl> <http://www.w3.org/2000/01/rdf-schema#comment> "Points to the FTL file containing the key" .
<$BASE_IRI#ftlUrl> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2002/07/owl#DatatypeProperty> .
<$BASE_IRI#propertiesUrl> <http://www.w3.org/2000/01/rdf-schema#label> "Propertie file url " .
<$BASE_IRI#propertiesUrl> <http://www.w3.org/2000/01/rdf-schema#range> <http://www.w3.org/2001/XMLSchema#anyURI> .
<$BASE_IRI#propertiesUrl> <http://www.w3.org/2000/01/rdf-schema#comment> "Points to the property file containing the defined key" .
<$BASE_IRI#propertiesUrl> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2002/07/owl#DatatypeProperty> .
<$BASE_IRI#hasTheme> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2002/07/owl#DatatypeProperty> .
<$BASE_IRI#hasTheme> <http://www.w3.org/2000/01/rdf-schema#label> "has theme" .
<$BASE_IRI#hasTheme> <http://www.w3.org/2000/01/rdf-schema#range> <http://www.w3.org/2001/XMLSchema#string> .
<$BASE_IRI#hasPackage> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2002/07/owl#DatatypeProperty> .
<$BASE_IRI#hasPackage> <http://www.w3.org/2000/01/rdf-schema#label> "has package" .
<$BASE_IRI#hasPackage> <http://www.w3.org/2000/01/rdf-schema#range> <http://www.w3.org/2001/XMLSchema#string> .
EOF
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
function build_indv() {
    cat $1 | while read PROPFN_VAL
    do
        echo $PROPFN_VAL
        extract_vars
#        print_values
        cat << EOF >> $TMP_ONTO_RESULT
<$BASE_IRI#$predicateValue> <http://www.w3.org/2004/02/skos/core#prefLabel> "$VALUE"@$REGION .
<$BASE_IRI#$predicateValue> <http://www.w3.org/2000/01/rdf-schema#label> "$predicateValue" .
<$BASE_IRI#$predicateValue> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2002/07/owl#NamedIndividual> .
<$BASE_IRI#$predicateValue> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <$BASE_IRI#PropertyKey> . 
<$BASE_IRI#$predicateValue> <$BASE_IRI#propertiesUrl> "file:///$BN.properties"^^<http://www.w3.org/2001/XMLSchema#anyURI> . 
<$BASE_IRI#$predicateValue> <$BASE_IRI#hasPackage> "$PKG" . 
EOF
        if [ -n "${THEME}" ]; then 
        cat << EOF >> $TMP_ONTO_RESULT
<$BASE_IRI#$predicateValue> <$BASE_IRI#hasTheme> "$THEME" . 
EOF
        fi
    

    done
    for PRODUCTS in "${PRODUCTS_LIST[@]}"
    do
#        echo "$PRODUCTS"
        cd $GIT_HOME/$PRODUCTS
        FTL_FILES=$(find . -name '*.ftl' ! -path '*target*' -exec grep -l $KEY {} \; | tr -s ' ' '\n') 
        if [ -n "$FTL_FILES" ]; then
            echo $FTL_FILES | tr ' ' '\n' | while read FTL_FN
            do
                FTL_PATH="$PRODUCTS/$(echo $FTL_FN | sed 's/\.\///g')"
                cat << EOF >> $TMP_ONTO_RESULT
<$BASE_IRI#$KEY> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2002/07/owl#NamedIndividual> .
<$BASE_IRI#$KEY> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <$BASE_IRI#PropertyKey> . 
<$BASE_IRI#$KEY> <http://www.w3.org/2000/01/rdf-schema#label> "$KEY" .
<$BASE_IRI#$KEY> <$BASE_IRI#ftlUrl> "file:///$FTL_PATH"^^<http://www.w3.org/2001/XMLSchema#anyURI> . 
EOF
            done
        fi
    done
    
}
###################################################################
# extraire la liste des clés
cd $PROPERTIES_DATA
for KEY in $(cat $LIST_OF_KEYS_FN)
do
    KEY=claim_publications_by
    grep -w $KEY * > $TMP_PROP_FN 
    ONTO_FN=$KEY.nt
    export TMP_ONTO_RESULT=$TMPDIR/$ONTO_FN
    build_semantic
    build_indv $TMP_PROP_FN
    cat $TMP_ONTO_RESULT | sort | uniq | grep -Ev "^$" > $ONTO_DATA/$ONTO_FN
    
    echo "turtle --base=$BASE_IRI --output=TTL -set http://vivoweb.org/ontology/core/properties=prop: $ONTO_DATA/$ONTO_FN > $ONTO_DATA/$KEY.ttl"
#    cat $ONTO_DATA/$KEY.ttl
    exit 0
done
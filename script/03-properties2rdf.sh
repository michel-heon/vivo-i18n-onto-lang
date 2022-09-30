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
source $LOC_SCRIPT_DIR/func_cleanup.sh
PATH=$PATH:$LOC_SCRIPT_DIR
TMP_PROP_FN=$TMPDIR/propFn.txt
export ONTO_FN=""
function extract_vars() {
        QUOTE_VALUE="$(echo $PROPFN_VAL | cut -f 2- -d '=')"
        VALUE=${QUOTE_VALUE//\"/\\\"} # replace " by \" in value
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
        extract_vars
#        print_values
        cat << EOF >> $TMP_ONTO_RESULT
<$BASE_IRI#$predicateValue> <http://www.w3.org/2004/02/skos/core#prefLabel> "$VALUE"@$REGION .
<$BASE_IRI#$predicateValue> <http://www.w3.org/2000/01/rdf-schema#label> "$predicateValue" .
<$BASE_IRI#$predicateValue> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2002/07/owl#NamedIndividual> .
<$BASE_IRI#$predicateValue> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <$SEMANTIC_BASE_IRI#PropertyKey> . 
<$BASE_IRI#$predicateValue> <$SEMANTIC_BASE_IRI#propertiesUrl> "file://$GIT_HOME/$BN.properties"^^<http://www.w3.org/2001/XMLSchema#anyURI> . 
<$BASE_IRI#$predicateValue> <$SEMANTIC_BASE_IRI#hasPackage> "$PKG" . 
EOF
        if [ -n "${THEME}" ]; then 
        cat << EOF >> $TMP_ONTO_RESULT
<$BASE_IRI#$predicateValue> <$SEMANTIC_BASE_IRI#hasTheme> "$THEME" . 
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
                FTL_PATH=$GIT_HOME/"$PRODUCTS/$(echo $FTL_FN | sed 's/\.\///g')"
                cat << EOF >> $TMP_ONTO_RESULT
<$BASE_IRI#$KEY> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2002/07/owl#NamedIndividual> .
<$BASE_IRI#$KEY> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <$SEMANTIC_BASE_IRI#PropertyKey> . 
<$BASE_IRI#$KEY> <http://www.w3.org/2000/01/rdf-schema#label> "$KEY" .
<$BASE_IRI#$KEY> <$SEMANTIC_BASE_IRI#ftlUrl> "file://$FTL_PATH"^^<http://www.w3.org/2001/XMLSchema#anyURI> . 
EOF
            done
        fi
    done
    
}
###################################################################
# extraire la liste des clés
for KEY in $(cat $LIST_OF_KEYS_FN)
do
#    KEY=cropping_note
    cd $PROPERTIES_DATA
    echo "Processing $KEY"
    SUB_REP="${KEY:0:1}"
    grep -w $KEY * > $TMP_PROP_FN 
    ONTO_FN=$KEY.nt
    export TMP_ONTO_RESULT=$TMPDIR/$ONTO_FN
    build_indv $TMP_PROP_FN
    cat $TMP_ONTO_RESULT | sort | uniq | grep -Ev "^$" > $ONTO_DATA/$SUB_REP/$ONTO_FN
    (func_nt2ttl.sh < $ONTO_DATA/$SUB_REP/$ONTO_FN > $ONTO_DATA_TTL/$SUB_REP/$KEY.ttl)&
    echo "Done !"
#   exit 0
done
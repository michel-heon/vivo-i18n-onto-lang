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
SPARQL_SCRIPT_DIR=$PROP_SCRIPT_DIR/../sparql
source $PROP_SCRIPT_DIR/func_cleanup.sh

export PROPFN=$1
export ONTOFN=$PROPERTIES_ONTO_DATA/$(basename $PROPFN .properties).n3

#export REGION="en_US" # Default Value

function extract_region() {
    lang_pkg=$(echo $PROPFN | cut -d ',' -f 1)
    if [[ $lang_pkg == *"languages"* ]]; then
        REGION=$(echo $PROPFN | cut -d ',' -f 2)
        LANG=$(echo $REGION| tr -s '_' '-')
    else
        REGION=""
        LANG='en-US'
    fi
    BN=$(basename $PROPFN .properties | tr -s ',' '/')
    PKG=$(echo $BN | cut -f 1 -d '/')
    THEME=$(echo $PROPFN | grep themes | sed  's/.*themes,//g'| cut -d ',' -f 1)
}

function print_values () {
    printf "\
\t PROPFN=($PROPFN) \n\
\t BN=($BN) \n\
\t REGION=($REGION) \n\
\t LANG=($LANG) \n\
\t PKG=$PKG\n\
\t THEME=($THEME) \n\
\t ONTOFN=$ONTOFN\n"
}

function to_rdf () {
    IRI=$BASE_IRI#
    if [ -z $REGION ]; then
        URLFILTER=''
    else
        URLFILTER="FILTER(regex(str(?url),\"${REGION}\")) ."
    fi
    if [ -z $THEME ]; then
        cat << EOF > $TMPDIR/describe.sparql
$(cat $SPARQL_HEADER)
CONSTRUCT {
        ?s a  ?type .
        ?s rdfs:label ?label .
        ?s prop:ftlUrl  ?url .
        ?s prop:hasApp  ?app .
        ?s prop:hasKey  ?key  .
        ?s prop:hasPackage ?pkg .
}
WHERE {
        ?s rdf:type prop:PropertyKey .
        ?s a  ?type .
        ?s prop:hasApp  ?app .
        ?s prop:hasKey  ?key  .
        ?s prop:hasPackage ?pkg .
        FILTER NOT EXISTS{ ?s prop:hasTheme ?theme }
        FILTER (str(?pkg) = '$PKG') .
        OPTIONAL {
            ?s rdfs:label ?label .
            FILTER (lang(?label) = '$LANG') .
        }
        OPTIONAL {
            ?s prop:ftlUrl  ?url .
            $URLFILTER
        }
}
EOF

    else
        cat << EOF > $TMPDIR/describe.sparql
$(cat $SPARQL_SCRIPT_DIR/header.sparql)
CONSTRUCT {
        ?s a  ?type .
        ?s rdfs:label ?label .
        ?s prop:ftlUrl  ?url .
        ?s prop:hasApp  ?app .
        ?s prop:hasKey  ?key  .
        ?s prop:hasPackage ?pkg .
        ?s prop:hasTheme ?theme .
}
WHERE {
        ?s rdf:type prop:PropertyKey .
        ?s a  ?type .
        ?s prop:hasApp  ?app .
        ?s prop:hasKey  ?key  .
        ?s prop:hasPackage ?pkg .
        ?s prop:hasTheme ?theme .
        FILTER (str(?theme) = '$THEME') .
        FILTER (str(?pkg) = '$PKG') .
        OPTIONAL {
            ?s rdfs:label ?label .
            FILTER (lang(?label) = '$LANG') .
        }
        OPTIONAL {
            ?s prop:ftlUrl  ?url .
            $URLFILTER
        }
}
EOF
    fi
    # cat $TMPDIR/describe.sparql
    sparql --results=TURTLE --query=$TMPDIR/describe.sparql \
        --data=$DATA/all.ttl \
        --base "$BASE_IRI" \
        --results=ntriples > $ONTOFN
    #    cat $ONTOFN

}
###################################################################
# Traduire la clé-valeurs en RDF
NBR_LINE=$(cat $PROPFN | wc -l )
PROPFN=$1
extract_region
print_values
to_rdf

exit 0
construct {
    ?$VAR_NAME ?p ?o .
    ?$VAR_NAME rdfs:label ?label .
    ?$VAR_NAME prop:ftlUrl ?ftl .
}
WHERE {
    ?s ?p ?o .
    ?s rdf:type prop:PropertyKey .
    ?s rdfs:label ?label .
    ?s prop:hasPackage "$PKG" .
    FILTER (regex(str(?s),".*$PKG\$")) .
    FILTER (!regex(str(?p),"http://www.w3.org/2000/01/rdf-schema#label")) .
    FILTER (lang(?label) = '$LANG') .
    FILTER (!regex(str(?p),"ftlUrl")) .
    FILTER NOT EXISTS { ?$VAR_NAME prop:hasTheme ?theme . }
    OPTIONAL {
        ?$VAR_NAME prop:ftlUrl ?ftl .
        FILTER (regex(str(?ftl),"${REGION}.ftl")) .
    }
}
EOF



avec theme
construct {
    ?$VAR_NAME ?p ?o .
    ?$VAR_NAME rdfs:label ?label .
    ?$VAR_NAME prop:ftlUrl ?ftl .
    ?$VAR_NAME prop:hasTheme "$THEME" .
}
WHERE {
    ?s ?p ?o .
    ?s rdf:type prop:PropertyKey .
    ?s rdfs:label ?label .
    ?s prop:hasTheme "$THEME" .
    ?s prop:hasPackage "$PKG" .
    FILTER (regex(str(?s),".*$PKG.$THEME\$")) .
    FILTER (!regex(str(?p),"http://www.w3.org/2000/01/rdf-schema#label")) .
    FILTER (!regex(str(?p),"ftlUrl")) .
    FILTER (lang(?label) = '$LANG') .
    OPTIONAL {
        ?$VAR_NAME prop:ftlUrl ?ftl .
        ?$VAR_NAME prop:hasTheme "$THEME" .
        FILTER (regex(str(?ftl),"${REGION}.ftl")) .
    }
}
EOF




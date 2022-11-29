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
export SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd -P)"
source $SCRIPT_DIR/../00-env.sh
function process_file {
    FILE=$(basename $file .n3)
    PROP_URL=$(echo $FILE | tr ',' '/').properties
    PROP_FN=$(basename $PROP_URL .properties)
    PROP_DIR_LOC=$(dirname $PROP_URL)
    ROOT_PKG=$(echo $file | cut -f 1 -d ',' )
    PKG=$(basename $ROOT_PKG)
    APP=$(echo $PKG | cut -f 1 -d '-' | tr '[:upper:]' '[:lower:]')
    REGION=$(echo $file | cut -f 2 -d ',')
    LANG_REPO=$PKG/$REGION/home/src/main/resources/rdf/i18n/$REGION/interface-i18n/firsttime
    TARGET_REPO=$TARGET_HOME/$LANG_REPO
    THEME=$(echo $PROP_DIR_LOC | grep theme | sed  's/.*themes\///g' | cut -f 1 -d '/')
    if [ -n "${THEME}" ]; then
        UI_ONTO_FN=${APP}_UiLabel_${REGION}_${THEME}.ttl
    else
        UI_ONTO_FN=${APP}_UiLabel_${REGION}.ttl
    fi
    README_URL=$TARGET_HOME/$PROP_DIR_LOC/README_$(basename $UI_ONTO_FN .ttl).txt
    echo "===================================================="
    echo "Processing $file"
    echo "      FILE         = $FILE"
    echo "      PKG          = $PKG"
    echo "      APP          = $APP"
    echo "      THEME        = $THEME"
    echo "      REGION       = $REGION"
    echo "      LANG_REPO    = $LANG_REPO"
    echo "      TARGET_REPO  = $TARGET_REPO"
    echo "      PROP_URL     = $PROP_URL"
    echo "      PROP_DIR_LOC = $PROP_DIR_LOC"
    echo "      PROP_URL_FN  = $PROP_URL_FN"
    echo "      UI_ONTO_FN   = $UI_ONTO_FN"
    echo "      README_URL   = $README_URL"
    echo ""

    mkdir -p $TARGET_REPO
    mkdir -p $TARGET_HOME/$PROP_DIR_LOC/
    cat << EOF > $README_URL
Please note that although usage of property files for translation of UI labels is supported at the moment,
it is deprecated and not recommended. Please, consider using ontology instead of property file located at:
Source code: [VIVO project]$LANG_REPO/$UI_ONTO_FN
Deployment: [VIVO home]/rdf/i18n/$REGION/display/interface-i18n/$UI_ONTO_FN

However, if you decide to use property files, please create and post the file in the same
directory as this Readme file.

EOF
    func_nt2ttl.sh < $file > $TARGET_REPO/$UI_ONTO_FN
    echo "Done installing $TARGET_REPO/$UI_ONTO_FN"
}
###################################################################
# Main loop
for file in $PROPERTIES_ONTO_DATA/*
do
    process_file &
    ((j=j+1))
    if [ $j = "5" ]
    then
        wait; ((j=0)) ;  echo "################ New cycle"
    else
        sleep .2
    fi
done
wait
echo "DONE!"


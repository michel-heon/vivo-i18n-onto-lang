#!/bin/bash 

###################################################################
# Script Name   :
# Description   : Useful for emptying working folders and files
# Args          : 
# Author        : Michel Héon PhD
# Institution   : Université du Québec à Montréal
# Copyright     : Université du Québec à Montréal (c) 2022
# Email         : heon.michel@uqam.ca
###################################################################
export CLEAN_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd -P)"
source $CLEAN_SCRIPT_DIR/../00-env.sh

rm -fr $PROPERTIES_DATA/*.properties
rm -fr $ONTO_DATA/*
rm -fr $ONTO_DATA_TTL/*
rm -fr $LIST_OF_KEYS_FN
rm -fr $PROPERTIES_ONTO_DATA/*
rm -fr $TARGET_HOME/*

mkdir -p $ONTO_DATA/_
mkdir -p $ONTO_DATA_TTL/_

for x in {a..z}
do
    mkdir -p $ONTO_DATA/${x}
    mkdir -p $ONTO_DATA_TTL/${x}
done


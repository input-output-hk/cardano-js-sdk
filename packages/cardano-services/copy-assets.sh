#!/usr/bin/env bash

# TODO: run this with 'shx' or replace this with some cross-platform script

# TODO: uncomment esm lines when ESM builds are enabled for this package

cp ./package.json ./dist/cjs/original-package.json
# cp ./package.json ./dist/esm/original-package.json

for i in `ls ./src` ; do
  SRC=./src/$i/openApi.json

  if [ -f $SRC ] ; then
    cp $SRC ./dist/cjs/$i/openApi.json
    # cp $SRC ./dist/esm/$i/openApi.json
  fi
done

cp -R ./src/StakePool/HttpStakePoolMetadata/schemas ./dist/cjs/StakePool/HttpStakePoolMetadata/schemas
# cp -R ./src/StakePool/HttpStakePoolMetadata/schemas ./dist/esm/StakePool/HttpStakePoolMetadata/schemas

#!/bin/sh
# 2017 April 10
# https://github.com/bevry/base
echo "installing docpad's dev dependencies so docpad's testers works..."
cd ./node_modules/docpad && npm install --only=dev && cd ../.. || exit -1
cd ./test && npm install && cd ../ || exit -1

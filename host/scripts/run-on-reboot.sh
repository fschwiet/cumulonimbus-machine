#!/bin/bash

for directory in ./deploys/*; do
   	if [ -d "$directory/current" ]; then
		pushd $directory/current; 
		./cumulonimbus/run.sh
        popd
  	fi
done

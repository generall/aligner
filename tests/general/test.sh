#!/bin/bash

DIR=$(dirname $0)


cat $DIR/data.txt | ruby $DIR/../../pipe_launch.rb 2>&1 | tee $DIR/res

DIFF=$(diff $DIR/res $DIR/orig)

echo $DIFF

if [ "$DIFF" == "" ]; then
  exit 0
fi

exit 1
#!/bin/bash

DIR=$(dirname $0)


cat $DIR/data.txt | ruby $DIR/../../pipe_launch.rb  2>&1 | tee $DIR/res

cat $DIR/data1.txt | ruby $DIR/../../pipe_launch.rb 2>&1 | tee $DIR/res

cat $DIR/data2.txt | ruby $DIR/../../pipe_launch.rb 2>&1 | tee $DIR/res


_FIX=${_FIX:="0"}

if [ $_FIX == "1" ]; then
	cp $DIR/res $DIR/orig
fi

DIFF=$(diff $DIR/res $DIR/orig)

echo $DIFF

if [ "$DIFF" == "" ]; then
  exit 0
fi

exit 1
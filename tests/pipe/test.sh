#!/bin/bash

DIR=$(dirname $0)


python $DIR/ppipe.py > $DIR/res
python3 $DIR/ppipe.py >> $DIR/res


DIFF=$(diff $DIR/res $DIR/orig)

echo $DIFF

if [ "$DIFF" == "" ]; then
  exit 0
fi

exit 1
#!/bin/bash
#
# Pass in a csv file and a column header name and this
# will return the 1 based index of the column
#

CSV_FILE=$1
HEADER=$2

HEADERS=$(sed -n 1p $CSV_FILE)
PRE_HEADERS=$(echo $HEADERS | grep -P ".*(?=(^|,)$HEADER(,|$))" -o)
if [ "$PRE_HEADERS" = "" ]
then
  INDEX=1
else
  COMMA_COUNT=$(grep -o "," <<< "$PRE_HEADERS" | wc -l)
  INDEX=$(($COMMA_COUNT + 2))
fi

echo $INDEX

#!/usr/bin/env bash
if [ $# -lt 2 ]; then
    echo "Usage : log-parser.sh <input file> <output file>"
    exit
fi
FILE=$1
OUT=$2
cp $FILE ./$OUT

TAB="    "
LEVEL=0
echo "T3 - IA" > $OUT
while read -n1 char ; do
    if [ $char == '}' ]; then
        LEVEL=$((LEVEL-1))
        echo '' >> $OUT
    fi
    for i in {1..$LEVEL}; do
        echo -n $TAB >> $OUT
    done
    echo -n $char >> $OUT
    if [ $char == '{' ]; then
        LEVEL=$((LEVEL+1))
        echo '' >> $OUT
    fi
    if [ $char == '}' ]; then
        echo '' >> $OUT
    fi
done < $FILE
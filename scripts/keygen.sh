#!/bin/bash

echo "Usage: ./keygen.sh BATCH_NAME BATCH_SIZE"

echo "Generating key batch '${1}' with ${2} keys"

rm $1.csv

for (( i=1; i <= $2; i++ ))
do
	echo $1.$i,`uuidgen` >> $1.csv
done


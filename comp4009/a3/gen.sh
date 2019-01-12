#!/bin/bash

for i in `seq 1 $1`; do
	for j in `seq 1 $1`; do
		echo -n $((RANDOM % 2))
	done
	echo
done
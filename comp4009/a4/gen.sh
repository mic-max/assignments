#!/bin/bash

# ./gen.sh 100 4
# n=100, p=4

echo "Writing files..."
echo "rm data/input*.txt"

n=$(($1/$2))
for (( c = 0; c < $2; c++ ))
do
	outfile=data/input-`printf %02d $c`.txt 
	printf "%d\n%d\n" $1 $2 > "$outfile"
	shuf -i 0-100 -n $n >> "$outfile"
done

echo "Done."
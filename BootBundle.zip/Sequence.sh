#!/bin/bash

Path=$1
FileType=$2

cd $Path
i=1;
for x in *.$FileType;
do
	mv $x $(printf "%05d.$FileType" $i);
	i=$(($i + 1));
done

#!/bin/bash
  
for f in $1/*.out; do
    split -n l/$3 --numeric-suffixes=1 --additional-suffix=.dat "$f" "${f%.out}_"
    filename=`basename -s .out $f`
    mkdir -p $2/${filename}/
    mv $1/*.dat $2/${filename}/
done
#mv $1/*.dat $2/

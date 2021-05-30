#!/bin/bash

rm -Rf $2
rm -Rf /tmp/monacodata

echo 'splitting data file ...'
currentdir=$(cd $(dirname $0); pwd)
$currentdir/split.sh $1/ $2/ $(($3*$4))
echo 'split data file completed'

for path in $2/* 
do
    counter=0
    nodeidx=0
    curpath=/tmp/monacodata/node$nodeidx/txs/$(basename $path)
    
    files=$(ls $path)
    for f in $files
    do
        echo 'copy file ' $f 
        if [ $counter -eq 0 ];then
            curpath=/tmp/monacodata/node$nodeidx/txs/$(basename $path)
            mkdir -p $curpath
            nodeidx=$((nodeidx+1))
        fi
        mv $path/$f $curpath
        counter=$((counter+1))
        if [ $counter -ge $4 ];then
            counter=0
        fi
        
    done    
done

for((i=0;i<$3;i++));
do
    cp $5 /tmp/monacodata/node$i/txs/
done


#!/bin/bash

prf="../data_awal_nc"
for i in `ls $prf | grep ".nc4"`; do
    ./specialized_args.R "$prf/$i" 8 8
done

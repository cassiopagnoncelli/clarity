#!/bin/bash

name=$1
qty=`echo "($2 + 300 - 1)/300" | bc`   # ceiling function, ceil(x, y) == floor(x+y-1, y)
authtoken="VAUwWyRdTWiYLnedNhuy"
#authtoken=$3

for i in `seq 1 $qty`; do
  wget http://www.quandl.com/api/v2/datasets.csv?query=*&source_code=$name&per_page=300&page=$i&auth_token=$authtoken
done

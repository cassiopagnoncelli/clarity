#!/bin/bash

wget https://www.quandl.com/data/$1 -q -O quandl_html.tmp
grep -A 1 "<td>Dataset Name</td>" quandl_html.tmp | tail -1 | sed "s/<td>//1" | sed "s/<\/td>//1"
grep -A 1 "<td>Description</td>" quandl_html.tmp | tail -1 | sed "s/<td><p sanitize=\"true\">//1" | sed "s/<\/p><\/td>//1"
rm quandl_html.tmp

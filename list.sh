#!/bin/bash

if [ $# -ne 1 ]; then
	echo "One parameter required: indicators|quandl|symbols"
	exit
fi

case "$1" in
'indicators')
  psql indicators -c '\d' | grep "table" | sed "s/ //g" | cut -d'|' -f 2
  ;;
'quandl')
  psql quandl -c '\d' | grep "table" | sed "s/ //g" | cut -d'|' -f 2 | grep -v 'meta'
  ;;
'symbols')
  psql timeseries -c '\d' | grep "table" | sed "s/ //g" | cut -d'|' -f 2
  ;;
esac

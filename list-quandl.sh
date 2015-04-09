#!/bin/bash

psql quandl -c '\d' | grep "table" | sed "s/ //g" | cut -d'|' -f 2 | grep -v 'meta'

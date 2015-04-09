#!/bin/bash

psql timeseries -c '\d' | grep "table" | sed "s/ //g" | cut -d'|' -f 2

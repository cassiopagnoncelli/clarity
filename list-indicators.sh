#!/bin/bash

psql indicators -c '\d' | grep "table" | sed "s/ //g" | cut -d'|' -f 2

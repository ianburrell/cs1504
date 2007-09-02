#!/bin/bash
date=$(date +%Y%m%D_%H%M%S)
ruby -Ilib bin/cs1504_dump.rb > dump_$date.txt
ruby -Ilib bin/cs1504_to_isbn.rn < dump_$date.txt > isbn_$date.txt

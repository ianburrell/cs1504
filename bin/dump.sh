#!/bin/bash -x
date=$(date +%Y%m%d_%H%M%S)
ruby -Ilib bin/cs1504_dump.rb --clear > dump_$date.txt
ruby -Ilib bin/cs1504_to_isbn.rb < dump_$date.txt > isbn_$date.txt

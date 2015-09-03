#!/bin/bash

# This script extracts from a specified C++ file all ranges of source
# lines that occur between Doxygen code-snippet delimiters. For
# example, suppose that our input file, namely test.cpp contains the
# following:
#
#   int foo() {
#     return 0;
#   }
#
#   //! [bar]
#   int bar() {
#     return 1;
#   }
#   //! [bar]
#
#   //! [baz]
#   int baz() {
#     return 2;
#   }
#   //! [baz]
#
# Now, if we call
#
#   $ extract_code_snippets.sh test.cpp test.out
#
# then, the script will first perform `touch test.out`, and the script
# will then create two files, namely "test.out.bar" and
# "test.out.baz".  Each of these latter two files will contain the
# source lines that appear between the corresponding delimiters. For
# example, the contents of test.out.bar will be:
#
#   int bar() {
#     return 1;
#   }
# 

SOURCE_FILE_NAME=$1
OUT_FILE_NAME=$2

touch $OUT_FILE_NAME

p=0
block_name=""
while IFS='' read -r line
do
    case $line in
        \/\/!*)
            p=$((1-$p));
            str=$line
            str1=${str##*\[}
            str2=${str1%%\]*}
            block_name=$str2
            continue;;
    esac
    filename="$OUT_FILE_NAME.$block_name"
    if [ "$p" -eq 1 ]; then
        echo "$line" >> $filename
    fi
done < $SOURCE_FILE_NAME


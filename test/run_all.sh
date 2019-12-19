#!/bin/bash

# Script to run the tests from inside a web container
readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

cd "${MY_DIR}"
TEST_FILES=(test_*.rb)
export RUBYOPT='-W2'
ruby -e "%w( ${TEST_FILES[*]} ).shuffle.map{ |file| require './'+file }"

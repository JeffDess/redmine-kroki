#!/bin/bash

if ! which entr &> /dev/null; then
  echo 'ERROR: You need to install entr to run this script (pacman -S entr)'
  exit 1
fi

find src/ -name "*.rb" | entr scripts/test.sh

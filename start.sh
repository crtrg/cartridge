#!/bin/sh
PORT=8081 \
  erl -sname cartridge -pa ebin -pa deps/*/ebin -s cartridge

#!/bin/sh
erl -sname cartridge -pa ebin -pa deps/*/ebin -s cartridge

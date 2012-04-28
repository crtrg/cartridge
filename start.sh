#!/bin/sh
erl -sname cowboy_examples -pa ebin -pa deps/*/ebin -s cowboy_examples

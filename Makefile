MOCHAFLAGS=--compilers coffee:coffee-script --require should

.PHONY: test test-watch

test:
	mocha $(MOCHAFLAGS) test/*

test-watch:
	mocha $(MOCHAFLAGS) --watch test/*

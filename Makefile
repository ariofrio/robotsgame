MOCHAFLAGS=--compilers coffee:coffee-script --require should

.PHONY: test test-watch

test:
	mocha $(MOCHAFLAGS) lib/robotsgame/*_test.coffee

test-watch:
	mocha $(MOCHAFLAGS) --watch lib/robotsgame/*_test.coffee

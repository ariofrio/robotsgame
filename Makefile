MOCHAFLAGS=--compilers coffee:coffee-script --require should

.PHONY: test test-watch

test:
	cd public/js; mocha $(MOCHAFLAGS) robotsgame/*_test.coffee

test-watch:
	cd public/js; mocha $(MOCHAFLAGS) --watch robotsgame/*_test.coffee

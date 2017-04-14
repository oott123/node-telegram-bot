PATH := ./node_modules/.bin:${PATH}

.PHONY: init clean build dist publish

build:
	coffee -o lib/ -c src/

init:
	npm install

clean:
	rm -rf lib/

dist: clean init build

publish: dist
	npm publish

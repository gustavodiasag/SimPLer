.PHONY: build clean format test

build:
	dune build @install

format:
	dune build @fmt
	
install:
	dune install

uninstall:
	dune uninstall

test:
	dune runtest

clean:
	dune clean
.PHONY: build
build: 
	# output goes to target/lambda
	# NOTE: not build with --release because it would make testing slow
	cargo lambda build --output-format zip 
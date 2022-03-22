.PHONY: build
build: 
	# output goes to target/lambda
	cargo lambda build --output-format zip 
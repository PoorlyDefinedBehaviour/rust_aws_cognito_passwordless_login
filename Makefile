.PHONY: build 
build: 
	cd ./create_auth_challenge && \
	cargo build && \
	cd .. && \
	mv ./target/debug/create_auth_challenge bootstrap && \
	zip bootstrap.zip bootstrap
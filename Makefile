.PHONY: build 
build: 
	cargo build; \
	mv ./target/debug/create_auth_challenge bootstrap && zip create_auth_challenge.zip bootstrap \
	mv ./target/debug/define_auth_challenge bootstrap && zip define_auth_challenge.zip bootstrap \
	mv ./target/debug/pre_signup bootstrap && zip pre_signup.zip bootstrap \
	mv ./target/debug/verify_auth_challenge bootstrap && zip verify_auth_challenge.zip bootstrap 
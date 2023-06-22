# Build
alias cbs="cargo-build-sbf"
alias cbp="cargo build-bpf"

# Deploy 
# Deploy first .so file
alias spd="solana program deploy (ls ./target/deploy/*.so | head -n 1)"
# Enter name of file you want to deploy
alias spd1="solana program deploy ./target/deploy/$1"

# Misc
alias sb="solana balance"
alias sdev="solana config set --url devnet"
alias slcl="solana config set --url localhost"

function build_docs() { # Build Solana docs and start local server
	ni &
	./build.sh &
	./build-cli-usage.sh &
	# Docker container necessary for generating svgs with svgbob on Apple Silicon macs
	docker run -it -v "$(pwd)/art:/solana/docs/art" -v "$(pwd)/static/img:/solana/docs/static/img" solana-docs-converter &
	nr start
}

function suck(){  # Transfers SOL from provided keypair to saved receiver, expects byte array with brackets

	# Return if no input
	if [[ -z "$1" ]]; then
		echo "Please provide a byte array"
		return 1
	fi

		local receiver_pubkey=$(solana address)
	local sender_bytes=$1

	# remove ; from input
	sender_bytes=${sender_bytes%;}
	
	# Create a temporary keypair with input
	local sender_keyfile=$(mktemp)	
	echo $sender_bytes > $sender_keyfile
	
	# Log balance of keypair
	local balance=$(solana balance --keypair $sender_keyfile)

	# If balance is not "0 SOL", transfer all SOL to receiver
	if [[ $balance != "0 SOL" ]]; then
		echo "Sucking $balance"
		solana transfer --keypair $sender_keyfile $receiver_pubkey ALL
	fi
	
	rm -f $sender_keyfile
}

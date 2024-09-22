# Build
alias cbs="cargo-build-sbf"
alias cbp="cargo build-bpf"

# Deploy first .so file
alias spd='
f() { if [ -d "./target/deploy/" ] && [ -n "$(ls -A ./target/deploy/*.so 2>/dev/null)" ]; 
then solana program deploy $(ls ./target/deploy/*.so | head -n 1); 
else echo "No .so files found in ./target/deploy/"; fi }; f'

# Enter name of file you want to deploy
spd_() {
  if [ -z "$1" ]; then
    echo "You must provide a filename"
    return 1
  fi
  solana program deploy "./target/deploy/$1"
}

# Misc
alias sb="solana balance"
alias scg="solana config get"
alias sdev="solana config set --url devnet"
alias slcl="solana config set --url localhost"

# Enable solana starship prompt
sol() {
  if [[ -z "$STARSHIP_SOLANA_TOGGLE" ]]; then
    export STARSHIP_SOLANA_TOGGLE="ON"
    echo "Solana prompt enabled"
  else
    unset STARSHIP_SOLANA_TOGGLE
    echo "Solana prompt disabled"
  fi
}

function build_docs() { # Build Solana docs and start local server
	ni &
	./build.sh &
	./build-cli-usage.sh &
	# Docker container necessary for generating svgs with svgbob on Apple Silicon macs
	docker run -it -v "$(pwd)/art:/solana/docs/art" -v "$(pwd)/static/img:/solana/docs/static/img" solana-docs-converter &
	nr start
}

function suck(){  # Transfers SOL from provided keypair to saved keypair $(solana address), expects byte array with brackets

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
	
	# Get balance of entered keypair
	local balance=$(solana balance --keypair $sender_keyfile)

	# If balance is not "0 SOL", transfer all SOL to receiver (output of "solana address")
	if [[ $balance != "0 SOL" ]]; then
		echo "Sucking $balance"
		solana transfer --keypair $sender_keyfile $receiver_pubkey ALL
	fi
	
	rm -f $sender_keyfile
}

function yoink() {   # Transfers all assets from provided keypair to saved receiver. Expects byte array with brackets.
    if [[ -z "$1" ]]; then
        echo "Please provide a byte array."
        return 1
    fi

    # Check if spl-token CLI is installed
    if ! command -v spl-token &> /dev/null; then
        echo "Error: spl-token CLI not found. Please install it and try again."
        return 1
    fi

    # Log the balance of the keypair
    local sol_balance=$(solana balance)

		# If empty, return
		if [[ $sol_balance == "0 SOL" ]]; then
			echo "No balance found for provided keypair."
			return 1
		fi

    local receiver_pubkey=$(solana address)

    # Store the original keypair path
    local original_keypair_path=$(solana config get | grep "Keypair Path:" | awk '{print $3}')

    # Create a new keypair file with the provided bytes
    local new_keypair_path="${HOME}/new-keypair.json"
    echo $1 > "$new_keypair_path"

    # Set the new keypair as the current keypair
    solana config set --keypair "$new_keypair_path" > /dev/null 2>&1
	
    # Loop through associated token accounts for the sender
    while IFS= read -r line; do
        if [[ -z "$line" || "$line" == "-----------------------------------------------------" ]]; then
            continue
        fi

        local token_mint=$(echo "$line" | awk '{print $1}')
        local balance=$(echo "$line" | awk '{print $2}')

        if [[ -n $token_mint && $balance != "0" ]]; then
            echo "Yoinking $balance tokens of mint $token_mint"
            spl-token transfer --fund-recipient --allow-unfunded-recipient $token_mint $balance $receiver_pubkey 
        fi
    done < <(spl-token accounts | tail -n +2)

		# Check balance again
		sol_balance=$(solana balance)
		
    # If the balance is not "0 SOL", transfer all SOL to the receiver
    if [[ $sol_balance != "0 SOL" ]]; then
        echo "Yoinking $sol_balance"
        solana transfer $receiver_pubkey ALL
    fi

    # Remove the temporary new keypair
    rm "$new_keypair_path"

    # Restore the previous configuration
    solana config set --keypair "$original_keypair_path" > /dev/null 2>&1
}

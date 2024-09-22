rpc_url=$(solana config get | grep 'RPC URL:' | awk '{print $3}')

if [[ $rpc_url == http://localhost* ]]; then
    echo "localhost"
else
    echo $rpc_url | sed -E 's/https:\/\/api\.([^.]+)\.solana\.com.*/\1/'
fi
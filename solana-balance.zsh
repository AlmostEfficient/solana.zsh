#!/bin/zsh

cache_file="/tmp/solana_balance_cache"
cache_timeout=600  # 10 minutes

if [ -f "$cache_file" ] && [ $(($(date +%s) - $(stat -f %m "$cache_file"))) -lt "$cache_timeout" ]; then
    cat "$cache_file"
else
    balance=$(solana balance 2>/dev/null | awk '{print $1}')
    if [ -n "$balance" ]; then
        echo "$balance" > "$cache_file"
        echo "$balance"
    else
        echo "N/A"
    fi
fi
## solana.zsh
zsh aliases and shortcuts to make developing, testing and contributing to Solana easier. tested on MacOS only.

### Setup
Copy `solana.zsh` over to your user folder (`~`) and add this to your `.zshrc` file:
```bash
source ~/solana.zsh
```

Reload your shell with
```bash
source ~/.zshrc
```

## Starship prompt
[Starship](https://starship.rs/) lets you customize your shell prompt. I've got mine set up to display current Solana cluster and balance.

<img width="818" alt="image" src="https://github.com/user-attachments/assets/5c9910fb-6417-4cf0-8c5a-7dfa1c46a23a">

To enable, copy over `solana-balance.zsh` and `solana-cluster.zsh` to ~ (or elsewhere and adjust `starship.toml` accordingly).

Make them executable:
```bash
chmod +x ~/solana-balance.zsh
chmod +x ~/solana-cluster.zsh
```

Update your Starship config as shown in `starship.toml`. 

Note: Since there's no way to detect if you're in a Solana project (unlike Node/Python/etc), I've set up a toggle function in `solana.zsh::25` that you can use to turn on/off the prompt. Toggle by running `sol` in your shell. 

> [!IMPORTANT]  
> since `solana balance` makes an API call, prompt balance is refreshed every 10 minutes, not every time Starship renders a new prompt (your balance is not live). this also causes first call to take like 400ms.

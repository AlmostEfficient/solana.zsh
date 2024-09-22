# solana.zsh
This file contains zsh aliases and shortcuts to make developing, testing and contributing to Solana easier. Built and tested on MacOS only.

## Setup
Copy this file over to your user folder (`~`) and add this to your `.zshrc` file:
```bash
source ~/solana.zsh
```

Reload your shell with
```bash
source ~/.zshrc
```

## Starship prompt
[Starship](https://starship.rs/) lets you customize your shell prompt. I've got mine set up to display current Solana cluster and balance.

To enable, copy over `solana-balance.zsh` and `solana-cluster.zsh` to ~ (or elsewhere and adjust `starship.toml` accordingly).

Make them executable:
```bash
chmod +x ~/solana-balance.zsh
chmod +x ~/solana-cluster.zsh
```

Update your Starship config as shown in `starship.toml`. Your shell should look something like this:


Note: Since there's no way to detect if you're in a Solana project (unlike Node/Python/etc), I've set up a toggle function in `solana.zsh::25` that you can use to turn on/off the prompt. Toggle by running `sol` in your shell. 

since solana balance makes an API call, the balance is refreshed every 10 minutes, not every time Starship renders a new prompt. This also causes first call to take like 400ms.

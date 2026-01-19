# GitHub SSH Setup

Quick guide for SSH authentication with GitHub.

## Generate SSH Key

```bash
ssh-keygen -t ed25519 -C "your-email@example.com" -f ~/.ssh/github_ed25519
```

## Add Key to SSH Agent

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/github_ed25519
```

## Copy Public Key

```bash
cat ~/.ssh/github_ed25519.pub
```

Add to: https://github.com/settings/keys

## Configure SSH

Create `~/.ssh/config`:

```
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/github_ed25519
    AddKeysToAgent yes
    IdentitiesOnly yes
```

## Set Permissions

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/github_ed25519
chmod 644 ~/.ssh/github_ed25519.pub
chmod 644 ~/.ssh/config
```

## Test Connection

```bash
ssh -T git@github.com
```

## Use SSH for All GitHub URLs

```bash
git config --global url."git@github.com:".insteadOf "https://github.com/"
```

## Troubleshooting

```bash
ssh -vT git@github.com    # Verbose debug
ssh-add -l                # List loaded keys
ssh-add -D                # Clear all keys
```

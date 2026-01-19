# GitHub SSH Setup Guide

## Prerequisites

- Git installed
- GitHub account

## Setup Steps

### 1. Generate SSH Key

```bash
ssh-keygen -t ed25519 -C "your-email@example.com" -f ~/.ssh/github_ed25519
```

Enter a strong passphrase when prompted.

### 2. Start SSH Agent and Add Key

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/github_ed25519
```

### 3. Copy Public Key

```bash
cat ~/.ssh/github_ed25519.pub
```

Copy the entire output.

### 4. Add Key to GitHub

1. Go to [GitHub SSH Settings](https://github.com/settings/keys)
2. Click **New SSH key**
3. Paste your public key
4. Give it a descriptive title (e.g., "Dell-XPS-Laptop")

### 5. Configure SSH Client

Create/edit `~/.ssh/config`:

```
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/github_ed25519
    AddKeysToAgent yes
    IdentitiesOnly yes
```

### 6. Set Correct Permissions

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/github_ed25519
chmod 644 ~/.ssh/github_ed25519.pub
chmod 644 ~/.ssh/config
```

### 7. Test Connection

```bash
ssh -T git@github.com
```

Expected output: `Hi username! You've successfully authenticated...`

### 8. Configure Git to Use SSH

```bash
git config --global url."git@github.com:".insteadOf "https://github.com/"
```

## Verification

Clone a private repo:

```bash
git clone git@github.com:username/private-repo.git
```

## Troubleshooting

**Permission denied:**

```bash
ssh -vT git@github.com  # Verbose output for debugging
```

**Wrong key being used:**

```bash
ssh-add -l  # List loaded keys
ssh-add -D  # Clear all keys
ssh-add ~/.ssh/github_ed25519  # Re-add correct key
```

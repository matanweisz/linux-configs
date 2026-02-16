#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# macOS Defaults - Developer Settings
# =============================================================================

osascript -e 'tell application "System Preferences" to quit' 2>/dev/null || true

# ---- Keyboard ----
defaults write NSGlobalDomain KeyRepeat -int 2                            # fast key repeat
defaults write NSGlobalDomain InitialKeyRepeat -int 15                    # short delay
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3                  # full keyboard nav

# ---- Finder ----
defaults write com.apple.finder AppleShowAllFiles -bool true              # show hidden files
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"       # list view
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"       # search current folder
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
chflags nohidden ~/Library 2>/dev/null || true

# ---- Dock ----
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.3
defaults write com.apple.dock minimize-to-application -bool true
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock tilesize -int 48
defaults write com.apple.dock mru-spaces -bool false                      # don't rearrange spaces
defaults write com.apple.dock expose-animation-duration -float 0.1

# ---- Screenshots ----
mkdir -p "${HOME}/Screenshots"
defaults write com.apple.screencapture location -string "${HOME}/Screenshots"
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool true

# ---- Trackpad ----
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true

# ---- Misc ----
defaults write com.apple.LaunchServices LSQuarantine -bool false          # no "open app?" dialog
defaults write com.apple.TextEdit RichText -int 0                         # plain text default
defaults write com.apple.ActivityMonitor ShowCategory -int 0              # show all processes

# ---- Apply ----
killall Finder Dock SystemUIServer 2>/dev/null || true
echo "macOS defaults applied. Some changes need a logout/restart."

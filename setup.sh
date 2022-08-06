#!/bin/bash

# Turn off font smoothing
# See here for why https://tonsky.me/blog/monitors/
defaults write-currentHost -g AppleFontSmoothing -int 0

# Re-enable slow animations while holding down Shift
defaults write com.apple.dock slow-motion-allowed -bool true

# Always expand open/save dialogs
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Disable chime when charging
defaults write com.apple.PowerChime ChimeOnAllHardware -bool false

# Disable accent key when holding down keys
sudo defaults write -g ApplePressAndHoldEnabled -bool false

# Disable Dock delay
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -int 0

# Always show full file extension in Finder
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Make crash reports appear as notifications
defaults write com.apple.CrashReporter UseUNC 1

# Restart processes
killall Dock
killall Finder
killall PowerChime

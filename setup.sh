#!/bin/bash

# Turn off font smoothing
# See here for why https://tonsky.me/blog/monitors/
defaults write-currentHost -g AppleFontSmoothing -int 0

# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
# Disable auto-capitalization
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
# Disable adding period after double space
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# Enable dragging window from anywhere while holding Ctrl + Cmd
defaults write -g NSWindowShouldDragOnGesture -bool true

# Don't display thumbnail after taking a screenshot
defaults write com.apple.screencapture show-thumbnail -bool false

# Use jpgs instead of pngs for screenshots since much more space-efficient
defaults write com.apple.screencapture type -string jpg

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

# Hide recent apps from Dock
defaults write com.apple.dock show-recents -bool false

# Always show full file extension in Finder
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Don't display warning when changing file extension in Finder
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Make crash reports appear as notifications
defaults write com.apple.CrashReporter UseUNC 1

# Restart processes
killall Dock
killall Finder
killall PowerChime

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

# Don't show open dialog when launching document apps
# via https://mas.to/@timac@mastodon.social/109851379681544342
defaults write -g NSShowAppCentricOpenPanelInsteadOfUntitledFile -bool false

# Disable chime when charging
defaults write com.apple.PowerChime ChimeOnAllHardware -bool false

# Disable accent key when holding down keys
sudo defaults write -g ApplePressAndHoldEnabled -bool false

# "Delay until repeat" setting in System Settings > Keyboard
# 15 (225 ms) is normal minimum configurable via UI
# via https://gist.github.com/hofmannsven/ff21749b0e6afc50da458bebbd9989c5
# Also see https://github.com/ZaymonFC/mac-os-key-repeat
defaults write -g InitialKeyRepeat -int 15

# "Key repeat rate" setting in System Settings > Keyboard
# Note that this is the interval in between repeats, so the lower this value the faster the repeats will be fired
# 2 (30 ms) is normal minimum configurable via UI
# via https://gist.github.com/hofmannsven/ff21749b0e6afc50da458bebbd9989c5
# Also see https://github.com/ZaymonFC/mac-os-key-repeat
defaults write -g KeyRepeat -int 2

# Disable Dock delay
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -int 0

# Hide recent apps from Dock
defaults write com.apple.dock show-recents -bool false

# Hide all icons on Desktop
defaults write com.apple.finder CreateDesktop -bool false

# Always show full file extension in Finder
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show path bar in Finder
defaults write com.apple.finder ShowPathbar -bool true

# Don't display warning when changing file extension in Finder
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Make crash reports appear as notifications
defaults write com.apple.CrashReporter UseUNC 1

# Set TextEdit default document format to plain text
defaults write com.apple.TextEdit RichText -bool false

# Set Activity Monitor update frequency to 2s
defaults write com.apple.ActivityMonitor UpdatePeriod -int 2

# Xcode defaults configuration
defaults write com.apple.dt.Xcode CodeFoldingAnimationSpeed -float 0.0
defaults write com.apple.dt.Xcode XcodeCloudUpsellPromptEnabled -bool false

# Install app-specific keyboard shortcuts
# https://apple.stackexchange.com/questions/398561/how-to-set-system-keyboard-shortcuts-via-command-line
# Note that the -array-add command is not idempotent, and there's no built-in defaults -array-remove, so if this runs multiple times may have to do some manual cleanup by clearing the custommenu.apps array and re-adding everything from scratch
# NetNewsWire.app: Edit > Copy Article URL is Shift+Cmd+C
defaults write com.apple.universalaccess com.apple.custommenu.apps -array-add "com.ranchero.NetNewsWire-Evergreen"
defaults write com.ranchero.NetNewsWire-Evergreen NSUserKeyEquivalents -dict-add "Copy Article URL" -string "@\$C"

# Messages.app: Conversation > Delete Conversation is Opt+Cmd+9
defaults write com.apple.universalaccess com.apple.custommenu.apps -array-add "com.apple.MobileSMS"
defaults write com.apple.MobileSMS NSUserKeyEquivalents -dict-add "Delete Conversation..." -string "@~9"

# Prime Video.app: View > Stay on top is Ctrl+Cmd+T
defaults write com.apple.universalaccess com.apple.custommenu.apps -array-add "com.amazon.aiv.AIVApp"
defaults write com.apple.MobileSMS NSUserKeyEquivalents -dict-add "Stay on top" -string "@^t"

# IINA.app: Playback > Jump to Beginning is Shift+Cmd+J
defaults write com.apple.universalaccess com.apple.custommenu.apps -array-add "com.colliderli.iina"
defaults write com.apple.MobileSMS NSUserKeyEquivalents -dict-add "Jump to Beginning" -string "@\$j"

# BBEdit: Window > Notes is Opt+1
defaults write com.apple.universalaccess com.apple.custommenu.apps -array-add "com.barebones.bbedit"
defaults write com.apple.MobileSMS NSUserKeyEquivalents -dict-add "Notes" -string "~1"
defaults write com.apple.MobileSMS NSUserKeyEquivalents -dict-add "Remove Note" -string "@~9"

sleep 2

# Install Rosetta 2
softwareupdate --install-rosetta --agree-to-license

sleep 2

# Restart processes
killall Dock
killall Finder
killall PowerChime

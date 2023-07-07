#!/bin/bash

# Full Disk Access is necessary for writing to com.apple.universalaccess preference domain
# prompt code via https://stackoverflow.com/a/1885534
read -p "Make sure that the current terminal app ($TERM_PROGRAM) has full disk access (System Settings > Privacy & Security > Full Disk Access) before continuing. Type y to continue: " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
  exit 1
fi

# Disable Homebrew analytics
brew analytics off

# Turn off font smoothing
# See here for why https://tonsky.me/blog/monitors/
defaults write-currentHost -g AppleFontSmoothing -int 0

# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
# Disable auto-capitalization
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
# Disable adding period after double space
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
# Disable smart quotes
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Enable dragging window from anywhere while holding Ctrl + Cmd
defaults write -g NSWindowShouldDragOnGesture -bool true

# Expand resize drag area
defaults write -g AppleEdgeResizeExteriorSize -int 15

# Don't display thumbnail after taking a screenshot
defaults write com.apple.screencapture show-thumbnail -bool false

# Use jpgs instead of pngs for screenshots since much more space-efficient
defaults write com.apple.screencapture type -string jpg

# Re-enable slow animations while holding down Shift
defaults write com.apple.dock slow-motion-allowed -bool true

# Always show proxy/document icons in window title bars
defaults write com.apple.universalaccess showWindowTitlebarIcons -bool true
# Remove rollover delay from title bar icon (even though should always appear from above command)
defaults write -g NSToolbarTitleViewRolloverDelay -float 0

# Always expand open/save dialogs
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Disable "Natural scrolling"
defaults write -g com.apple.swipescrolldirection -bool false

# Always show scroll bars
defaults write -g AppleShowScrollBars -string "Always"

# Set sidebar icon size to large
defaults write -g NSTableViewDefaultSizeMode -int 3

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

# Enable Dock autohide
defaults write com.apple.dock autohide -bool true
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

# Set default location of new Finder windows to ~/Downloads
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Downloads"

# Make crash reports appear as notifications
defaults write com.apple.CrashReporter UseUNC 1

# Show full URL in Safari address bar
# Update (6/25/23): doesn't seem to work as of Ventura 13.2 + Safari 16.3, can only change this via the Safari Settings window
# defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

# Set Safari home page to about:blank
defaults write com.apple.Safari HomePage -string "about:blank"

# Only enable AutoFill for address book (for icloud hide my email integration) and credit card (for apple card integration)
defaults write com.apple.Safari AutoFillFromAddressBook -bool true
defaults write com.apple.Safari AutoFillCreditCardData -bool true
defaults write com.apple.Safari AutoFillPasswords -bool false
defaults write com.apple.Safari AutoFillMiscellaneousForms -bool false

# Enable Develop menu in Safari
defaults write com.apple.Safari IncludeDevelopMenu -bool true

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

# TODO: automate and/or add message about logging out / rebooting

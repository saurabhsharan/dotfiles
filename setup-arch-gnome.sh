#!/bin/bash

# List of packages to install
# Each line is a package, lines starting with # are comments
read -r -d '' PACKAGES <<EOM
# dev tools
alacritty
atuin
cmake
fish
git
lazygit
neovim
ruby
ruby-irb
rust
starship
the_silver_searcher
wezterm

# linux tools
age
btop
cpufetch
csvlens
dust
evtest
exa
fastfetch
glow
inxi
neofetch
plocate
tldr
tree
rclone
vi

# apps
chromium
firefox
solaar
vivaldi
vlc

# gnome
gnome-browser-connector
gnome-screenshot
gnome-shell-extensions
gnome-tweaks
libayatana-appindicator

# wayland
wl-clipboard

# fonts
adobe-source-code-pro-fonts
# international fonts via https://gist.github.com/AntonFriberg/9e67269639b5ba3b2020c2396eb35216 (see comment about sans-serif version)
adobe-source-han-sans-cn-fonts
adobe-source-han-sans-jp-fonts
adobe-source-han-sans-kr-fonts
adobe-source-han-sans-otc-fonts
adobe-source-han-sans-tw-fonts
nerd-fonts

# networking
iw
iwctl
wavemon
wireless_tools

# media
ffmpeg
gst-plugin-openh264
perl-image-exiftool
yt-dlp

# system
dbus
libxkbcommon
pacman-contrib
# adds Power Mode to GNOME Settings
power-profiles-daemon
wxwidgets-gtk3
dconf-editor
EOM

install_pacman_packages() {
  echo "Installing Pacman packages..."
  pacman -Syu --noconfirm
  echo "$PACKAGES" | grep -v '^#' | xargs pacman -S --needed --noconfirm
}

install_yay() {
  echo "Installing Yay..."
  if ! command -v yay &>/dev/null; then
    su - $SUDO_USER <<EOF
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd ..
        rm -rf yay
EOF
  else
    echo "Yay is already installed."
  fi
}

install_yay_packages() {
  echo "Installing Yay packages..."
  # Add AUR packages here
  AUR_PACKAGES="doggo-bin cyme-bin localsend-bin sioyek ulauncher"
  su - $SUDO_USER -c "yay -S --needed --noconfirm $AUR_PACKAGES"
}

set_gnome_settings() {
  echo "Setting GNOME settings..."

  gsettings set org.gnome.desktop.interface clock-show-seconds true
  gsettings set org.gnome.desktop.interface clock-show-weekday true
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
  gsettings set org.gnome.desktop.interface enable-hot-corners false

  gsettings set org.gnome.desktop.peripherals.keyboard delay 320
  gsettings set org.gnome.desktop.peripherals.keyboard repeat true
  gsettings set org.gnome.desktop.peripherals.keyboard repeat-interval 18
  gsettings set org.gnome.desktop.peripherals.mouse natural-scroll false
  gsettings set org.gnome.desktop.peripherals.touchpad tap-and-drag false

  gsettings set org.gnome.desktop.wm.keybindings always-on-top "['<Super><Control>t']"
  gsettings set org.gnome.desktop.wm.keybindings maximize "[]"
  gsettings set org.gnome.desktop.wm.keybindings minimize "['<Super>m']"
  gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-down "[]"
  gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-left "[]"
  gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-right "[]"
  gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-up "[]"
  gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-left "['<Control><Alt><Super>Left']"
  gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-right "['<Control><Alt><Super>Right']"
  gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-1 "['<Control>1']"
  gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-2 "['<Control>2']"
  gsettings set org.gnome.desktop.wm.keybindings switch-applications "[]"
  gsettings set org.gnome.desktop.wm.keybindings switch-input-source "[]"
  gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward "[]"
  gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Super>Tab']"

  gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:appmenu'

  gsettings set org.gnome.mutter center-new-windows true
  gsettings set org.gnome.mutter edge-tiling false
  gsettings set org.gnome.mutter dynamic-workspaces false
  gsettings set org.gnome.mutter overlay-key ''
  gsettings set org.gnome.mutter workspaces-only-on-primary false

  gsettings set org.gnome.mutter.keybindings toggle-tiled-left "[]"
  gsettings set org.gnome.mutter.keybindings toggle-tiled-right "[]"

  gsettings set org.gnome.settings-daemon.plugins.media-keys magnifier "[]"
  gsettings set org.gnome.settings-daemon.plugins.media-keys magnifier-zoom-in "[]"
  gsettings set org.gnome.settings-daemon.plugins.media-keys magnifier-zoom-out "[]"
  gsettings set org.gnome.settings-daemon.plugins.media-keys on-screen-keyboard "[]"
  gsettings set org.gnome.settings-daemon.plugins.media-keys screenreader "[]"
  gsettings set org.gnome.settings-daemon.plugins.media-keys screensaver "['<Control><Super>q']" # lock screen shortcut

  gsettings set org.gnome.shell.keybindings focus-active-notification "[]"
  gsettings set org.gnome.shell.keybindings open-new-window-application-1 "[]"
  gsettings set org.gnome.shell.keybindings open-new-window-application-2 "[]"
  gsettings set org.gnome.shell.keybindings open-new-window-application-3 "[]"
  gsettings set org.gnome.shell.keybindings open-new-window-application-4 "[]"
  gsettings set org.gnome.shell.keybindings open-new-window-application-5 "[]"
  gsettings set org.gnome.shell.keybindings open-new-window-application-6 "[]"
  gsettings set org.gnome.shell.keybindings open-new-window-application-7 "[]"
  gsettings set org.gnome.shell.keybindings open-new-window-application-8 "[]"
  gsettings set org.gnome.shell.keybindings open-new-window-application-9 "[]"
  gsettings set org.gnome.shell.keybindings switch-to-application-1 "[]"
  gsettings set org.gnome.shell.keybindings switch-to-application-2 "[]"
  gsettings set org.gnome.shell.keybindings switch-to-application-3 "[]"
  gsettings set org.gnome.shell.keybindings switch-to-application-4 "[]"
  gsettings set org.gnome.shell.keybindings switch-to-application-5 "[]"
  gsettings set org.gnome.shell.keybindings switch-to-application-6 "[]"
  gsettings set org.gnome.shell.keybindings switch-to-application-7 "[]"
  gsettings set org.gnome.shell.keybindings switch-to-application-8 "[]"
  gsettings set org.gnome.shell.keybindings switch-to-application-9 "[]"
  gsettings set org.gnome.shell.keybindings toggle-application-view "[]"
  # toggle-message-tray also clears the shortcut for "System > Show the notification list"
  gsettings set org.gnome.shell.keybindings toggle-message-tray "[]"
  gsettings set org.gnome.shell.keybindings toggle-overview "[]"
  gsettings set org.gnome.shell.keybindings toggle-quick-settings "[]"
}

install_gnome_extensions() {
  echo "Installing GNOME extensions..."
  # You might want to use a tool like gnome-shell-extension-installer
  # For example:
  # su - $SUDO_USER -c "gnome-shell-extension-installer 19 307 1160"
}

configure_gnome_extensions() {
  echo "Configuring GNOME extensions..."
  # Add commands to configure GNOME extensions here
  # For example:
  # su - $SUDO_USER -c "dconf write /org/gnome/shell/extensions/user-theme/name \"'YourThemeName'\""
}

main() {
  install_pacman_packages
  install_yay
  install_yay_packages
  set_gnome_settings
  install_gnome_extensions
  configure_gnome_extensions
}

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root"
  exec sudo "$0" "$@"
fi

main

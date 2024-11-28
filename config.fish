# Use Homebrew
eval (env SHELL=fish /opt/homebrew/bin/brew shellenv)

# Use Starship
starship init fish | source

# prevent __pycache__ files https://www.scivision.dev/python-pycache-eliminate
set -gx PYTHONDONTWRITEBYTECODE 1

# Force exa to always print output in one line/column (i.e. without a grid)
# No native env var to disable grid view by default, so as a hack just set the minimum threshold for displaying a grid to some really large number
# https://the.exa.website/docs/environment-variables
set -gx EXA_GRID_ROWS 10000000

# `cdf` will change shell's current directory to frontmost Finder window
function cdf
    cd (osascript -e 'tell application "Finder" to get POSIX path of (target of front Finder window as text)')
end

# via https://mastodon.online/@nikitonsky/111421674555445464
function ckdir
    mkdir -p $argv[1] && cd $argv[1]
end

# `f` will open current directory in new Finder window
alias f='open -a Finder .'

alias g="git"
alias gs="git status -sb"
alias gcd="git clone --depth 1"
alias gpu="git push"
alias gd="git diff"
alias gfa="git fetch --all"
alias gcd="git clone --depth 1"
alias gpf="git pull --ff-only"
alias git-my-branches="git for-each-ref --format=' %(authorname) %09 %(refname)' --sort=authorname | grep -i saurabh"

set -gx RCLONE_IGNORE_EXISTING true
set -gx RCLONE_EXCLUDE ".directory"
set -gx RCLONE_PROGRESS true
alias rcp="rclone copy"

alias ls-dir="ls -d */"
alias lsd="ls-dir"

alias sl="ls"
alias s="ls"
alias l="ls"
alias lsl="ls"
alias sls="ls"
alias la="ls -A"

alias v="vim"
alias vi="vim"
alias vmi="vim"
alias imv="vim"
alias miv="vim"
alias iv="vim"

alias m="make"
alias ma="make"
alias mak="make"
alias mkae="make"
alias mka="make"
alias maek="make"
alias mke="make"
alias amke="make"
alias akme="make"
alias amek="make"
alias mk="make"

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."
alias .......="cd ../../../../../.."

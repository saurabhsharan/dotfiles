# prevent __pycache__ files https://www.scivision.dev/python-pycache-eliminate
set -gx PYTHONDONTWRITEBYTECODE 1

# `cdf` will change shell's current directory to frontmost Finder window
function cdf
  cd (osascript -e 'tell application "Finder" to get POSIX path of (target of front Finder window as text)')
end

alias g="git"
alias gs="git status -sb"

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

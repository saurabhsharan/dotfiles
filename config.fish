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

# `ffile` prints path of selected file in Finder
# via https://alexwlchan.net/2024/finder-terminal-tools
function ffile
    osascript -e 'tell application "Finder" to get POSIX path of first item of (selection as alias list)'
end

# via https://mastodon.online/@nikitonsky/111421674555445464
function ckdir
    mkdir -p $argv[1] && cd $argv[1]
end

function age-passphrase-encrypt
    if test (count $argv) -ne 1
        echo "Usage: age-passphrase-encrypt <file>"
        return 1
    end

    set -l input_file $argv[1]
    set -l output_file "$input_file.age"

    echo "+ age --passphrase --output $output_file $input_file"
    age --passphrase --output $output_file $input_file
end

function github-mirror
    # Check if a URL was provided
    if test -z "$argv[1]"
        echo "Error: Please provide a GitHub repository URL"
        echo "Usage: github-mirror https://github.com/username/repo-name"
        return 1
    end

    # Extract the repo name from the URL
    set repo_url $argv[1]

    # Extract just the repo name from the URL (last part)
    set repo_name (string match -r '[^/]+$' $repo_url)

    # If no repo name could be extracted, exit with an error
    if test -z "$repo_name"
        echo "Error: Could not extract repository name from URL"
        return 1
    end

    # Get today's date in YYYY-MM-DD format
    set today_date (date +%Y-%m-%d)

    # Format the directory and tar file names
    set dir_name "$today_date-$repo_name"
    set tar_name "$dir_name.tar.gz"

    # Run the commands
    echo "Cloning repository to $dir_name..."
    git clone --mirror $repo_url $dir_name

    if test $status -ne 0
        echo "Error: Failed to clone the repository"
        return 1
    end

    echo "Creating archive $tar_name..."
    tar -czf $tar_name $dir_name

    if test $status -ne 0
        echo "Error: Failed to create the archive"
        return 1
    end

    echo "Successfully created mirror clone archive: $tar_name"
end

# `f` will open current directory in new Finder window
alias f='open -a Finder .'

alias j="z"

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
set -gx RCLONE_EXCLUDE ".directory,.DS_Store"
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

alias firefly-up="cd ~/Downloads/firefly3 && docker-compose -f docker-compose.yml up -d --pull=always"
alias firefly-down="cd ~/Downloads/firefly3 && docker-compose -f docker-compose.yml down"

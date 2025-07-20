alias showFiles='defaults write com.apple.finder AppleShowAllFiles YES;
killall Finder /System/Library/CoreServices/Finder.app'
alias hideFiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app'
# node version manager
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

alias brewup='brew update; brew upgrade; brew prune; brew cleanup; brew doctor'
alias nfslogin='ssh jenchan_ifcatsneedart@ssh.phx.nearlyfreespeech.net'
alias expose=../script/expose.sh
# Set up fzf key bindings and fuzzy completion
eval "$(fzf --bash)"

. "$HOME/.cargo/env"

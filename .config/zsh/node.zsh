export NVM_DIR="$HOME/.nvm"
[ -s "$(brew --prefix nvm)/nvm.sh" ] && source "$(brew --prefix nvm)/nvm.sh"
[ -s "$(brew --prefix nvm)/etc/bash_completion.d/nvm" ] && source "$(brew --prefix nvm)/etc/bash_completion.d/nvm"

# Auto-switch node version when entering a directory with an .nvmrc
_nvm_auto_use() {
	[[ -f .nvmrc ]] && nvm use --silent
}

autoload -U add-zsh-hook
add-zsh-hook chpwd _nvm_auto_use

_nvm_auto_use  # Run on initial shell load to catch current directory

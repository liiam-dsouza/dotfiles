export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"

# Auto-switch Python version and activate venv on cd
_python_auto_use() {
	# If a .python-version file exists, pyenv picks it up automatically
	# via pyenv init - so nothing extra needed there

	# Auto-activate .venv if it exists in the current directory
	if [[ -d ".venv" ]]; then
		source ".venv/bin/activate"

	# If we've moved out of a venv'd directory, deactivate
	elif [[ -n "$VIRTUAL_ENV" ]] && [[ "$PWD" != "$VIRTUAL_ENV"* ]]; then
		deactivate
	fi
}

autoload -U add-zsh-hook
add-zsh-hook chpwd _python_auto_use

_python_auto_use  # Run on initial shell load to catch current directory

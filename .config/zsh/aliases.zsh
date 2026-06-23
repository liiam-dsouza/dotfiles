# lsd
alias ls="lsd"
alias ll="lsd -l"
alias la="lsd -a"
alias lla="lsd -la"
alias lt="lsd --tree"

# tools
alias lzg="lazygit"
alias lzd="lazydocker"
alias fr="fresh"
alias top="btop"
alias cat="bat"
alias catp="bat --plain"
alias yless="jless --yaml"
alias help="tldr"

# suffix aliases
alias -s md="bat"
alias -s mov="open"
alias -s mp4="open"
alias -s png="open"
alias -s yaml="jless --yaml"
alias -s yml="jless --yaml"
alias -s json="jless"

# global aliases
alias -g NE="2>/dev/null"
alias -g DN="> /dev/null"
alias -g NUL=">/dev/null 2>&1"
alias -g G="| grep"
alias -g L="| less"
alias -g JQ="| jq"
alias -g C="| pbcopy"
alias -g P="pbpaste >"

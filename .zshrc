# Powerlevel10k instant prompt — must be at the very top
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ── Zinit ──────────────────────────────────────────────────────────────────────
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

# ── Plugins ────────────────────────────────────────────────────────────────────
# p10k loads eagerly so the prompt is available immediately
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Remaining plugins load asynchronously after the prompt appears (turbo mode)
# syntax-highlighting must be last so it can wrap the other plugins
zinit wait lucid for \
	zsh-users/zsh-completions \
  	zsh-users/zsh-autosuggestions \
  	Aloxaf/fzf-tab \
 	atload"zicompinit; zicdreplay" \
  	zdharma-continuum/fast-syntax-highlighting \
	hlissner/zsh-autopair

# ── Powerlevel10k ──────────────────────────────────────────────────────────────
# Customise prompt by running `p10k configure`, or edit ~/.p10k.zsh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ── Keybindings ────────────────────────────────────────────────────────────────
bindkey -e
bindkey "^p" history-search-backward
bindkey "^n" history-search-forward

# ── History ────────────────────────────────────────────────────────────────────
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups

# ── Completion styling ─────────────────────────────────────────────────────────
zstyle ":completion:*" matcher-list "m:{a-z}={A-Za-z}"
zstyle ":completion:*" list-colors "${(s.:.)LS_COLORS}"
zstyle ":completion:*" menu no
zstyle ":fzf-tab:complete:cd:*" fzf-preview "lsd --tree --icon never --color always \$realpath 2>/dev/null | head -50"

# ── Modular config ─────────────────────────────────────────────────────────────
# paths.zsh is sourced explicitly first so PATH is set before other modules run
source ~/.config/zsh/paths.zsh
for config_file in ~/.config/zsh/*.zsh; do
  	[[ "$config_file" == */paths.zsh ]] && continue
  	source "$config_file"
done

# ── Shell integrations ─────────────────────────────────────────────────────────
eval "$(fzf --zsh)"
eval "$(zoxide init zsh --cmd cd)"
fuck() {
	eval "$(thefuck --alias)"
	unset -f fuck
	fuck "$@"
} # lets you use `fuck` to correct previous command

# ── Environment ────────────────────────────────────────────────────────────────
export BAT_PAGER="less -F --mouse"
export LESS='-R'

# ── Fastfetch ──────────────────────────────────────────────────────────────────
fastfetch

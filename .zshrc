. ~/.zsh/conf.sh
. ~/.zsh/alias.sh
. ~/.zsh/func.sh
. ~/.zsh/keyboard.sh
. ~/.zsh/tmux.sh

[[ $OSTYPE == linux*   && -f ~/.zsh/linux.sh ]]   && source ~/.zsh/linux.sh

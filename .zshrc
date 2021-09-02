. ~/.zsh/conf.sh
. ~/.zsh/alias.sh
. ~/.zsh/func.sh
. ~/.zsh/keyboard.sh

[[ $OSTYPE == linux*   && -f ~/.zsh/linux.sh ]]   && source ~/.zsh/linux.sh
[[ $OSTYPE == freebsd* && -f ~/.zsh/freebsd.sh ]] && source ~/.zsh/freebsd.sh

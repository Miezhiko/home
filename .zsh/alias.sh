# Asynchronous typing support O_o
alias gti=git
alias tgi=git
alias tig=git
alias igt=git
alias itg=git

alias sl=ls

alias cls="clear"

# Default commands args
alias du='du -sh'
alias cat='bat'

alias chmod="chmod -c"
alias chown="chown -c"

if which colordiff > /dev/null 2>&1; then
  alias diff="colordiff -Nuar"
else
  alias diff="diff -Nuar"
fi

alias grep='grep --colour=auto'
alias egrep='egrep --colour=auto'

alias ды='ls --color=auto --human-readable --group-directories-first --classify'
alias ls='ls --color=auto --human-readable --group-directories-first --classify'

#editors
alias n='nano'
alias g='gedit "$@" 2>/dev/null'

#because of zsh...
alias calc='noglob _calc'

#DEVELOPPMENT:
alias genpatch='diff -Naur'

alias p='pijul'

alias gl='git pull'
alias gb='git branch'
alias gd='git diff'
alias gp='git push'

alias cmake_debug='cmake $1 -DCMAKE_BUILD_TYPE=DEBUG'
alias cmake_release='cmake $1 -DCMAKE_BUILD_TYPE=RELEASE'

#misc
alias unwindows='iconv -f WINDOWS-1251 -t UTF-8'

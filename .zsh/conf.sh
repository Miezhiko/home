export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

ZDOTDIR=${ZDOTDIR:-${HOME}}
ZSHDDIR="${HOME}/.config/zsh.d"
HISTFILE="${ZDOTDIR}/.zsh_history"
HISTSIZE='10000'
SAVEHIST="${HISTSIZE}"
autoload colors && colors

# Ignore duplicate in history.
setopt hist_ignore_dups
setopt hist_ignore_space
setopt noflowcontrol

setopt extendedGlob
setopt NO_NOMATCH
autoload -U zmv
autoload -U zargs

() {
  local LC_ALL="" LC_CTYPE="en_US.UTF-8"
  SEGMENT_SEPARATOR='>'
}

[[ ${TERM} != dumb ]] && () {
  local termtitle_format
  local zhooks zhook
  zstyle -a ':zim:termtitle' hooks 'zhooks' || zhooks=(precmd)
  setopt prompt{percent,subst}
  autoload -Uz add-zsh-hook
  for zhook in ${zhooks}; do
    if [[ ${TERM_PROGRAM} == Apple_Terminal ]]; then
      termtitle_update_${zhook}() {
        print -n "\E]7;${PWD}\a"
      }
    else
      zstyle -s ":zim:termtitle:${zhook}" format 'termtitle_format' || \
          zstyle -s ':zim:termtitle' format 'termtitle_format' || \
          termtitle_format='%n@%m: %~'
      case ${TERM} in
        screen)
          builtin eval "termtitle_update_${zhook}() { print -Pn '\Ek'${(qq)termtitle_format}'\E\\' }"
          ;;
        *)
          builtin eval "termtitle_update_${zhook}() { print -Pn '\E]0;'${(qq)termtitle_format}'\a' }"
          ;;
      esac
    fi
    add-zsh-hook ${zhook} termtitle_update_${zhook}
  done
}

# Completion.
autoload -Uz compinit
compinit
zstyle ':completion:*::::' completer _expand _complete _ignored _approximate
zstyle -e ':completion:*:approximate:*' max-errors 'reply=( $(( ($#PREFIX+$#SUFFIX)/3 )) numeric )'
zstyle ':completion:*:expand:*' tag-order all-expansions
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters
zstyle ':completion:*:*:(^rm):*:*files' ignored-patterns '*?.o' '*?.c~''*?.old' '*?.pro'
zstyle ':completion:*:functions' ignored-patterns '_*'
zstyle ':completion:*:*:kill:*:processes' list-colors "=(#b) #([0-9]#)*=$color[darkblue]=$color[red]"
export LS_COLORS='no=00;35:fi=00;35:di=01;34:ln=04;36:pi=30:so=01;35:do=01;35:bd=30;01:cd=30;01:or=31;01:su=37:sg=30:tw=30:ow=34:st=37:ex=01;31:*.cmd=01;31:*.exe=01;31:*.com=01;31:*.btm=01;31:*.sh=01;31:*.run=01;31:*.tar=30:*.tgz=30:*.arj=30:*.taz=30:*.lzh=30:*.zip=30:*.z=30:*.Z=30:*.gz=30:*.bz2=30:*.deb=30:*.rpm=30:*.jar=30:*.rar=30:*.jpg=32:*.jpeg=32:*.gif=32:*.bmp=32:*.pbm=32:*.pgm=32:*.ppm=32:*.tga=32:*.xbm=32:*.xpm=32:*.tif=32:*.tiff=32:*.png=32:*.mov=34:*.mpg=34:*.mpeg=34:*.avi=34:*.fli=34:*.flv=34:*.3gp=34:*.mp4=34:*.divx=34:*.gl=32:*.dl=32:*.xcf=32:*.xwd=32:*.flac=35:*.mp3=35:*.mpc=35:*.ogg=35:*.wav=35:*.m3u=35:';
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

if [[ "$USER" = 'root' ]] && [[ "$(cut -d ' ' -f 19 /proc/$$/stat)" -gt 0 ]]; then
  renice -n 0 -p "$$" && echo "# Adjusted nice level for current shell to 0."
fi

build_prompt() {
  local PL_BRANCH_CHAR
  () {
    PL_BRANCH_CHAR='%{$fg_bold[green]%}'
  }
  local ref mode repo_path
  repo_path=$(git rev-parse --git-dir 2>/dev/null)

  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git rev-parse --short HEAD 2> /dev/null)"

    if [[ -e "${repo_path}/BISECT_LOG" ]]; then
      mode=" <B>"
    elif [[ -e "${repo_path}/MERGE_HEAD" ]]; then
      mode=" >M<"
    elif [[ -e "${repo_path}/rebase" || -e "${repo_path}/rebase-apply" || -e "${repo_path}/rebase-merge" || -e "${repo_path}/../.dotest" ]]; then
      mode=" >R>"
    fi

    setopt promptsubst
    autoload -Uz vcs_info

    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:*' get-revision true
    zstyle ':vcs_info:*' check-for-changes true
    zstyle ':vcs_info:*' stagedstr '%{$fg_bold[yellow]%}✚'
    zstyle ':vcs_info:*' unstagedstr '%{$fg_bold[yellow]%}●'
    zstyle ':vcs_info:*' formats ' %u%c'
    zstyle ':vcs_info:*' actionformats ' %u%c'
    vcs_info
    PROMPT="%{%f%b%k%}${ref/refs\/heads\//$PL_BRANCH_CHAR}${vcs_info_msg_0_%% }${mode} "
  else
    PROMPT=""
  fi
  if [[ "$USER" = 'root' ]]; then
    PROMPT+="%{$reset_color%}%{$fg_bold[red]%}λ %{$reset_color%}"
  else
    PROMPT+="%{$reset_color%}%{$fg_bold[default]%}λ %{$reset_color%}"
  fi
}

[[ -z $precmd_functions ]] && precmd_functions=()
precmd_functions=($precmd_functions build_prompt)

RPROMPT="%{$fg[cyan]%}%n%{$fg[default]%}⋆%{%(#~$fg_bold[blue]~$fg_bold[magenta])%}%m %{$fg_bold[default]%}%~/ %{$reset_color%}% %(?,%{$fg[green]%}Π%{$reset_color%},%{$fg_bold[red]%}∅%{$reset_color%}"

autoload -U url-quote-magic
zle -N self-insert url-quote-magic

# Shell config.
export EDITOR="nano"
export LD_LIBRARY_PATH=/usr/local/lib64
export force_3tc_enable=true
export NODE_PATH=/usr/lib64/node_modules
export NO_AT_BRIDGE=1

alias grep='grep -G'
alias egrep='egrep -G'
alias ls='ls -G'

#packages installed by hand
alias world="pkg query -e '%a=0' '%o %a'"

export KWIN_DIRECT_GL=1

fixglx() {
  sudo pw groupadd video;
  sudo pw groupmod video -g 44;
  sudo pw groupmod video -m "mpkh";
}

reload () {
  source /etc/profile
  exec "${SHELL}" "$@"
}

#There is alias which is using it with noglob
_calc() { echo "${1}"|bc -l; }

unpack () {
   if [[ -f $1 ]] ; then
     case $1 in
       *.tar.bz2) tar xjf $1  ;;
       *.tar.gz)  tar xzf $1  ;;
       *.tbz)     tar xjvf $1   ;;
       *.bz2)     bunzip2 $1  ;;
       *.rar)     rar x $1    ;;
       *.gz)      gunzip $1   ;;
       *.tar)     tar xf $1   ;;
       *.tbz2)    tar xjf $1  ;;
       *.tgz)     tar xzf $1  ;;
       *.zip)     unzip $1    ;;
       *.Z)       uncompress $1 ;;
       *.7z)      7z x $1     ;;
       *)         echo "'$1' cannot be extracted via extract()" ;;
     esac
   else
     echo "'$1' is not a valid file"
   fi
}

pack () {
  if [[ $1 ]] ; then
    case $1 in
      tbz)   tar cjvf $2.tar.bz2 $2   ;;
      tgz)   tar czvf $2.tar.gz  $2   ;;
      tar)   tar cpvf $2.tar  $2    ;;
      bz2)   bzip $2          ;;
      gz)    gzip -c -9 -n $2 > $2.gz ;;
      zip)   zip -r $2.zip $2     ;;
      7z)    7z a $2.7z $2      ;;
      *)     echo "'$1' cannot be packed via pk()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

kill-port() {
  if [[ $1 ]] ; then
    lsof -i :$1 | grep 'TCP' | awk '{print $2}' | xargs kill -9
  else
    echo "'$1' is not a valid port"
  fi
}

countdown() {
    start="$(( $(date '+%s') + $1))"
    while [ $start -ge $(date +%s) ]; do
        time="$(( $start - $(date +%s) ))"
        printf '%s\r' "$(date -u -d "@$time" +%H:%M:%S)"
        sleep 0.1
    done
}

stopwatch() {
    start=$(date +%s)
    while true; do
        time="$(( $(date +%s) - $start))"
        printf '%s\r' "$(date -u -d "@$time" +%H:%M:%S)"
        sleep 0.1
    done
}

function forget() {
    # Remove this command from history immediately
    local histno=$HISTCMD
    
    local input="$1"
    
    if [[ -z "$input" ]]; then
        input=1
    fi
    
    fc -W  # Write current history (includes this forget command)
    
    if [[ "$input" =~ ^[0-9]+$ ]]; then
        # Remove last N + this forget command
        local N=$((input + 1))
        head -n -$N "$HISTFILE" > "$HISTFILE.tmp" && mv "$HISTFILE.tmp" "$HISTFILE"
    else

        # Remove lines with string + this forget command
        grep -a -v "$input" "$HISTFILE" > "$HISTFILE.tmp" && mv "$HISTFILE.tmp" "$HISTFILE"
        head -n -1 "$HISTFILE" > "$HISTFILE.tmp" && mv "$HISTFILE.tmp" "$HISTFILE"
    fi
    
    fc -R
    
    # Clear this command from the in-memory history
    print -s ""  # This tricks zsh
    fc -p
}

function proxify() {
    if command -v gsettings &>/dev/null; then
        local proxy_mode=$(gsettings get org.gnome.system.proxy mode 2>/dev/null | tr -d "'")
        if [[ "$proxy_mode" == "manual" ]]; then
            local proxy_host=$(gsettings get org.gnome.system.proxy.http host 2>/dev/null | tr -d "'")
            local proxy_port=$(gsettings get org.gnome.system.proxy.http port 2>/dev/null)
            if [[ -n "$proxy_host" && -n "$proxy_port" ]]; then
                export http_proxy="http://${proxy_host}:${proxy_port}"
                export https_proxy="http://${proxy_host}:${proxy_port}"
                export HTTP_PROXY="http://${proxy_host}:${proxy_port}"
                export HTTPS_PROXY="http://${proxy_host}:${proxy_port}"
                export no_proxy="localhost,127.0.0.1,::1"
                export NO_PROXY="localhost,127.0.0.1,::1"
                echo "✅ Proxy detected from GNOME: ${proxy_host}:${proxy_port}"
                return 0
            fi
        fi
    fi
    
    # Fallback
    export http_proxy="http://127.0.0.1:12334"
    export https_proxy="http://127.0.0.1:12334"
    export HTTP_PROXY="http://127.0.0.1:12334"
    export HTTPS_PROXY="http://127.0.0.1:12334"
    export no_proxy="localhost,127.0.0.1,::1"
    export NO_PROXY="localhost,127.0.0.1,::1"
    echo "✅ Using manual proxy: 127.0.0.1:12334"
}

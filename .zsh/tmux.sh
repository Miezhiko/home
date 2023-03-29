tmux_dump() {
  local d=$'\t'
  tmux list-windows -a -F "#S${d}#W${d}#{pane_current_path}"
}

tmux_save() {
  tmux_dump > ~/.tmux-session
}

terminal_size() {
  stty size 2>/dev/null | awk '{ printf "-x%d -y%d", $2, $1 }'
}

tmux_session_exists() {
  tmux has-session -t "$1" 2>/dev/null
}

tmux_add_window() {
  tmux new-window -d -t "$1:" -n "$2" -c "$3"
}

tmux_new_session() {
  cd "$3" &&
  tmux new-session -d -s "$1" -n "$2" $4
}

tmux_restore() {
  tmux start-server
  local count=0
  local dimensions="$(terminal_size)"

  while IFS=$'\t' read session_name window_name dir; do
    if [[ -d "$dir" && $window_name != "log" && $window_name != "man" ]]; then
      if tmux_session_exists "$session_name"; then
        tmux_add_window "$session_name" "$window_name" "$dir"
      else
        tmux_new_session "$session_name" "$window_name" "$dir" "$dimensions"
        count=$(( count + 1 ))
      fi
    fi
  done < ~/.tmux-session

  echo "restored $count sessions"
}

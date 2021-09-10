alias battery='upower -i $(upower -e | grep 'BAT') | grep -E "state|to\ full|percentage"'

if [[ $UID == 0 || $EUID == 0 ]]; then
  ulimit -Sn 10000
fi

# Distribution packages
wupdate() {
  shelter
  emerge --sync
  echo "updating metadata cache ..."
  egencache --repo=gentoo --update
  eix-update
}

wazzup() {
  eix -I | grep "\[U\]"
}

watsnew() {
  emerge -avuDN @world --backtrack=100 \
    --with-bdeps=y --quiet-build=n
}

wupgrade() {
  wupdate
  emerge -vuDN @world --backtrack=100 \
    --keep-going --with-bdeps=y --quiet-build=n
  emerge @smart-live-rebuild --keep-going
  haskell-updater
  haskell-updater
  emerge @preserved-rebuild --keep-going --verbose-conflicts --quiet-build=n
}

wclean() {
  emerge --depclean
}

GOAWAYFROMSWAPYOUASSHOLES() {
  swapoff -a
  swapon -a
  free
}

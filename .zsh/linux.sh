alias battery='upower -i $(upower -e | grep 'BAT') | grep -E "state|to\ full|percentage"'

if [[ $UID == 0 || $EUID == 0 ]]; then
  ulimit -Sn 10000
fi

wupdate() {
  shelter
  emerge --sync
  echo "updating metadata cache ..."
  egencache --repo=gentoo --update
  eix-update
}

watsnew() {
  emerge -avuDN @world --exclude=nvidia-drviers --backtrack=100 \
    --with-bdeps=y --quiet-build=n
}

wupgrade() {
  wupdate
  emerge -vuDN @world --exclude=nvidia-drviers --backtrack=100 \
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

if [ -d "/data/platform-tools" ] ; then
    PATH="/data/platform-tools:$PATH"
fi

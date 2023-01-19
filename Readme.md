# a

`sudo env LOCALE_ARCHIVE=$LOCALE_ARCHIVE nixos-rebuild switch --flake '.#spacedesktop'`

`home-manager switch --flake ".#space@spacedesktop" --option extra-builtins-file extra-builtins.nix`

#!/usr/bin/env bash

#Set the versions you want installed and set to default in nvm/rvm
node_version='6.10.0'
ruby_version='2.6.0'

brews=(
  autoconf
  automake
  c-ares
  cairo
  cask
  coreutils
  csshx
  dirmngr
  emacs
  fontconfig
  freetype
  fzf
  gcc
  gettext
  git
  git-extras
  glib
  gmp
  gnupg
  gnupg2
  gpg-agent
  isl
  jpeg
  jq
  libassuan
  libffi
  libgcrypt
  libgpg-error
  libksba
  libmpc
  libpng
  libtiff
  libtool
  libusb
  libusb-compat
  libwebsockets
  libyaml
  mackup
  mosquitto
  mpfr
  nvm
  oniguruma
  openssl
  pcre
  pinentry
  pixman
  pkg-config
  pth
  rbenv
  readline
  ruby-build
  unrar
  wget
  xz
  zeromq
  zlib
)

casks=(
  atom
  cyberduck
  docker
  dropbox
  etcher
  evernote
  flux
  flycut
  google-chrome
  insync
  istat-menus
  lastpass
  omnigraffle
  skitch
  skype
  slack
  sourcetree
  spectacle
  spotify
  the-unarchiver
  transmission
  virtualbox
  virtualbox-extension-pack
  vlc
)

npms=(
  bower
  cordova
  evrythng
  evrythng-extended
  gulp
  gulp-cli
  http-server
  ionic
  ios-deploy
  ios-sim
  netlify-cli
  typings
  webpack
)

clibs=(
)

bkpgs=(
)

git_configs=(

)

apms=(
  atom-beautify
  atom-bootstrap3
  atom-html-preview
  auto-update-packages
  compare-files
  config-import-export
  copy-as-rtf
  editorconfig
  filesize
  highlight-selected
  hyperclick
  js-hyperclick
  language-docker
  linter
  linter-eslint
  minimap
  script
  terminal-plus
)

fonts=(
)

omfs=(
)

######################################## End of app list ########################################
set +e
#set -x

if test ! $(which brew); then
  echo "Installing Xcode ..."
  xcode-select --install

  echo "Installing Homebrew ..."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
  echo "Updating Homebrew ..."
  brew update
  brew upgrade
fi
brew doctor

echo "Tapping casks ..."
#brew tap caskroom/fonts
brew tap caskroom/versions
brew tap homebrew/dupes
brew tap caskroom/cask

fails=()

function print_red {
  red='\x1B[0;31m'
  NC='\x1B[0m' # no color
  echo -e "${red}$1${NC}"
}

function install {
  cmd=$1
  shift
  for pkg in $@;
  do
    exec="$cmd $pkg"
    echo "Executing: $exec"
    if $exec ; then
      echo "Installed $pkg"
    else
      fails+=($pkg)
      print_red "Failed to execute: $exec"
    fi
  done
}

echo "Installing ruby ..."
ruby -v
curl -sSL https://get.rvm.io | bash -s stable

rvm install ${ruby_version}
rvm use ${ruby_version} --default
ruby -v
sudo gem update --system

#echo "Installing Java ..."
brew cask install java

echo "Installing packages ..."
brew info ${brews[@]}
install 'brew install' ${brews[@]}

echo "Installing software ..."
brew cask info ${casks[@]}
install 'brew cask install' ${casks[@]}

# TODO:  Fix this
#echo "Installing Node ..."
#nvm install ${node_version}
#nvm alias default ${node_version}
#nvm use default

echo "Installing secondary packages ..."
# TODO: add info part of install or do reinstall?
#install 'pip install --upgrade' ${pips[@]}
#install 'gem install' ${gems[@]}
#install 'clib install' ${clibs[@]}
#install 'bpkg install' ${bpkgs[@]}
install 'npm install --global' ${npms[@]}
install 'apm install' ${apms[@]}
#install 'brew cask install' ${fonts[@]}

echo "Upgrading bash ..."
brew install bash
sudo bash -c "echo $(brew --prefix)/bin/bash >> /private/etc/shells"
mv ~/.bash_profile ~/.bash_profile_backup
mv ~/.bashrc ~/.bashrc_backup
mv ~/.gitconfig ~/.gitconfig_backup
cd; curl -#L https://github.com/barryclark/bashstrap/tarball/master | tar -xzv --strip-components 1 --exclude={README.md,screenshot.png}
source ~/.bash_profile

#echo "Setting git defaults ..."
#for config in "${git_configs[@]}"
#do
#  git config --global ${config}
#done
#gpg --keyserver hkp://pgp.mit.edu --recv ${gpg_key}

echo "Installing mac CLI ..."
# Note: Say NO to bash-completions since we have fzf!
sh -c "$(curl -fsSL https://raw.githubusercontent.com/guarinogabriel/mac-cli/master/mac-cli/tools/install)"

echo "Final Updating ..."
pip3 install --upgrade pip setuptools wheel
mac update

echo "Cleaning up ..."
brew cleanup
brew cask cleanup

for fail in ${fails[@]}
do
  echo "Failed to install: $fail"
done

echo "Run `mackup restore` after DropBox has done syncing"

echo "Done!"

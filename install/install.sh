REPO_DIR=$HOME/Git/archlinux-environment-installer
INSTALL_DIR=$REPO_DIR/install
SCRIPTS_DIR=$INSTALL_DIR/scripts

HYPRLAND_PACMAN_PACKAGES=(
  "hyprland"
  "sddm"
)

HYPRLAND_YAY_PACKAGES=(
  "uwsm"
  "sddm-theme-sugar-candy-git"
)

MY_PACMAN_PACKAGES=(
  "fastfetch"
  "vim"
  "kitty"
  "chromium"
  "nautilus"
  "wofi"
  "gnome-text-editor"
  "git"
  "less"
  "man-db"
)

MY_YAY_PACKAGES=(
  "visual-studio-code-bin"    
)

COLOR_GREEN='\033[0;32m'
COLOR_RED='\033[1;31m'
COLOR_NONE='\033[0m'

source "${SCRIPTS_DIR}/main.sh"

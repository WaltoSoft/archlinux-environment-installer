set -e

REPO_DIR=$HOME/Git/archlinux-environment-installer
INSTALL_DIR=$REPO_DIR/install
SCRIPTS_DIR=$INSTALL_DIR/scripts
LOGS_DIR=/var/log/archlinux-environment-installer
LOG_FILE="${LOGS_DIR}/$(date '+%Y%m%d%H%M%S').log"

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

COLOR_AQUA=14
COLOR_GREEN=10
COLOR_RED=9

source "${SCRIPTS_DIR}/main.sh"

executeScript() {
  clear
  sudo mkdir -p $LOGS_DIR
  confirmStart
}

confirmStart() {
  echo-text -fc $COLOR_AQUA "Installation"
  echo-text "This script will setup Hyprland"
  echo-text

  if askUser -c "DO YOU WANT TO START THE INSTALLATION?"; then
    echo-text -c $COLOR_GREEN "Installation Starting"
  elif [ $? -eq 130 ] ; then
    echo-text -c $COLOR_RED "Installation Cancelled"
    exit 130
  else
    echo-text -c $COLOR_RED "Installation Cancelled"
    exit
  fi
}

executeScript
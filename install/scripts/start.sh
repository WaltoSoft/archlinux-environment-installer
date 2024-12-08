executeScript() {
  clear
  sudo mkdir -p $LOGS_DIR
  confirmStart
}

confirmStart() {
  echo_text -fc $COLOR_AQUA "Installation"
  echo_text "This script will setup Hyprland"
  echo_text

  if askUser -c "DO YOU WANT TO START THE INSTALLATION?"; then
    echo_text -c $COLOR_GREEN "Installation Starting"
  elif [ $? -eq 130 ] ; then
    echo_text -c $COLOR_RED "Installation Cancelled"
    exit 130
  else
    echo_text -c $COLOR_RED "Installation Cancelled"
    exit
  fi
}

executeScript
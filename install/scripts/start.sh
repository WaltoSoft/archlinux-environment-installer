executeScript() {
  clear
  sudo mkdir -p $LOGS_DIR
  confirmStart
}

confirmStart() {
  echoText -fc $COLOR_AQUA "Installation"
  echoText

  if $(askUser -c "DO YOU WANT TO START THE INSTALLATION?"); then
    echoText -c $COLOR_GREEN "Installation Starting"
  elif [ $? -eq 130 ] ; then
    echoText -c $COLOR_RED "Installation Cancelled"
    exit 130
  else
    echoText -c $COLOR_RED "Installation Cancelled"
    exit
  fi
}

executeScript
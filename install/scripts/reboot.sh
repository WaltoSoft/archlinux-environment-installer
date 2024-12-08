executeScript() {
  clear
  echoText -fc $COLOR_AQUA "Reboot"
  echoText "A reboot of your system is recommended."
  echoText
  if [ $(askUser -c "Would you like to reboot now?") -eq 0 ] ; then
    echoText "Rebooting..."
    systemctl reboot
  elif [ $? -eq 130 ]; then
    exit 130
  else
    echoText -c $COLOR_RED "Reboot skipped"
  fi

  echoText ""
  echoText -c $COLOR_GREEN "Installation Complete!"
}

executeScript

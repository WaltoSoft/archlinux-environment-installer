executeScript() {
  clear
  echo_text -fc $COLOR_AQUA "Reboot"
  echo_text "A reboot of your system is recommended."
  echo_text
  if [ $(askUser -c "Would you like to reboot now?") -eq 0 ] ; then
    echo_text "Rebooting..."
    systemctl reboot
  elif [ $? -eq 130 ]; then
    exit 130
  else
    echo_text -c $COLOR_RED "Reboot skipped"
  fi

  echo_text ""
  echo_text -c $COLOR_GREEN "Installation Complete!"
}

executeScript

executeScript() {
  clear
  echo-text -fc $COLOR_AQUA "Reboot"
  echo-text "A reboot of your system is recommended."
  echo-text
  if askUser -c "Would you like to reboot now?" ; then
    echo-text "Rebooting..."
    systemctl reboot
  elif [ $? -eq 130 ]; then
    exit 130
  else
    echo-text -c $COLOR_RED "Reboot skipped"
  fi

  echo-text ""
  echo-text -c $COLOR_GREEN "Installation Complete!"
}

executeScript()
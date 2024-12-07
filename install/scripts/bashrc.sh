executeScript() {
  clear
  echo-text -fc $COLOR_AQUA "bashrc"
  echo-text "Copying bashrc configuration scripts"
  cp $INSTALL_DIR/home/.bashrc ~/.bashrc
  cp $INSTALL_DIR/home/.bashrc_custom ~/.bashrc_custom
  echo-text "bashrc scripts copied"
}

executeScript
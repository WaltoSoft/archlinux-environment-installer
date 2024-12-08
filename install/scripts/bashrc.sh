executeScript() {
  clear
  echo_text -fc $COLOR_AQUA "bashrc"
  echo_text "Copying bashrc configuration scripts"
  cp $INSTALL_DIR/home/.bashrc ~/.bashrc
  cp $INSTALL_DIR/home/.bashrc_custom ~/.bashrc_custom
  echo_text "bashrc scripts copied"
}

executeScript
executeScript() {
  clear
  echoText -fc $COLOR_AQUA "bashrc"
  echoText "Copying bashrc configuration scripts"
  cp $INSTALL_DIR/home/.bashrc ~/.bashrc
  cp $INSTALL_DIR/home/.bashrc_custom ~/.bashrc_custom
  echoText "bashrc scripts copied"
}

executeScript
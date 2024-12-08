executeScript() {
  clear
  echo_text -fc $COLOR_AQUA "Dot files"
  echo_text "Copying dot files"
  rsync -avhp -I $INSTALL_DIR/dotfiles/ ~/ 2>&1 | sudo tee -a $LOG_FILE
  echo_text "dot files copied"
}

executeScript;

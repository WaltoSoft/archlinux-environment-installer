executeScript() {
  clear
  echo-text -fc $COLOR_AQUA "Dot files"
  echo-text "Copying dot files"
  rsync -avhp -I $INSTALL_DIR/dotfiles/ ~/ 2>&1 | sudo tee -a $LOG_FILE
  echo-text "dot files copied"
}

executeScript;

executeScript() {
  clear
  echoText -fc $COLOR_AQUA "Dot files"
  echoText "Copying dot files"
  rsync -avhp -I $INSTALL_DIR/dotfiles/ ~/ 2>&1 | sudo tee -a $LOG_FILE
  echoText "dot files copied"
}

executeScript;

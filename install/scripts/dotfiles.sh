executeScript() {
  rsync -avhp -I $INSTALL_DIR/dotfiles/ ~/
}

executeScript;

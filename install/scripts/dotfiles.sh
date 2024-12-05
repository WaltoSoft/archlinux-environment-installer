executeScript() {
  local dotFilesDirectory=$HOME/.config/hypr
  local installDotFilesDirectory=$INSTALL_DIR/dotfiles/.config/hypr

  if [ -d "${dotFilesDirectory}" ]; then
    cp -r $installDotFilesDirectory/* $dotFilesDirectory
  fi
}

executeScript;

executeScript() {
  echoText -fc $COLOR_AQUA "Dot files"
  echoText "Copying Hyperland Dot files"

  doit() {
    rsync -avhp -I $INSTALL_DIR/dotfiles/ ~/ >> $LOG_FILE 2> >(tee -a $LOG_FILE >&2)
  }

  if ! doit; then
    echoText -c $COLOR_RED "ERROR: An error occured copying Hyprland Dot files"
    exit 1
  fi

  echoText -c $COLOR_GREEN "Hyprland Dot files successfully copied"
}

executeScript;

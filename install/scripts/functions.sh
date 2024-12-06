confirmStart() {
  echo-color "Installation" $COLOR_AQUA True
  echo "This script will setup Hyprland" 

  if gum confirm "DO YOU WANT TO START THE INSTALLATION?" ; then
    echo
    echo-color "Installation Starting" $COLOR_GREEN
  elif [ $? -eq 130 ] ; then
    echo
    echo-color "Installation Cancelled" $COLOR_RED
    exit 130
  else
    echo
    echo-color "Installation Cancelled" $COLOR_RED
    exit
  fi
}

echo-color() {
  local text="$1"
  local color="$2"
  local useFiglet="$3"

  if [ ! -z $useFiglet ] && [ $useFiglet = True ]; then
    local outputText=$(figlet "${text}")
    gum style --foreground $color --border-foreground $color --align "center" --border double --margin "1 2" --padding "2 4" "${outputText}"
  else
    gum style --foreground $color "${text}"
  fi
}

ensureFolder() {
  local folderPath=$1
  local useSudo=$2

  echo "Ensuring folder ${folderPath} exists"

  if [ ! -d $folderPath ] ;then
    if [ $useSudo = True ]; then
      sudo mkdir $folderPath
    else
      mkdir $folderPath
    fi
  fi
}
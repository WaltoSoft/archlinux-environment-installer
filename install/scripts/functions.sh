changeColor() {
  local color=$1

  if [ ! -z color ]; then
    echo -e $color
  fi
}

# Confirm that the user is ready to run the installation
confirmStart() {
   echoInColor "This script will setup Hyprland" $COLOR_GREEN

  if gum confirm "DO YOU WANT TeO START THE INSTALLATION?" ; then
    echo
    echoInColor "Installation Starting" $COLOR_GREEN
  elif [ $? -eq 130 ] ; then
    echo
    echoInColor "Installation Cancelled" $COLOR_RED
    exit 130
  else
    echo
    echoInColor "Installation Cancelled" $COLOR_RED
    exit
  fi

  changeColor $COLOR_NONE
}

# The same as echo, it just outputs the text with the specified color.
echoInColor() {
  local text=$1
  local color=$2

  if [ -n "${color}" ]; then
    changeColor $color
  fi

  if [ -n "${text}" ]; then
    echo $text
  fi

  changeColor $COLOR_NONE
}

# Ensures the specified folder exists, if it doesn't then create it and optionally change directory to it
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

clear
confirmStart
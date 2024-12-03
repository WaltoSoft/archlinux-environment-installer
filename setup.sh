#--------------------------------------------------
# Declare variables
#--------------------------------------------------
SETUP_BRANCH=""

#--------------------------------------------------
# Function declarations
#--------------------------------------------------
  setup_executeScript() {
    echo "Getting command line arguments"

    getopts ":b:" test;
    echo "Args ${test}";

    while getopts ":b:" opt; do
      case "${opt}" in
        b) SETUP_BRANCH="${OPTARG}";;
        :) exit 1;;
        ?) echo "Invalid option: -${OPTARG}." 
           exit 1
           ;;
      esac
    done

    echo "Setup Branch: ${SETUP_BRANCH}"

    setup_installPackages
    setup_confirmStart
    setup_getCommandLineArgs
    setup_cloneRepo
    setup_startInstallation
  }

  setup_confirmStart() {
    echo "This script will setup Hyprland"

    if gum confirm "DO YOU WANT TO START THE INSTALLATION?"; then
      echo
      echo "Installation Starting" 
    elif [ $? -eq 130 ]; then
      echo
      echo "Installation Cancelled"
      exit 130
    else
      echo
      echo "Installation Cancelled"
      exit
    fi
  }

  setup_cloneRepo() {
    if [ ! -d ~/Git ]; then
      mkdir ~/Git
    fi

    cd ~/Git

    if [ -d ~/Git/hyprland-installation ]; then
      rm -rf ~/Git/hyprland-installation
    fi

    echo "Cloning hyprland-installation git repo."
    git clone -q --no-progress --depth 1 https://github.com/waltosoft/hyprland-installation.git
    echo "Clone complete."
    cd ~/Git/hyprland-installation

    if [ ! -z $SETUP_BRANCH ]; then
      git config --get remote.origin.fetch
      git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
      git config --get remote.origin.fetch
      git remote update
      git fetch

      git checkout $SETUP_BRANCH
    fi
  }

  setup_installPackages() {
    sudo pacman --noconfirm -Sqy
    sudo pacman --noconfirm -Sq git gum
  }

  setup_startInstallation() {
    echo "Starting Installation."    
    cd ~/Git/hyprland-installation
    ./install/install.sh
  }
#--------------------------------------------------

setup_executeScript
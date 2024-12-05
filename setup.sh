#--------------------------------------------------
# Declare variables
#--------------------------------------------------
SETUP_BRANCH=""

#--------------------------------------------------
# Function declarations
#--------------------------------------------------
  setup_executeScript() {
    setup_installPackages
    setup_cloneRepo
    setup_startInstallation
  }

  setup_cloneRepo() {
    if [ ! -d ~/Git ]; then
      mkdir ~/Git
    fi

    cd ~/Git

    if [ -d ~/Git/archlinux-environment-installer ]; then
      rm -rf ~/Git/archlinux-environment-installer
    fi

    echo "Cloning archlinux-environment-installer git repo."
    git clone -q --no-progress --depth 1 https://github.com/waltosoft/archlinux-environment-installer.git
    echo "Clone complete."
    cd ~/Git/archlinux-environment-installer

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
    sudo pacman --noconfirm -Sq git gum rsync
  }

  setup_startInstallation() {
    echo "Starting Installation."    
    cd ~/Git/archlinux-environment-installer
    ./install/install.sh
  }
#--------------------------------------------------

while getopts ":b:" option; do
  case $option in
    b) SETUP_BRANCH=$OPTARG
        ;;
    :) exit 1;;
    \?) echo "Invalid option: -${OPTARG}." 
        exit 1
        ;;
  esac
done

echo "Setup Branch: ${SETUP_BRANCH}"
setup_executeScript

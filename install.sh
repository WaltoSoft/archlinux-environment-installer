#--------------------------------------------------
# Declare variables
#--------------------------------------------------
PACMAN_INITIAL_PACKAGES=(
  "gum"
  "git"
  "base-devel"
)

PACMAN_INSTALL_PACKAGES=(
  "kitty"
  "nautilus"
  "wofi"
  "hyprland"  
)

YAY_INSTALL_PACKAGES=(
  "uwsm"
)

COLOR_GREEN='\033[0;32m'
COLOR_NONE='\033[0m'
COLOR_RED='\033[1;31m'

#--------------------------------------------------
# Function Declarations
#--------------------------------------------------
  executeScript() {
    sudo pacman -Sy

    ensureFolder "${HOME}/Git" true
    installPackages "${PACMAN_INITIAL_PACKAGES[@]}" true
    confirmStart
    installPackages "${PACMAN_INSTALL_PACKAGES[@]}"
    installYayPackages "${YAY_INSTALL_PACKAGES[@]}"
  }

  confirmStart() {
    echoInColor "This script will setup Hyprland" $COLOR_GREEN

    if gum confirm "DO YOU WANT TO START THE INSTALLATION?" ; then
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
  }

  echoInColor() {
    color=$2

    echo -e "${color}"
    echo $1

    echo -e "${COLOR_NONE}"
  }

  ensureFolder() {
    folderPath=$1
    enterPath=$2

    if [ -d path ] ;then
      mkdir $folderPath
    fi

    if [ "${enterPath}" = true ] ; then
      echo "Changing dir to ${folderPath}"
      cd $folderPath
    fi
  }

  installPackages() {
    packagesToInstall=();
    needed = $1

    for package; do
      if [[ $(isPackageInstalled "${package}") == 0 ]]; then
        echo "${package} is already installed.";
        continue;
      fi;
      
      packagesToInstall+=("${package}");
    done;

    if [[ "${packagesToInstall[@]}" == "" ]] ; then
      echo "All pacman packages are already installed.";
      return;
    fi;

    echo "Installing packages that haven't been installed yet"
    sudo pacman --noconfirm -S "${packagesToInstall[@]}";

     if [ "${needed}" = true ] ; then
       sudo pacman --noconfirm --needed -S "${packagesToInstall[@]}";
     else
       sudo pacman --noconfirm -S "${packagesToInstall[@]}";
     fi
     
     echo "pacman package installation complete."
  }

  installYay() {
    if sudo pacman -Qs yay > /dev/null ; then
      echo "yay is already installed!"
    else
      echo "Building and Installing yay from source code"

      ensureFolder "${HOME}/Git"

      if [ -d ~/Git/yay-git ] ;then
        rm -rf ~/Git/yay-git
        echo "Existing yay-git repo removed"
      fi

      echo "Cloning the yay git repository at https://aur.archlinux.org/yay-git"
      git clone https://aur.archlinux.org/yay-git.git

      ensureFolder "${HOME/Git/yay-git" true

      echo "Compiling yay source code and installing as a package"
      makepkg -si

      if sudo pacman -Qs yay > /dev/null ; then
        echo "yay has been installed successfully."
      else
        echo "yay was not installed successfully."
      fi
    fi
  }

  installYayPackages() {
    packagesToInstall=();

    installYay

    for package; do
      if [[ $(isPackageInstalled "${package}") == 0 ]]; then
        echo "Package '${package}' is already installed.";
        continue;
      fi;
        
      packagesToInstall+=("${package}");
    done;

    if [[ "${packagesToInstall[@]}" == "" ]] ; then
      echo "All packages are already installed.";
      return;
    fi;

    echo "Installing packages that haven''t been installed yet"
    yay --noconfirm -S "${packagesToInstall[@]}";
    echo "yay packages installation complete."
  }

  isPackageInstalled() {
    package="$1";
    isInstalled="$(sudo pacman -Qs --color always "${package}" | grep "local" | grep "${package} ")";

    if [ -n "${isInstalled}" ] ; then
      echo 0; 
      return;  #package was found
    fi;
    
    echo 1; #package was not found
    return;  
  }
#--------------------------------------------------

#Run the script
executeScript

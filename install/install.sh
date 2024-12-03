#--------------------------------------------------
# Declare variables
#--------------------------------------------------
PACMAN_INSTALL_PACKAGES=(
  "hyprland"  
  "sddm"
  "vim"
  "kitty"
  "nautilus"
  "wofi"
  "code"
  "gnome-text-editor"
)

YAY_INSTALL_PACKAGES=(
  "uwsm"
)

COLOR_GREEN='\033[0;32m'
COLOR_NONE='\033[0m'
COLOR_RED='\033[1;31m'

INSTALL_DIRECTORY='${HOME}/Git/install'


#--------------------------------------------------
# Function Declarations
#--------------------------------------------------
  executeScript() {
    clear
    confirmStart

    cd $INSTALL_DIRECTORY
    sudo pacman -Sqy
    installPackages "${PACMAN_INSTALL_PACKAGES[@]}"
    installYayPackages "${YAY_INSTALL_PACKAGES[@]}"
    startSDDM
    configureShell
  }

  configureShell(){
    echo "Copying Shell configuration"
    cp $INSTALL_DIRECTORY/home/.bashrc ~/.bashrc
    cp $INSTALL_DIRECTORY/home/.bashrc_custom ~/.bashrc_custom
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

    echo "Ensuring folder ${folderPath} exists"
    
    if [ ! -d $folderPath ] ;then
      mkdir $folderPath
    fi

    if [ "${enterPath}" = true ] ; then
      echo "Changing dir to ${folderPath}"
      cd $folderPath
      echo "Current path: "
      pwd
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

    echo "Installing packages that haven''t been installed yet"
    sudo pacman --noconfirm -S "${packagesToInstall[@]}";
    echo "pacman package installation complete."
  }

  installYay() {
    if sudo pacman -Qs yay > /dev/null ; then
      echo "yay is already installed!"
    else
      echo "Building and Installing yay from source code"

      ensureFolder ~/Git

      if [ -d ~/Git/yay-git ]; then
        rm -rf ~/Git/yay-git
        echo "Existing yay-git repo removed"
      fi

      echo "Cloning the yay git repository at https://aur.archlinux.org/yay-git"
      git clone -q --no-progress --depth 1 https://aur.archlinux.org/yay-git.git

      ensureFolder ~/Git/yay-git true

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
    packagesToInstall=()

    installYay

    for package; do
      if [[ $(isPackageInstalled "${package}") == 0 ]]; then
        echo "Package ''${package}'' is already installed."
        continue
      fi;
        
      packagesToInstall+=("${package}")
    done

    if [[ "${packagesToInstall[@]}" == "" ]] ; then
      echo "All packages are already installed."
      return
    fi

    echo "Installing packages that haven''t been installed yet"
    yay --noconfirm -S "${packagesToInstall[@]}"
    echo "yay packages installation complete."
  }

  isPackageInstalled() {
    package="$1"
    isInstalled="$(sudo pacman -Qs --color always "${package}" | grep "local" | grep "${package} ")"

    if [ -n "${isInstalled}" ] ; then
      echo 0 
      return  #package was found
    fi
    
    echo 1 #package was not found
    return  
  }

  startSDDM() {
    sudo systemctl enable sddm.service
  }
#--------------------------------------------------

#Run the script
executeScript

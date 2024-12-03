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

#--------------------------------------------------
# Function Declarations
#--------------------------------------------------
  # This is the main code for the script.
  executeScript() {
    clear
    confirmStart
    installPackages "${PACMAN_INSTALL_PACKAGES[@]}"
    installYayPackages "${YAY_INSTALL_PACKAGES[@]}"
    startSDDM
    configureShell
  }

  # Copies the .bashrc files in the install folder into the users home directory.
  configureShell(){
    echo "Copying Shell configuration"
    cp ~/Git/hyprland-installation/home/.bashrc ~/.bashrc
    cp ~/Git/hyprland-installation/home/.bashrc_custom ~/.bashrc_custom
  }

  # Confirm that the user is ready to run the installation
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

  # The same as echo, it just outputs the text with the specified color.
  echoInColor() {
    local text=$1
    local color=$2

    echo -e "${color}"
    echo $text

    echo -e "${COLOR_NONE}"
  }

  # Ensures the specified folder exists, if it doesn't then create it and optionally change directory to it
  ensureFolder() {
    local folderPath=$1
    local enterPath=$2

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

  # Installs the packages in the PACMAN_INSTALL_PACKAGES array via pacman
  installPackages() {
    local packagesToInstall=();

    # Update the pacman databases
    sudo pacman -Sy

    # Check to see which packages haven't already been installed
    for package; do
      if [[ $(isPackageInstalled "${package}") == 0 ]]; then
        continue
      fi;
      
      packagesToInstall+=("${package}")
    done;

    # Check to see if all of the packages have already been installed
    if [[ "${packagesToInstall[@]}" == "" ]] ; then
      echo "All pacman packages are already installed."
      return
    fi;

    # Installing those packages that haven't already been installed
    echo "Installing packages that haven''t been installed yet"
    sudo pacman --noconfirm -S "${packagesToInstall[@]}"
    echo "pacman package installation complete."
  }

  # Installs the Yay helper
  installYay() {
    # check to see if yay is already installed
    if sudo pacman -Qs yay > /dev/null ; then
      echo "yay is already installed!"
    else
      echo "Building and Installing yay from source code"

      ensureFolder ~/Git
      pwd

      # If the yay-git repo already exists it, then remove it
      # so we are sure to get the latest version
      if [ -d ~/Git/yay-git ]; then
        rm -rf ~/Git/yay-git
        echo "Existing yay-git repo removed"
      fi

      # Clone the yay repo
      echo "Cloning the yay git repository at https://aur.archlinux.org/yay-git"
      git clone --quite --no-progress --depth 1 https://aur.archlinux.org/yay-git.git

      cd ~/Git/yay-git

      # Compiles the source code and then installs it via pacman
      echo "Compiling yay source code and installing as a package"
      makepkg -si

      # Check to see if yay is now installed via pacman
      if sudo pacman -Qs yay > /dev/null ; then
        echo "yay has been installed successfully."
      else
        echo "yay was not installed successfully."
      fi
    fi
  }

  # Installs those yay packages defined in the YAY_INSTALL_PACKAGES array
  installYayPackages() {
    local packagesToInstall=()

    installYay

    # Determining which packages need to be installed
    for package; do
      if [[ $(isPackageInstalled "${package}") == 0 ]]; then
        continue
      fi;
        
      packagesToInstall+=("${package}")
    done

    # Check to see if all of the packages have already been installed
    if [[ "${packagesToInstall[@]}" == "" ]] ; then
      echo "All packages are already installed."
      return
    fi

    # Installing those packages which haven't already been installed
    echo "Installing packages that haven''t been installed yet"
    yay --noconfirm -S "${packagesToInstall[@]}"
    echo "yay packages installation complete."
  }

  # Checks to see if the package passed in has alredy been 
  # installed via pacman
  isPackageInstalled() {
    local package="$1"
    local isInstalled="$(sudo pacman -Qs --color always "${package}" | grep "local" | grep "${package} ")"

    if [ -n "${isInstalled}" ] ; then
      echo 0 
      return  #package was found
    fi
    
    echo 1 #package was not found
    return  
  }

  # Start the SDDM service
  startSDDM() {
    sudo systemctl enable sddm.service
  }
#--------------------------------------------------

#Run the script
executeScript

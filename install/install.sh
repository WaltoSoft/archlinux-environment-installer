#--------------------------------------------------
# Declare variables
#--------------------------------------------------
PACMAN_INSTALL_PACKAGES=(
  "hyprland"  
  "sddm"
  "fastfetch"
  "vim"
  "kitty"
  "chromium"
  "nautilus"
  "wofi"
  "gnome-text-editor"
  "less"
  "man-db"
)

YAY_INSTALL_PACKAGES=(
  "uwsm"
  "sddm-theme-sugar-candy-git"
  "visual-studio-code-bin"
)

COLOR_GREEN='\033[0;32m'
COLOR_RED='\033[1;31m'
COLOR_CYAN='\033[36m'

#--------------------------------------------------
# Function Declarations
#--------------------------------------------------
  # This is the main code for the script.
  executeScript() {
    clear
    changeColor $COLOR_CYAN
    confirmStart
    installPackages "${PACMAN_INSTALL_PACKAGES[@]}"
    installYayPackages "${YAY_INSTALL_PACKAGES[@]}"
    setupsddm
    configureShell
  }

  changeColor() {
    local color=$1

    if [ ! -z color ]; then
      echo -e $color
    fi
  }

  # Copies the .bashrc files in the install folder into the users home directory.
  configureShell(){
    echo "Copying Shell configuration"
    cp ~/Git/hyprland-installation/install/home/.bashrc ~/.bashrc
    cp ~/Git/hyprland-installation/install/home/.bashrc_custom ~/.bashrc_custom
  }

  # Confirm that the user is ready to run the installation
  confirmStart() {
    echo "This script will setup Hyprland"

    if gum confirm "DO YOU WANT TO START THE INSTALLATION?" ; then
      echo
      echo "Installation Starting"
      changeColor $COLOR_CYAN
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

    if [ ! -z $color ]; then
      changeColor $color
    fi

    if [ ! -z $text ]; then
      echo $text
    fi

    changeColor $COLOR_CYAN
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
    sudo pacman --quiet --noconfirm -S "${packagesToInstall[@]}"
    echo "pacman package installation complete."
  }

  # Installs the Yay helper
  installYay() {
    # check to see if yay is already installed
    if sudo pacman -Qs yay > /dev/null ; then
      echo "yay is already installed!"
    else
      echo "Building and Installing yay from source code"

      # If the yay-git repo already exists it, then remove it
      # so we are sure to get the latest version
      if [ -d ~/Git/yay-git ]; then
        rm -rf ~/Git/yay-git
        echo "Existing yay-git repo removed"
      fi

      # Clone the yay repo
      ensureFolder ~/Git
      cd ~/Git
      echo "Cloning the yay git repository at https://aur.archlinux.org/yay-git"
      git clone --quiet --no-progress --depth 1 https://aur.archlinux.org/yay-git.git
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
    yay --quiet --noconfirm -S "${packagesToInstall[@]}"
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
  setupsddm() {
    ensureFolder "/etc/sddm.conf.d" True

    sudo cp /usr/lib/sddm/sddm.conf.d/default.conf /etc/sddm.conf.d/sddm.conf
    sudo python ~/Git/hyprland-installation/install/iniupdate.py /etc/sddm.conf.d/sddm.conf Theme Current Sugar-Candy  
    sudo python ~/Git/hyprland-installation/install/iniupdate.py /usr/share/sddm/themes/Sugar-Candy/theme.conf General HourFormat '"h:mm AP"'
    sudo python ~/Git/hyprland-installation/install/iniupdate.py /usr/share/sddm/themes/Sugar-Candy/theme.conf General DateFormat '"dddd, MMMM d"'
    sudo systemctl enable sddm.service
  }
#--------------------------------------------------

#Run the script
executeScript

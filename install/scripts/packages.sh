executeScript() {
  local pacmanPackages=( ${HYPRLAND_PACMAN_PACKAGES[*]} ${MY_PACMAN_PACKAGES[*]} )
  local yayPackages=( ${HYPRLAND_YAY_PACKAGES[*]} ${MY_YAY_PACKAGES[*]} )

  installPackages "${pacmanPackages[@]}"
  installYayPackages "${yayPackages[@]}"
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

# Installs the specified YAY packages
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

executeScript
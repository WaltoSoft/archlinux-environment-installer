executeScript() {
  local pacmanPackages=( ${HYPRLAND_PACMAN_PACKAGES[*]} ${MY_PACMAN_PACKAGES[*]} )
  local yayPackages=( ${HYPRLAND_YAY_PACKAGES[*]} ${MY_YAY_PACKAGES[*]} )

  clear
  echo_text -fc $COLOR_AQUA "Packages"
  installPackages "${pacmanPackages[@]}"
  installYayPackages "${yayPackages[@]}"
}

# Installs the packages in the PACMAN_INSTALL_PACKAGES array via pacman
installPackages() {
  local packagesToInstall=();

  # Update the pacman databases
  sudo pacman -Sy 2>&1 | sudo tee -a $LOG_FILE > /dev/null
  echo_text "Updated pacman databases"

  # Check to see which packages haven't already been installed
  for package; do
    if [ $(isPackageInstalled "${package}") -eq 0 ]; then
      echo_text "Pacman package '${package}' is already installed"
      continue
    fi;
    
    packagesToInstall+=("${package}")
  done;

  # Check to see if all of the packages have already been installed
  if [[ "${packagesToInstall[@]}" == "" ]] ; then
    echo_text "All pacman packages are already installed."
  else
    # Installing those packages that haven't already been installed
    echo_text "Installing pacman packages: ${packagesToInstall[*]}."
    sudo pacman -Sq --noconfirm "${packagesToInstall[@]}" 2>&1 | sudo tee -a $LOG_FILE
    echo_text "pacman package installation complete."
  fi
}

installYay() {
  if sudo pacman -Qs yay > /dev/null ; then
    echo_text "yay is already installed!"
  else
    echo_text "Building and Installing yay from source code"

    if [ -d ~/Git/yay-git ]; then
      rm -rf ~/Git/yay-git
      echo_text "Existing yay-git repo removed"
    fi

    ensureFolder ~/Git
    cd ~/Git
    echo_text "Cloning the yay git repository at https://aur.archlinux.org/yay-git"
    git clone --quiet --no-progress --depth 1 https://aur.archlinux.org/yay-git.git 2>&1 | sudo tee -a $LOG_FILE > /dev/null
    cd ~/Git/yay-git

    # Compiles the source code and then installs it via pacman
    echo_text "Compiling yay source code and installing as a package"
    makepkg -si 2>&1 | sudo tee -a $LOG_FILE > /dev/null

    # Check to see if yay is now installed via pacman
    if sudo pacman -Qs yay > /dev/null ; then
      echo_text "yay has been installed successfully."
    else
      echo_text "yay was not installed successfully."
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
      echo "Yay package '${package}' is already installed" 2>&1 | sudo tee -a $LOG_FILE > /dev/null
      continue
    fi;
      
    packagesToInstall+=("${package}")
  done

  # Check to see if all of the packages have already been installed
  if [[ "${packagesToInstall[@]}" == "" ]] ; then
    echo_text "All packages are already installed."
    return
  fi

  # Installing those packages which haven't already been installed
  echo_text "Installing packages that haven''t been installed yet"
  yay --quiet --noconfirm -S "${packagesToInstall[@]}" 2>&1 | sudo tee -a $LOG_FILE > /dev/null
  echo_text "yay packages installation complete."
}

isPackageInstalled() {
  local package="$1"
  local isInstalled="$(sudo pacman -Qqs "${package}" | grep -Fx --color=never "${package}")"

  if [ -n "${isInstalled}" ] ; then
    echo 0  #package was found
    return 0
  fi
  
  echo 1 #package was not found
}

executeScript
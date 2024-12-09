executeScript() {
  local aurPackages=( ${HYPRLAND_AURS[*]} ${MY_AURS[*]} )

  echoText -fc $COLOR_AQUA "Aur Packages"
  installYay
  installPackagesWithYay "${aurPackages[@]}"
}

installPackagesWithYay() {
  local packagesToInstall=()

  for package; do
    if $(isInstalledWithPacman $package); then
      echoText "yay package '${package}' is already installed"
    else
      packagesToInstall+=("${package}")      
    fi
  done

  if [ "${#packagesToInstall[@]}" -eq 0 ] ; then
    echo -c $COLOR_GREEN "All yay packages are already installed."
  else
    echoText "Installing yay packages (this will take a while!): ${packagesToInstall[*]}"

    doit() {
      yay -S --noconfirm "${packagesToInstall[@]}" >> $LOG_FILE 2> >(tee -a $LOG_FILE >&2) 
    }

    if ! doit ; then
      echoText -c $COLOR_RED "ERROR: Unable to install one or more yay packages"
    else
      echoText -c $COLOR_GREEN "All yay packages installed successfuly"
    fi
  fi;
}

installYay() {
  local yayGitFolder="${GIT_DIR}/yay-git"

  if ! $(isInstalledWithPacman 'yay-git') ; then
    removeExistingFolder $yayGitFolder
    cloneRepo 'https://aur.archlinux.org/yay-git' $yayGitFolder
    cd $yayGitFolder
   
    doit() {
      echoText "Compiling the 'yay-git' package"
      sudo -u $SUDO_USER makepkg -si --noconfirm >> $LOG_FILE 2> >(tee -a $LOG_FILE >&2)
    }

    if ! doit ; then
      echoText -c $COLOR_RED "ERROR: yay-git could not be compiled"
    fi

    if $(isInstalledWithPacman 'yay-git') ; then
      echoText -c $COLOR_GREEN "yay-git installed successfully"
    else
      echoText -c $COLOR_RED "ERROR: yay-git failed to install"
      exit 1
    fi
  else
    echoText -c $COLOR_GREEN "yay is already installed!"
  fi
}

executeScript
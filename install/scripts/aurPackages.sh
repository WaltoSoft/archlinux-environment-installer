executeScript() {
  local aurPackages=( ${HYPRLAND_AURS[*]} ${MY_AURS[*]} )

  echoText -fc $COLOR_AQUA "Aur Packages"
  installYay
  installPackagesWithYay "${aurPackages[@]}"
}

buildAndInstallPackage() {
  existsOrExit $1 "No package name provided to installAurPackage"

  local packageName=$1
  local packageAurFolder="${AURFOLDER}/${packageName}"
  local packageUrl="https://aur.archlinux.org/${packageName}.git"
  
  if $(isInstalledWithPacman $packageName) ; then
    echoText "${$packageName} is already installed!"
  else
    removeExistingFolder $packageAurFolder
    cloneRepo $packageUrl $packageAurFolder "${packageAurFolder}/PKGBUILD"
    echoText "Compiling the ${packageName} package"

    doit() {
      sudo -u $SUDO_USER makepkg -si >> $LOG_FILE 2> >(tee -a $LOG_FILE >&2)
    }

    if ! doit ; then
      echoText -c $COLOR_RED "ERROR: Aur package '${packageName}' could not be compiled"
    fi

    if $(isInstalledWithPacman $packageName) ; then
      echoText -c $COLOR_GREEN "Package '${packageName}' installed successfully"
    else
      echoText -c $COLOR_RED "ERROR: Package '${packageName}' failed to install"
      exit 1
    fi
  fi
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
      sudo -u $SUDO_USER makepkg -si >> $LOG_FILE 2> >(tee -a $LOG_FILE >&2)
    }

    if ! doit ; then
      echoText -c $COLOR_RED "ERROR: yay-git could not be compiled"
    fi

    if $(isInstalledWithPacman $packageName) ; then
      echoText -c $COLOR_GREEN "Package '${packageName}' installed successfully"
    else
      echoText -c $COLOR_RED "ERROR: Package '${packageName}' failed to install"
      exit 1
    fi
  else
    echoText "yay is already installed!"
  fi
}

executeScript
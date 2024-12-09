executeScript() {
  local AURFOLDER="/home/${SUDO_USER}/.aurtmp"
  local aurPackages=( ${HYPRLAND_AURS[*]} ${MY_AURS[*]} )

  echoText -fc $COLOR_AQUA "Aur Packages"
  installAurPackages "${aurPackages[@]}"
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

installAurPackages() {
  local packagesToInstall=()

  for package; do
    if $(isInstalledWithPacman $package) ; then
      echoText "Aur package '${package}' is already installed with pacman" 
      continue
    fi;
      
    packagesToInstall+=($package)
  done

  if [ "${#packagesToInstall[@]}" -le 0 ] ; then
    echoText -c $COLOR_GREEN "All Aur packages are already installed via pacman"
  else
    echoText "The following Aur packages need to be installed: ${packagesToInstall[*]}"

    for packageToInstall in "${packagesToInstall[@]}"; do
      echoText "Installing Aur package ${packageToInstall}"
      
      compileAurPackage $packageToInstall
      installAurPackageFile $packageToInstall

      if $(isInstalledWithPacman $packageToInstall) ; then
        echoText "Aur package '${packagToInstalle}' installed successfully with pacman" 
      else
        echoText -c $COLOR_RED "ERROR: Aur package '${packageToInstall}' was not installed successfully with pacman"
        exit 1
      fi;
    done

    echoText -c $COLOR_GREEN "All Aur packages have been successfully installed"
  fi
}

installYay() {
  if $(isInstalledWithPacman 'yay-git') ; then
    echoText "yay is already installed!"
  else
    buildAndInstallPackage 'yay-git'
  fi
}

installWithYay() {


}

executeScript

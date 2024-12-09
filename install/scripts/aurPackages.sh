executeScript() {
  local AURFOLDER="/home/${SUDO_USER}/.aurtmp"
  local aurPackages=( ${HYPRLAND_AURS[*]} ${MY_AURS[*]} )

  echoText -fc $COLOR_AQUA "Aur Packages"
  installAurPackages "${aurPackages[@]}"
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
    echoText "Installing Aur packages: ${packagesToInstall[*]}"

    for packageToInstall in "${packagesToInstall[@]}"; do
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

compileAurPackage() {
  existsOrExit $1 "No package name provided to installAurPackage"

  local packageName=$1
  local packageAurFolder="${AURFOLDER}/${packageName}"
  local packageUrl="https://aur.archlinux.org/${packageName}.git"
  
  if $(isInstalledWithPacman $packageName) ; then
    echoText "${$packageName} is already installed!"
  else
    removeExistingFolder $packageAurFolder
    cloneRepo $packageUrl $packageAurFolder "${packageAurFolder}/PKGBUILD"
    installAurDependencies $packageName

    echoText "Compiling the ${packageName} package"
    sudo -u $SUDO_USER makepkg >> $LOG_FILE 2>&1
  fi
}

installAurDependencies() {
  existsOrExit $1 "No package name provided to installAurDependencies"

  local dependencies
  local packageName=$1
  local packageFolder="${AURFOLDER}/${packageName}"

  if [ ! -d $packageFolder ]; then
    echoText -c $COLOR_RED "ERROR: ${packageName} folder does not exist"
    exit 1
  fi

  cd $packageFolder
  echoText "Getting dependencies for ${packageName}"
  dependencies=($(sudo -u $SUDO_USER makepkg --printsrcinfo | grep -E 'depends|makedepends|checkdepends' | awk '{print $3}'))

  if [ "${#dependencies[@]}" -le 0 ]; then
    echoText "${packageName} has no dependencies"
  else
    echoText "${packageName} has the following dependencies: ${dependencies[*]}"
    installWithPacman "${dependencies[@]}"
  fi
}

installAurPackageFile() {
  existsOrExit $1 "No package name provided to installAurPackageFile"  
  
  local packageName=$1
  local packageAurFolder="${AURFOLDER}/${packageName}"
  local packageFiles=($(find $packageAurFolder -type f -name "${packageName}*" ! -exec basename {} \;))
  local packageToInstall

  if [ "${#packageFiles[@]}" -le 0 ]; then
    echoText -c $COLOR_RED "ERROR: No package files found for ${packageName}"
    exit 1
  fi
 
  if [ "${#packageFiles[@]}" -eq 1 ]; then
    packageToInstall=${packageFiles[0]}
  else
    packageToInstall=$(askUser -m "Choose which package to install for ${packageName}:" "${packageFiles[@]}") 
  fi

  if [ -z $packageToInstall ]; then
    echoText -c $COLOR_RED "ERROR: No package file was selected for ${packageName}"
    exit 1
  fi

  echoText "Installing package file '${packageToInstall}' with pacman"
  pacmanFromFile ${packageAurFolder}/${packageToInstall}

  if $(isInstalledWithPacman $packageName) ; then
    echoText "${packageName} has been installed successfully."
  else
    echoText -c $COLOR_RED "ERROR: ${packageName} was not installed successfully."
    exit 1
  fi
}

executeScript
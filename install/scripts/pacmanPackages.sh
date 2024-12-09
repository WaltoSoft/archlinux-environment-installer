executeScript() {
  local pacmanPackages=( ${HYPRLAND_PACMAN_PACKAGES[*]} ${MY_PACMAN_PACKAGES[*]} )

  echoText -fc $COLOR_AQUA "Pacman Packages"
  installWithPacman "${pacmanPackages[@]}"
}

installWithPacman() {
  local packagesToInstall=();

  pacman -Sy >> $LOG_FILE
  echoText "Updated pacman databases"

  for package; do
    if $(isInstalledWithPacman ${package}) ; then
      echoText "pacman package '${package}' is already installed"
      continue
    fi;
    
    packagesToInstall+=("${package}")
  done;

  if [[ "${packagesToInstall[@]}" == "" ]] ; then
    echoText -c $COLOR_GREEN "All pacman packages are already installed."
  else
    echoText "Installing pacman packages: ${packagesToInstall[*]}."
    pacmanFromPackage "${packagesToInstall[@]}"
    echoText -c $COLOR_GREEN "Pacman packages successfully installed."
  fi
}

isInstalledWithPacman() {
  local package="$1"
  local isInstalled="$(pacman -Qqs "${package}" | grep -Fx --color=never "${package}")"

  if [ -n "${isInstalled}" ] ; then
    echo true
  else
    echo false
  fi
}

pacmanFromFile() {
  existsOrExit $1 "No file provided to pacmanFromFile"
  packageFile=$1

  doit() {
    pacman -U --noconfirm $packageFile >> $LOG_FILE 2> >(tee -a $LOG_FILE >&2)
  }

  if ! doit; then
    echoText -c $COLOR_RED "ERROR: An error occured executing packman with file '${packageFile}'"
    exit 1
  fi
}

pacmanFromPackage() {
  existsOrExit $1 "No package name provided to pacmanFromPackage"
  packageName=$1

  doit() {
    pacman -S --noconfirm $packageName >> $LOG_FILE 2> >(tee -a $LOG_FILE >&2)
  }

  if ! doit; then
    echoText -c $COLOR_RED "ERROR: An error occured executing packman with package '${packageName}'"
    exit 1
  fi
}

executeScript
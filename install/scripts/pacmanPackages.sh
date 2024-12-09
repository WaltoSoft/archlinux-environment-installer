executeScript() {
  local pacmanPackages=( ${HYPRLAND_PACMAN_PACKAGES[*]} ${MY_PACMAN_PACKAGES[*]} )

  echoText -fc $COLOR_AQUA "Pacman Packages"

  pacman -Sy >> $LOG_FILE 2> >(tee -a $LOG_FILE >&2)
  echoText "Updated pacman databases"
  
  installWithPacman "${pacmanPackages[@]}"
}

installWithPacman() {
  for package; do
    if $(isInstalledWithPacman ${package}) ; then
      echoText "pacman package '${package}' is already installed"
      continue
    fi;

    echoText "Installing pacman package '${package}'"
    pacmanFromPackage $package

    if $(isInstalledWithPacman ${package}); then
      echoText "pacman package ${package} was successfully installed"
    else
      echoText -c $COLOR_RED "ERROR: pacman package ${package} failed to install"
      exit 1
    fi
  done;
  
  echoText -c $COLOR_GREEN "Pacman packages successfully installed."
}

isInstalledWithPacman() {
  local package="$1"
  #local isInstalled="$(pacman -Qqs "${package}" | grep -Fx --color=never "${package}")"
  local isInstalled="$(pacman -Qq "${package}")"

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

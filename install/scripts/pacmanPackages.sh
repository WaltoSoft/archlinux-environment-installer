executeScript() {
  local pacmanPackages=( ${HYPRLAND_PACMAN_PACKAGES[*]} ${MY_PACMAN_PACKAGES[*]} )

  echoText -fc $COLOR_AQUA "Pacman Packages"
  pacman -Sy >> $LOG_FILE 2> >(tee -a $LOG_FILE >&2)
  echoText "Updated pacman databases"
  installPackagesWithPacman "${pacmanPackages[@]}"
}

installPackagesWithPacman() {
  local packagesToInstall=()

  for package; do
    if $(isInstalledWithPacman ${package}) ; then
      echoText "pacman package '${package}' is already installed"
    else
      packagesToInstall+=("${package}")      
    fi;
  done;

  if [ "${#packagesToInstall[@]}" -eq 0 ] ; then
    echo -c $COLOR_GREEN "All pacman packages are already installed."
  else
    echoText "Installing pacman packages (this may take a while!): ${packagesToInstall[*]}"

    doit() {
      pacman -S --noconfirm $packageName >> $LOG_FILE 2> >(tee -a $LOG_FILE >&2)    
    }

    if ! doit ; then
      echoText -c $COLOR_RED "ERROR: Unable to install one or more pacman packages"
    else
      echoText -c $COLOR_GREEN "All pacman packages installed successfuly"
    fi
  fi
}

isInstalledWithPacman() {
  local package="$1"
  local isInstalled="$(pacman -Qq "${package}" 2> >(tee -a $LOG_FILE >&2))"

  if [ -n "${isInstalled}" ] ; then
    echo true
  else
    echo false
  fi
}

executeScript
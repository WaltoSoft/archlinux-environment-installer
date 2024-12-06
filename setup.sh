set -e

executeScript() {
  local GIT_DIR=${HOME}/Git
  local REPO_BRANCH=$1
  local REPO_NAME="archlinux-environment-installer"
  local REPO_DIR="${GIT_DIR}/${REPO_NAME}"
  local RPEO_URL="https://github.com/waltosoft/${REPO_NAME}.git"

  displayHeader
  installPackages
  cloneRepo
  startInstallation
}

cloneRepo() {
  if [ ! -d "${GIT_DIR}" ]; then
    mkdir -p "${GIT_DIR}"
  fi

  if [ -d "${REPO_DIR}" ]; then
    rm -rf "${REPO_DIR}"
  fi

  echo "Cloning ${REPO_NAME} git repo."
  git clone -q --no-progress --depth 1 $RPEO_URL "${REPO_DIR}"
  echo "Clone complete."
  cd $REPO_DIR

  if [ ! -z "${REPO_BRANCH}" ]; then
    git config --get remote.origin.fetch > /dev/null
    git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*" > /dev/null
    git config --get remote.origin.fetch > /dev/null
    git remote update > /dev/null
    git fetch > /dev/null

    git checkout "${REPO_BRANCH}" > /dev/null
    echo "Switched to branch '${REPO_BRANCH}'"
  fi
}

displayDefault() { echo -e "\033[0m"; }
displayAqua() { echo -e "\033[36m"; }

displayHeader() {
  clear

  displayAqua
cat << "EOF"
    _             _       _     _                  
   / \   _ __ ___| |__   | |   (_)_ __  _   ___  __
  / _ \ | '__/ __| '_ \  | |   | | '_ \| | | \ \/ /
 / ___ \| | | (__| | | | | |___| | | | | |_| |>  < 
/_/   \_\_|  \___|_| |_| |_____|_|_| |_|\__,_/_/\_\
                                                   
 _____            _                                      _   
| ____|_ ____   _(_)_ __ ___  _ __  _ __ ___   ___ _ __ | |_ 
|  _| | '_ \ \ / / | '__/ _ \| '_ \| '_ ` _ \ / _ \ '_ \| __|
| |___| | | \ V /| | | | (_) | | | | | | | | |  __/ | | | |_ 
|_____|_| |_|\_/ |_|_|  \___/|_| |_|_| |_| |_|\___|_| |_|\__|
                                                             
 ___           _        _ _           
|_ _|_ __  ___| |_ __ _| | | ___ _ __ 
 | || '_ \/ __| __/ _` | | |/ _ \ '__|
 | || | | \__ \ || (_| | | |  __/ |   
|___|_| |_|___/\__\__,_|_|_|\___|_|   
                                                                                   
EOF
  displayDefault

  read -p "First we need to download the installation scripts.  Do you want to continue? (y/n): " answer

  case $answer in
    [Yy]* ) 
        echo "Continuing..."
        ;;
    [Nn]* ) 
        echo "Exiting..."
        exit 0
        ;;
    * ) 
        echo "Invalid response."
        exit 0
        ;;
  esac  
}

installPackages() {
  sudo pacman --noconfirm -Sy > /dev/null 2>&1
  sudo pacman --noconfirm --needed -S git gum rsync figlet > /dev/null 2>&1
}

startInstallation() {
  echo "Starting Installation."    
  cd "${REPO_DIR}"
  ./install/install.sh
}

while getopts ":b:" option; do
  case $option in
    b)  executeScript "${OPTARG}"
        exit 0
        ;;
    :)  echo "Option -${OPTARG} requires an argument."
        exit 1;;
    ?)  echo "Invalid option: -${OPTARG}." 
        exit 1
        ;;
  esac
done

executeScript
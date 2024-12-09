AURFOLDER="/home/${SUDO_USER}/.aurtmp"

askUser() {
  local OPTIND=1
  local command
  local choices
  local prompt

  while getopts ":c:m:" option; do
    case $option in
      c)  if [ -z $command ]; then
            command="confirm"
            prompt="${OPTARG}"
          else
            echoText -c $COLOR_RED "ERROR: You can only speciy -c or -m, not both"
            exit 1
          fi
          ;;

      m)  if [ -z $command ]; then
            command="choose"
            prompt="${OPTARG}"
          else
            echoText -c $COLOR_RED "ERROR: You can only speciy -c or -m, not both"
            exit 1
          fi
          ;;

      :)  echoText -c $COLOR_RED "ERROR: Option -${OPTARG} requires a prompt argument."
          exit 1
          ;;

     \?)  echoText -c $COLOR_RED "ERROR: Invalid option passed to askUser: -${OPTARG}"
          exit 1
          ;;
    esac
  done

  shift $((OPTIND-1))
  choices=$@

  if [ -z $"{prompt}" ]; then
    echoText -c $COLOR_RED "ERROR: No prompt provided to askUser"
    exit 1
  fi

  case $command in
    "confirm")  echo "Confirm Prompt: '${prompt}'" >> $LOG_FILE
                if gum confirm "${prompt}"; then
                  echo "User Chose: Yes" >> $LOG_FILE
                  echo true
                else
                  echo "User Chose: No" >> $LOG_FILE
                  echo false
                fi
                ;;

    "choose")   echo "Choose Prompt: '${prompt}', Choices: '$choices'" >> $LOG_FILE
                local result=$(gum choose --header "${prompt}" $choices)
                echo "User Chose: '${result}'" >> $LOG_FILE
                echo $result
                ;;
  esac
}

cloneRepo() {
  repoUrl=$1
  repoFolder=$2
  validationFile=$3

  if [ -z $repoUrl ]; then
    echoText -c $COLOR_RED "ERROR: No repo URL provided to cloneRepo"
    exit 1
  fi

  if [ -z $repoFolder ]; then
    echoText -c $COLOR_RED "ERROR: No repo folder provided to cloneRepo"
    exit 1
  fi

  ensureFolder $repoFolder

  echoText "Cloning the git repository at '${repoUrl}'"

  doit() {
    sudo -u $SUDO_USER git clone --depth 1 $repoUrl $repoFolder >> $LOG_FILE 2>&1
  }

  if ! doit; then
    echoText -c $COLOR_RED "ERROR: An error occured cloning the git repository at '${repoUrl}'"
    exit 1
  fi

  if [ -d $repoFolder ]; then
    echoText "'${repoUrl}' repo cloned successfully"
    cd $repoFolder
  else
    echoText -c $COLOR_RED "ERROR: '${repoUrl}' was not successfully cloned"
    exit 1
  fi

  if [ -n $validateFile ] && [ ! -f $validationFile ]; then
    echoText -c $COLOR_RED "ERROR: '${validationFile}' does not exist"
    exit 1
  fi
}

echoText() {
  local OPTIND=1
  local useFiglet=false
  local color
  local message
  local messageSet=false
  local errorExit=false

  while getopts ":c:f" option; do
    case $option in
      c)  color="${OPTARG}"
          ;;
      f)  useFiglet=true
          ;;
      :)  color=$COLOR_RED
          useFiglet=false
          message="ERROR: Option -${OPTARG} requires an argument."
          messageSet=true
          errorExit=true
          break
          ;;
     \?)  color=$COLOR_RED
          useFiglet=false
          message="ERROR: Invalid option: -${OPTARG}." 
          messageSet=true
          errorExit=true
          break
          ;;
    esac
  done  

  if ! $messageSet ; then
    shift $((OPTIND-1))
    message="$1"
  fi

  if [ -z "${message}" ]; then
    echo "" | tee -a $LOG_FILE
  else
    if $useFiglet ; then
      message=$(figlet "${message}")
    fi

    if [ -z $color ]; then
      if $useFiglet ; then
        gum style --align "center" --border double --margin "1 2" --padding "2 4" "${message}" 
      else
        gum style "${message}" | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g"
      fi
    else
      if $useFiglet ; then
        gum style --foreground $color --border-foreground $color --align "center" --border double --margin "1 2" --padding "2 4" "${message}"
      else
        gum style --foreground $color "${message}"
      fi
    fi
  
    echo "${message}" >> $LOG_FILE 2>&1

    if $errorExit ; then
      exit 1
    fi
  fi
}

ensureFolder() {
  local folderPath=$1
  local useSudoUser=false
  
  if [[ $folderPath == "/home/$SUDO_USER/"* ]]; then
    useSudoUser=true
  fi

  echoText "Ensuring folder '${folderPath}' exists"
   
  if [ ! -d $folderPath ] ;then
    if $useSudoUser; then
      sudo -u $SUDO_USER mkdir -p $folderPath
    else
      mkdir -p $folderPath
    fi

    echoText "Folder '${folderPath}' created"
  fi
}


existsOrExit() {
  if [ -z $1 ]; then
    echoText -c $COLOR_RED "ERROR: $2"
    exit 1
  fi
}

removeExistingFolder() {
  existsOrExit $1 "No folder path provided to removeFolderIfExists"

  if [ -d $1 ]; then
    rm -rf $1
    echoText "Existing folder '$1' removed"
  fi
}
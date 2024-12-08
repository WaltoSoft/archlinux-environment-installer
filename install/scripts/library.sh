askUser() {
  local OPTIND=1
  local command

  while getopts ":cm" option; do
    case $option in
      c)  if [ -z $command ]; then
            command="confirm"
          else
            echo_text -c $COLOR_RED "ERROR: You can only speciy -c or -m, not both"
            exit 1
          fi
          ;;

      m)  if [ -z $command ]; then
            command="choose"
          else
            echo_text -c $COLOR_RED "ERROR: You can only speciy -c or -m, not both"
            exit 1
          fi
          ;;

     \?)  echo_text -c $COLOR_RED "ERROR: Invalid option passed to askUser: -${OPTARG}"
          exit 1
          ;;
    esac
  done

  shift $((OPTIND-1))

  case $command in
    "confirm")  echo "Confirm Prompt: '$@'" >> $LOG_FILE
                if gum confirm "$@"; then
                  echo "User Chose: Yes" >> $LOG_FILE
                  echo true
                else
                  echo "User Chose: No" >> $LOG_FILE
                  echo false
                fi
                ;;

    "choose")   echo "Choose Prompt: '$@'" >> $LOG_FILE
                local result=$(gum choose "$@")
                echo "User Chose: ${result}" >> $LOG_FILE
                echo $result
                ;;
  esac
}

echo_text() {
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

  echo_text "Ensuring folder '${folderPath}' exists"
   
  if [ ! -d $folderPath ] ;then
    if $useSudoUser; then
      sudo -u $SUDO_USER mkdir $folderPath
    else
      mkdir $folderPath
    fi

    echo_text "Folder '${folderPath}' created"
  fi
}
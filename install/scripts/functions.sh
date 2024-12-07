askUser() {
  local OPTIND=1
  local command

  while getopts ":cm" option; do
    case $option in
      c)  if [ -z $command ]; then
            command="confirm"
          else
            echo-text -c $COLOR_RED "CYou can only speciy -c or -m, not both"
            exit 1
          fi
          ;;
      m)  if [ -z $command ]; then
            command="choose"
          else
            echo-text -c $COLOR_RED "MYou can only speciy -c or -m, not both"
            exit 1
          fi
          ;;
     \?)   echo-text -c $COLOR_RED "Invalid option passed to askUser: -${OPTARG}"
          ;;
    esac
  done

  shift $((OPTIND-1))

  case $command in
    "confirm")  echo "Confirm Prompt: '$@'" | sudo tee -a $LOG_FILE > /dev/null
                gum confirm "$@"
                local result="$?"
                if [ $result -eq 0 ]; then
                  echo "User Chose: Yes" | sudo tee -a $LOG_FILE > /dev/null
                else
                  echo "User Chose: No" | sudo tee -a $LOG_FILE > /dev/null
                fi
                
                return $result
                ;;

    "choose")   echo "Choose Prompt: '$@'" | sudo tee -a $LOG_FILE > /dev/null
                local result=$(gum choose "$@")
                echo "User Chose: ${result}" | sudo tee -a $LOG_FILE > /dev/null
                echo $result
                return 0
                ;;
  esac
}

echo-text() {
  local useFiglet=False
  local color
  local message
  local messageSet=False
  local OPTIND=1

  while getopts ":c:f" option; do
    case $option in
      c)  color="${OPTARG}"
          ;;
      f)  useFiglet=True
          ;;
      :)  color=$COLOR_RED
          useFiglet=False
          message="Option -${OPTARG} requires an argument."
          messageSet=True
          exit 1
          ;;
     \?)  color=$COLOR_RED
          useFiglet=False
          message="Invalid option: -${OPTARG}." 
          messageSet=True
          exit 1
          ;;
    esac
  done  

  shift $((OPTIND-1))
  message="$1"

  if [ -z "${message}" ]; then
    echo ""
  else
    if [ $useFiglet = True ]; then
      message=$(figlet "${message}")
    fi

    if [ -z $color ]; then
      if [ $useFiglet = True ]; then
        gum style --align "center" --border double --margin "1 2" --padding "2 4" "${message}" 
      else
        gum style "${message}" | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g"
      fi
    else
      if [ $useFiglet = True ]; then
        gum style --foreground $color --border-foreground $color --align "center" --border double --margin "1 2" --padding "2 4" "${message}"
      else
        gum style --foreground $color "${message}"
      fi
    fi
  fi

  echo "${message}" | sudo tee -a $LOG_FILE > /dev/null
}

ensureFolder() {
  local folderPath
  local useSudo=False

  while getopts ":s" option; do
    case $option in
      s)  useSudo=True
          ;;
      :)  echo-text -c $COLOR_RED "Option -${OPTARG} requires an argument."
          exit 1;;
      ?)  echo-text -c $COLOR_RED "Invalid option: -${OPTARG}." 
          exit 1
          ;;
    esac
  done  

  shift $((OPTIND-1))
  folderPath="$1"

  echo-text "Ensuring folder ${folderPath} exists"

  if [ ! -d $folderPath ] ;then
    if [ $useSudo = True ]; then
      sudo mkdir $folderPath
    else
      mkdir $folderPath
    fi
  fi
}
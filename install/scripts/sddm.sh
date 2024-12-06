executeScript() {
  local sddmConfigFolder=/etc/sddm.conf.d
  local sddmConfigFile=$sddmConfigFolder/sddm.conf
  local defaultConfigFile=/usr/lib/sddm/sddm.conf.d/default.conf
  local iniUpdateScript=$SCRIPTS_DIR/iniupdate.py
  local themeDirectory=/usr/share/sddm/themes

  ensureFolder $sddmConfigFolder True
  copyDefaultConfiguration
  configureThemes
  selectTheme
  enableSDDM  
}

copyDefaultConfiguration() {
  sudo cp $defaultConfigFile $sddmConfigFile
  echo "Default SDDM Configuration copied"
}

getInstalledThemes() {
  local themes=()

  for folder in $themeDirectory/*; do
    if [ -d $folder ]; then
      local themeName=$(basename $folder)
      themes+=("${themeName}")
    fi
  done

  echo "${themes[@]}";
}

selectTheme() {
  local themeOptions=($(getInstalledThemes))
  local selectedTheme=$(gum choose "${themeOptions[@]}")

  echo "Selected Theme: ${selectedTheme}"
  sudo python $iniUpdateScript $sddmConfigFile Theme Current $selectedTheme
}

enableSDDM () {
  sudo systemctl enable sddm.service
  echo "SDDM Enabled"
}

configureThemes() {
  #These three themes are installed by SDDM but they don't
  #work on Hyprland for some reason
  sudo rm -rf $themeDirectory/elarun
  sudo rm -rf $themeDirectory/maldives
  sudo rm -rf $themeDirectory/maya

  configureSugarCandy
}

# Add functions to configure various theme choices
configureSugarCandy() {
  local sugarCandyConfigFile=/usr/share/sddm/themes/Sugar-Candy/theme.conf

  if [ -f $sugarCandyConfigFile ]; then 
    sudo python $iniUpdateScript $sugarCandyConfigFile General HourFormat '"h:mm AP"'
    sudo python $iniUpdateScript $sugarCandyConfigFile General DateFormat '"dddd, MMMM d"'
  fi
}

executeScript
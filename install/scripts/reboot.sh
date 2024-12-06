clear
echo-color "Reboot" $COLOR_AQUA True
echo "A reboot of your system is recommended."
echo
if gum confirm "Would you like to reboot now?" ; then
    gum spin --spinner dot --title "Rebooting now..." -- sleep 3
    systemctl reboot
elif [ $? -eq 130 ]; then
    exit 130
else
    echo ":: Reboot skipped"
fi
echo ""
#!/bin/bash

# config reference: https://thepcspy.com/read/building-a-kiosk-computer-ubuntu-1404-chrome/

KIOSK_SCRIPT="/opt/kiosk.sh"
KIOSK_CONFIG_FILE="/etc/init/kiosk.conf"
USER="pktck"

#TODO: script adding the following line to /etc/sudoers
# %sudo   ALL=(ALL:ALL) NOPASSWD: ALL

#config repos & install packages

sudo add-apt-repository 'deb http://dl.google.com/linux/chrome/deb/ stable main'
wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo apt update
sudo apt --assume-yes install --no-install-recommends xorg openbox google-chrome-stable pulseaudio unclutter openssh-server vim ctags git

sudo usermod -a -G audio $USER

#read -rsp $'Press any key to continue...\n' -n1 key


# write the kiosk script

#sudo cat > $KIOSK_SCRIPT <<- EOF
sudo tee $KIOSK_SCRIPT > /dev/null << EOF

#!/bin/bash

xset -dpms
xset s off
openbox-session &
start-pulseaudio-x11

while true; do
    rm -rf ~/.{config,cache}/chromium/
    # chromium-browser --kiosk --no-first-run  --force-device-scale-factor=1.25 'https://www.youtube.com/embed/5FqH02gN29o?autoplay=1&loop=1&playlist=5FqH02gN29o'
    chromium-browser --kiosk --no-first-run  --force-device-scale-factor=3 'http://publish.smartsheet.com/f79b8aa62f3147549b51906cf0f0cd70'
done

EOF

sudo chmod +x $KIOSK_SCRIPT

#read -rsp $'Press any key to continue...\n' -n1 key


# write the kiosk config file

sudo tee $KIOSK_CONFIG_FILE > /dev/null << EOF

start on (filesystem and stopped udevtrigger)
stop on runlevel [06]

console output
emits starting-x

respawn

exec sudo -u pktck startx /etc/X11/Xsession /opt/kiosk.sh --

EOF

#read -rsp $'Press any key to continue...\n' -n1 key

#sudo dpkg-reconfigure x11-common
sudo sed -i 's/allowed_users=console/allowed_users=anybody/' /etc/X11/Xwrapper.config


# set up SSH keys
ssh-keygen -t rsa -f ~/.ssh/id_rsa -N ""
chmod 700 ~/.ssh

cat > ~/.ssh/authorized_keys <<- EOF

ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC7bjcfbTD9aR78rFCSu9K0K+PSuR68UFNyWTHvfkWbFZ0y21o0XcAMMrNgOMhi4u++jIFGaD0Vb0BJiNjocjv3Vzy1ghxCsBAe21ktGhrBN3jGCpQ7f6h8XWGwNBYqIJEkGmQVfqgShAGsmseaxKVD+QNAX2CqKh/UAqUDwfjvkbafS8nu9I1mM74j7cdluENyyUG82W87kj3mNrRaGQuNal9xRxE0abhIkYdkOfjDKL1gR2ZADo25b1gAZVuqhJN/gP3I6QMEXQxoacJ42+d8sxsZJh/wCQnFrydqpY4ef4FYU+enb5o6ZgAXasF7rSSxcfZ2K6TPU0A4o8yvyZK9 pktck@everywhere

EOF



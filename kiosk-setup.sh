#!/bin/bash

USER="pktck"

#TODO: script adding the following line to /etc/sudoers
# %sudo   ALL=(ALL:ALL) NOPASSWD: ALL

sudo sed -i 's/%sudo   ALL=(ALL:ALL) ALL/%sudo   ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/X11/Xwrapper.config

sudo apt update
sudo apt install --no-install-recommends openbox pulseaudio openssh-server vim
sudo usermod -a -G audio $USER

sudo install -b -m 755 /dev/stdin /opt/kiosk.sh << EOF
#!/bin/bash

xset -dpms
xset s off
openbox-session &
start-pulseaudio-x11

while true; do
    rm -rf ~/.{config,cache}/chromium/
    # chromium-browser --kiosk --no-first-run  --force-device-scale-factor=1.25 'https://www.youtube.com/embed/5FqH02gN29o?autoplay=1&loop=1&playlist=5FqH02gN29o'
    chromium-browser --kiosk --no-first-run  --force-device-scale-factor=3 'http://pktck.github.io/ccc-kiosk/'
done
EOF

sudo install -b -m 644 /dev/stdin /etc/init/kiosk.conf << EOF
start on (filesystem and stopped udevtrigger)
stop on runlevel [06]

emits starting-x
respawn

exec sudo -u $USER startx /etc/X11/Xsession /opt/kiosk.sh --
EOF

sudo sed -i 's/allowed_users=console/allowed_users=anybody/' /etc/X11/Xwrapper.config

echo manual | sudo tee /etc/init/lightdm.override  # disable desktop

sudo install -b -m 755 /dev/stdin /home/$USER/.ssh/authoried_keys << EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC7bjcfbTD9aR78rFCSu9K0K+PSuR68UFNyWTHvfkWbFZ0y21o0XcAMMrNgOMhi4u++jIFGaD0Vb0BJiNjocjv3Vzy1ghxCsBAe21ktGhrBN3jGCpQ7f6h8XWGwNBYqIJEkGmQVfqgShAGsmseaxKVD+QNAX2CqKh/UAqUDwfjvkbafS8nu9I1mM74j7cdluENyyUG82W87kj3mNrRaGQuNal9xRxE0abhIkYdkOfjDKL1gR2ZADo25b1gAZVuqhJN/gP3I6QMEXQxoacJ42+d8sxsZJh/wCQnFrydqpY4ef4FYU+enb5o6ZgAXasF7rSSxcfZ2K6TPU0A4o8yvyZK9 pktck@everywhere
EOF

sudo reboot

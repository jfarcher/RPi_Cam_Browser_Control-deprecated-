#!/bin/bash

# Copyright (c) 2013, Silvan Melchior
# All rights reserved.

# Redistribution and use, with or without modification, are permitted provided
# that the following conditions are met:
#    * Redistributions of source code must retain the above copyright
#      notice, this list of conditions and the following disclaimer.
#    * Neither the name of the copyright holder nor the
#      names of its contributors may be used to endorse or promote products
#      derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Description
# This script installs a browser-interface to control the RPi Cam. It can be run
# on any Raspberry Pi with a newly installed raspbian and enabled camera-support.

case "$1" in

  remove)
        sudo killall raspimjpeg
        sudo apt-get remove -y apache2 php5 libapache2-mod-php5 gpac motion
        sudo apt-get autoremove -y

        sudo rm -r /var/www/*
        sudo rm /usr/bin/raspimjpeg
        sudo rm /opt/vc/bin/raspimjpeg

        cd /etc
        sudo wget -N http://grustu.ch/share/rpi_cam/rc_local_std/rc.local
        sudo chmod 755 rc.local

        echo "Removed everything"
        ;;

  autostart_run)
        cd /etc
        sudo wget -N http://grustu.ch/share/rpi_cam/rc_local_run/rc.local
        sudo chmod 755 rc.local
        echo "Changed autostart"
        ;;

  autostart_idle)
        cd /etc
        sudo wget -N http://grustu.ch/share/rpi_cam/rc_local_idle/rc.local
        sudo chmod 755 rc.local
        echo "Changed autostart"
        ;;

  autostart_md)
        cd /etc
        sudo wget -N http://grustu.ch/share/rpi_cam/rc_local_md/rc.local
        sudo chmod 755 rc.local
        echo "Changed autostart"
        ;;

  autostart_no)
        cd /etc
        sudo wget -N http://grustu.ch/share/rpi_cam/rc_local_std/rc.local
        sudo chmod 755 rc.local
        echo "Changed autostart"
        ;;

  install)
        sudo apt-get install -y apache2 php5 libapache2-mod-php5 gpac motion

        cd /var/www
        sudo wget -N http://grustu.ch/share/rpi_cam/www.tar.gz
        sudo tar -xvzf www.tar.gz -C .
        sudo rm www.tar.gz
        sudo mknod FIFO p
        sudo chmod 666 FIFO
        sudo chown www-data:www-data media
        
        cd /etc/apache2/sites-available
        sudo wget -N http://grustu.ch/share/rpi_cam/default
        sudo chmod 644 default
        cd /etc/apache2/conf.d
        sudo wget -N http://grustu.ch/share/rpi_cam/other-vhosts-access-log
        sudo chmod 644 other-vhosts-access-log

        cd /opt/vc/bin
        sudo wget -N http://grustu.ch/share/rpi_cam/raspimjpeg
        sudo chmod 755 raspimjpeg
        sudo ln -s /opt/vc/bin/raspimjpeg /usr/bin/raspimjpeg

        cd /etc
        sudo wget -N http://grustu.ch/share/rpi_cam/rc_local_run/rc.local
        sudo chmod 755 rc.local

        cd /etc/motion
        sudo wget -N http://grustu.ch/share/rpi_cam/motion.conf
        sudo chmod 640 motion.conf

        echo "Installer finished"
        ;;

  start)
        shopt -s nullglob

        video=-1
        for f in /var/www/media/video_*.mp4; do
          video=`echo $f | cut -d '_' -f2 | cut -d '.' -f1`
        done
        video=`echo $video | sed 's/^0*//'`
        video=`expr $video + 1`

        image=-1
        for f in /var/www/media/image_*.jpg; do
          image=`echo $f | cut -d '_' -f2 | cut -d '.' -f1`
        done
        image=`echo $image | sed 's/^0*//'`
        image=`expr $image + 1`

        shopt -u nullglob

        sudo mkdir -p /dev/shm/mjpeg
        sudo raspimjpeg -w 512 -h 288 -d 1 -q 25 -of /dev/shm/mjpeg/cam.jpg -cf /var/www/FIFO -sf /var/www/status_mjpeg.txt -vf /var/www/media/video_%04d_%04d%02d%02d_%02d%02d%02d.mp4 -if /var/www/media/image_%04d_%04d%02d%02d_%02d%02d%02d.jpg -p -ic $image -vc $video > /dev/null &
        echo "Started"
        ;;

  stop)
        sudo killall raspimjpeg
        echo "Stopped"
        ;;


  *)
        echo "No option selected"
        ;;

esac



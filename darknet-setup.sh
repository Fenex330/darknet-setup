#!/bin/sh

# this scriptis intended to be run as root
# feel free to change parameters according to your needs

pacman -Syyu wget tcc i2pd tor --noconfirm

cd /usr/local/src/
wget https://unix4lyfe.org/gitweb/darkhttpd/blob_plain/HEAD:/darkhttpd.c
tcc darkhttpd.c -o darkhttpd
cp darkhttpd /usr/local/bin/

echo "[anon-website]" >> /etc/i2pd/tunnels.conf
echo "type = http" >> /etc/i2pd/tunnels.conf
echo "host = 0.0.0.0" >> /etc/i2pd/tunnels.conf
echo "port = 80" >> /etc/i2pd/tunnels.conf
echo "keys = anon-website.dat" >> /etc/i2pd/tunnels.conf

echo "HiddenServiceDir /var/lib/tor/hidden_service/" >> /etc/tor/torrc
echo "HiddenServicePort 80 0.0.0.0:80" >> /etc/tor/torrc

systemctl enable tor
systemctl enable i2pd
systemctl start tor
systemctl start i2pd

touch /usr/local/bin/darknet-start
chmod +x /usr/local/bin/darknet-start

echo "#!/bin/sh" > /usr/local/bin/darknet-start
echo "darkhttpd /srv/darknet --addr 0.0.0.0 --port 80 --index index.html --log ~/darknet.log --timeout 0 --no-listing &" >> /usr/local/bin/darknet-start
echo "wget http://127.0.0.1:7070/?page=i2p_tunnels -O /tmp/hostname.html" >> /usr/local/bin/darknet-start
echo "echo " "" >> /usr/local/bin/darknet-start
echo "echo "------------------------------------------------------"" >> /usr/local/bin/darknet-start
echo "echo " "" >> /usr/local/bin/darknet-start
echo "echo "i2p address:"" >> /usr/local/bin/darknet-start
echo "cat /tmp/hostname.html | grep anon-website" >> /usr/local/bin/darknet-start
echo "rm /tmp/hostname.html" >> /usr/local/bin/darknet-start
echo "echo "tor address"" >> /usr/local/bin/darknet-start
echo "cat /var/lib/tor/hidden_service/hostname" >> /usr/local/bin/darknet-start

echo "The setup is complete"
echo "Please wait a few minutes until full hidden service bootstrap"
echo "Then enter darknet-start in the terminal to launch your server"
echo "Note that you have to run this command after every reboot"

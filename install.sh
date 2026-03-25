#!/bin/bash

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
NC='\033[0m'

# Loading Animation
loading() {
echo -ne "${YELLOW}Processing"
for i in {1..5}; do
    echo -ne "."
    sleep 0.3
done
echo -e "${NC}"
}

clear
echo -e "${CYAN}"
echo "========================================"
echo "        🚀 JLPG ULTIMATE INSTALLER 🚀"
echo "========================================"
echo -e "${NC}"

echo -e "${GREEN}1) Install Pterodactyl Panel${NC}"
echo -e "${GREEN}2) Install Wings${NC}"
echo -e "${GREEN}3) Install Panel + Wings${NC}"
echo -e "${GREEN}4) Create Admin User${NC}"
echo -e "${GREEN}5) Wing Auto Config${NC}"
echo -e "${GREEN}6) Install PufferPanel (JLPG Script)${NC}"
echo -e "${GREEN}7) JLPG VM Manager${NC}"
echo -e "${GREEN}8) System Info${NC}"
echo -e "${GREEN}9) Exit${NC}"

echo ""
read -p "👉 Select option [1-9]: " option

# ---------------- PANEL ----------------
install_panel() {
loading
echo -e "${CYAN}Installing Pterodactyl Panel...${NC}"

apt update -y && apt upgrade -y
apt install nginx mysql-server redis-server curl tar unzip git software-properties-common -y

add-apt-repository ppa:ondrej/php -y
apt update
apt install php8.1 php8.1-cli php8.1-fpm php8.1-mysql php8.1-gd php8.1-mbstring php8.1-bcmath php8.1-xml php8.1-curl php8.1-zip -y

curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

mkdir -p /var/www/pterodactyl
cd /var/www/pterodactyl

curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
tar -xzvf panel.tar.gz

chmod -R 755 storage/* bootstrap/cache/
cp .env.example .env

composer install --no-dev --optimize-autoloader
php artisan key:generate

echo -e "${GREEN}✅ Panel Installed Successfully!${NC}"
}

# ---------------- WINGS ----------------
install_wings() {
loading
echo -e "${CYAN}Installing Wings...${NC}"

curl -sSL https://get.docker.com/ | bash
systemctl enable docker
systemctl start docker

mkdir -p /etc/pterodactyl

curl -L -o /usr/local/bin/wings https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_amd64
chmod +x /usr/local/bin/wings

cat <<EOF > /etc/systemd/system/wings.service
[Unit]
Description=Pterodactyl Wings
After=docker.service

[Service]
User=root
WorkingDirectory=/etc/pterodactyl
ExecStart=/usr/local/bin/wings
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reexec
systemctl enable wings
systemctl start wings

echo -e "${GREEN}✅ Wings Installed & Running!${NC}"
}

# ---------------- PUFFER PANEL ----------------
install_puffer() {
loading
echo -e "${CYAN}Installing PufferPanel via JLPG Script...${NC}"

bash <(curl -s https://raw.githubusercontent.com/jlpggamerz/pufferpanelcode/refs/heads/main/install.sh)

echo -e "${GREEN}✅ PufferPanel Installed!${NC}"
echo -e "${YELLOW}🌐 Open: http://YOUR_IP:8080${NC}"
}

# ---------------- SYSTEM INFO ----------------
system_info() {
echo -e "${CYAN}===== SYSTEM INFO =====${NC}"
echo -e "${GREEN}OS:${NC} $(lsb_release -d | cut -f2)"
echo -e "${GREEN}CPU:${NC} $(nproc) cores"
echo -e "${GREEN}RAM:${NC} $(free -h | awk '/Mem:/ {print $2}')"
echo -e "${GREEN}IP:${NC} $(curl -s ifconfig.me)"
}

# ---------------- MENU ----------------
case $option in

1)
install_panel
;;

2)
install_wings
;;

3)
install_panel
install_wings
;;

4)
cd /var/www/pterodactyl
php artisan p:user:make
;;

5)
bash <(curl -s https://raw.githubusercontent.com/jlpggamerz/Wingcmd/refs/heads/main/install.sh)
;;

6)
install_puffer
;;

7)
bash <(curl -s https://raw.githubusercontent.com/jlpggamerz/Vps-cmd-code-/refs/heads/main/install.sh)
;;

8)
system_info
;;

9)
echo -e "${RED}Exiting...${NC}"
exit
;;

*)
echo -e "${RED}Invalid Option!${NC}"
;;

esac

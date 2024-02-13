variable "region" {
    default = "us-west-2"
}


variable "ec2_instance_type" {
    description = "AWS EC2 instance type."
    type = string
    default = "t3.micro"
}

variable "ami" {
    description = "AWS EC2 instance ami type."
    type = string
    default = "ami-0b98fa71853d8d270"  // eg:Ubuntu OS
}

variable "default-VPC" {
    description = "AWS Defualt VPC"
    type = string
    default = "vpc-0bc0045418284a100"
}


variable "user_data" {
    description = "User Data for basic home lab instance"
    type        = string
    default     = <<EOF
#!/bin/bash
# installing docker
sudo apt-get update -y
sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose -y
sudo usermod -aG docker $USER
sudo chmod 666 /var/run/docker.sock
sudo service docker restart
sudo apt-get update -y

# installing  aws cli & Terraform 
sudo apt-get install unzip -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
sudo aws --version
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform -y
sudo apt-get update -y

# Adding Portainer & ITtools & uptime-kuma
docker volume create portainer_data
docker run -d -p 9000:9000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest
docker run -d --name it-tools --restart unless-stopped -p 8090:80 ghcr.io/corentinth/it-tools:latest
docker run -d --restart=always -p 3001:3001 -v uptime-kuma:/app/data --name uptime-kuma louislam/uptime-kuma:1

# Docker Compose Emby-media Configuration
cat <<EOL > docker-compose.yml
version: '3'
services:
  emby:
    image: lscr.io/linuxserver/emby:latest
    container_name: emby
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
    volumes:
      - /path/to/library:/config
      - /path/to/tvshows:/data/tvshows
      - /path/to/movies:/data/movies
    ports:
      - 8096:8096
      - 8920:8920 #optional
    restart: unless-stopped
EOL
docker-compose up -d

# uTorrent installing
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y
sudo apt install -y libssl-dev
sudo wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl1.0/libssl1.0.0_1.0.2n-1ubuntu5_amd64.deb
sudo apt install -y ./libssl1.0.0_1.0.2n-1ubuntu5_amd64.deb

sudo adduser --system --group vpsfix
sudo wget http://download-hr.utorrent.com/track/beta/endpoint/utserver/os/linux-x64-ubuntu-13-04 -O utserver.tar.gz

sudo tar xvf utserver.tar.gz -C /opt/
sudo ln -s /opt/utorrent-server-alpha-v3_3/utserver /usr/bin/utserver

sudo bash -c 'cat <<EOL > /etc/systemd/system/utserver.service
[Unit]
Description=uTorrent Server
After=network.target

[Service]
Type=simple
User=vpsfix
Group=vpsfix
ExecStart=/usr/bin/utserver -settingspath /opt/utorrent-server-alpha-v3_3/
ExecStop=/usr/bin/pkill utserver
Restart=always
SyslogIdentifier=uTorrent Server

[Install]
WantedBy=multi-user.target
EOL'

sudo systemctl daemon-reload
sudo chown vpsfix:vpsfix /opt/utorrent-server-alpha-v3_3/ -R

sudo systemctl enable utserver
sudo systemctl start utserver
EOF
}


variable "name-key-pair" {
    description = "the ssh key pair"
    type = string
    default = "the key name"
}

variable "public-key-pair" {
    description = "the ssh key pair public key"
    type = string
    default = "****"  // replace with your public key
}


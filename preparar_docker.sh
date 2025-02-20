#!/bin/bash

# Atualizando o servidor
echo "Atualizando o servidor..."
apt update -y
apt upgrade -y

# Instalando dependências
echo "Instalando dependências..."
apt-get install -y curl apt-transport-https ca-certificates software-properties-common

# Adicionando repositório do Docker
echo "Adicionando repositório do Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Atualizando novamente após adicionar o repositório
echo "Atualizando lista de pacotes..."
apt update -y
apt install -y git
# Instalando Docker
echo "Instalando Docker..."
apt install -y docker-ce

# Alternando para o backend legado do iptables
echo "Configurando iptables para usar o backend legado..."
update-alternatives --set iptables /usr/sbin/iptables-legacy
update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy

# Habilitando e iniciando o Docker
echo "Habilitando e iniciando o Docker..."
systemctl enable docker
systemctl start docker
/etc/init.d/docker start

# Inicializando o Docker Swarm
echo "Inicializando o Docker Swarm..."
docker swarm init

# Criando diretório para o Portainer e ajustando permissões
echo "Criando diretório /portainer e ajustando permissões..."

git clone https://github.com/ricardobras/metodoep1.git /portainer

chmod 777 -R /portainer/
cd /portainer

#iniciando portainer
docker stack deploy -c /portainer/portainer.yaml portainer
# Criando redes Docker para Traefik e aplicações
echo "Criando redes Docker (traefik_public e app_network)..."
docker network create --driver=overlay traefik_public
docker network create --driver=overlay app_network

# Implantando o Portainer usando um arquivo YAML
echo "Implantando o Portainer com docker stack deploy..."

echo "Instalação concluída!"
echo "Acesse o Portainer em http://seu_ip:9000"

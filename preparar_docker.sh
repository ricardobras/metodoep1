#!/bin/bash

# Atualizando o servidor
echo "Atualizando o servidor..."
apt update -y
apt upgrade -y

# Instalando dependências
echo "Instalando dependências..."
apt-get install -y curl apt-transport-https ca-certificates software-properties-common

# Adicionando repositório do Docker sem pedir confirmação
echo "Adicionando repositório do Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

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

# Passo 1: Destacar o prompt e solicitar o novo domínio
echo -e "\n\e[1;32m*************************************************************\e[0m"
echo -e "\e[1;32m*      Digite o novo domínio para substituir no arquivo      *\e[0m"
echo -e "\e[1;32m*             (exemplo: meudominio.com)                     *\e[0m"
echo -e "\e[1;32m*************************************************************\e[0m"
echo -n "Digite o novo domínio: "
read novo_dominio

# Passo 2: Concatenar 'portainer.' ao domínio
subdominio="portainer.$novo_dominio"

# Passo 3: Verificar se o arquivo portainer.yaml existe
arquivo="/portainer/portainer.yaml"
if [ -f "$arquivo" ]; then
    # Passo 4: Substituir o domínio no arquivo
    sed -i "s/meudominio.com/$subdominio/g" "$arquivo"
    echo -e "\e[1;34mSubdomínio substituído com sucesso! Novo subdomínio: $subdominio\e[0m"
else
    echo -e "\e[1;31mArquivo portainer.yaml não encontrado!\e[0m"
fi

# Iniciando Portainer
docker stack deploy -c /portainer/portainer.yaml portainer

# Criando redes Docker para Traefik e aplicações
echo "Criando redes Docker (traefik_public e app_network)..."
docker network create --driver=overlay traefik_public
docker network create --driver=overlay app_network

# Implantando o Portainer usando um arquivo YAML
echo "Implantando o Portainer com docker stack deploy..."

# Mensagem de sucesso com o endereço de acesso
ip_servidor=$(hostname -I | awk '{print $1}')
echo -e "\n\e[1;32mInstalação concluída!\e[0m"
echo -e "\e[1;32mAcesse o Portainer em: http://$ip_servidor:9000\e[0m"
echo -e "\n\e[1;33m** Observação: Para que o acesso ao Portainer funcione corretamente, você precisará adicionar o seguinte registro CNAME no seu DNS: \e[0m"
echo -e "\e[1;33m** portainer.$novo_dominio -> $ip_servidor\e[0m"
echo -e "\e[1;33m** Após configurar o DNS, você poderá acessar o Portainer usando o endereço: portainer.$novo_dominio\e[0m"

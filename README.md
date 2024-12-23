# Estudo de Volumes com Docker: WordPress com Nginx, PHP-FPM e MariaDB

Este projeto tem como objetivo demonstrar como configurar e gerenciar uma aplicação WordPress utilizando Docker. A arquitetura da aplicação é composta por três contêineres independentes: **MariaDB** (para o banco de dados), **Nginx** (como servidor web) e **PHP-FPM** (para processamento PHP). Além disso, a configuração inclui o uso de volumes para persistir dados e melhorar o gerenciamento da aplicação.

## Estrutura do Projeto

O projeto é composto por três serviços principais:

1. **MariaDB**: Servidor de banco de dados que armazena os dados do WordPress.
2. **Nginx**: Servidor web que serve os arquivos do WordPress e interage com o PHP-FPM para processar conteúdo dinâmico.
3. **PHP-FPM**: Processador PHP que executa o código PHP do WordPress.

### Arquivos do Projeto

- **nginx/**: Diretório que contém a configuração do Nginx.
- **wp-config.php**: Arquivo de configuração do WordPress, utilizado para configurar o banco de dados.
- **Dockerfile para MariaDB**: Arquivo que define o contêiner para o MariaDB.
- **Dockerfile para Nginx**: Arquivo que define o contêiner para o Nginx.
- **Dockerfile para PHP-FPM**: Arquivo que define o contêiner para o PHP-FPM.

## Pré-requisitos

- **Docker**: Certifique-se de ter o Docker instalado e configurado corretamente na sua máquina.
- **Docker Compose** (opcional): Pode ser utilizado para orquestrar os contêineres, facilitando o gerenciamento de rede e volumes entre os contêineres.

## Como Executar a Aplicação

### 1. Criar a Rede Docker

Primeiro, crie uma rede Docker para que os contêineres se comuniquem entre si de forma isolada. Isso pode ser feito com o comando `docker network create wordpress-net`.

### 2. Executar o Banco de Dados (MariaDB)

Inicie o contêiner MariaDB com o seguinte comando:

- O MariaDB é configurado para criar o banco de dados `wordpress`, configurar o usuário `user` com senha `1234` e permitir o acesso remoto.
- O acesso remoto ao banco de dados é habilitado, alterando o arquivo de configuração do MariaDB.

### 3. Executar o PHP-FPM

O contêiner PHP-FPM é responsável por processar as requisições PHP. Ele é configurado para escutar na porta 9000, com suporte para as principais extensões do PHP, como `php-mysql`, `php-curl`, `php-json`, entre outras. Ele é configurado para se conectar ao MariaDB e processar o conteúdo dinâmico do WordPress.

### 4. Executar o Nginx

O Nginx serve como o servidor web, servindo o conteúdo estático do WordPress e encaminhando as requisições PHP para o contêiner PHP-FPM.

- O Nginx é configurado para escutar na porta 80.
- O WordPress é baixado e extraído no diretório `/var/www/html`.
- O arquivo `wp-config.php` é copiado para o contêiner para configurar o banco de dados.

## Configuração do WordPress

A configuração do WordPress é realizada por meio do arquivo `wp-config.php`, onde são definidas as informações de conexão com o banco de dados.

No arquivo `wp-config.php`, as seguintes variáveis precisam ser configuradas:

- **DB_NAME**: Nome do banco de dados.
- **DB_USER**: Usuário do banco de dados.
- **DB_PASSWORD**: Senha do banco de dados.
- **DB_HOST**: Host do banco de dados (para contêineres Docker, o nome do serviço ou contêiner do banco de dados).

Exemplo de configurações do `wp-config.php`:

```php
define( 'DB_NAME', 'wordpress' );
define( 'DB_USER', 'user' );
define( 'DB_PASSWORD', '1234' );
define( 'DB_HOST', 'mariadb' );  // Nome do serviço ou contêiner MariaDB
```

## Detalhes dos Dockerfiles

### Dockerfile para MariaDB

Este Dockerfile configura o MariaDB, criando o banco de dados e o usuário para o WordPress:

- Instala o MariaDB e configura o banco de dados `wordpress`.
- Cria o usuário `user` com senha `1234`.
- Configura o MariaDB para aceitar conexões de qualquer IP, permitindo o acesso remoto.

```dockerfile
FROM debian:12.8

EXPOSE 3306

RUN apt update -y && apt install mariadb-server -y

## Configuração do MariaDB (criação da senha do root, criação do usuário WordPress)
RUN /etc/init.d/mariadb start && mysql -u root -e  "CREATE USER 'user'@'%' IDENTIFIED BY '1234'; \
 CREATE DATABASE wordpress CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci; \
 GRANT ALL PRIVILEGES ON *.* TO 'user'@'%' WITH GRANT OPTION; \
 ALTER USER 'root'@'localhost' IDENTIFIED BY '1234'; \
 FLUSH PRIVILEGES;"

## Configuração para habilitar o acesso remoto
RUN sed -i "s/^bind-address.*$/bind-address = 0.0.0.0/" /etc/mysql/mariadb.conf.d/50-server.cnf

CMD ["mariadbd", "--user=root"]
```

### Dockerfile para Nginx

Este Dockerfile configura o Nginx para servir o WordPress e se comunicar com o PHP-FPM:

- Instala o Nginx e baixa o WordPress.
- Configura o Nginx para servir o conteúdo do WordPress.
- Define permissões adequadas para os arquivos do WordPress.

```dockerfile
FROM debian:12.8

RUN apt-get update -y && apt-get install -y \
    nginx \
    rpcbind \
    wget && \
    apt-get clean

EXPOSE 80

# Configuração do Nginx
COPY ./nginx /etc/nginx/sites-enabled/default 
WORKDIR /var/www/html

# Configuração do WordPress
RUN wget https://wordpress.org/latest.tar.gz && tar -xvzf latest.tar.gz
RUN chown -R www-data: /var/www/html/ && chmod -R 755 /var/www/html/
COPY ./wp-config.php /var/www/html/wordpress/wp-config.php

RUN mkdir /run/sendsigs.omit.d

CMD ["bash", "-c", "rpcbind && nginx -g 'daemon off;'"]
```

### Dockerfile para PHP-FPM

Este Dockerfile configura o PHP-FPM para processar os scripts PHP do WordPress:

- Instala o PHP e as extensões necessárias para o WordPress.
- Configura o PHP-FPM para escutar em `0.0.0.0:9000`.

```dockerfile
FROM debian:12.8

EXPOSE 9000

RUN apt update -y && \
    apt install -y \
    lsb-release \
    apt-transport-https \
    ca-certificates \
    wget && \
    wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list && \
    apt update -y && \
    apt install -y \
    php \
    php-mysql \
    php-curl \
    php-json \
    php-xml \
    php-mbstring \
    php-fpm

RUN sed -i -e "/^listen =/ s/^.*$/listen = 0.0.0.0:9000/" /etc/php/8.3/fpm/pool.d/www.conf

CMD ["bash", "-c", "php-fpm8.3 -F"]
```

## Gerenciamento de Volumes

Os dados persistentes, como arquivos do WordPress e banco de dados, são armazenados em volumes Docker, o que permite a continuidade dos dados mesmo após a reinicialização ou remoção de contêineres. É recomendado utilizar volumes para garantir a integridade e persistência dos dados.

Para criar volumes para o WordPress e MariaDB, adicione as opções `-v` nos comandos de execução dos contêineres:

```bash
docker run -d --name mariadb --network wordpress-net -v mariadb_data:/var/lib/mysql -p 3306:3306 mariadb:latest
docker run -d --name nginx --network wordpress-net -v wordpress_data:/var/www/html -p 80:80 nginx:latest
docker run -d --name php-fpm --network wordpress-net -v wordpress_data:/var/www/html -p 9000:9000 php-fpm:latest
```

## Conclusão

Este estudo de volumes com Docker demonstra como configurar e orquestrar uma aplicação WordPress com Nginx, PHP-FPM e MariaDB. Utilizando volumes Docker, você garante que os dados do banco de dados e os arquivos do WordPress sejam persistentes, independentemente de mudanças nos contêineres.
# volume-studies

## README - WordPress com Nginx, PHP-FPM e MariaDB no Docker
Este projeto contém uma aplicação WordPress configurada com contêineres Docker, usando as tecnologias Nginx para o servidor web, PHP-FPM para processamento PHP e MariaDB como banco de dados. Ele foi projetado para funcionar em contêineres separados que se comunicam entre si por meio de uma rede Docker interna.

# Estrutura do Projeto
O projeto é composto por três serviços principais:

MariaDB: Servidor de banco de dados para o WordPress.
Nginx: Servidor web que serve os arquivos do WordPress e interage com o PHP-FPM.
PHP-FPM: Processador PHP que executa o código do WordPress.
A seguir, detalhes de cada serviço e como eles são configurados.

# Pré-requisitos
Docker: Certifique-se de ter o Docker instalado e configurado corretamente em sua máquina.
Docker Compose (opcional, se você deseja usar para orquestrar os contêineres).
Como Executar a Aplicação
1. Criar a Rede Docker
Primeiro, crie uma rede Docker para os contêineres se comunicarem entre si.

2. Executar o Banco de Dados (MariaDB)
Inicie o contêiner MariaDB com o seguinte comando.

Isso criará o banco de dados WordPress e configurará as permissões.

3. Executar o PHP-FPM
Inicie o contêiner PHP-FPM.

4. Executar o Nginx
Inicie o contêiner Nginx.

# Estrutura de Arquivos
nginx/: Contém a configuração do Nginx.
wp-config.php: Arquivo de configuração do WordPress.
Dockerfile para Nginx: Arquivo que define o contêiner Nginx.
Dockerfile para PHP-FPM: Arquivo que define o contêiner PHP-FPM.
Dockerfile para MariaDB: Arquivo que define o contêiner MariaDB.
# Configuração do WordPress
A configuração do WordPress é feita através do arquivo wp-config.php, onde as informações do banco de dados, como nome do banco, usuário e senha, são definidas.

DB_NAME: Nome do banco de dados.
DB_USER: Usuário do banco de dados.
DB_PASSWORD: Senha do banco de dados.
DB_HOST: Host do banco de dados (no caso do Docker, o nome do contêiner ou serviço de banco de dados).
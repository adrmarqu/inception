# Inception - 42 Barcelona

Inception is a system administration and DevOps project from the 42 Barcelona curriculum. The goal is to build, configure, and orchestrate a secure, modular web infrastructure containerized with Docker and orchestrated with Docker Compose on Debian Bookworm. The infrastructure consists of an NGINX reverse proxy acting as the sole entrypoint with TLS 1.2 and 1.3 encryption, a WordPress application driven by PHP-FPM, and a dedicated MariaDB database server. All services communicate over an isolated private bridge network with persistent host storage.

# Prerequisites

To configure and launch the Inception stack, you will need:

- Docker Engine (v20.10 or higher, or Docker Desktop)
- Docker Compose (v2 integrated via docker compose)
- GNU Make and standard Unix utilities
- Superuser privileges (sudo) to update /etc/hosts for domain resolution

# Configuration

1. Clone the repository:
```bash
git clone https://github.com/adrmarqu/inception.git
cd inception
```

2. Configure environment variables in srcs/.env:
Copy the template file to srcs/.env if not present, and update the values:
```env
# Domain configuration (mandatory 42 format: <login>.42.fr)
DOMAIN_NAME=adrmarqu.42.fr

# Base host storage path for persistent volumes:
DATA_PATH=/home/adrmarqu/data

# MariaDB Credentials
MYSQL_DATABASE=wordpress
MYSQL_USER=wp_adrmarqu
MYSQL_PASSWORD=your_secure_db_password
MYSQL_ROOT_PASSWORD=your_secure_root_password

# WordPress Site Settings
WORDPRESS_TITLE=Inception Site

# WordPress Administrator (Forbidden to contain 'admin' or 'administrator')
WORDPRESS_ADMIN_USER=superuser42
WORDPRESS_ADMIN_PASSWORD=your_secure_admin_password
WORDPRESS_ADMIN_EMAIL=superuser42@adrmarqu.42.fr

# WordPress Regular User (Role: author)
WORDPRESS_USER=wp_adri
WORDPRESS_USER_PASSWORD=your_secure_user_password
WORDPRESS_USER_EMAIL=wp_adri@adrmarqu.42.fr
```

3. Map the domain name in your local /etc/hosts file:
```bash
echo "127.0.0.1 adrmarqu.42.fr" | sudo tee -a /etc/hosts
```

# Execution

### Start the Infrastructure

Build the container images and launch the infrastructure in detached mode:
```bash
make
```
The Makefile automatically validates .env, prepares secrets in secrets/, provisions host storage directories, builds each custom image, and starts all services.

### Accessing the Services

Open your browser and navigate to:
- WordPress Website: https://adrmarqu.42.fr
- WordPress Admin Panel: https://adrmarqu.42.fr/wp-admin

Note: Because the TLS certificate is dynamically self-signed, bypass the browser security warning to enter the site.

### Stop the Infrastructure

Stop all running containers without removing data volumes:
```bash
make down
```

# Project Structure

```
inception/
├── Makefile                     # Infrastructure lifecycle automation
├── secrets/                     # Secure credentials mounted into containers
└── srcs/
    ├── docker-compose.yml       # Service composition and network definition
    ├── .env                     # Global environment parameters
    └── requirements/
        ├── nginx/               # NGINX reverse proxy service
        │   ├── Dockerfile       # Custom Debian Bookworm build
        │   ├── conf/            # TLS configuration and FastCGI rules
        │   └── tools/           # SSL certificate generation scripts
        ├── wordpress/           # WordPress + PHP-FPM service
        │   ├── Dockerfile       # PHP-FPM 8.2 and WP-CLI dependencies
        │   ├── conf/            # www.conf listening on port 9000
        │   └── tools/           # Auto-installer script via WP-CLI
        └── mariadb/             # MariaDB relational database service
            ├── Dockerfile       # MariaDB 10.11 server setup
            ├── conf/            # 50-server.cnf binding and network config
            └── tools/           # Database initialization and grant script
```

# Commands and Makefile Targets

- make or make all: Create directories, generate secrets, build images, and run all containers
- make up: Start containers in the background
- make down: Stop containers gracefully
- make start: Start previously stopped containers
- make stop: Stop running containers without removal
- make status: Inspect container status via docker compose ps
- make logs: Follow live log output from all services
- make clean: Stop containers and clean orphan networks
- make fclean: Complete reset, wiping containers, images, volumes, and persistent host files
- make re: Recompile and reinitialize the entire infrastructure from scratch

# Architecture and Security Features

- Single Exposed Port: Only port 443 (HTTPS) is accessible on the host machine. MariaDB (port 3306) and WordPress (port 9000) communicate exclusively inside the private inception_net network.
- Protocol Security: NGINX strictly accepts TLS 1.2 and TLS 1.3 cryptographic protocols, discarding legacy vulnerable versions.
- Data Persistence: Persistent host volume bind mounts ensure database tables, WordPress media, and uploaded content survive container restarts and complete rebuilds.
- 42 Evaluation Compliance: No service uses latest tags, all images derive from debian:bookworm-slim, and administrative credentials satisfy evaluation constraints.

# Author Details

Author: Adrià Márquez Nebot
Github: https://github.com/adrmarqu
LinkedIn: https://www.linkedin.com/in/adria-marquez
Portfolio: https://adrmarqu.github.io

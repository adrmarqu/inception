# 🐳 Inception - 42 School

This project consists of designing and administering a complete web infrastructure, containerized with **Docker** and orchestrated using **Docker Compose**, strictly following the system administration and security guidelines of the **42** curriculum.

---

## 🏗️ System Architecture

The infrastructure runs on an isolated private bridge network (`inception_net`) and consists of three dedicated services, each built inside its own container using **Debian Bookworm**:

```
                       [ Client / Browser ]
                                │
                                │ (Port 443 - HTTPS / TLS 1.2 or 1.3)
                                ▼
                  ┌───────────────────────────┐
                  │      NGINX Container      │
                  │     (Single Entrypoint)   │
                  └─────────────┬─────────────┘
                                │
                                │ (FastCGI - Port 9000)
                                ▼
                  ┌───────────────────────────┐
                  │    WordPress + PHP-FPM    │
                  └─────────────┬─────────────┘
                                │
                                │ (MySQL - Port 3306)
                                ▼
                  ┌───────────────────────────┐
                  │     MariaDB Container     │
                  └───────────────────────────┘
```

### Services Breakdown

1. **NGINX:**
   * The **sole entrypoint** to the infrastructure (exposing port `443` only).
   * Strictly configured for **TLSv1.2 and TLSv1.3** protocols only.
   * Dynamically generates self-signed SSL certificates for the configured domain.
   * Proxies PHP requests to WordPress over FastCGI (`wordpress:9000`).

2. **WordPress + PHP-FPM 8.2:**
   * Runs PHP-FPM listening on port `9000` (isolated from external access).
   * Automated installation, database configuration, and user creation via **WP-CLI**.
   * Creates two users: a secure administrator (complying with 42 naming restrictions) and a regular user with the author role.

3. **MariaDB 10.11:**
   * Dedicated database server listening on port `3306` inside the internal network.
   * Robust initialization script that automatically handles empty volume mounts via `mariadb-install-db`.
   * Secure initialization with dedicated user privileges and root credentials.

### Volumes and Data Persistence

Data persists across container restarts, stops, and rebuilds through host bind mounts configured at `${DATA_PATH}`:
* `${DATA_PATH}/wordpress` ➔ `/var/www/html` in WordPress and NGINX.
* `${DATA_PATH}/mariadb` ➔ `/var/lib/mysql` in MariaDB.

---

## 📋 Prerequisites

* **Docker Engine** (v20+ or Docker Desktop on macOS).
* **Docker Compose** (v2 integrated via `docker compose`).
* **Make** and standard Unix utilities.
* Superuser privileges (`sudo`) to edit `/etc/hosts` and manage host data directories.

---

## ⚙️ Step-by-Step Configuration

### 1. Clone the Repository

```bash
git clone <repository-url> inception
cd inception
```

### 2. Configure Environment Variables (`.env`)

Copy the template file to `srcs/.env`:

```bash
cp srcs/.env.example srcs/.env
```

Open `srcs/.env` and adjust the variables to match your environment:

```env
# Domain configuration (mandatory 42 format: <login>.42.fr)
DOMAIN_NAME=adrmarqu.42.fr

# Base host storage path for persistent volumes:
# - On 42 school computers (Linux): /home/<login>/data
# - On personal Linux or macOS:     ./data or /Users/<username>/data
DATA_PATH=/home/adrmarqu/data

# MariaDB Credentials
MYSQL_DATABASE=wordpress
MYSQL_USER=wp_adrmarqu
MYSQL_PASSWORD=your_secure_db_password
MYSQL_ROOT_PASSWORD=your_secure_root_password

# WordPress Site Settings
WORDPRESS_TITLE="Inception Site"

# WordPress Administrator
# IMPORTANT: 42 evaluation strictly forbids usernames containing 'admin' or 'administrator'
WORDPRESS_ADMIN_USER=superuser42
WORDPRESS_ADMIN_PASSWORD=your_secure_admin_password
WORDPRESS_ADMIN_EMAIL=superuser42@adrmarqu.42.fr

# WordPress Regular User (Role: author)
WORDPRESS_USER=wp_adri
WORDPRESS_USER_PASSWORD=your_secure_user_password
WORDPRESS_USER_EMAIL=wp_adri@adrmarqu.42.fr
```

> [!TIP]
> **No manual secret file setup required:** When you run `make`, the Makefile automatically reads passwords from `srcs/.env` and populates any missing or empty files in `secrets/`.

### 3. Add Domain to `/etc/hosts`

To resolve `<login>.42.fr` to your local machine, add an entry to `/etc/hosts`:

```bash
echo "127.0.0.1 adrmarqu.42.fr" | sudo tee -a /etc/hosts
```

*(Replace `adrmarqu.42.fr` with your configured `DOMAIN_NAME`)*.

---

## 🚀 Running and Managing the Project

All container lifecycle tasks are managed via the root [Makefile](file:///Users/adria/Desktop/42Barcelona/inception/Makefile):

### Start Everything (Build and Run)

```bash
make
```
*(Equivalent to `make all`. Validates `.env`, creates data and secret directories, builds Docker images, and starts all containers in detached mode)*.

### Available Commands

| Command | Description |
| :--- | :--- |
| `make` / `make all` | Initialize directories & secrets, build images, and start all containers |
| `make up` | Start containers in the background |
| `make down` | Stop containers without deleting images or volume data |
| `make start` | Start stopped containers |
| `make stop` | Stop running containers without removing them |
| `make status` | View container status (`docker compose ps`) |
| `make logs` | Stream real-time logs from all running services |
| `make clean` | Stop containers and remove orphan networks |
| `make fclean` | **Deep clean:** Stop containers, remove Docker volumes, images, and wipe host data directories |
| `make re` | Complete reset: runs `make fclean` followed by `make all` |
| `make dangling` | Prune unused and dangling Docker images |
| `make help` | Display available Makefile targets |

---

## 🌐 Verification and Access

1. **Visit the Website:**
   Navigate to:
   ```
   https://adrmarqu.42.fr
   ```
   > [!NOTE]
   > Because the SSL certificate is self-signed, browsers will display a security warning. Click **"Advanced"** and proceed to the site (**"Proceed to ... (unsafe)"**).

2. **Access the WordPress Admin Panel:**
   Navigate to:
   ```
   https://adrmarqu.42.fr/wp-admin
   ```
   Log in with the credentials defined in `srcs/.env`:
   * **Username:** `WORDPRESS_ADMIN_USER`
   * **Password:** `WORDPRESS_ADMIN_PASSWORD`

---

## 🔍 42 Evaluation Checklist

* [x] **No `latest` tag:** No service image or Dockerfile uses `:latest`.
* [x] **Debian Bookworm base:** All containers are built from `debian:bookworm-slim`.
* [x] **Strict port exposure:** Only port `443` is exposed on the host. MariaDB (`3306`) and WordPress (`9000`) communicate exclusively within `inception_net`.
* [x] **TLS 1.2 / 1.3:** NGINX rejects legacy insecure protocols (SSLv3, TLS 1.0, TLS 1.1).
* [x] **Admin username compliance:** The admin username does not contain `admin` or `administrator`.
* [x] **Volume persistence verified:**
  ```bash
  make down
  make up
  ```
  All WordPress posts, user accounts, and database entries remain intact after restarting containers.
* [x] **Safe cleanup (`make fclean`):** Removes only WordPress and MariaDB volume data without risking project source files.

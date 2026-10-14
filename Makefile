# Makefile - 42 Inception
ENV_FILE = srcs/.env
-include $(ENV_FILE)

# Persistent volumes path (configurable in .env)
DATA_PATH ?= /home/$(USER)/data
WP_DATA = $(DATA_PATH)/wordpress
DB_DATA = $(DATA_PATH)/mariadb
SECRETS_DIR = secrets

# Docker Compose command
DC = docker compose -f ./srcs/docker-compose.yml --env-file $(ENV_FILE)

# Default target
all: build up

check-env:
	@if [ ! -f srcs/.env ] && [ -f .env ]; then \
		cp .env srcs/.env; \
	fi
	@if [ ! -f $(ENV_FILE) ]; then \
		echo "❌ Error: $(ENV_FILE) not found."; \
		echo "ℹ️  Please create it from the example:"; \
		echo "   cp srcs/.env.example srcs/.env"; \
		exit 1; \
	fi

init-dirs: check-env
ifeq ($(UNAME_S),Darwin)
	@echo "🍎 macOS detected: using $(DATA_PATH) for local volumes (as /home is reserved by macOS autofs)"
endif
	@mkdir -p $(WP_DATA)
	@mkdir -p $(DB_DATA)
	@mkdir -p $(SECRETS_DIR)

init-secrets: check-env init-dirs
	@if [ ! -s $(SECRETS_DIR)/db_password.txt ]; then \
		printf "%s" "$(MYSQL_PASSWORD)" > $(SECRETS_DIR)/db_password.txt; \
	fi
	@if [ ! -s $(SECRETS_DIR)/db_root_password.txt ]; then \
		printf "%s" "$(MYSQL_ROOT_PASSWORD)" > $(SECRETS_DIR)/db_root_password.txt; \
	fi
	@if [ ! -s $(SECRETS_DIR)/wp_admin_password.txt ]; then \
		printf "%s" "$(WORDPRESS_ADMIN_PASSWORD)" > $(SECRETS_DIR)/wp_admin_password.txt; \
	fi
	@if [ ! -s $(SECRETS_DIR)/wp_user_password.txt ]; then \
		printf "%s" "$(WORDPRESS_USER_PASSWORD)" > $(SECRETS_DIR)/wp_user_password.txt; \
	fi
	@if [ ! -f $(SECRETS_DIR)/credentials.txt ]; then \
		touch $(SECRETS_DIR)/credentials.txt; \
	fi

build: init-secrets
	$(DC) build

up: init-secrets
	$(DC) up -d

down:
	$(DC) down

stop:
	$(DC) stop

start:
	$(DC) start

restart: clean all

clean:
	$(DC) down --remove-orphans

fclean:
	@echo "🧹 Stopping containers, removing images and volumes..."
	-$(DC) down -v --rmi all --remove-orphans
	@echo "🧹 Removing data directories ($(WP_DATA), $(DB_DATA))..."
	-rm -rf $(WP_DATA) $(DB_DATA) 2>/dev/null || sudo rm -rf $(WP_DATA) $(DB_DATA)

re: fclean all

status:
	$(DC) ps

logs:
	$(DC) logs -f

dangling:
	docker image prune -f

help:
	@echo "📋 Available commands:"
	@echo "  make all      - Prepare directories/secrets, build images, and start containers"
	@echo "  make build    - Build all service images"
	@echo "  make up       - Launch containers in background"
	@echo "  make down     - Stop containers"
	@echo "  make start    - Start stopped containers"
	@echo "  make stop     - Stop containers without removing them"
	@echo "  make restart  - Clean containers and restart"
	@echo "  make clean    - Remove containers and network orphans"
	@echo "  make fclean   - Remove containers, images, volumes and data directories"
	@echo "  make re       - Full cleanup (fclean) and rebuild/start everything (all)"
	@echo "  make status   - Show running containers"
	@echo "  make logs     - Follow logs from all services"
	@echo "  make dangling - Prune unused dangling docker images"
	@echo "  make help     - Show this help message"

h: help

.PHONY: all check-env init-dirs init-secrets build up down stop start restart clean fclean re status logs dangling help h
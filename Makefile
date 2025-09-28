DOCKER_COMPOSE = docker-compose -f srcs/docker-compose.yml --env-file srcs/.env
SERVICES = nginx wordpress mariadb
DATA_DIR = ./data

all: setup build up

setup:
	@echo "📁 Creando carpetas de datos..."
	@mkdir -p $(DATA_DIR)
	@for service in $(SERVICES); do \
		mkdir -p $(DATA_DIR)/$$service; \
	done
	@echo "✅ Carpetas de datos listas en $(DATA_DIR)"

build:
	@echo "🔧 Construyendo todas las imágenes..."
	$(DOCKER_COMPOSE) build

up:
	@echo "🚀 Levantando los contenedores..."
	$(DOCKER_COMPOSE) up -d

down:
	@echo "🛑 Deteniendo los contenedores..."
	$(DOCKER_COMPOSE) down

restart: down up

logs:
	@echo "📄 Mostrando logs de los contenedores..."
	$(DOCKER_COMPOSE) logs -f

clean:
	@echo "🧹 Limpiando contenedores, imágenes y volúmenes..."
	$(DOCKER_COMPOSE) down -v --rmi all --remove-orphans

fclean: clean
	@echo "🧹 Limpiando datos..."
	rm -rf $(DATA_DIR)

help:
	@echo "📋 Comandos disponibles:"
	@echo "  make all       - Crear carpetas de datos, construir imágenes y levantar contenedores"
	@echo "  make setup     - Crear carpetas de datos para los servicios"
	@echo "  make build     - Construir imágenes de todos los servicios"
	@echo "  make up        - Levantar contenedores en segundo plano"
	@echo "  make down      - Detener contenedores"
	@echo "  make restart   - Reiniciar contenedores"
	@echo "  make logs      - Ver logs de todos los contenedores"
	@echo "  make clean     - Borrar contenedores, imágenes y volúmenes"
	@echo "  make fclean    - Borrar $(DATA_DIR), contenedores, imágenes y volúmenes"
	@echo "  make help      - Mostrar esta ayuda"

.PHONY: all build up down restart logs clean setup help

DC = docker-compose -f ./srcs/docker-compose.yml --env-file srcs/.env
DATA = /home/adrmarqu/data

all: build up

build:
	mkdir -p $(DATA)
	mkdir -p $(DATA)/WordPress
	mkdir -p $(DATA)/DB
	$(DC) build

up:
	$(DC) up -d

down:
	$(DC) down

clean:
	$(DC) down --remove-orphans

fclean:
	$(DC) down -v --rmi all --remove-orphans
	sudo rm -rf $(DATA)

restart: clean all

re: fclean all

dangling:
	docker image prune -f

help:
	@echo "📋 Available commands:"
	@echo "  make all	- Create data folders, build images, and launch containers"
	@echo "  make build	- Build images of all services"
	@echo "  make up	- Launch containers in the background"
	@echo "  make down	- Stop containers"
	@echo "  make restart	- Restart containers"
	@echo "  make re	- Delete all and restart"
	@echo "  make clean	- Delete containers"
	@echo "  make fclean	- Delete $(DATA), containers, images and volumes"
	@echo "  make dangling	- Delete old containers"
	@echo "  make help	- Show this help"

h: help

.PHONY: all build up down kill clean fclean restart re help h dangling

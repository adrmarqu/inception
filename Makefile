# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: adrmarqu <marvin@42.fr>                    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/08/10 11:53:41 by adrmarqu          #+#    #+#              #
#    Updated: 2025/08/30 13:15:26 by adrmarqu         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

DC = docker-compose -f
FILE = srcs/docker-compose.yml
RO = --remove-orphans
DSP = docker system prune

all: up

build:
	$(DC) $(FILE) build

up:
	$(DC) $(FILE) up -d $(RO)

down:
	$(DC) $(FILE) down $(RO)

clean: down
	$(DSP) -f $(RO)

fclean: down
	$(DC) $(FILE) down -v $(RO)
	$(DSP) -af --volumes

logs:
	$(DC) $(FILE) logs -f

reboot:
	$(DC) $(FILE) restart

rebuild: fclean up

.PHONY: all build up down clean fclean logs reboot rebuild

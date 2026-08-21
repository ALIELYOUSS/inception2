compose	=	 ./srcs/docker-compose.yml

all: build up

up:	mk-vlms 
	@docker compose --file $(compose) up -d

build:
	@docker compose --file $(compose) build 

mk-vlms:
	@mkdir -p $(HOME)/data/wordpress
	@mkdir -p $(HOME)/data/mariadb

down:	
	@docker compose --file $(compose) down -v

check:	
	@docker compose --file $(compose) ps -a

rm-vlms:
	@rm -rf $(HOME)/data/*/* || true

clean: down 
	@docker image rm wordpress:alel-you nginx:alel-you mariadb:alel-you 2>/dev/null || true

fclean: clean rm-vlms

LANG=rust
DOCKER_COMPOSE=docker compose -f docker-compose-common.yml -f docker-compose-$(LANG).yml

build:
	$(DOCKER_COMPOSE) up --build

up:
	$(DOCKER_COMPOSE) up -d

down:
	$(DOCKER_COMPOSE) down --volumes

down-all:
	$(DOCKER_COMPOSE) down --volumes --rmi local

top:
	$(DOCKER_COMPOSE) top

logs:
	$(DOCKER_COMPOSE) logs -f

# データベースの中身を確認する
.PHONY: exec-mysql
exec-mysql:
	$(DOCKER_COMPOSE) exec -- mysql mysql -u root -proot isupipe

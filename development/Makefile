DOCKER_COMPOSE=docker compose -f docker-compose-common.yml -f docker-compose-go.yml

build/%:
	$(DOCKER_COMPOSE) up --build

up/%:
	$(DOCKER_COMPOSE) up

down/%:
	$(DOCKER_COMPOSE) down --volumes

down-all/%:
	$(DOCKER_COMPOSE) down --volumes --rmi local

top/%:
	$(DOCKER_COMPOSE) top

# 計測データを初期化する
.PHONY: truncate-mysql
truncate-mysql:
	$(DOCKER_COMPOSE) exec -- mysql mysql -u root -proot isupipe -e "TRUNCATE TABLE performance_schema.events_statements_summary_by_digest"


# 計測データを吐く
.PHONY: analyze-mysql
analyze-mysql:
	$(DOCKER_COMPOSE) exec -- mysql mysql -u root -proot isupipe < ../performance_schema.sql > ../webapp/logs/mysql/performance_schema.tsv

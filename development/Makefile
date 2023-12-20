DOCKER_COMPOSE=docker compose -f docker-compose-common.yml -f docker-compose-rust.yml

.PHONY: default
default: help

build:
	$(DOCKER_COMPOSE) build

up:
	$(DOCKER_COMPOSE) up -d

down:
	$(DOCKER_COMPOSE) down --volumes

down-all:
	$(DOCKER_COMPOSE) down --volumes --rmi local

restart:
	make down
	make up

top:
	$(DOCKER_COMPOSE) top

logs:
	$(DOCKER_COMPOSE) logs -f

# データベースの中身を確認する
.PHONY: exec-mysql
exec-mysql:
	$(DOCKER_COMPOSE) exec -- mysql mysql -u root -proot isupipe

# 計測データを初期化する
.PHONY: truncate-mysql
truncate-mysql:
	$(DOCKER_COMPOSE) exec -- mysql mysql -u root -proot isupipe -e "TRUNCATE TABLE performance_schema.events_statements_summary_by_digest"


# 計測データを吐く
.PHONY: analyze-mysql
analyze-mysql:
	$(DOCKER_COMPOSE) exec -- mysql mysql -u root -proot isupipe < ../performance_schema.sql > ../webapp/logs/mysql/performance_schema.tsv

.PHONY: help
help:
	@cat $(MAKEFILE_LIST) | python3 -u -c 'import sys, re; rx = re.compile(r"^[a-zA-Z0-9\-_]+:"); lines = [line.rstrip() for line in sys.stdin if not line.startswith(".PHONY")]; [print(f"""{line.split(":")[0]:20s}\t{prev.lstrip("# ")}""") if rx.search(line) and prev.startswith("# ") else print(f"""\n\033[92m{prev.lstrip("## ")}\033[0m""") if prev.startswith("## ") else "" for prev, line in zip([""] + lines, lines)]'

MAKE=make -C

DOCKER_BUILD=docker build
DOCKER_BUILD_OPTS=--no-cache
DOCKER_RMI=docker rmi -f

ISUPIPE_TAG=isupipe:latest
LOG_FILE_MYSQL=webapp/logs/mysql/mysql-slow.log

.PHONY: defaul
default: help

.PHONY: bench
bench:
	:> webapp/logs/nginx/access.log
	:> $(LOG_FILE_MYSQL)
	cd development && make restart && make truncate-mysql && cd ../
	sleep 3
	cd bench && make bench && cd ../
	cd development && make analyze-mysql

.PHONY: logs
logs:
	cd development && make logs

.PHONY: help
help:
	@cat $(MAKEFILE_LIST) | python3 -u -c 'import sys, re; rx = re.compile(r"^[a-zA-Z0-9\-_]+:"); lines = [line.rstrip() for line in sys.stdin if not line.startswith(".PHONY")]; [print(f"""{line.split(":")[0]:20s}\t{prev.lstrip("# ")}""") if rx.search(line) and prev.startswith("# ") else print(f"""\n\033[92m{prev.lstrip("## ")}\033[0m""") if prev.startswith("## ") else "" for prev, line in zip([""] + lines, lines)]'

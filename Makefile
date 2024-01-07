MAKE=make -C

DOCKER_BUILD=docker build
DOCKER_BUILD_OPTS=--no-cache
DOCKER_RMI=docker rmi -f

ISUPIPE_TAG=isupipe:latest
LOG_FILE_MYSQL=webapp/logs/mysql/mysql-slow.log
LOG_FILE_NGINX=webapp/logs/nginx/access.log
LOG_ERROR_FILE_NGINX=webapp/logs/nginx/error.log

.PHONY: default
default: help

## Run benchmark
# Restart servers and run benchmark
.PHONY: bench
bench:
	:> $(LOG_FILE_NGINX)
	:> $(LOG_ERROR_FILE_NGINX)
	:> $(LOG_FILE_MYSQL)
	cd development && make build && make restart && make truncate-mysql && cd ../
	sleep 3
	cd bench && make bench
	cd development && make analyze-mysql
	make analyze-nginx-log
	make analyze-mysql-log

# Restart servers and run pretest
.PHONY: pretest
pretest:
	:> $(LOG_FILE_NGINX)
	:> $(LOG_ERROR_FILE_NGINX)
	:> $(LOG_FILE_MYSQL)
	cd development && make build && make restart && make truncate-mysql && cd ../
	sleep 3
	cd bench && make pretest

## Monitors
# Show servers log
.PHONY: logs
logs:
	cd development && make less-logs

## Debug
# get into mysql
.PHONY: exec-mysql
exec-mysql:
	cd development && make exec-mysql

## ログの解析
# nginxのログ解析
.PHONY: analyze-nginx-log
analyze-nginx-log:
	cat $(LOG_FILE_NGINX) | \
		alp json \
			-o count,method,uri,min,avg,max,sum \
			--sort=sum -r \
			--matching-groups='/api/livestream/\d{4}/moderate$$,/api/livestream/\d{4}/statistics$$,/api/livestream/\d{4}/report$$,/api/livestream/\d{4}/ngwords$$,/api/livestream/\d{4}/exit$$,/api/livestream/\d{4}/enter$$,/api/livestream/\d{4}/livecomment$$,/api/livestream/\d{4}/livecomment/\d{4}/report$$,/api/livestream/\d{4}/reaction$$,/api/user/.*/statistics$$,/api/user/.*/icon$$,/api/user/.*/livestream$$,/api/user/.*/theme$$' \
			> webapp/logs/nginx/collected

.PHONY: analyze-mysql-log
analyze-mysql-log:
	docker pull matsuu/pt-query-digest
	cat $(LOG_FILE_MYSQL) | \
		docker run --rm -i matsuu/pt-query-digest \
			--group-by fingerprint \
		> webapp/logs/mysql/collected

.PHONY: help
help:
	@cat $(MAKEFILE_LIST) | python3 -u -c 'import sys, re; rx = re.compile(r"^[a-zA-Z0-9\-_]+:"); lines = [line.rstrip() for line in sys.stdin if not line.startswith(".PHONY")]; [print(f"""{line.split(":")[0]:20s}\t{prev.lstrip("# ")}""") if rx.search(line) and prev.startswith("# ") else print(f"""\n\033[92m{prev.lstrip("## ")}\033[0m""") if prev.startswith("## ") else "" for prev, line in zip([""] + lines, lines)]'

MAKE=make -C

DOCKER_BUILD=docker build
DOCKER_BUILD_OPTS=--no-cache
DOCKER_RMI=docker rmi -f

ISUPIPE_TAG=isupipe:latest
LOG_FILE_MYSQL=webapp/logs/mysql/mysql-slow.log

.PHONY: bench
bench:
	:> webapp/logs/nginx/access.log
	:> $(LOG_FILE_MYSQL)
	cd bench && make bench

.PHONY: logs
logs:
	cd development && make logs

.PHONY: analyze-mysql-log
analyze-mysql-log:
	docker pull matsuu/pt-query-digest
	cat $(LOG_FILE_MYSQL) | \
		docker run --rm -i matsuu/pt-query-digest \
			--group-by fingerprint | \
		less

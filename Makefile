MAKE=make -C

DOCKER_BUILD=docker build
DOCKER_BUILD_OPTS=--no-cache
DOCKER_RMI=docker rmi -f

ISUPIPE_TAG=isupipe:latest

test: test_benchmarker
.PHONY: test

test_benchmarker:
	$(MAKE) bench test
.PHONY: test_benchmarker

build_webapp:
	$(MAKE) webapp/go docker_image
.PHONY: build_webapp

.PHONY: bench
bench:
	cd development && make truncate-mysql
	go tool pprof -seconds 90 -http=localhost:1080 http://localhost:8080/debug/pprof/profile &
	cd bench && make bench
	cd development && make analyze-mysql

.PHONY: pretest
pretest:
	cd bench && make pretest

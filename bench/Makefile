BUILD=go build
TEST=go test
TEST_FLAGS=-p=1 -v

DARWIN_TARGET_ENV=GOOS=darwin GOARCH=amd64
DARWIN_TARGET_ARM64_ENV=GOOS=darwin GOARCH=arm64
LINUX_TARGET_ENV=GOOS=linux GOARCH=amd64
LINUX_TARGET_ARM64_ENV=GOOS=linux GOARCH=arm64
IMAGE_NAME="isucon13-bench"

RM=rm -f

.PHONY: all build bench linux_amd64 test clean

all: build

build:
	docker build . -t $(IMAGE_NAME)

linux_amd64:
	make build

test: clean
	$(TEST) $(TEST_FLAGS) ./...

bench:
	docker run --network host $(IMAGE_NAME) run --dns-port=1053 --target http://pipe.u.isucon.dev

pretest:
	docker run --network host $(IMAGE_NAME) run --dns-port=1053 --target http://pipe.u.isucon.dev --pretest-only

bench-help:
	docker run $(IMAGE_NAME) run --help

clean:
	docker rmi $(IMAGE_NAME)
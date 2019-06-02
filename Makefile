
NAME = madharjan/docker-gitea
VERSION = 1.8.2

DEBUG ?= true

DOCKER_USERNAME ?= $(shell read -p "DockerHub Username: " pwd; echo $$pwd)
DOCKER_PASSWORD ?= $(shell stty -echo; read -p "DockerHub Password: " pwd; stty echo; echo $$pwd)
DOCKER_LOGIN ?= $(shell cat ~/.docker/config.json | grep "docker.io" | wc -l)

.PHONY: all build run test stop clean tag_latest release clean_images

all: build

docker_login:
ifeq ($(DOCKER_LOGIN), 1)
		@echo "Already login to DockerHub"
else
		@docker login -u $(DOCKER_USERNAME) -p $(DOCKER_PASSWORD)
endif

build:
	sed -i -e "s/VERSION=.*/VERSION=$(VERSION)/g" bin/gitea-systemd-unit
	sed -i -e "s/GITEA_VERSION=.*/GITEA_VERSION=$(VERSION)/g" services/gitea/gitea.sh
	docker build \
		--build-arg GITEA_VERSION=$(VERSION) \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg DEBUG=$(DEBUG) \
		-t $(NAME):$(VERSION) --rm .

run:
	@if ! docker images $(NAME) | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME) version $(VERSION) is not yet built. Please run 'make build'"; false; fi

	rm -rf /tmp/gitea
	mkdir -p /tmp/gitea

	docker run -d \
		-e POSTGRESQL_DATABASE=gitea \
		-e POSTGRESQL_USERNAME=gitea \
		-e POSTGRESQL_PASSWORD=gitea \
		--name gitea-postgresql madharjan/docker-postgresql:9.5

	sleep 2

	docker run -d \
		-e POSTGRESQL_DATABASE=gitea \
		-e POSTGRESQL_USERNAME=gitea \
		-e POSTGRESQL_PASSWORD=gitea \
		--name gitea-postgresql_default madharjan/docker-postgresql:9.5

	sleep 2

	docker run -d \
		--link gitea-postgresql:postgresql \
		-e DEBUG=$(DEBUG) \
		-e GITEA_USERNAME=myuser \
		-e GITEA_PASSWORD=mypass \
		-v /tmp/gitea/etc/:/etc/gitea/ \
		-v /tmp/gitea/lib:/var/lib/gitea/ \
		--name gitea $(NAME):$(VERSION)

	sleep 2

	docker run -d \
		-e DISABLE_GITEA=1 \
		-e DEBUG=$(DEBUG) \
		--name gitea_no_gitea $(NAME):$(VERSION)

	sleep 2

	docker run -d \
		--link gitea-postgresql_default:postgresql \
		-e DEBUG=$(DEBUG) \
		--name gitea_default $(NAME):$(VERSION)

	sleep 2

test:
	sleep 2
	./bats/bin/bats test/tests.bats

stop:
	docker exec gitea /bin/bash -c "sv stop gitea" 2> /dev/null || true
	sleep 2
	docker exec gitea /bin/bash -c "rm -rf /etc/gitea/*" 2> /dev/null || true
	docker exec gitea /bin/bash -c "rm -rf /var/lib/gitea/*" 2> /dev/null || true
	docker stop gitea gitea_no_gitea gitea_default 2> /dev/null || true

clean: stop
	docker rm gitea gitea_no_gitea gitea_default 2> /dev/null || true
	rm -rf /tmp/gitea || true
	docker images | grep "<none>" | awk '{print$3 }' | xargs docker rmi 2> /dev/null || true

publish: docker_login run test clean
	docker push $(NAME)

tag_latest:
	docker tag $(NAME):$(VERSION) $(NAME):latest

release: docker_login  run test clean tag_latest
	docker push $(NAME)

clean_images: clean
	docker rmi $(NAME):latest $(NAME):$(VERSION) 2> /dev/null || true
	docker logout 



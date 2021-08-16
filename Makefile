COMPOSE_USER=$(shell id -u):$(shell id -g)

# Linting
########################################################################
.PHONY: lint
lint: lint-hcl lint-docker

.PHONY: lint-hcl
lint-hcl:
	docker-compose run --rm hcl-linter

.PHONY: lint-docker
lint-docker:
	docker-compose run --rm hadolint

# Formatting
########################################################################
.PHONY: format
format: format-hcl

.PHONY: format-hcl
format-hcl:
	docker-compose run --rm --user=${COMPOSE_USER} hcl-formatter

# Containers
########################################################################

.PHONY: image
image:
	docker buildx bake

.PHONY: image-push
image-push:
	docker buildx bake --push

########################################################################

.PHONY: all
all: format lint image

.DEFAULT_GOAL := all
DOCKER_COMPOSE_RUN := docker compose run --rm --user=$(shell id --user):$(shell id --group)
DOCKER_BAKE := docker buildx bake
PANTS_SHELL_FILTER := ./pants filter --target-type=shell_sources,shunit2_tests :: | xargs ./pants

.PHONY: all
all: format
all: lint
all: image
all: ## Run all operations

.PHONY: help
help: ## Print this help
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make <target>\n"} \
		 /^[a-zA-Z0-9_-]+:.*?##/ { printf "  %-46s %s\n", $$1, $$2 } \
		 /^##@/ { printf "\n%s\n", substr($$0, 5) } ' \
		 $(MAKEFILE_LIST)
	@printf '\n'

##@ Linting
########################################################################

.PHONY: lint
lint: lint-docker
lint: lint-hcl
lint: lint-shell
lint: ## Perform lint checks on all files

.PHONY: lint-docker
lint-docker: ## Lint Dockerfile
	./pants filter --target-type=docker_image :: | xargs ./pants lint

.PHONY: lint-hcl
lint-hcl: image # IMPORTANT: run off code from the repository
lint-hcl: ## Lint HCL files
	$(DOCKER_COMPOSE_RUN) hcl-linter
	@echo 🤯 WHOA INCEPTION 🤯

.PHONY: lint-shell
lint-shell: ## Lint shell scripts
	$(PANTS_SHELL_FILTER) lint

##@ Formatting
########################################################################

.PHONY: format
format: format-hcl
format: format-shell
format: ## Automatically format all code

.PHONY: format-hcl
format-hcl: image # IMPORTANT: run off code from the repository
format-hcl: ## Format HCL files
	$(DOCKER_COMPOSE_RUN) hcl-formatter
	@echo 🤯 WHOA INCEPTION 🤯

.PHONY: format-shell
format-shell: ## Format shell scripts
	$(PANTS_SHELL_FILTER) fmt

# Images
########################################################################

.PHONY: image
image:
	$(DOCKER_BAKE)

.PHONY: image-push
image-push:
	$(DOCKER_BAKE) --push

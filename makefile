# Executables (local)
DOCKER_COMP = docker-compose
DOCKER = docker
SYMFONY_VERSION = SYMFONY_VERSION=5.4.* 
DOCKER_COMP_FILE = -f docker-compose.yml -f docker-compose.debug.yml -f docker-compose.override.yml

# Docker containers
PHP_CONT = $(DOCKER_COMP) exec php

# Executables
PHP      = $(PHP_CONT) php
COMPOSER = $(PHP_CONT) composer
SYMFONY  = $(PHP_CONT) bin/console

# Misc
.DEFAULT_GOAL = help
.PHONY        = help build up start down logs sh composer vendor sf cc

## —— 🎵 🐳 The Symfony-docker Makefile 🐳 🎵 ——————————————————————————————————
help: ## Outputs this help screen
	@grep -E '(^[a-zA-Z0-9_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

## —— Docker 🐳 ————————————————————————————————————————————————————————————————

rebuild: ## rebuilds images
	@$(SYMFONY_VERSION) $(DOCKER_COMP) $(DOCKER_COMP_FILE) build --pull --no-cache

build: ## Builds the Docker images
	@$(SYMFONY_VERSION) $(DOCKER_COMP) $(DOCKER_COMP_FILE) build

up: ## Start the docker hub in detached mode (no logs)
	@$(DOCKER_COMP) $(DOCKER_COMP_FILE) up --detach

start: build up permissions## Build and start the containers

down: ## Stop the docker hub
	@$(DOCKER_COMP) down --remove-orphans

logs: ## Show live logs
	@$(DOCKER_COMP) logs --tail=0 --follow

sh: ## Connect to the PHP FPM container
	@$(PHP_CONT) sh
	
permissions: ## cambia el usuario propietario de los archivos
	@$(DOCKER_COMP) run --rm php chown -R $$(id -u):$$(id -g) .
	
prune: ## borra todos los contenedores e imagenes que no están activos
	@$(DOCKER) system prune -a

## —— Composer 🧙 ——————————————————————————————————————————————————————————————
composer: ## Run composer, pass the parameter "c=" to run a given command, example: make composer c='req symfony/orm-pack'
	@$(eval c ?=)
	@$(COMPOSER) $(c)

vendor: ## Install vendors according to the current composer.lock file
vendor: c=install --prefer-dist --no-dev --no-progress --no-scripts --no-interaction
vendor: composer

## —— Symfony 🎵 ———————————————————————————————————————————————————————————————
sf: ## List all Symfony commands or pass the parameter "c=" to run a given command, example: make sf c=about
	@$(eval c ?=)
	@$(SYMFONY) $(c)

cc: c=c:c ## Clear the cache
cc: sf

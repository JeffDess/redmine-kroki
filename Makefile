.PHONY: build diagrams halt lint restart run test test-stop test-ci watch
.DEFAULT_GOAL := build

build:
	docker compose build

diagrams:
	@./scripts/combine-diagrams.sh

halt:
	@docker compose down

lint:
	@yamllint .

restart:
	@docker compose down redmine5 redmine6 \
		&& docker compose up -d redmine5 redmine6

run:
	@docker compose up -d

test:
	@./scripts/test.sh

test-stop:
	@./scripts/test.sh --down

test-ci:
	@./scripts/test-ci.sh

watch:
	@./scripts/watch.sh

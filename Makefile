diagrams:
	@./scripts/combine-diagrams.sh

halt:
	@docker compose down

lint:
	@yamllint .

restart:
	@docker compose down && docker compose up -d

run:
	@docker compose up -d

test:
	@./scripts/test.sh

test-ci:
	@./scripts/test-ci.sh

watch:
	@./scripts/watch.sh


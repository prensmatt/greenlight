GREENLIGHT_DB_DSN=postgres://greenlight:meleyke6@localhost:5432/greenlight?sslmode=disable

run:
	go run ./cmd/api -db-dsn=$(GREENLIGHT_DB_DSN)

psql:
	psql $(GREENLIGHT_DB_DSN)

up:
	@echo Running up migrations
	migrate -path ./migrations -database $(GREENLIGHT_DB_DSN) up

audit:	vendor
	@echo 'Formatting code...'
	go fmt ./...
	@echo 'Vetting code...'
	go vet ./...
	staticcheck ./...
	@echo 'Running tests...'
	go test -vet=off ./...

.PHONY:	vendor

vendor:
	@echo 'Tidying and verifying module dependencies...'
	go mod tidy
	go mod verify
	@echo 'Vendoring dependencies...'
	go mod vendor

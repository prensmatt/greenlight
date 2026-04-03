include .envrc

.PHONY:	help
help:
	@echo Usage:
	@echo make run/api
	@echo make db/psql
	@echo make db/migrations/up
	@echo make audit

.PHONY:	confirm
confirm:
	@cmd /V:ON /C "set /p ans=Are you sure? [y/N] && if /I not \"!ans!\"==\"y\" exit /b 1"

.PHONY: run/api

run/api:
	go run ./cmd/api -db-dsn=$(GREENLIGHT_DB_DSN) -port=4040

.PHONY: db/psql
db/psql:
	@$(PSQL) $(GREENLIGHT_DB_DSN)

.PHONY:	db/migrations/new

db/migrations/new:
	@echo Creating migration files for $(name)...
	migrate create -seq -ext=.sql -dir=./migrations $(name)

.PHONY: db/migrations/up

db/migrations/up:	confirm
	@echo Running up migrations...
	migrate -path ./migrations -database $(GREENLIGHT_DB_DSN) up

.PHONY:	audit

audit:	vendor
	@echo Formatting code...
	go fmt ./...
	@echo Vetting code...
	go vet ./...
	staticcheck ./...
	@echo Running tests...
	go test -vet=off ./...

.PHONY:	vendor

vendor:
	@echo Tidying and verifying module dependencies...
	go mod tidy
	go mod verify
	@echo Vendoring dependencies...
	go mod vendor

current_time = $(shell powershell -Command "Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ'")
git_description = $(shell git describe --always --dirty)
linker_flags = '-s -X main.buildTime=${current_time} -X main.version=${git_description}'

.PHONY: build/api
build/api:
	@echo Building cmd/api...
	go build -ldflags=${linker_flags} -o=.\bin\api.exe .\cmd\api
	set GOOS=linux&& set GOARCH=amd64&& go build -ldflags="-s -X main.buildTime=$(current_time)" -o=.\bin\linux_amd64\api .\cmd\api
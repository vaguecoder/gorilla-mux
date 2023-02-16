lint:
	@echo "Linting ...Please make sure you are on golangci-lint v1.50.0 or later:\n\tgo install github.com/golangci/golangci-lint/cmd/golangci-lint@latest\n"
	@golangci-lint run --timeout=5m

test:
	@echo "Testing ..."
	@go clean -testcache
	@go test -v -race -coverprofile coverage.out ./...
	@go tool cover -func=coverage.out

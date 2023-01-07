test:
	@echo "Testing ..."
	@go clean -testcache
	@go test -v -race -coverprofile cover.out ./...
	@go tool cover -func=cover.out

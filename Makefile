.PHONY: binaries
binaries:
	go build -o gobin/post-checkout/js_after_hook/main post-checkout/js_after_hook/main.go
	go build -o gobin/post-merge/rails_after_hook/main post-merge/rails_after_hook/main.go
	go build -o gobin/post-merge/js_after_hook/main post-merge/js_after_hook/main.go
	go build -o gobin/pre-commit/debugger-checcker/main pre-commit/debugger-checker/main.go
	go build -o gobin/pre-push/prevent-force-push-master/main pre-push/prevent-force-push-master/main.go

.PHONY: clean
clean:
	rm -r gobin

.PHONY: test
test:
	go test -v --race -count=1 ./...

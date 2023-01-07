### Middleware

Mux supports the addition of middlewares to a [Router](https://godoc.org/github.com/vaguecoder/gorilla-mux#Router), which are executed in the order they are added if a match is found, including its subrouters.
Middlewares are (typically) small pieces of code which take one request, do something with it, and pass it down to another middleware or the final handler. Some common use cases for middleware are request logging, header manipulation, or `ResponseWriter` hijacking.

Mux middlewares are defined using the de facto standard type:

```go
type MiddlewareFunc func(http.Handler) http.Handler
```

Typically, the returned handler is a closure which does something with the http.ResponseWriter and http.Request passed to it, and then calls the handler passed as parameter to the MiddlewareFunc. This takes advantage of closures being able access variables from the context where they are created, while retaining the signature enforced by the receivers.

A very basic middleware which logs the URI of the request being handled could be written as:

```go
func loggingMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        // Do stuff here
        log.Println(r.RequestURI)
        // Call the next handler, which can be another middleware in the chain, or the final handler.
        next.ServeHTTP(w, r)
    })
}
```

Middlewares can be added to a router using `Router.Use()`:

```go
r := mux.NewRouter()
r.HandleFunc("/", handler)
r.Use(loggingMiddleware)
```

A more complex authentication middleware, which maps session token to users, could be written as:

```go
// Define our struct
type authenticationMiddleware struct {
	tokenUsers map[string]string
}

// Initialize it somewhere
func (amw *authenticationMiddleware) Populate() {
	amw.tokenUsers["00000000"] = "user0"
	amw.tokenUsers["aaaaaaaa"] = "userA"
	amw.tokenUsers["05f717e5"] = "randomUser"
	amw.tokenUsers["deadbeef"] = "user0"
}

// Middleware function, which will be called for each request
func (amw *authenticationMiddleware) Middleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        token := r.Header.Get("X-Session-Token")

        if user, found := amw.tokenUsers[token]; found {
        	// We found the token in our map
        	log.Printf("Authenticated user %s\n", user)
        	// Pass down the request to the next middleware (or final handler)
        	next.ServeHTTP(w, r)
        } else {
        	// Write an error and stop the handler chain
        	http.Error(w, "Forbidden", http.StatusForbidden)
        }
    })
}
```

```go
r := mux.NewRouter()
r.HandleFunc("/", handler)

amw := authenticationMiddleware{tokenUsers: make(map[string]string)}
amw.Populate()

r.Use(amw.Middleware)
```

Note: The handler chain will be stopped if your middleware doesn't call `next.ServeHTTP()` with the corresponding parameters. This can be used to abort a request if the middleware writer wants to. Middlewares _should_ write to `ResponseWriter` if they _are_ going to terminate the request, and they _should not_ write to `ResponseWriter` if they _are not_ going to terminate it.
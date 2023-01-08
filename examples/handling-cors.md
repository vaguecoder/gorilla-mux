### Handling CORS Requests

[CORSMethodMiddleware](https://godoc.org/github.com/vaguecoder/gorilla-mux#CORSMethodMiddleware) intends to make it easier to strictly set the `Access-Control-Allow-Methods` response header.

* You will still need to use your own CORS handler to set the other CORS headers such as `Access-Control-Allow-Origin`
* The middleware will set the `Access-Control-Allow-Methods` header to all the method matchers (e.g. `r.Methods(http.MethodGet, http.MethodPut, http.MethodOptions)` -> `Access-Control-Allow-Methods: GET,PUT,OPTIONS`) on a route
* If you do not specify any methods, then:
> _Important_: there must be an `OPTIONS` method matcher for the middleware to set the headers.

Here is an example of using `CORSMethodMiddleware` along with a custom `OPTIONS` handler to set all the required CORS headers:

```go
package main

import (
	"net/http"
	mux "github.com/vaguecoder/gorilla-mux"
)

func main() {
    r := mux.NewRouter()

    // IMPORTANT: you must specify an OPTIONS method matcher for the middleware to set CORS headers
    r.HandleFunc("/foo", fooHandler).Methods(http.MethodGet, http.MethodPut, http.MethodPatch, http.MethodOptions)
    r.Use(mux.CORSMethodMiddleware(r))
    
    http.ListenAndServe(":8080", r)
}

func fooHandler(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Access-Control-Allow-Origin", "*")
    if r.Method == http.MethodOptions {
        return
    }

    w.Write([]byte("foo"))
}
```

And a request to `/foo` using something like:

```bash
curl localhost:8080/foo -v
```

Would look like:

```bash
*   Trying ::1...
* TCP_NODELAY set
* Connected to localhost (::1) port 8080 (#0)
> GET /foo HTTP/1.1
> Host: localhost:8080
> User-Agent: curl/7.59.0
> Accept: */*
> 
< HTTP/1.1 200 OK
< Access-Control-Allow-Methods: GET,PUT,PATCH,OPTIONS
< Access-Control-Allow-Origin: *
< Date: Fri, 28 Jun 2019 20:13:30 GMT
< Content-Length: 3
< Content-Type: text/plain; charset=utf-8
< 
* Connection #0 to host localhost left intact
foo
```
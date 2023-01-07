### Testing Handlers

Testing handlers in a Go web application is straightforward, and _mux_ doesn't complicate this any further. Given two files: `endpoints.go` and `endpoints_test.go`, here's how we'd test an application using _mux_.

First, our simple HTTP handler:

```go
// endpoints.go
package main

func HealthCheckHandler(w http.ResponseWriter, r *http.Request) {
    // A very simple health check.
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(http.StatusOK)

    // In the future we could report back on the status of our DB, or our cache
    // (e.g. Redis) by performing a simple PING, and include them in the response.
    io.WriteString(w, `{"alive": true}`)
}

func main() {
    r := mux.NewRouter()
    r.HandleFunc("/health", HealthCheckHandler)

    log.Fatal(http.ListenAndServe("localhost:8080", r))
}
```

Our test code:

```go
// endpoints_test.go
package main

import (
    "net/http"
    "net/http/httptest"
    "testing"
)

func TestHealthCheckHandler(t *testing.T) {
    // Create a request to pass to our handler. We don't have any query parameters for now, so we'll
    // pass 'nil' as the third parameter.
    req, err := http.NewRequest("GET", "/health", nil)
    if err != nil {
        t.Fatal(err)
    }

    // We create a ResponseRecorder (which satisfies http.ResponseWriter) to record the response.
    rr := httptest.NewRecorder()
    handler := http.HandlerFunc(HealthCheckHandler)

    // Our handlers satisfy http.Handler, so we can call their ServeHTTP method
    // directly and pass in our Request and ResponseRecorder.
    handler.ServeHTTP(rr, req)

    // Check the status code is what we expect.
    if status := rr.Code; status != http.StatusOK {
        t.Errorf("handler returned wrong status code: got %v want %v",
            status, http.StatusOK)
    }

    // Check the response body is what we expect.
    expected := `{"alive": true}`
    if rr.Body.String() != expected {
        t.Errorf("handler returned unexpected body: got %v want %v",
            rr.Body.String(), expected)
    }
}
```

In the case that our routes have [variables](../README.md), we can pass those in the request. We could write
[table-driven tests](https://dave.cheney.net/2013/06/09/writing-table-driven-tests-in-go) to test multiple
possible route variables as needed.

```go
// endpoints.go
func main() {
    r := mux.NewRouter()
    // A route with a route variable:
    r.HandleFunc("/metrics/{type}", MetricsHandler)

    log.Fatal(http.ListenAndServe("localhost:8080", r))
}
```

Our test file, with a table-driven test of `routeVariables`:

```go
// endpoints_test.go
func TestMetricsHandler(t *testing.T) {
    tt := []struct{
        routeVariable string
        shouldPass bool
    }{
        {"goroutines", true},
        {"heap", true},
        {"counters", true},
        {"queries", true},
        {"adhadaeqm3k", false},
    }

    for _, tc := range tt {
        path := fmt.Sprintf("/metrics/%s", tc.routeVariable)
        req, err := http.NewRequest("GET", path, nil)
        if err != nil {
            t.Fatal(err)
        }

        rr := httptest.NewRecorder()
	
	// Need to create a router that we can pass the request through so that the vars will be added to the context
	router := mux.NewRouter()
        router.HandleFunc("/metrics/{type}", MetricsHandler)
        router.ServeHTTP(rr, req)

        // In this case, our MetricsHandler returns a non-200 response
        // for a route variable it doesn't know about.
        if rr.Code == http.StatusOK && !tc.shouldPass {
            t.Errorf("handler should have failed on routeVariable %s: got %v want %v",
                tc.routeVariable, rr.Code, http.StatusOK)
        }
    }
}
```
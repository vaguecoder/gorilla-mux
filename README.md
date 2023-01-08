# Gorilla Mux

[![GoDoc](https://godoc.org/github.com/vaguecoder/gorilla-mux?status.svg)](https://godoc.org/github.com/vaguecoder/gorilla-mux)
[![CircleCI](https://circleci.com/gh/gorilla/mux.svg?style=svg)](https://circleci.com/gh/gorilla/mux)
[![Sourcegraph](https://sourcegraph.com/github.com/vaguecoder/gorilla-mux/-/badge.svg)](https://sourcegraph.com/github.com/vaguecoder/gorilla-mux?badge)

![Gorilla Logo](https://cloud-cdn.questionable.services/gorilla-icon-64.png)

---

Just a fork of the https://github.com/gorilla/mux project since it is archived. Who knows what might come in handy?

---

Package `gorilla/mux` implements a request router and dispatcher for matching incoming requests to
their respective handler.

The name mux stands for "HTTP request multiplexer". Like the standard `http.ServeMux`, `mux.Router` matches incoming requests against a list of registered routes and calls a handler for the route that matches the URL or other conditions. The main features are:

* It implements the `http.Handler` interface so, it is compatible with the standard `http.ServeMux`.
* Requests can be matched based on URL host, path, path prefix, schemes, header and query values, HTTP methods or using custom matchers.
* URL hosts, paths and query values can have variables with an optional regular expression.
* Registered URLs can be built, or "reversed", which helps to maintain references to resources.
* Routes can be used as subrouters: nested routes are only tested if the parent route matches. This is useful to define groups of routes that share common conditions like a host, a path prefix or other repeated attributes. As a bonus, this optimizes request matching.

---

* [Install](#install)
* [Examples](#examples)
* [Matching Routes](./examples/matching-routes.md)
* [Static Files](./examples/static-files.md)
* [Serving Single Page Applications](./examples/serving-single-page.md) (e.g. React, Vue, Ember.js, etc.)
* [Registered URLs](./examples/registered-urls.md)
* [Walking Routes](./examples/walking-routes.md)
* [Graceful Shutdown](./examples/graceful-shutdown.md)
* [Middleware](./examples/middleware.md)
* [Handling CORS Requests](./examples/handling-cors.md)
* [Testing Handlers](./examples/testing-handlers.md)
* [Full Example](./examples/full-example.md)

---

## Install

With a [correctly configured](https://golang.org/doc/install#testing) Go toolchain:

```sh
go get -u github.com/vaguecoder/gorilla-mux
```

## Examples

Let's start registering a couple of URL paths and handlers:

```go
func main() {
    r := mux.NewRouter()
    r.HandleFunc("/", HomeHandler)
    r.HandleFunc("/products", ProductsHandler)
    r.HandleFunc("/articles", ArticlesHandler)
    http.Handle("/", r)
}
```

Here we register three routes mapping URL paths to handlers. This is equivalent to how `http.HandleFunc()` works: if an incoming request URL matches one of the paths, the corresponding handler is called passing (`http.ResponseWriter`, `*http.Request`) as parameters.

Paths can have variables. They are defined using the format `{name}` or `{name:pattern}`. If a regular expression pattern is not defined, the matched variable will be anything until the next slash. For example:

```go
r := mux.NewRouter()
r.HandleFunc("/products/{key}", ProductHandler)
r.HandleFunc("/articles/{category}/", ArticlesCategoryHandler)
r.HandleFunc("/articles/{category}/{id:[0-9]+}", ArticleHandler)
```

The names are used to create a map of route variables which can be retrieved calling `mux.Vars()`:

```go
func ArticlesCategoryHandler(w http.ResponseWriter, r *http.Request) {
    vars := mux.Vars(r)
    w.WriteHeader(http.StatusOK)
    fmt.Fprintf(w, "Category: %v\n", vars["category"])
}
```

## License

BSD licensed. See the LICENSE file for details.

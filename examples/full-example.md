## Full Example

Here's a complete, runnable example of a small `mux` based server:

```go
package main

import (
    "net/http"
    "log"
    mux "github.com/vaguecoder/gorilla-mux"
)

func YourHandler(w http.ResponseWriter, r *http.Request) {
    w.Write([]byte("Gorilla!\n"))
}

func main() {
    r := mux.NewRouter()
    // Routes consist of a path and a handler function.
    r.HandleFunc("/", YourHandler)

    // Bind to a port and pass our router in
    log.Fatal(http.ListenAndServe(":8000", r))
}
```
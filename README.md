
### idris http client

This is a very limited httpclient implementation based on libcurl for idris.
It is still littered with debug output and currently just supports a minimal subset
of HTTP features. It is probably not threadsafe, is leaking memory, the API is far from stable and not documented etc.

```idris
module Main

import HttpClient

Show Reply where
  show (MkReply statusCode header body) = "\nstatusCode: " ++
                                          show statusCode ++
                                          "\nheader:\n" ++
                                          show header ++
                                          "\nbody:\n" ++
                                          body

main: IO ()
main = do
    putStrLn "GET request"
    getResp <- httpClient $ mkReq ("http://httpbin.org/get")
    putStrLn $ show getResp
    putStrLn "\n\n\n"
    putStrLn "POST request"
    postResp <- httpClient $ post "language=idris&http=libcurl" .
                             withHeader ("Content-Type", "foo") .
                             withHeader ("Link", "bar")
                           $ mkReq("http://httpbin.org/post")
    putStrLn $ show postResp
```

Compile this with
```bash
idris -p httpclient Main.idr -o main
```


### Installation

Installation is only tested on Mac OS X. You will need libcurl (and idris 0.10.2):

```bash
brew install curl
```

The Makefile in `/src` assumes a standard location. If that is not ok, adopt to your needs.
If you have the prerequisites, just do:

```bash
make install
```

You will see a warning about a missing main file - that is ok, as long everything typechecks.

### Issues

This is pretty much a learning project for me. If you find this project useful, and would like to have features, I am happy to learn in areas which help you. If you have suggestions to make the code better - please let me know.


### memstream

Memstream implementation taken from http://piumarta.com/software/memstream/
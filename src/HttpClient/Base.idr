module HttpClient.Base

import HttpClient.Requests
import HttpClient.Methods
import HttpClient.Headers
import HttpClient.Foreign
import Data.Fin

%access export
%default total

||| initialzie the curl subsystem
http_init: IO (Response CURLPTR)
http_init = do_http_init >>= responsePtr

||| set the url for the request
||| @ url the url
||| @ curlHandle the curlHandle
http_setopt_url: (url: String) -> (curlHandle: CURLPTR) -> IO (Response Ok)
http_setopt_url url (MkHttp ptr) =
  responseTy <$> (do_http_setopt_url url ptr)

||| set the request method
||| @ method the request method
||| @ curlHandle the curlHandle
http_setopt_method: (method: Method) -> (curlHandle: CURLPTR) -> IO (Response Ok)
http_setopt_method (GET) (MkHttp ptr)  = do_http_setopt_method 0 ptr
http_setopt_method (POST d) (MkHttp ptr)  =
  do
    r1 <- do_http_setopt_method 1 ptr
    r2 <- do_http_setopt_postfields (bodyToString d) ptr
    pure $  r2
http_setopt_method (PUT d) (MkHttp ptr) =
  do
    do_http_setopt_method 2 ptr
    r <- do_http_setopt_postfields (bodyToString d) ptr
    pure $ r
http_setopt_method (DELETE d) (MkHttp ptr) = do_http_setopt_method 3 ptr

http_header_append: (header: Header) -> (curlHandle: CURLPTR) -> IO (CURLPTR)
http_header_append header (MkHttp ptr) =
  MkHttp <$> (do_http_header_append (showHeader header) ptr)

http_setopt_option: Option -> (curlHandle: CURLPTR) -> IO (Response Ok)
http_setopt_option FOLLOW (MkHttp ptr) = do_http_setopt_follow ptr


||| higher level perform of the request, which
||| transforms the request into a reply
||| @ curlHandle the curlHandle
http_perform_high: (curlHandle: CURLPTR) -> IO (Response Reply)
http_perform_high curlPtr = do
    responsePtr <- do_http_perform curlPtr
    if !(nullPtr $ getResponsePtr responsePtr)
      then pure $ Left $ MkError ("Error in curl subsystem")
      else
        do
        body <- response_body responsePtr
        header <- parseHeaders <$> response_header responsePtr
        statusCode <- response_code responsePtr
        do_http_cleanup curlPtr
        pure $ Right $ MkReply statusCode header body

#lang typed/racket ; Simple web scraper
(require/typed net/url
               [#:opaque Url url?]
               [get-pure-port (Url -> Input-Port)]
               [string->url (String -> Url)])

(require/typed net/uri-codec
               [uri-encode (String -> String)])

(: let-me-google-that-for-you : String -> Any)
(define (let-me-google-that-for-you str)
  (let* ([g "http://www.google.com/search?q="]
         [u (string-append g (uri-encode str))]
         [rx #rx"(?<=<h3 class=\"r\">).*?(?=</h3>)"])
    (regexp-match* rx (get-pure-port (string->url u)))))

(module+ main
  (pretty-print
   (let-me-google-that-for-you "Racket")))
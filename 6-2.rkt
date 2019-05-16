#lang typed/racket ; Simple web scraper
(require typed/net/url typed/net/uri-codec)

(: let-me-google-that-for-you : String -> Any)
(define (let-me-google-that-for-you str)
  (let* ([g "http://www.google.com/search?q="]
         [u (string-append g (uri-encode str))]
         [rx #rx"(?<=<h3 class=\"r\">).*?(?=</h3>)"])
    (regexp-match* rx (get-pure-port (string->url u)))))


(pretty-print
 (let-me-google-that-for-you "Racket"))
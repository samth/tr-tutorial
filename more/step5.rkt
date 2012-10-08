#lang typed/racket

(require typed/net/url)
(require/typed xml [xexpr->string (Any -> String)])

(: serve : Integer -> Any)
(: accept-and-handle : TCP-Listener -> Any)
(: handle : Input-Port Output-Port -> Any)
(: dispatch : String -> Any)

(define (serve port-no)
  (define main-cust (make-custodian))
  (parameterize ([current-custodian main-cust])
    (define listener (tcp-listen port-no 5 #t))
    (: loop : -> Any)
    (define (loop)
      (accept-and-handle listener)
      (loop))
    (thread loop))
  (lambda ()
    (custodian-shutdown-all main-cust)))

(define (accept-and-handle listener)
  (define cust (make-custodian))
  (parameterize ([current-custodian cust])
    (define-values (in out) (tcp-accept listener))
    (thread (lambda ()
              (handle in out)
              (close-input-port in)
              (close-output-port out))))
  ;; Watcher thread:
  (thread (lambda ()
            (sleep 10)
            (custodian-shutdown-all cust))))

;; The `handle' function now parses the request into `req', and it
;; calls the new `dispatch' function to get the response, which is an
;; xexpr instead of a string.

(define (handle in out)
  (define req
    ;; Match the first line to extract the request:
    (regexp-match #rx"^GET (.+) HTTP/[0-9]+\\.[0-9]+"
                  (assert (read-line in) string?)))
  (when req
    ;; Discard the rest of the header (up to blank line):
    (regexp-match #rx"(\r\n|^)\r\n" in)
    ;; Dispatch:
    (let ([xexpr (dispatch (assert (list-ref req 1) string?))])
      ;; Send reply:
      (display "HTTP/1.0 200 Okay\r\n" out)
      (display "Server: k\r\nContent-Type: text/html\r\n\r\n" out)
      (display (xexpr->string xexpr) out))))

;; New: the `dispatch' function and `dispatch-table':

(define (dispatch str-path)
  ;; Parse the request as a URL:
  (define url (string->url str-path))
  ;; Extract the path part:
  (define path (map path/param-path (url-path url)))
  ;; Find a handler based on the path's first element:
  (define h (hash-ref dispatch-table (assert (car path) string?) (lambda () #f)))
  (if h
      ;; Call a handler:
      (h (url-query url))
      ;; No handler found:
      `(html (head (title "Error"))
             (body
              (font ((color "red"))
                    "Unknown page: "
                    ,str-path)))))

(define-type Query (Listof (Pairof Symbol (Option String))))

(: dispatch-table : (HashTable String (Query -> Any)))

(define dispatch-table (make-hash))

;; A simple dispatcher:

(hash-set! dispatch-table "hello"
           (lambda: ([query : Query])
             `(html (body "Hello, World!"))))

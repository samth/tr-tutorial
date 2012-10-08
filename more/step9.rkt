#lang typed/racket

(require typed/net/url (except-in racket/control abort))
(require/typed racket/control [abort (Any -> Nothing)])
(require/typed racket/base
               [call-with-continuation-prompt
                (All (A) (-> A) -> A)])
(define-type XExpr Any)
(require/typed xml [xexpr->string (XExpr -> String)])

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
  (custodian-limit-memory cust (* 50 1024 1024))
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
    (let ([xexpr (call-with-continuation-prompt (lambda () (dispatch (assert (list-ref req 1) string?))))])
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

(: dispatch-table : (HashTable String (Query -> XExpr)))

(define dispatch-table (make-hash))

;; A simple dispatcher:

(hash-set! dispatch-table "hello"
           (lambda: ([query : Query])
             `(html (body "Hello, World!"))))


;; New helper function: builds and HTML page
;; for a form that has a "number" field and
;; a "hidden" field:

(: build-request-page : String String String -> XExpr)
(define (build-request-page label next-url hidden)
  `(html
    (head (title "Enter a Number to Add"))
    (body ([bgcolor "white"])
          (form ([action ,next-url] [method "get"])
                ,label
                (input ([type "text"] [name "number"]
                        [value ""]))
                (input ([type "hidden"] [name "hidden"]
                        [value ,hidden]))
                (input ([type "submit"] [name "enter"]
                        [value "Enter"]))))))

(: many : Query -> XExpr)
(define (many query)
  ;; Create a page containing the form:
  (build-request-page "Number of greetings:" "/reply" ""))

(: reply : Query -> XExpr)
(define (reply query)
  ;; Extract and use the form results:
  (define n (assert (string->number (assert (cdr (assert (assq 'number query))))) exact-integer?))
  `(html (body ,@(for/list: : (Listof String) ([i : Integer (in-range n)])
                   " hello"))))

(: send/suspend : (String -> XExpr) -> XExpr)
(define (send/suspend mk-page)
  (let/cc: k : Query
    (define tag (format "k~a" (current-inexact-milliseconds)))
    (hash-set! dispatch-table tag k)
    (abort (mk-page (string-append "/" tag)))))

(hash-set! dispatch-table "many" many)
(hash-set! dispatch-table "reply" reply)

(: sum : Query -> XExpr)
(define (sum query)
  (build-request-page "First number:" "/one" ""))

(: one : Query -> XExpr)
(define (one query)
  (build-request-page "Second number:"
                      "/two"
                      (assert (cdr (assert (assq 'number query))))))

(: two : Query -> XExpr)
(define (two query)
  (let ([n (assert (string->number (assert (cdr (assert (assq 'hidden query))))))]
        [m (assert (string->number (assert (cdr (assert (assq 'number query))))))])
    `(html (body "The sum is " ,(number->string (+ m n))))))

(hash-set! dispatch-table "sum" sum)
(hash-set! dispatch-table "one" one)
(hash-set! dispatch-table "two" two)


;; Helper to run the number-getting page via `send/suspend':
(: get-number : String -> Number)
(define (get-number label)
  (define query
    ;; Generate a URL for the current computation:
    (send/suspend
     ;; Receive the computation-as-URL here:
     (lambda (k-url)
       ;; Generate the query-page result for this connection.
       ;; Send the query result to the saved-computation URL:
       (build-request-page label k-url ""))))
  ;; We arrive here later, in a new connection
  (assert (string->number (assert (cdr (assert (assq 'number query)))))))

;; ----------------------------------------

;; New direct-style servlet:

(: sum2 : Query -> XExpr)
(define (sum2 query)
  (define m (get-number "First number:"))
  (define n (get-number "Second number:"))
  `(html (body "The sum is " ,(number->string (+ m n)))))

(hash-set! dispatch-table "sum2" sum2)
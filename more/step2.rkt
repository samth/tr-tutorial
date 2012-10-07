#lang typed/racket

(: serve : Integer -> Any)
(define (serve port-no)
  (define listener (tcp-listen port-no 5 #t))
  (: loop : -> Any)
  (define (loop)
    (accept-and-handle listener)
      (loop))
  (: t : Thread)
  (define t (thread loop))
  (lambda ()
    (kill-thread t)
    (tcp-close listener)))

(: accept-and-handle : TCP-Listener -> Any)
(define (accept-and-handle listener)
  (define-values (in out) (tcp-accept listener))
  (handle in out)
  (close-input-port in)
  (close-output-port out))

(: handle : Input-Port Output-Port -> Any)
(define (handle in out)
  ;; Discard the request header (up to blank line):
  (regexp-match #rx"(\r\n|^)\r\n" in)
  ;; Send reply:
  (display "HTTP/1.0 200 Okay\r\n" out)
  (display "Server: k\r\nContent-Type: text/html\r\n\r\n" out)
  (display "<html><body>Hello, world!</body></html>" out))

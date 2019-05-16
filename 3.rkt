#lang typed/racket  ; An echo server
(define listener (tcp-listen 12345))
(let echo-server ()
  (define-values (in out) (tcp-accept listener))
  (thread (λ () (copy-port in out)
                (close-output-port out)))
  (echo-server))



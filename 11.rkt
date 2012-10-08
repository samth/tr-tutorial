#lang typed/racket  ; A GUI guessing game
(require typed/mred/mred)
(define f (new frame% [label "Guess"]))
(define n (random 5))  (send f show #t)
(: check : Integer -> Any Any -> Any)
(define ((check i) btn evt)
  (message-box "." (if (= i n) "Yes" "No")))
(for ([i (in-range 5)])
  (make-object button% (format "~a" i) f (check i)))
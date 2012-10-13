#lang typed/racket

(: f2c : Number -> Number)
(define (f2c n)
  (* (- n 32) 5/9))

(module+ test
  (require typed/rackunit)
  (check-equal? (f2c 32) 0)
  (check-equal? (f2c -40) -40)
  (check-equal? (f2c 98.6) 37.))

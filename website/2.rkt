#lang racket

;; Report each unique line from stdin
(define saw (make-hash))
(for ([line (in-lines)])
  (unless (hash-ref saw line (lambda () #f))
    (displayln line))
  (hash-set! saw line #t))


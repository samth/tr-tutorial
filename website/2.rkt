#lang typed/racket

;; Report each unique line from stdin
(: saw : (HashTable Bytes Boolean))
(define saw (make-hash))

(for ([line (in-bytes-lines)])
  (unless (hash-ref saw line (lambda () #f))
    (displayln line))
  (hash-set! saw line #t))



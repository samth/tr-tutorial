# Beginning Typed Racket

## What is Typed Racket?

 * A type system for Racket
 * That interoperates with untyped code

## Basics

    #lang typed/racket
    "Hello RacketCon!"

## Type Errors

    #lang typed/racket
    (+ "Hello" "RacketCon!")

### Type Annotations

    (define: ...)

    (: ...)

    (struct: ...)

    (lambda: ...)

## A Simple TR Program

```
#lang typed/racket

(: f2c : Number -> Number)
(define (f2c n)
  (* (- n 32) 5/9))

(module+ test
  (require typed/rackunit)
  (check-equal (f2c 32) 0)
  (check-equal (f2c -40) -40)
  (check-equal (f2c 98.6) 37.))
```

## Exercise 1

Port this program to Typed Racket

```
#lang racket  ; An echo server
(define listener (tcp-listen 12345))
(define (echo-server)
  (define-values (in out) (tcp-accept listener))
  (thread (lambda () (copy-port in out)
                     (close-output-port out)))
  (echo-server))

(echo-server)
```
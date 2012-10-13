# Larger programs in Typed Racket

## Modules

```
#lang racket/load

(module R typed/racket
  (: R String)
  (define R "Racket")
  (provide R))

(module C typed/racket
  (: C String)
  (define C "Con!")
  (provide C))

(module RC typed/racket
  (require 'R 'C)
  (displayln (string-append R C)))

(require 'RC)
```

But these don't need to be typed ...

```
#lang racket/load

(module R racket
  (define R "Racket")
  (provide R))

(module C typed/racket
  (: C String)
  (define C "Con!")
  (provide C))

(module RC typed/racket
  (require 'C)
  (require/typed 'R [R String])
  (displayln (string-append R C)))

(require 'RC)
```

or ...

```
#lang racket/load

(module R typed/racket
  (: R String)
  (define R "Racket")
  (provide R))

(module C typed/racket
  (: C String)
  (define C "Con!")
  (provide C))

(module RC racket
  (require 'R 'C)
  (displayln (string-append R C)))

(require 'RC)
```


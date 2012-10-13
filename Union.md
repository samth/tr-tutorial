# Union Types and Occurrence Typing

How do you report failure in Racket?

```
(string->number "2012")

(string->number "RacketCon")
```

```
(define v (string->number (read-string)))
(cond [(number? v) (* v 2)]
      [else (error 'whoops)])
```
# Polymorphism

## Polymorphic functions

```
(: id : (All (A) (A -> A)))
(define (id x) x)
```

## Polymorphic structures

```
(struct: Pare (X) ([left : X] [right : X]))
```

## Polymorphic types

```
(define-type (Lst T) (Rec L (U Null (Cons T L))))
```

## Variable-arity polymorphism

    > map
; -------------------------------------------------------------------------------------
; Name     : Michael Maxwell
; Student #: 10106277
; -------------------------------------------------------------------------------------

(#%require racket/base racket/string)
(require racket/format)

; -------------------------------------------------------------------------------------
;                                      Question 1
; -------------------------------------------------------------------------------------

; purpose: creates an interval with a start and end (2 element list)
; input: start and end must be numbers, end should be the greater value
; output: 2 element list (start end)
(define (make-interval start end)
  (cons start end))

; purpose: gets the lower bound of an interval
; input: an interval
; output: a number
(define (lower-bound interval)
  (car interval))

; purpose: gets the upper bound of an interval
; input: an interval
; output: a numbers
(define (upper-bound interval)
  (cdr interval))

; purpose: creates a string representation of an interval
; input: an interval
; output: string similar to: [x, y]
(define (stringify-interval int)
  (if (eq? int #f)
    #f
    (string-append*
      (list
        "["
        (~a (lower-bound int))
        ", "
        (~a (upper-bound int))
        "]"
))))

; purpose: displays the [start, end]
; input: an interval
; output: writes it to the console
(define (display-interval interval)
  (display (stringify-interval interval)))

; purpose: adds 2 intervals
; input: x and y are intervals
; output: a new interval: [a+c,b+d]
(define (add-interval x y)
  (let ((a (lower-bound x))
        (b (upper-bound x))
        (c (lower-bound y))
        (d (upper-bound y)))
    (make-interval (+ a c) (+ b d))))
  
; purpose: subtracts 2 intervals
; input: x and y are intervals
; output: a new interval: [a-d,b-c]
(define (subtract-interval x y)
  (let ((a (lower-bound x))
        (b (upper-bound x))
        (c (lower-bound y))
        (d (upper-bound y)))
    (make-interval (- a d) (- b c))))

; purpose: multiplies 2 intervals
; input: x and y are intervals
; output: a new interval: [min(ac,ad,bc,bd), max(ac,ad,bc,bd)]
(define (multiply-interval x y)
  (let ((ac (* (lower-bound x) (lower-bound y)))
        (ad (* (lower-bound x) (upper-bound y)))
        (bc (* (upper-bound x) (lower-bound y)))
        (bd (* (upper-bound x) (upper-bound y))))
    (make-interval (min ac ad bc bd) (max ac ad bc bd))))

; purpose: divides 2 intervals
; input: x and y are intervals
; output: [a,b] * [1/d,1/c] if [c,d] does not contain 0, otherwise error
(define (divide-interval x y)
  (let ((c (lower-bound y))
        (d (upper-bound y)))
    (if (and (<= c 0) (>= d 0))
      #f
      (multiply-interval x (make-interval (/ 1 d) (/ 1 c))))))

; -------------------------------------------------------------------------------------
;                                      Question 2
; -------------------------------------------------------------------------------------

(define (special-cons x y)
  (lambda (m) (m x y)))

; 2a
; purpose: custom function to get the first element of a list
; input: the result of a special-cons ('list')
; output: the first element
(define (special-car z)
  (z (lambda (a b) a)))

; purpose: custom function to get the list after the first element
; input: the result of a special-cons ('list')
; output: the elements [1..n] of that list (not including the car)
(define (special-cdr z)
  (z (lambda (a b) b)))

; 2b
; purpose: generates a triple (3 element list) without using built-in functions
; input: 3 values
; output: a list of the 3 arguments
(define (triple x y z)
  (special-cons x (special-cons y z)))

; purpose: returns the first value of a triple
; input: a triple
; output: the first element
(define (first i)
  (special-car i))

; purpose: returns the second value of a triple
; input: a triple
; output: the second element
(define (second i)
  (special-car (special-cdr i)))

; purpose: returns the third value of a triple
; input: a triple
; output: the third/last element
(define (third i)
  (special-cdr (special-cdr i)))

; -------------------------------------------------------------------------------------
;                                      Question 3
; -------------------------------------------------------------------------------------

; purpose: gets first n elements of a given list
; input: a list and the number of elements to take from the front
; output: the first n elements of L
(define (before L n)
  (if (or (= n 0) (null? L))
      '()
      (cons (car L) (before (cdr L) (- n 1)))))

; 3a
; purpose: counts how many occurences of x there are in L
; input: a list and a value to count
; output: the number of occurences
(define (count x L)
  (if (null? L)
    0
    (+ (if (eq? (car L) x) 1 0) (count x (cdr L)))))

; 3b
; purpose: returns the most common element in L
; input: a list
; output: a value from the list or #f for an empty list
;         on a tie the element that appeared first in the list is returned
(define (mode L)
  (define (help list max-count max-val)
    (if (null? list)
      max-val
      (let ((n (count (car list) L)))
        (if (> n max-count)
          (help (cdr list) n (car list))
          (help (cdr list) max-count max-val)))))
  (help L 0 #f))

; 3c
; purpose: returns a list that contains all but the first n items of L
; input: a list and the index to exclude upto
; output: the last |L| - n elements of L
(define (after L n)
  (if (or (= n 0) (null? L))
    L
    (after (cdr L) (- n 1))))

; 3d
; purpose: splices the list A into L at index i
; input: a list L, the index to put A, a list A
; output: the resulting list, L[0..i] + A + L[i...]
(define (splice L i A)
  (append (before L i) A (after L i)))

; 3e
; purpose: splices the list A into L at index i, also removing n elements from L starting at i
; input: a list L, the index to put A, how many elements to delete from L, a list A
; output: the resulting list, L[0..i] + A + L[i+n...]
(define (splice2 L i n A)
  (append (before L i) A (after L (+ n i))))

; -------------------------------------------------------------------------------------
;                                      Question 4
; -------------------------------------------------------------------------------------

; 4a
; purpose: returns the maximum depth of a list
; input: a list, with nested sublists
; output: an integer
(define (height L)
  (if (not (pair? L))
    0
    (max (+ 1 (height (car L))) (height (cdr L)))))

; 4b
; purpose: removes elements from the tree that don't satisfy the predicate
; input: a tree and a boolean function (predicate)
; output: a tree without the failing elements
(define (tree-filter pred L)
  (cond ((null? L) '())
        ((list? (car L)) (cons (tree-filter pred (car L)) (tree-filter pred (cdr L))))
        ((pred (car L)) (cons (car L) (tree-filter pred (cdr L))))
        (else (tree-filter pred (cdr L)))))

; 4c
; purpose: returns the leaf values of a tree
; input: a tree
; output: a list with all the elements from the tree on the same level
(define (flatten-list T)
  (cond ((null? T) '())
        ((pair? T) (append (flatten-list (car T)) (flatten-list (cdr T))))
        (else (list T))))

; 4d
; purpose: returns all items from a tree at the given level
; input: the level i, and the tree T
; output: a list with elements from T with depth i
(define (level i T)
  (flatten-list ; copped out and used flatten :)
  (cond ((null? T) '())
        ((list? (car T)) (cons (level (- i 1) (car T)) (level i (cdr T)))) ; the element is a list
        ((= i 1) (cons (car T) (level i (cdr T)))) ; correct depth, add it to the front
        (else (level i (cdr T))))) ; element but wrong depth
  )

; -------------------------------------------------------------------------------------
;                                      Question 5
; -------------------------------------------------------------------------------------

(define-syntax stream-cons
  (syntax-rules ()
    ((stream-cons a b)(cons a (delay b)))))

(define (stream-car s)(car s))
(define (stream-cdr s)(force (cdr s)))

; purpose: computes f using recursion, f defined by rules in assignment specification
; input: n is a number
; output: returns the computed value of f using n
(define (f n)
  (if (< n 4)
    n
    (+ (f (- n 1)) (* 2 (f (- n 2))) (* 3 (f (- n 3))))))

; 5a i
; purpose: makes a new stream of the first n items in a stream
; input: n amount of items, a stream
; output: a stream with the first n elements of the original stream
(define (stream-first n str)
  (if (= n 0)
    '()
    (stream-cons (stream-car str) (stream-first (- n 1) (stream-cdr str)))))

; 5a ii
; purpose: makes a stream from a list
; input: a list
; output: a stream with the elments from the list
(define (list->stream L)
  (if (null? L)
      '()
      (stream-cons (car L) (list->stream (cdr L)))))

; 5a iii
; purpose: makes a list from a finite stream
; input: a finite stream
; output: a list with all the elements from the stream
(define (stream->list S)
  (if (null? S)
    '()
    (cons (stream-car S) (stream->list (stream-cdr S)))))

; 5b i
; purpose: generates an infinite stream of 1's
; input: N/A
; output: infinite 1 stream
(define (1s-stream)
  (stream-cons 1 (1s-stream)))

; 5b ii
; purpose: generates an infinite stream of all odd integers
; input: N/A
; output: infinite odd stream (starting at 1)
(define (odd-stream)
  (define (help n)
    (stream-cons n (help (+ n 2))))
  (help 1))

; 5b iii
; purpose: generates an infinite stream of the function defined
; input: N/A
; output: infinite stream of the f function starting at 0
(define (f-stream)
  (define (help n)
    (stream-cons (f n) (help (+ n 1))))
  (help 0))

; 5c
; purpose: combines two streams using a function
; input: 2 streams of equal length or infinite
; output: 
(define (combine f s1 s2)
  (if (or (null? s1) (null? s2))
    '()
    (stream-cons (f (stream-car s1) (stream-car s2))
                 (combine f (stream-cdr s1) (stream-cdr s2)))))

; -------------------------------------------------------------------------------------
;                                Documentation & Testing
; -------------------------------------------------------------------------------------

(define (test-val func val exp)
  (display func)
  (display " =>")(newline)
  (display " Expected: ")(display exp)(newline)
  (display " Actual:   ")(display val)(newline)(newline)
)

(define (test func a exp)
  (display func)
  (display a)
  (display " =>")(newline)
  (display " Expected: ")(display exp)(newline)
  (display " Actual:   ")(display (func a))(newline)(newline)
)

(define (test2 func a b exp)
  (display func)
  (display a)
  (display ", ")
  (display b)
  (display " =>")(newline)
  (display " Expected: ")(display exp)(newline)
  (display " Actual:   ")(display (func a b))(newline)(newline)
)


(define (test3 func a b c exp)
  (display func)
  (display a)
  (display ", ")
  (display b)
  (display ", ")
  (display c)
  (display " =>")(newline)
  (display " Expected: ")(display exp)(newline)
  (display " Actual:   ")(display (func a b c))(newline)(newline)
)

(define (test4 func a b c d exp)
  (display func)
  (display a)
  (display ", ")
  (display b)
  (display ", ")
  (display c)
  (display ", ")
  (display d)
  (display " =>")(newline)
  (display " Expected: ")(display exp)(newline)
  (display " Actual:   ")(display (func a b c d))(newline)(newline)
)

; -------------------------------------------------------------------------------------
;                                    Question 1 Tests
; -------------------------------------------------------------------------------------
(define int1 (make-interval -1 5))
(define int2 (make-interval 0 10))
(define int3 (make-interval 1.6 5))
(define int4 (make-interval -5 -0.4))
(define int5 (make-interval -5 5))
(define int6 (make-interval -66 0))

;; DISPLAY INTERVAL
(display "--------------------------------- DISPLAY INTERVAL ----------------------------------\n")
(display "interval 1: ")
(display-interval int1)
(newline)

(display "interval 2: ")
(display-interval int2)
(newline)

(display "interval 3: ")
(display-interval int3)
(newline)

(display "interval 4: ")
(display-interval int4)
(newline)

(display "interval 5: ")
(display-interval int5)
(newline)

(display "interval 6: ")
(display-interval int6)
(newline)

;; ADD INTERVAL
(display "--------------------------------- ADD INTERVAL --------------------------------------\n")
(test-val "add-interval int1 int2" (stringify-interval (add-interval int1 int2)) "[-1, 15]")
(test-val "add-interval int3 int4" (stringify-interval (add-interval int3 int4)) "[-3.4, 4.6]")
(test-val "add-interval int5 int6" (stringify-interval (add-interval int5 int6)) "[-71, 5]")
(test-val "add-interval int4 int3" (stringify-interval (add-interval int4 int3)) "[-3.4, 4.6]")

;; SUBTRACT INTERVAL
(display "--------------------------------- SUBTRACT INTERVAL ---------------------------------\n")
(test-val "subtract-interval int1 int2" (stringify-interval (subtract-interval int1 int2)) "[-11, 5]")
(test-val "subtract-interval int3 int4" (stringify-interval (subtract-interval int3 int4)) "[2, 10]")
(test-val "subtract-interval int5 int6" (stringify-interval (subtract-interval int5 int6)) "[-5, 71]")
(test-val "subtract-interval int6 int5" (stringify-interval (subtract-interval int6 int5)) "[-71, 5]")

;; MULTIPLY INTERVAL
(display "--------------------------------- MULTIPLY INTERVAL ---------------------------------\n")
(test-val "multiply-interval int1 int2" (stringify-interval (multiply-interval int1 int2)) "[-10, 50]")
(test-val "multiply-interval int4 int3" (stringify-interval (multiply-interval int4 int3)) "[-25, -0.64]")
(test-val "multiply-interval int6 int5" (stringify-interval (multiply-interval int6 int5)) "[-330, 330]")
(test-val "multiply-interval int3 int1" (stringify-interval (multiply-interval int3 int1)) "[-5, 25]")

;; DIVIDE INTERVAL
(display "--------------------------------- DIVIDE INTERVAL -----------------------------------\n")
(test-val "divide-interval int1 int2" (stringify-interval (divide-interval int1 int2)) "#f")
(test-val "divide-interval int2 int1" (stringify-interval (divide-interval int2 int1)) "#f")
(test-val "divide-interval int2 int3" (stringify-interval (divide-interval int2 int3)) "[0, 6.25]")
(test-val "divide-interval int3 int4" (stringify-interval (divide-interval int3 int4)) "[-12.5, -0.32]")
(test-val "divide-interval int3 int5" (stringify-interval (divide-interval int3 int5)) "#f")
(test-val "divide-interval int5 int3" (stringify-interval (divide-interval int5 int3)) "[-3.125, 3.125]")
(test-val "divide-interval int1 int6" (stringify-interval (divide-interval int1 int6)) "#f")

; -------------------------------------------------------------------------------------
;                                    Question 2 Tests
; -------------------------------------------------------------------------------------
; 2a
(display "--------------------------------- CAR AND CDR ---------------------------------------\n")
(test special-car (special-cons 1 2) 1)
(test special-cdr (special-cons 1 2) 2)

; 2b
(display "--------------------------------- TRIPLE --------------------------------------------\n")
(define a (triple 1 2 3))
(display "triple a = (1 2 3)\n")
(test first a 1)
(test second a 2)
(test third a 3)

(define b (triple 99 + "hello"))
(display "triple b = (99 #<procedure:+> \"hello\")\n")
(test first b 99)
(test second b +)
(test third b "hello")

; -------------------------------------------------------------------------------------
;                                    Question 3 Tests
; -------------------------------------------------------------------------------------
; 3a
(display "--------------------------------- COUNT ---------------------------------------------\n")
(test2 count 3 '(1 4 3 6 2 3 3 1 4 3 5 7) 4)
(test2 count 'b '(4 b a 3 2 c b 1 b 2 d a) 3)

; 3b
(display "--------------------------------- MODE ----------------------------------------------\n")
(test mode '(a b a c a d d a b c a b) 'a)
(test mode '(2 b a 3 2 c b 1 b 2 d a) 2)
(test mode '(6 1 1 6) 6)

; 3c
(display "--------------------------------- AFTER ---------------------------------------------\n")
(test2 after '(a b c d e f g h) 3 '(d e f g h))
(test2 after '(a b c d e f g h) 0 '(a b c d e f g h))
(test2 after '(a b c d e f g h) 8 '())
(test2 after '(1 2 3 4 5 6) 3 '(4 5 6))

; 3d
(display "--------------------------------- SPLICE --------------------------------------------\n")
(test3 splice '(1 2 3 4 5) 2 '(a b c) '(1 2 a b c 3 4 5))
(test3 splice '(1 2 3 4 5) 0 '(a b c) '(a b c 1 2 3 4 5))

; 3e
(display "--------------------------------- SPLICE 2 ------------------------------------------\n")
(test4 splice2 '(1 2 3 4 5) 2 1 '(a b c) '(1 2 a b c 4 5))
(test4 splice2 '(1 2 3 4 5) 2 0 '(a b c) '(1 2 a b c 3 4 5))
(test4 splice2 '(1 2 3 4 5) 3 4 '(a b c) '(1 2 3 a b c))

; -------------------------------------------------------------------------------------
;                                    Question 4 Tests
; -------------------------------------------------------------------------------------
; 4a
(display "--------------------------------- HEIGHT --------------------------------------------\n")
(test height 'a 0)
(test height '(a) 1)
(test height '(a (b) c) 2)
(test height '(((((a(((b)))))))) 8)

; 4b
(display "--------------------------------- TREE FILTER ---------------------------------------\n")
(test2 tree-filter even? '(1 (2 3) ((4 5) (6 7)) (((8 (9))))) '((2) ((4) (6)) (((8 ())))))
(test2 tree-filter odd? '(1 (2 3) ((4 5) (6 7)) (((8 (9))))) '(1 (3) ((5) (7)) ((((9))))))
(test2 tree-filter (lambda (x) (> x 2)) '(1 ((3 (4 (5 ((((9)))) 5) 4)) 2) 1) '(((3 (4 (5 ((((9)))) 5) 4)))))

; 4c
(display "--------------------------------- FLATTEN LIST --------------------------------------\n")
(test flatten-list '(1 (2 3) ((4 5 6 (7)))(((8 (9))))) '(1 2 3 4 5 6 7 8 9))
(test flatten-list '(((((((((666))))))))) '(666))
(test flatten-list '(1 ((3 (4 (5 ((((9)))) 5) 4)) 2) 1) '(1 3 4 5 9 5 4 2 1))

; 4d
(display "--------------------------------- LEVEL ---------------------------------------------\n")
(test2 level 1 '(1 (2 3 4) 5 (6 (7 8) 9)) '(1 5))
(test2 level 2 '(1 (2 3 4) 5 (6 (7 8) 9)) '(2 3 4 6 9))
(test2 level 3 '(1 (2 3 4) 5 (6 (7 8) 9)) '(7 8))
(test2 level 6 '(1 (2 3 4) 5 (6 (7 8) 9)) '())
(test2 level 1 '(1 9 2 8 3 7 4 6 5) '(1 9 2 8 3 7 4 6 5))

; -------------------------------------------------------------------------------------
;                                    Question 5 Tests
; -------------------------------------------------------------------------------------
; 5a
(display "--------------------------------- 1's STREAM -----------------------------------------\n")
(display "(stream-first 12 (1s-stream)): ")
(define ones (stream-first 12 (1s-stream)))
(stream->list ones)

(display "--------------------------------- ODDs STREAM ---------------------------------------\n")
(display "(stream-first 12 (odd-stream)): ")
(define odds (stream-first 12 (odd-stream)))
(stream->list odds)

(display "--------------------------------- FUNCTION STREAM -----------------------------------\n")
(display "(stream-first 12 (f-stream)): ")
(define fs (stream-first 12 (f-stream)))
(stream->list fs)

(display "--------------------------------- LIST -> STREAM ------------------------------------\n")
(display "(list->stream '(7 8 9 x y z)): ")
(define strum (list->stream '(7 8 9 x y z)))
(stream->list strum)

(display "--------------------------------- STREAM -> LIST ------------------------------------\n")
(display "(stream->list (list->stream '(7 8 9 x y z))): ")
(stream->list strum)

(display "--------------------------------- COMBINE STREAM ------------------------------------\n")
(display "(stream-first 7 (combine + ones odds)): ")
(define combo1 (stream-first 7 (combine + ones odds)))
(stream->list combo1)

(display "(stream-first 7 (combine (lambda (x y) (+ x y 10)) ones odds)): ")
(define combo2 (stream-first 7 (combine (lambda (x y) (+ x y 10)) ones odds)))
(stream->list combo2)
; Name     : Michael Maxwell
; Student #: 10106277

(#%require (only racket/base random))

; 1a
; purpose: computes f using recursion, f defined by rules in assignment specification
; input: n is a number
; output: returns the computed value of f using n
(define (f n)
  (if (< n 4)
    n
    (+ (f (- n 1)) (* 2 (f (- n 2))) (* 3 (f (- n 3))) (* 4 (f (- n 4))))))

; Substitution Model
(f 6)
#|
(if (< 6 4) 6 (+ (f (- 6 1)) (* 2 (f (- 6 2))) (* 3 (f (- 6 3))) (* 4 (f (- 6 4)))))
(+ (f (- 6 1)) (* 2 (f (- 6 2))) (* 3 (f (- 6 3))) (* 4 (f (- 6 4))))
(+ (f 5) (* 2 (f 4)) (* 3 (f 3)) (* 4 (f 2)))
(+ (if (< 5 4) 5 (+ (f (- 5 1)) (* 2 (f (- 5 2))) (* 3 (f (- 5 3))) (* 4 (f (- 5 4))))) (* 2 (f 4)) (* 3 (f 3)) (* 4 (f 2)))
(+ (+ (f (- 5 1)) (* 2 (f (- 5 2))) (* 3 (f (- 5 3))) (* 4 (f (- 5 4)))) (* 2 (f 4)) (* 3 (f 3)) (* 4 (f 2)))
(+ (+ (f 4) (* 2 (f 3)) (* 3 (f 2)) (* 4 (f 1))) (* 2 (f 4)) (* 3 (f 3)) (* 4 (f 2)))
(+ (+ (if (< 4 4) 4 (+ (f (- 4 1)) (* 2 (f (- 4 2))) (* 3 (f (- 4 3))) (* 4 (f (- 4 4))))) (* 2 (f 3)) (* 3 (f 2)) (* 4 (f 1))) (* 2 (f 4)) (* 3 (f 3)) (* 4 (f 2)))
(+ (+ (+ (f 3) (* 2 (f 2)) (* 3 (f 1)) (* 4 (f 0))) (* 2 (f 3)) (* 3 (f 2)) (* 4 (f 1))) (* 2 (f 4)) (* 3 (f 3)) (* 4 (f 2)))
(+ (+ (+ 3 (* 2 2) (* 3 1) (* 4 0)) (* 2 3) (* 3 2) (* 4 1)) (* 2 (f 4)) (* 3 (f 3)) (* 4 (f 2)))
(+ (+ (+ 3 (* 2 2) (* 3 1) (* 4 0)) (* 2 3) (* 3 2) (* 4 1)) (* 2 (if (< 4 4) 4 (+ (f (- 4 1)) (* 2 (f (- 4 2))) (* 3 (f (- 4 3))) (* 4 (f (- 4 4)))))) (* 3 (f 3)) (* 4 (f 2)))
(+ (+ (+ 3 (* 2 2) (* 3 1) (* 4 0)) (* 2 3) (* 3 2) (* 4 1)) (* 2 (+ (f (- 4 1)) (* 2 (f (- 4 2))) (* 3 (f (- 4 3))) (* 4 (f (- 4 4))))) (* 3 (f 3)) (* 4 (f 2)))
(+ (+ (+ 3 (* 2 2) (* 3 1) (* 4 0)) (* 2 3) (* 3 2) (* 4 1)) (* 2 (+ (f 3) (* 2 (f 2)) (* 3 (f 1)) (* 4 (f 0)))) (* 3 (f 3)) (* 4 (f 2)))
(+ (+ (+ 3 (* 2 2) (* 3 1) (* 4 0)) (* 2 3) (* 3 2) (* 4 1)) (* 2 (+ 3 (* 2 2) (* 3 1) (* 4 0))) (* 3 3) (* 4 2))
(+ (+ (+ 3 4 3 0) 6 6 4) (* 2 (+ 3 4 3 0)) 9 8)
(+ (+ 10 6 6 4) (* 2 10) 9 8)
(+ 26 20 9 8)
63
|#

; 1b
; purpose: computes f with an iterative procedure
; input: n is a number
; output: returns the computed value of f using n
(define (f-it n)
  (define (f-iteration n1 n2 n3 n4 count)
    (cond ((< n 4) n)
          ((> count n) n1)
          (else (f-iteration (+ n1 (* 2 n2) (* 3 n3) (* 4 n4)) n1 n2 n3 (+ 1 count)))))
  (f-iteration 3 2 1 0 4))

; Substitution Model
(f-it 6)
#|
(f-iteration 3 2 1 0 4)
(cond ((< 6 4) 6) ((> count 6) 3) (else (f-iteration (+ 3 (* 2 2) (* 3 1) (* 4 0)) 3 2 1 (+ 1 4))))
(f-iteration (+ 3 (* 2 2) (* 3 1) (* 4 0)) 3 2 1 (+ 1 4))
(f-iteration (+ 3 4 3 0) 3 2 1 (+ 1 4))
(f-iteration 10 3 2 1 5)
(cond ((< 6 4) 6) ((> 5 6) n1) (else (f-iteration (+ 10 (* 2 3) (* 3 2) (* 4 1)) 10 3 2 (+ 1 5))))
(f-iteration (+ 10 (* 2 3) (* 3 2) (* 4 1)) 10 3 2 (+ 1 5))
(f-iteration (+ 10 6 6 4) 10 3 2 (+ 1 5))
(f-iteration 26 10 3 2 6)
(cond ((< 6 4) 6) ((> 6 6) n1) (else (f-iteration (+ 26 (* 2 10) (* 3 3) (* 4 2)) 26 10 3 (+ 1 6))))
(f-iteration (+ 26 (* 2 10) (* 3 3) (* 4 2)) 26 10 3 (+ 1 6))
(f-iteration (+ 26 20 9 8) 26 10 3 7)
(f-iteration 63 26 10 3 7)
(cond ((< 6 4) 6) ((> 7 6) 63) (else (f-iteration (+ 63 (* 2 26) (* 3 10) (* 4 3)) 63 26 10 (+ 1 7))))
63
|#

; 2
; purpose: computes elements of Pascal's triangle recursively
; input: r is the row [integer], c is the column [integer]
; output: value of Pascal's triangle at (r, c) [integer], -1 if the row and column are out of range
(define (pascals r c)
  (cond ((< c 0) -1)
        ((> c r) -1)
        ((= c 0) 1)
        ((= c r) 1)
        (else (+ (pascals (- r 1) c) (pascals (- r 1) (- c 1))))))

; 3a
; purpose: recursive procedure that computes number of digits
; input: n is the number [integer]
; output: how many digits n has [integer]
(define (digits n)
  (if (< (abs n) 10)
    1
    (+ 1 (digits (/ n 10)))))

; 3b
; purpose: iterative procedure that computes number of digits
; input: n is the number [integer]
; output: how many digits n has [integer]
(define (digits-iter n)
  (define (digit-help n count)
    (if (< (abs n) 10)
    count
    (digit-help (/ n 10) (+ 1 count))))

  (digit-help n 1))

; 4
; purpose: plays rock, paper, scissors vs a computer
; input: nothing: when playing use 0-3 to specify your move
; output: your final score after quitting the game [integer]
(define (rps)
  (define (play me cpu)
    (if (= me cpu) 0
      (if (or (and (= me 0) (= cpu 2))
              (and (= me 1) (= cpu 0))
              (and (= me 2) (= cpu 1)))
          1 -1)))
  
  (define (looper score)
    (display "your score: ")
    (display score)
    (newline)
    (define cpu (random 3))
    #|
    ;cheat
    (display "CPU: ")
    (display cpu)
    (newline)
    |#
    (define me (read))

    (if (= me 3)
      score
      (looper (+ score (play me cpu)))))

  (display "0. Rock, 1. Paper, 2. Scissors, 3. Exit\n")
  (looper 0)
)

; 5
; purpose: iterative procedure adding all numbers from a to b together
; input: a - starting number, b - ending number
; output: sum of values [a, b] (a + a+1 + a+2 + .. + b-2 + b-1 + b)
(define (sum-integers a b)
  (define (inc x) (+ x 1))
  (define (identity x) x)
  (define (sum term a next b)
    (define (sum-it a b sigma)
      (if (> a b)
        sigma
        (sum-it (next a) b (+ (term a) sigma))))

    (sum-it a b 0))
  (sum identity a inc b))

; 6ab

; accurate
(define (my-good-enough0 n y) (< (abs (- (* y y y) n)) 0.00000001))
; decent
(define (my-good-enough1 n y) (< (abs (- (* y y y) n)) 0.0001))
; very bad
(define (my-good-enough2 n y) (< (abs (- (* 6 y) n)) 3))

; purpose: newton's method for cube root aproximation
; input: a good-enough? procedure, n is the number you want the cube root of
; output: an approximation of the cube root of n, precision defined by good-enough?
(define (cbrt good-enough? n)
  (define (improve y) (/ (+ (/ n y y) (* 2 y)) 3))
  (define (cbrt-it y)
    (if (good-enough? n y)
        y
        (cbrt-it (improve y))))
  (cbrt-it 1.0))

; 6c
; Using new-if doesn't work because our scheme is being run in applicative order. Therefore it will keep
; evaluating the alternate (cbrt-it (improve y)) forever. cond must be evaluated differently than if in scheme.
; if is optimized to only evaluate the consequent or the alternate, so if the predicate is true, the alternate
; is never evaluated.

; 7
; purpose: creates a closure on the specified number range
; input: starting and ending value in a series, will iterate over these increasing by 1
; output: a closure with the proper range (1, 5) => (1 2 3 4 5)
;         more importantly is how the closure can be used to iterate such a list and perform operations
;         on each position and build up a result. ex. the sum, the product, or just a printed list.
(define (forAll start end)
  (define (helper op i cur)
    (if (> i end)
        cur
        (helper op (+ i 1) (op i cur))))
  (lambda (op init) (helper op start init)))

; -----------------------
; Documentation & Testing
; -----------------------

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

; Question 1

(test f 0 0)
(test f-it 0 0)
(test f 3 3)
(test f-it 3 3)
(test f 4 10)
(test f-it 4 10)
(test f 6 63)
(test f-it 6 63)
(test f 14 101885)
(test f-it 14 101885)

; Question 2

; Row 0
(test2 pascals 0 0 1)
; Row 1
(test2 pascals 1 0 1)
(test2 pascals 1 1 1)
; Row 2
(test2 pascals 2 0 1)
(test2 pascals 2 1 2)
(test2 pascals 2 2 1)
; Row 3
(test2 pascals 3 0 1)
(test2 pascals 3 1 3)
(test2 pascals 3 2 3)
(test2 pascals 3 3 1)
; Row 4
(test2 pascals 4 0 1)
(test2 pascals 4 1 4)
(test2 pascals 4 2 6)
(test2 pascals 4 3 4)
(test2 pascals 4 4 1)
; Row 16
(test2 pascals 16 8 12870)
; Invalid
(test2 pascals -1 0 -1)
(test2 pascals 4 -2 -1)
(test2 pascals 4 6 -1)
(test2 pascals 0 -2 -1)

; Question 3

(test digits 0 1)
(test digits-iter 0 1)

(test digits 4 1)
(test digits-iter 4 1)
(test digits 10 2)
(test digits-iter 10 2)
(test digits 11 2)
(test digits-iter 11 2)
(test digits 673 3)
(test digits-iter 673 3)
(test digits 2310 4)
(test digits-iter 2310 4)
(test digits 66604 5)
(test digits-iter 66604 5)
(test digits -1 1)
(test digits-iter -1 1)
(test digits -134 3)
(test digits-iter -134 3)

; Question 4
; uncomment line in rps to show cpu's move! testing!
;(rps)
; Test Run;
#|
0. Rock, 1. Paper, 2. Scissors, 3. Exit
your score: 0
CPU: 0 <----- cpu random pick
1 <---------- user's pick
your score: 1
CPU: 1
2
your score: 2
CPU: 1
2
your score: 3
CPU: 2
1
your score: 2
CPU: 0
2
your score: 1
CPU: 1
1
your score: 1
CPU: 2
0
your score: 2
CPU: 0
2
your score: 1
CPU: 0
1
your score: 2
CPU: 1
0
your score: 1
CPU: 1
3
1 <----- exits with your current score
|#

; Question 5

(test2 sum-integers 1 10 55)
(test2 sum-integers 1 100 5050)
(test2 sum-integers -50 50 0)
(test2 sum-integers 24 69 2139)

; Question 6

(test2 cbrt my-good-enough1 0 0)
(test2 cbrt my-good-enough1 1 1)
(test2 cbrt my-good-enough1 4 1.58740105)
(test2 cbrt my-good-enough1 16 2.5198421)
(test2 cbrt my-good-enough1 256 6.34960421)
(test2 cbrt my-good-enough1 625 8.54987973)
(test2 cbrt my-good-enough1 1000 10)

(test2 cbrt my-good-enough0 27 3) ; accurate
(test2 cbrt my-good-enough1 27 3) ; decent
(test2 cbrt my-good-enough2 27 3) ; horrible

; Question 7

(define my_iterator (forAll 1 5))
(test2 my_iterator + 0 15)
(test2 my_iterator * 1 120)

(my_iterator (lambda (x y) (display x)(display " ")) "") ; Expected: 1 2 3 4 5 
(newline)

(define my_it (forAll 5 13))
(test2 my_it + 69 150)
(test2 my_it * -0.1 -25945920)
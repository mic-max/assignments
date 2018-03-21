; -------------------------------------------------------------------------------------
; Name     : Michael Maxwell
; Student #: 10106277
; -------------------------------------------------------------------------------------

; -------------------------------------------------------------------------------------
;                                      Question 1
; -------------------------------------------------------------------------------------

(define (f n)
  (define (iter a b c)
    (if (> a (* n n)) (+ a b c)
      (iter (+ a b c) a b)))       ; line 4
        (if (> n 1)
          (iter n (- n 1) (- n 2)) ; line 6
          n))
(f 5)

; 1a
; see #1 contour-diagrams.pdf

; 1b
; see #2 contour-diagrams.pdf

; -------------------------------------------------------------------------------------
;                                      Question 2
; -------------------------------------------------------------------------------------

(define (outer z)
  (define x 2)
  (define (in1)
    (define z (+ 20 x))
    (in2))              ; line 5
  (define (in2)
    (set! z (* z 10))
    z)
  in1)

(define closure (outer 30))
(closure)

; 2a
; see #3 contour-diagrams.pdf

; 2b
; The output of this code using lexical scoping is: 300

; 2c
; would this code work using dynamic scope, provide output or explain why not.
; Yes, the output would be 220. in1 is defining a new z variable with a starting
; value of 20 + x, which at that point equals 22. Then because in2 is called after this
; using dynamic scoping, in2 will set the z variable of the in1 frame to itself * 10.
; That's then the last statement of in2 returns the z value which is 22 * 10 = 220.

; -------------------------------------------------------------------------------------
;                                      Question 3
; -------------------------------------------------------------------------------------

; purpose: implements a list using object oriented design
; input: N/A
; output: a list object
(define (make-list) ; TODO: does scheme have default arguments? (make-list L='() sz=0)
  (let ((L '())
        (sz 0))

  ; returns boolean if i is a proper index into the list
  (define (index? i inclusive)
    (and (integer? i) (>= i 0) (if inclusive (<= i sz) (< i sz))))
    
  ; returns an integer equal to the number of items in the list
  (define (size) sz)

  ; TODO: coding this function could simplify all other list functions created
  ;(define (traverse ls n helper ifzero elsef))

  ; returns the item stored at index i in the list
  (define (get i)
    (define (get-help ls n)
      (if (zero? n)
        (car ls)
        (get-help (cdr ls) (- n 1))))
    
    (if (index? i #f) (get-help L i) #f))

  ; modifies index i in the list to hold item x
  (define (set i x)
    (define (set-help ls n)
      (if (zero? n)
          (cons x (cdr ls))
          (cons (car ls) (set-help (cdr ls) (- n 1)))))
    
    (if (index? i #f) (set! L (set-help L i)) #f))

  ; adds item x at index i in the list
  (define (add i x)
    (define (add-help ls n)
      (if (zero? n)
        (cons x ls)
        (cons (car ls) (add-help (cdr ls) (- n 1)))))
    
    (if (index? i #t)
        (begin (set! L (add-help L i))
               (set! sz (+ sz 1)))
        #f))

  ; removes and returns the item at index i from the list
  (define (remove i)
    (define (remove-help ls n)
      (if (zero? n)
        (cdr ls)
        (cons (car ls) (remove-help (cdr ls) (- n 1)))))
    
    (if (index? i #f)
        (begin (set! L (remove-help L i))
               (set! sz (- sz 1)))
        #f))

  ; displays the list in the standard scheme form
  (define (print)
    (define (print-help ls)
      (if (pair? ls)
        (begin
          (display (car ls))
          (if (null? (cdr ls)) ; TODO: could be optimized
              #f
              (display " "))
          (print-help (cdr ls)))))
    (display "(")
    (print-help L)
    (display ")"))

  (lambda (method)
    (case method
      ('size size)
      ('get get)
      ('set set)
      ('add add)
      ('remove remove)
      ('print print)
      (else (lambda()
        (display "Unknown Request: ")
        (display method)
        (newline)))))))

; -------------------------------------------------------------------------------------
;                                Documentation & Testing
; -------------------------------------------------------------------------------------

(define (test-val func val exp)
  (display func)
  (display " =>")(newline)
  (display " Expected: ")(display exp)(newline)
  (display " Actual:   ")(display val)(newline)(newline)
)

; -------------------------------------------------------------------------------------
;                                    Question 3 Tests
; -------------------------------------------------------------------------------------

(define L1 (make-list))
(define L2 (make-list))
(define onefour (make-list))
(define Empty (make-list))

(define (printL var L)
  (display var)
  (display ": ")
  ((L 'print))
  (newline))

(define (printAll)
  (printL "| L1" L1)
  (printL "| L2" L2)
  (printL "| onefour" onefour)
  (printL "| Empty" Empty))

;setup
((onefour 'add) 0 1)
((onefour 'add) 1 2)
((onefour 'add) 2 3)
((onefour 'add) 3 4)
(printAll)

(display "--------------------------------- UNKNOWN REQUESTS ----------------------------------\n")
((L1 'hello))
((L1 'fake))
((L1 'mutate))

(display "--------------------------------- LIST . ADD ----------------------------------------\n")
((L1 'add) 0 1)
((L1 'add) 1 3)
((L1 'add) 2 4)
((L1 'add) 0 0)
((L1 'add) 2 2)

((L2 'add) 0 0)
((L2 'add) 0 "hello")
((L2 'add) 0 'a)
((L2 'add) 0 'b)
((L2 'add) 0 '(6 9))

(printAll)
(display "\nBad Indices\n")
((Empty 'add) 1 5)
((Empty 'add) "index" 5)
((Empty 'add) 1.5 5)
((L1 'add) -1 "*")
((L1 'add) 6 "$")

(display "--------------------------------- LIST . GET ----------------------------------------\n")
(test-val "onefour.get 0" ((onefour 'get) 0) 1)
(test-val "onefour.get 1" ((onefour 'get) 1) 2)
(test-val "onefour.get 2" ((onefour 'get) 2) 3)
(test-val "onefour.get 3" ((onefour 'get) 3) 4)

(test-val "L1.get 0" ((L1 'get) 0) 0)
(test-val "L1.get 1" ((L1 'get) 1) 1)
(test-val "L1.get 2" ((L1 'get) 2) 2)
(test-val "L1.get 3" ((L1 'get) 3) 3)
(test-val "L1.get 4" ((L1 'get) 4) 4)

(test-val "L2.get 0" ((L2 'get) 0) '(6 9))
(test-val "L2.get 1" ((L2 'get) 1) 'b)
(test-val "L2.get 2" ((L2 'get) 2) 'a)
(test-val "L2.get 3" ((L2 'get) 3) "hello")
(test-val "L2.get 4" ((L2 'get) 4) 0)

(display "\nBad Indices\n")
((Empty 'get) -1)
((Empty 'get) 0)
((Empty 'get) 1)
((L2 'get) "hello")
((L2 'get) 5)
((L2 'get) -1)
((L2 'get) 2.2)

(display "--------------------------------- LIST . SET ----------------------------------------\n")
(printAll)
((L1 'set) 0 9)
((L1 'set) 1 8)
((L1 'set) 2 7)
((L1 'set) 3 6)
((L1 'set) 4 5)

((L2 'set) 4 +)
((L2 'set) 2 'z)

(display "SET NEW VALUES\n")
(printAll)

(display "\nBad Indices\n")
((Empty 'set) -1 2)
((Empty 'set) 1 2)
((Empty 'set) 0 2)
((L1 'set) -1 5)
((L1 'set) "really" 6)
((L1 'set) 5 5)
((onefour 'set) 99 "Gretzky")

(display "--------------------------------- LIST . REMOVE -------------------------------------\n")
((L1 'remove) 2)

((L2 'remove) 4)
((L2 'remove) 1)
((L2 'remove) 0)
((L2 'remove) 0)
((L2 'remove) 0)

(display "POST DELETE VALUES\n")
(printAll)

(display "\nBad Indices\n")
((Empty 'remove) -1)
((Empty 'remove) 0)
((Empty 'remove) 1)
((onefour 'remove) "yoda")
((onefour 'remove) 22)
((onefour 'remove) 1.0001)

(display "--------------------------------- LIST . SIZE ---------------------------------------\n")
(test-val "L1.size" ((L1 'size)) 4)
(test-val "L2.size" ((L2 'size)) 0)
(test-val "onefour.size" ((onefour 'size)) 4)
(test-val "Empty.size" ((Empty 'size)) 0)

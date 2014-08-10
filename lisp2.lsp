;;; A Lisp evaluator in Lisp.
;;;
;;; It consists of QUOTE, IF, LAMBDA, DEFUN, SETQ, CAR, CDR, CONS, EQ, ATOM, +,
;;; *, -, /, MOD, LOOP, and RETURN. It provides them all, so it can run itself
;;; recursively.
;;; This program is for both Zick's Lisp and Common Lisp.

((lambda (ge err lv)
   ;; HACK: Common Lisp treats this as (setq) but my implementations treat #+nil
   ;; as just a symbol so it defines funcall. Please modify this line if you
   ;; want to run this evaluator with itself recursively in Common Lisp. CL's
   ;; reader skips the defun of funcall but it's necessary for this evaluator.
   (setq #+nil (defun funcall (f x) (f x)))

   ;; Makes mutable cons using lambda.
   ;; Example:
   ;;   (setq x (mcon% 1 2))
   ;;   (x 'car) ;=> 1
   ;;   (x 'cdr) ;=> 2
   ;;   (x (cons 'cdr 99)) ;=> 99 (mutation)
   ;;   (x 'cdr) ;=> 99
   (defun mcon% (a d)
     (lambda (c) (if (eq c 'car) a
                     (if (eq c 'cdr) d
                         (if (eq (car c) 'car) (setq a (cdr c))
                             (if (eq (car c) 'cdr) (setq d (cdr c))))))))

   ;; Initialize the global environment. An environment consists of a list of
   ;; alist.
   (setq ge (mcon% (mcon% (mcon% 't 't) ()) ()))

   (defun cadr% (x) (car (cdr x)))
   (defun cddr% (x) (cdr (cdr x)))

   ;; assoc for mutable cons.
   (defun assoc% (k l)
     (loop
        (if (eq l ()) (return))
        (if (eq k (funcall (funcall l 'car) 'car)) (return (funcall l 'car)))
        (setq l (funcall l 'cdr))))

   ;; Finds a variable from environment.
   (defun fv% (k a)
     ((lambda (r)
        (loop
           (if (eq a ()) (return))
           (setq r (assoc% k (funcall a 'car)))
           (if r (return r))
           (setq a (funcall a 'cdr))))
      ()))

   ;; Evaluates an atom. It returns the corresponding value when the given
   ;; environment has a bind. Otherwise returns the given atom itself.
   (defun ea% (e a) ((lambda (b) (if b (funcall b 'cdr) e)) (fv% e a)))

   ;; Makes an EXPR from lambda or defun.
   (defun el% (e a) (cons '%e% (cons (car e) (cons (cdr e) a))))

   ;; Adds a bind to the global environment.
   (defun ae% (s v) (funcall ge
                             (cons 'car
                                   (mcon% (mcon% s v)
                                          (funcall ge 'car)))) s)

   (defun eval% (e a)
     (loop
        (if (eq e err) (return e))
        (if (atom e) (return (ea% e a)))
        (if (eq (car e) 'quote) (return (cadr% e)))
        (if (eq (car e) 'if)
            (if (eval% (cadr% e) a)
                (return (eval% (cadr% (cdr e)) a))
                (return (eval% (cadr% (cddr% e)) a))))
        (if (eq (car e) 'lambda) (return (el% (cdr e) a)))
        (if (eq (car e) 'defun)
            (return (ae% (cadr% e) (el% (cddr% e) a))))
        (if (eq (car e) 'setq)
            (return
              ((lambda (b v)
                 (if b (funcall b (cons 'cdr v))
                     (ae% (cadr% e) v))
                 v)
               (fv% (cadr% e) a) (eval% (cadr% (cdr e)) a))))
        (if (eq (car e) 'loop) (return (loop% (cdr e) a ())))
        (if (eq (car e) 'return)
            (return (loop (setq lv (eval% (cadr% e) a)) (return err))))
        (return (apply% (eval% (car e) a) (evlis% (cdr e) a)))))

   (defun pairlis% (x y)
     (if x (if y (mcon% (mcon% (car x) (car y))
                       (pairlis% (cdr x) (cdr y))) ()) ()))

   (defun evlis% (l a) (if l (cons (eval% (car l) a) (evlis% (cdr l) a)) ()))

   (defun progn% (l a r)
     (loop
        (if (eq l ()) (return r))
        (setq r (eval% (car l) a))
        (if (eq r err) (return r))
        (setq l (cdr l))))

   (defun loop% (l a r)
     (loop
        (setq r (progn% l a ()))
        (if (eq r err) (return lv))))

   (defun apply% (f a)
     (if (eq (car f) '%e%)
         (progn% (cadr% (cdr f))
                 (mcon% (pairlis% (cadr% f) a) (cddr% (cdr f))) ())
         (if (eq (car f) '%s%)
             (funcall (cdr f) a)
             f)))

   ;; Makes SUBR and EXPR more readable.
   (defun es% (e)
     (if (atom e) e
         (if (eq (car e) '%s%) '<subr> (if (eq (car e) '%e%) '<expr> e))))

   (defun eval%% (e) (es% (eval% e ge)))

   (ae% 'car (cons '%s% (lambda(x)(car(car x)))))
   (ae% 'cdr (cons '%s% (lambda(x)(cdr(car x)))))
   (ae% 'cons (cons '%s% (lambda(x)(cons(car x)(cadr% x)))))
   (ae% 'eq (cons '%s% (lambda(x)(eq(car x)(cadr% x)))))
   (ae% 'atom (cons '%s% (lambda(x)(atom(car x)))))
   (ae% '+ (cons '%s% (lambda(x)(+(car x)(cadr% x)))))
   (ae% '* (cons '%s% (lambda(x)(*(car x)(cadr% x)))))
   (ae% '- (cons '%s% (lambda(x)(-(car x)(cadr% x)))))
   (ae% '/ (cons '%s% (lambda(x)(*(car x)(cadr% x)))))
   (ae% 'mod (cons '%s% (lambda(x)(mod(car x)(cadr% x)))))
   (eval%% 'WRITE_HERE))
 () (cons 1 1) ())

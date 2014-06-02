((lambda (ge)
   (defun mcon% (a d)
     (lambda (c) (if (eq c 'car) a
                     (if (eq c 'cdr) d
                         (if (eq (car c) 'car) (setq a (cdr c))
                             (if (eq (car c) 'cdr) (setq d (cdr c))))))))
   (setq ge (mcon% (mcon% (mcon% 't 't) ()) ()))
   (defun cadr% (x) (car (cdr x)))
   (defun assoc% (k l)
     (if l (if (eq k (funcall (funcall l 'car) 'car)) (funcall l 'car)
               (assoc% k (funcall l 'cdr))) ()))
   (defun fv% (k a) (if a ((lambda (r) (if r r (fv% k (funcall a 'cdr))))
                           (assoc% k (funcall a 'car))) ()))
   (defun ea% (e a) ((lambda (b) (if b (funcall b 'cdr) e)) (fv% e a)))
   (defun el% (e a) (cons '%e% (cons (car e) (cons (cdr e) a))))
   (defun ae% (s v) (funcall ge
                             (cons 'car
                                   (mcon% (mcon% s v)
                                          (funcall ge 'car)))) s)
   (defun eval% (e a)
     (if (atom e) (ea% e a)
         (if (eq (car e) 'quote) (cadr% e)
             (if (eq (car e) 'if)
                 (if (eval% (cadr% e) a)
                     (eval% (cadr% (cdr e)) a) (eval% (cadr% (cdr (cdr e))) a))
                 (if (eq (car e) 'lambda) (el% (cdr e) a)
                     (if (eq (car e) 'defun)
                         (ae% (cadr% e) (el% (cdr (cdr e)) a))
                         (if (eq (car e) 'setq)
                             ((lambda (b v)
                                (if b (funcall b (cons 'cdr v))
                                    (ae% (cadr% e) v))
                                v)
                              (fv% (cadr% e) a) (eval% (cadr% (cdr e)) a))
                             (apply% (eval% (car e) a)
                                     (evlis% (cdr e) a)))))))))
   (defun pairlis% (x y)
     (if x (if y (mcon% (mcon% (car x) (car y))
                       (pairlis% (cdr x) (cdr y))) ()) ()))
   (defun evlis% (l a) (if l (cons (eval% (car l) a) (evlis% (cdr l) a)) ()))
   (defun progn% (l a r) (if l (progn% (cdr l) a (eval% (car l) a)) r))
   (defun apply% (f a)
     (if (eq (car f) '%e%)
         (progn% (cadr% (cdr f))
                 (mcon% (pairlis% (cadr% f) a) (cdr (cdr (cdr f)))) ())
         (if (eq (car f) '%s%)
             (funcall (cdr f) a)
             f)))
   (defun es% (e)
     (if (atom e) e
         (if (eq (car e) '%s%) '<subr> (if (eq (car e) '%e%) '<expr> e))))
   (defun eval%% (e) (es% (eval% e ge)))
   (ae% 'car (cons '%s% (lambda(x)(car(car x)))))
   (ae% 'cdr (cons '%s% (lambda(x)(cdr(car x)))))
   (ae% 'cons (cons '%s% (lambda(x)(cons(car x)(cadr% x)))))
   (ae% 'eq (cons '%s% (lambda(x)(eq(car x)(cadr% x)))))
   (ae% 'atom (cons '%s% (lambda(x)(atom(car(car x))))))
   (ae% '+ (cons '%s% (lambda(x)(+(car x)(cadr% x)))))
   (ae% '* (cons '%s% (lambda(x)(*(car x)(cadr% x)))))
   (ae% '- (cons '%s% (lambda(x)(-(car x)(cadr% x)))))
   (ae% '/ (cons '%s% (lambda(x)(*(car x)(cadr% x)))))
   (ae% 'mod (cons '%s% (lambda(x)(mod(car x)(cadr% x)))))
   (eval%% 'WRITE_HERE))
 ())

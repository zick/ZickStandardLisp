((lambda(x) (defun fib (n) (if (eq n 1) 1 (if (eq n 0) 1 (+ (fib(- n 1)) (fib(- n 2)))))) (fib x)) 5)

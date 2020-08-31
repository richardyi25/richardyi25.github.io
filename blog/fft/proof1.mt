#site-title Proof of Theorem 1
#title Proof of Theorem 1
#main

#section Uniqueness of Interpolation
#block Statement
Let $f(x) = a_0 + \dots + a_nx^n$ be a polynomial with degree $n$ whose coefficients $a_0, \dots, a_n$ are unknown. For any choice of $n + 1$ distinct numbers $s_0, \dots, s_n$, if we know $f(s_0), \dots, f(s_n)$, then we can uniquely determine $a_0, \dots, a_n$.
#end block

Suppose we have some polynomials $f(x)$ and $g(x)$ of degree $n$ and for $0 \leq i \leq n$, $f(s_i) = g(s_i)$, that is, they have the same value at $n + 1$ points. If we prove that $f(x)$ is neccesarily equal to $g(x)$, then values at $n + 1$ points will uniquely determine a polynomial of degree $n$.

Consider the polynomial $h(x) = f(x) - g(x)$. Since $f(x)$ and $g(x)$ have degree $n$, $h(x)$ has at most degree $n$, and by the Fundamental Theorem of Algebra, if $h(x)$ is not $0$ for every value of $x$, then it has at most $n$ roots.

However, $0 \leq i \leq n$, $f(s_i) = g(s_i) \implies f(s_i) - g(s_i) = h(s_i) = 0$, so $h(x)$ has $n + 1$ roots. Therefore, the only possbility is that $h(x) = 0$, which means $f(x) = g(x)$, as required.
#end section
#end main

#site-title Proof of Theorem 3
#title Proof of Theorem 3
#latex-preamble
$$
\newcommand{\om}{\omega}
$$
#end latex-preamble

#main

#section $\mathbf{e^{i\frac{2\pi}n}}$ is a Primitive $\mathbf n$-th Root of Unity
First, we prove that $e^{i\frac{2\pi}n}$ is an $n$-th root of unity by checking $\left(e^{i\frac{2\pi}n}\right)^n = 1$
$\left(e^{i\frac{2\pi}n}\right)^n = e^{i\frac{2\pi}n n} = e^{i2\pi} = \cos(2\pi) + i\sin(2\pi) = 1 + i(0) = 1$

Second, we prove that $e^{i\frac{2\pi}n}$ is a primitive $n$-th root of unity by showing that for all $0 < k < n$, $\left(e^{i\frac{2\pi}n}\right)^k \neq 1$.

For all $0 < k < n$, we have
$\left(e^{i\frac{2\pi}n}\right)^k = e^{i\frac{2k\pi}n} = \cos\left(\frac{2k\pi}n\right) + i\sin\left(\frac{2k\pi}n\right)$

Since $0 < k < n$, we have $0 < \frac{2k\pi}n < 2\pi$, and we know from trignometry that for this range, $\cos\left(\frac{2k\pi}n\right) \neq 1$ and $\sin\left(\frac{2k\pi}n\right) \neq 0$, so 
$\left(e^{i\frac{2\pi}n}\right)^k = \cos\left(\frac{2k\pi}n\right) + i\sin\left(\frac{2k\pi}n\right) \neq 1$.


#end section

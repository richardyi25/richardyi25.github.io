#site-title Proof of Theorem 4
#title Proof of Theorem 4

#main
#section Complex Roots of Unity
#block Statement
For all integers $n > 0$, the solutions to the polynomial $x^n = 1$ are

$$\cos \theta + i \sin\theta $$ 

For all angles $\theta$ (in radians)
$$0, \frac{2\pi}{n}, \frac{4\pi}n, \frac{6\pi}n, \dots, \frac{(n-1)2\pi}n$$

In particular, for $\theta = \frac{2\pi}{n}$, ie. the number $\cos\left(\frac{2\pi}{n}\right) + i\sin\left(\frac{2\pi}{n}\right)$ is a primitive $n$-th root of unity.
#end block

In order to prove this, we need to use a mathematical result:
#block Euler's Formula
$$e^{i\theta} = \cos \theta + i\sin\theta$$
where $\theta$ is in radians.
#end block

This formula has a variety of proofs, all of which are beyond the scope of this article. If you're interested, the <a href="https://en.wikipedia.org/wiki/Euler%27s_formula#Proofs">Wikipedia article</a> is a good starting point.

Back to the actual proof, we first prove that for $\theta = 0, \frac{2\pi}{n}, \frac{4\pi}n, \frac{6\pi}n, \dots, \frac{(n-1)2\pi}n$, $\cos \theta + i\sin\theta$ is an $n$-th root of unity, that is $(\cos\theta + i\sin\theta)^n = 1$

$$
\begin{align}
&\phantom{=|}(\cos\theta + i\sin\theta)^n \\
&= \left(e^{i\theta}\right)^n && \text{ by Euler's Formula}\\
&= e^{i\theta n} \\
&= \cos(\theta n) + i\sin(\theta n) && \text{ by Euler's Formula, in the other direction}
\end{align}
$$

Since $\theta = 0, \frac{2\pi}{n}, \frac{4\pi}n, \frac{6\pi}n, \dots, \frac{(n-1)2\pi}n$, we have $\theta n = 0, 2\pi, 4\pi, 6\pi, (n-1)2\pi$.

Now $\cos(0) = \cos(2\pi) = \cos(4\pi) = \dots = 1$ and $\sin(0) = \sin(2\pi) = \sin(4\pi) = \dots = 0$ so
$$\cos (\theta n) + i \sin(\theta n) = 1 + i(0) = 1$$

Next, we prove that $\cos\left(\frac{2\pi}{n}\right) + i\sin\left(\frac{2\pi}{n}\right)$ is a primitive $n$-th root of unity, ie. for all $0 < k < n$, $\left(\cos\left(\frac{2\pi}{n}\right) + i\sin\left(\frac{2\pi}{n}\right)\right)^k \neq 1$.

Again, we'll use Euler's formula. Let $0 < k < n$. Then,
$$
\begin{align}
&\phantom{=.}\left(\cos\left(\tfrac{2\pi}{n}\right) + i\sin\left(\tfrac{2\pi}{n}\right)\right)^k \\
&= \left(e^{i\frac{2\pi}n}\right)^k \\
&= e^{\large i\frac{2\pi}nk} \\
&= \cos\left(\tfrac{2\pi}nk\right) + i\sin\left(\tfrac{2\pi}nk\right) \\
&= \cos\left(2\pi\tfrac kn\right) + i\sin\left(2\pi \tfrac kn\right)
\end{align}
$$

We know that for all angles $\theta$ strictly between $0$ and $2\pi$, $\cos \theta \neq 1$ and $\sin \theta \neq 0$, so $\cos \theta + i \sin \theta \neq 1$.

Since $0 < k < n$, $0 < \frac kn < 1$. This means $0 < 2\pi\frac kn < 2\pi$. Therefore, $\cos\left(2\pi\tfrac kn\right) + i\sin\left(2\pi \tfrac kn\right) \neq 1$.

#end section
#end main

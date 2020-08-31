#site-title Proof of Theorem 2
#title Proof of Theorem 2
#latex-preamble
$$
\newcommand{\om}{\omega}
$$
#end latex-preamble

#main

#section Theorem 2.1
#block Statement
Let $n$ be an even number, $\om_n$ be a primitive $n$-th root of unity, and $m = \frac n2$.
<b>Theorem 2.1:</b> For all $0 < k < n$, the values of $\om_n^k$ are distinct roots of unity.
#end section

First, we prove that the values of $\om_n^k$ for $0 < k < n$ are $n$-th roots of unity. By definition, since $(\om_n^k)^n = \om_n^{kn} = (\om_n^n)^k = 1^k = 1$, $\om_n^k$ must be a root of unity for any $0 < k < n$.

Next we prove that they are all distinct roots of unity. Suppose the statement isn't true: that there exist $k_1$ and $k_2$ such that $0 < k_1 < k_2 < n$ and $\om_m^{k_1} = \om_m^{k_2}$. If we divide both sides by $\om_n^{k_1}$, we then get $\om_n^{k_2 - k_1} = 1$. But since $0 < k_1 < k_2 < n$, we have $0 < k_2 - k_1 < n$, and by the definition of primitivity, $\om_n^{k_2 - k_1}$ can't be $1$. We reach a contradiction, so the values of $\om_n^k$ must indeed be distinct.
#end section

#section Theorem 2.2
#block Statement
Let $n$ be an even number, $\om_n$ be a primitive $n$-th root of unity, and $m = \frac n2$.
$\om_n^m = -1$.
#end section
Since $(\om_n^m)^2 = \om_n^{2m} = \om_n^n = 1$, we have $(\om_n^m)^2 - 1 = 0 \implies (\om_n^m - 1)(\om_n^m + 1) = 0$.
This means either at least one of $\om_n^m - 1 = 0$ and $\om_n^m + 1 = 0$ is true. $\om_n^m - 1 = 0 \implies \om_n^m = 1$ can't be true by the primitivity of $\om_n$. Therefore, $\om_n^m + 1 = 0$ must be true and $\om_n^m = -1$.
#end section

#section Theorem 2.3
#block Statement
Let $n$ be an even number, $\om_n$ be a primitive $n$-th root of unity, and $m = \frac n2$.
<ol>
	<li>$\om_n^2$ is an $m$-th root of unity. Let's call it $\om_m$.</li>
	<li>For all $0 < k < n$, $(\om_n^k)^2 = \om_m^k$</li>
	<li>For all $0 < k < n$, $(\om_n^{k + m})^2 = \om_m^k$</li>
</ol>
#end section

<div class="subheading">Part 1</div>
We use the definitions to prove that $\om_n^2$ is a primitive $m$-th root of unity. $(\om_n^2)^m = \om_n^{2m} = \om_n^n = 1$, so $\om_n^2$ is an $m$-th root of unity. Also, for all $0 < k < m$, $(\om_n^2)^k = \om_n^{2k}$. Since $\om_n$ is prmitive and $k < m \implies 2k < n$, $\om_n^{2k} \neq 1$ by definition.

<div class="subheading">Part 2</div>
$(\om_n^k)^2 = \om_n^{2k} = (\om_n^2)^k = (\om_m)^k = \om_m^k$.

<div class="subheading">Part 3</div>
$(\om_n^{k + m})^2 = \om_n^{2(k + m)} = \om_n^{2k + 2m} = (\om_n^{2k})(\om_n^{2m}) = (\om_n^k)^2 (\om_n^n) = (\om_m^k)(1) = \om_m^k$.
#end section

#section Theorem 2.4
#block Statement
Let $n$ be an even number, $\om_n$ be a primitive $n$-th root of unity, and $m = \frac n2$.
For all $0 < k < n$, $\om_n^0 + \om_n^k + \om_n^{2k} + \dots + \om_n^{(n-1)k} = 0$.
#end section
Let $c$ be the value of the sum $\om_n^0 + \om_n^k+ \dots + \om_n^{(n-1)k}$. We want to prove that $c=0$.
$$\begin{align}c &= \om_n^0 + \om_n^k+ \dots + \om_n^{(n-1)k}\end{align}$$
Let's mutiply both sides by $1 - \om_n^k$:
$$
\require{cancel}
\begin{align}
c(1 -\om_n^k) &= (\om_n^0 + \om_n^k + \dots + \om_n^{(n-1)k})(1-\om_n^k) \\
c(1-\om_n^k)  &= (\om_n^0 + \om_n^k + \dots + \om_n^{(n-1)k})-\om_n^k(\om_n^0 + \om_n^k + \dots + \om_n^{(n-1)k}) \\
c(1-\om_n^k)  &= \om_n^0+\om_n^k+\dots+\om_n^{(n-1)k}-\om_n^k-\om_n^{2k}-\dots-\om_n^{nk} \\
c(1-\om_n^k)  &= \om_n^0+\cancel{\om_n^k}+\dots+\cancel{\om_n^{(n-1)k}}-\cancel{\om_n^k}-\cancel{\om_n^{2k}}-\dots-\om_n^{nk} \\
c(1-\om_n^k)  &= \om_n^0-\om_n^{nk} \\
c(1-\om_n^k)  &= 1-(\om_n^{n})^k \\
c(1-\om_n^k)  &= 1-(1)^k \\
c(1-\om_n^k)  &= 0
\end{align}
$$
Since $c(1-\om_n^k) = 0$, at least one of $c$ and $(1-\om_n^k)$ must be $0$.

But since $0 < k < n$, by definition we have $\om_n^k \neq 1 \implies 1 - \om_n^k \neq 0$, so $c$ must be $0$.
#end section

#end main

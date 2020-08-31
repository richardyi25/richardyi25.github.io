// TODO normalize phantoms to X's for readability
#site-title A Gentle Dive into FFT
#title A Gentle Dive into FFT
#latex-preamble
$$
\newcommand{\om}{\omega}
$$
#end latex-preamble
#toc

#warning

#main

#section Pre-Requisite Knowledge
This article is intended for people who are familiar with time complexity and have a high school level knowledge of trignometry and polynomials.
#end section

#section Introduction
In competitive programming, the Fast Fourier Transform is a technique that speeds up polynomial multiplication from $O(n^2)$ to $O(n \log n)$. In this article, we will explore the basic concepts behind this speedup and its implementation and applications.
#end section

#section Multiplying Polynomials
First, let's recap what a polynomial is:
#block Defintion - Polynomial
A polynomial $f(x)$ of degree $n$ is defined as $$f(x) = a_0 + a_1x + a_2x^2 + \dots + a_nx^n$$
where $a_0, \dots, a_n$ are numbers.
#end block
It's common to include the restriction $a_n \neq 0$, but we won't. This allows us to "upgrade" polynomials to a higher degree by adding coefficients with value $0$.

For example, if $f(x) = a_0 + a_1x + \dots + a_nx^n$ is a polynomial of degree $n$, we can "upgrade" it to a polynomial of degree $n + k$ if we take $f(x)$ to be $a_0 + \dots + a_nx^n + 0a_{n+1} + \dots + 0x^{n+k}$.

We can multiply polynomials to get a new polynomial. Suppose $f(x) = a_0 + a_1 + \dots + a_nx^n$ and $g(x) = b_0 + b_1 + \dots + b_nx^n$ are both polynomials of degree $n$. Let $h(x) = f(x)g(x)$ be their product. We can calculate $h(x)$ by distributing and collecting the terms:
$$
\begin{align}
h(x) &= f(x)g(x) \\
     &=(a_0 + a_1x + \dots + a_nx^n)(b_0 + b_1x + \dots + b_nx^n) \\
     &= \sum_{i = 0}^n \sum_{j = 0}^n a_ib_jx^{i+j}
\end{align}
$$

The product $h(x) = f(x)g(x) = c_0 + c_1x + \dots + c_{2n}x^{2n}$ is a polynomial of degree $2n$. We can find the $k$-th coefficient $c_k$ for all $0 \leq k \leq 2n$ by adding all $a_ib_j$ such that $i + j = k$. To do this, we loop thourgh all $i$ from 0 to $k$ inclusive and set $j = k - i$. 

#block Polynomial Mutliplciation Formula
If
$$
\begin{align}
f(x) &= a_0 + a_1x + \dots + a_nx^n \\
g(x) &= b_0 + b_1x + \dots + a_nx^n \\
h(x) = f(x)g(x) &= c_0 + c_1x + \dots + c_{2n}x^{2n}\end{align}
$$
then for all $0 \leq k \leq 2n$,
$$ c_k = \sum_{i = 0}^k a_ib_{k - i} $$
#end block

Note that this formula takes $O(n^2)$ time to compute $c_k$ for all $0 \leq k \leq 2n$, despite it only being $O(n)$ space of information. There seems to be a neat structure to the computation, so there's probably room for improvement by reusing calculations. This is where the Fast Fourier Transform comes in.
#end section
#section Sampling and Interpolating
A polynomial $f(x) = a_0 + \dots + a_nx^n$ can be represented by only its coefficients $a_0, \dots, a_n$. However, if we know its value at enough points, we can also determine the coefficients of the polynomial.
#block Theorem 1: Uniqueness of Interpolation
Let $f(x) = a_0 + \dots + a_nx^n$ be a polynomial with degree $n$ whose coefficients $a_0, \dots, a_n$ are unknown. For any choice of $n + 1$ distinct numbers $s_0, \dots, s_n$, if we know $f(s_0), \dots, f(s_n)$, then we can uniquely determine $a_0, \dots, a_n$.

<a href="proof1.html">Proof</a>
#end block

Let's call the choice of distinct numbers $s_0, \dots, s_n$ <b>sampling points</b> and the values of $f(s_0), \dots f(s_n)$ <b>samples</b>. Note that while the samples uniquely determine the coefficients, the samples themselves aren't unique because any choice of distinct sampling points will work. Any polynomial that satisfies the samples is said to <b>interpolate</b> the samples.

We'll call the process of calculating samples from the polynomial in coefficient form <b>sampling</b> and the process of determining the coefficients from samples <b>interpolating</b>.

#end section

#section Speedup Overview
For the sake of later convenience, we'll talk about multiplying polynomials of degree $n - 1$ from now on.

Let $f(x) = a_0 + \dots + a_{n-1}x^{n-1}$ and $g(x) = b_0 + \dots + b_{n-1}x^{n-1}$ be polynomials of degree $n - 1$. Instead of multiplying them directly, we'll first sample both $f(x)$ and $g(x)$ at sample points $s_0, \dots, s_{2n - 1}$, calculating $f(s_0), \dots, f(s_{2n - 1})$ as well as $g(s_0), \dots, g(s_{2n - 1})$.

Then we'll pointwise multiply the samples, calculating $f(s_0)g(s_0), \dots f(s_{2n - 1})g(s_{2n - 1})$. The theorem from the previous section tells us that this is enough to recover the coefficients of $f(x)g(x)$, since we have $2n$ samples and $f(x)g(x)$ is of degree $2n - 2$. Once we do that, we've calculated $f(x)g(x)$.

If we can quickly sample and interpolate polynomials, then we can quickly multiply polynomials since the pointwise multiplication step only takes $O(N)$ time.
#end section

#section Primitive Roots of Unity
We have the luxury of picking whichever $2n$ sample points $s_0, \dots s_{2n - 1}$ we want, but if we want both sampling and interpolation to be fast, we better pick sample points that allow us to reuse calculations.

The type of number that will allow us to do this is the primitive roots of unity.
#block Definition - Roots of Unity and Primitivity
Let $n$ be a positive integer. A number $\om_n$ is said to be an <b>$\mathbf n$-th root of unity</b> if $\om_n^n =1 $.
In addition, a $n$-th root of unity $\om_n$ is said to be <b>primitive</b> if for all $0 < k < n$, $\om_n^k \neq 1$.
#end block

For $n > 2$, $n$-th roots of unity don't exist in the real numbers, so we'll have to use a new number system. If you're not familiar with complex numbers or number theory, that's fine since we can talk about these numbers without using a particular system. The important fact is that there are number systems that allow for these $n$-th roots of unity for any $n$.

#block Theorem 2: Properties of Primitive Roots of Unity
Let $n$ be an even number, $\om_n$ be a primitive $n$-th root of unity, and $m = \frac n2$.
<div>
	<b>Theorem 2.1:</b> For all $0 < k < n$, the values of $\om_n^k$ are distinct $n$-th roots of unity.
</div>
<div style="margin: 5px 0px 2px 0px">
	<b>Theorem 2.2:</b> $\om_{n}^m = -1$.
</div>
<div>
	<b>Theorem 2.3:</b>
	<ol>
		<li>$\om_n^2$ is an $m$-th root of unity. Let's call it $\om_m$.</li>
		<li>For all $0 < k < n$, $(\om_n^k)^2 = \om_m^k$</li>
		<li>For all $0 < k < n$, $(\om_n^{k + m})^2 = \om_m^k$</li>
	</ol>
</div>
<div>
<b>Theorem 2.4:</b> For all $0 < k < n$, $\om_n^0 + \om_n^k + \om_n^{2k} + \dots + \om_n^{(n-1)k} = 0$.
</div>

<div style="margin-top: 10px">
	<a href="proof2.html">Proof</a>
</div>
#end block

For the rest of the article, we'll keep the convention of $m = \frac n2$.
#end section

#section Sampling Quickly
We can now solve the problem of finding $n$ samples from a polynomial of degree $n - 1$.
Let's recap what the problem is
#block Sampling Problem Statement
Given $a_0, \dots, a_{n-1}$ which determines $f(x) = a_0 + \dots + a_{n-1}x^{n-1}$, and a choice of $n$ sampling points $s_0, s_1, \dots, s_{n-1}$, we wish to find the samples
$$ f(s_0), f(s_1), \dots, f(s_{n-1}) $$
where
$$
\begin{align}
f(s_0) &= a_0 + a_1s_0 + a_2s_0^2 + \dots + a_{n-1}s_0^{n-1} \\
f(s_1) &= a_1 + a_1s_1 + a_2s_1^2 + \dots + a_{n-1}s_1^{n-1} \\
&\phantom{$a_1+a_1s_1+a_2$}     \vdots \\
f(s_{n-1}) &= a_1 + a_1s_{n-1} + a_2s_{n-1}^2 + \dots + a_{n-1}s_{n-1}^{n-1} \\
\end{align}
$$
#end block

We can easily evaluate the $n$ samples in $O(n^2)$ time since it takes $O(n)$ time to calculate a single sample and we have $O(n)$ samples to calculate. In order to speed this up to $O(n \log n)$, we'll have to take advantage of the properties of the primitive roots of unity.

Let $n$ be an even number and $m = \frac n2$. Let $f(x) = a_0 + \dots + a_{n-1}x^{n-1}$ be an $n - 1$ degree polyomial. We define two $n - 1$ degree polynomials, $f_e$ keeping only the coefficients at even degree and $f_o$ keeping only the coefficients at odd degree:
$$
\begin{align}
f_e(x) &= a_0 + a_2x + a_4x^2 + \dots+ a_{n-2}x^{m-1}
f_o(x)&=a_1+a_3x + a_5x^2 + \dots + a_{n-1}x^{m-1}
\end{align}
$$

Now let $\om_n$ be a primitive $n$-th root of unity. We'll drop the subscript $_n$ for now for convenience. We can conveniently evaluate $f(\om^k)$ from just $f_e(\om^{2k})$ and $f_o(\om^{2k})$:
$$
\begin{align}
f_e(\om^{2k}) + \om^kf_o(\om^{2k})
  &= \left(a_0 + a_2\om^{2k} + \dots + a_{n-2}\om^{2k(m - 1)}\right)+\om^k\left(a_1+a_3\om^{2k}+\dots+a_{n-1}\om^{2k(m-1)}\right) \\
  &= \left(a_0+a_2\om^{2k}+\dots+a_{n-2}\om^{(n-2)k}\right)+\left(a_1\om^k+a_3\om^{3k}+\dots+a_{n-1}\om^{(n-1)k}\right) \\
  &= a_0+a_1\om^k+a_2\om^{2k}+a_3\om^{3k}+\dots+a_{n-2}\om^{(n-2)k}+a_{n-1}\om^{(n-1)k} \\
  &= f(\om^k)
\end{align}
$$

Let's bring the subscript $_n$ back so we can manipulate the result that we found. If $\om_n$ is a primitive $n$-th root of unity and $m = \frac n2$, then
$$
\begin{align}
f(\om_n^k) &= f_e(\om_n^{2k}) + \om_n^k f_o(\om_n^{2k}) \\
           &= f_e((\om_n^k)^2) + \om_n^kf_o((\om_n^k)^2) \\
           &= f_e(\om_m^k)+\om_n^kf_o(\om_m^k)
\end{align}
$$
This formula works for all $0 \leq k < n$, but if we restrict $k$ to the range $0 \leq k < m$ and consider both $k$ and $k + m$, we find a very special pattern:
$$ f(\om_n^k) = f_e(\om_m^k)+\om_n^kf_o(\om_m^k) $$
as expected, but
$$
\begin{align}
f(\om_n^{k + m}) &= f_e(\om_n^{k + m})+\om_n^{k + m}f_o(\om_m^{k + m}) \\
                 &= f_e(\om_m^k\om_m^m) + \om_n^n \om_n^k f_o(\om_m^k\om_m^m) \\
                 &= f_e(\om_m^k) - \om_n^k f_o(\om_m^k)
\end{align}
$$
To recap, we've found that
#block Sampling Reduction Formula
If $n$ is an even number, $m = \frac n2$, and
$$
\begin{align}
f(x)   &= a_0 + a_1x + a_2x^2+ \dots + a_{n-1}x^{n-1} \\
f_e(x) &= a_0 + a_2x + a_4x^2 + \dots+ a_{n -2}x^{m-1} \\
f_o(x) &= a_1+a_3x + a_5x^2 + \dots + a_{n-1}x^{m-1}
\end{align}
$$
and $\om_n$ is a primitive $n$-th root of unity, then for all $0 \leq k < m$,
$$
\begin{align}
f(\om_n^k)     &= f_e(\om^k_m) + \om^k_n f_o(\om^k_m) \\
f(\om_n^{k+m}) &= f_e(\om^k_m) - \om^k_nf_o(\om^k_m)
\end{align}
$$
#end block
This is an extremely important formula. This means that if we need to sample $f(x)$ at $\om_{2n}^0, \om_{2n}^1, \dots \om_{2n}^{2n-1}$, we can reduce this into the problem of sampling $f_e(x)$ and $f_o(x)$ at $\om_n^0, \om_n^1, \dots \om_n^{n-1}$ with a cost of $O(n)$ steps.

At first glance, this doesn't help at all. In order to calculate $2n$ samples, we need to calculate $n$ samples for each of the functions $f_e$ and $f_o$, which is still $2n$ samples in total.

What if we kept using this formula over and over again? Let $n$ be a power of two, say $n = 2^k$. Suppose we have a polynomial of degree $n - 1$ and want to find $n$ samples. With a cost of $O(n)$ steps, we can reduce the problem into finding $\frac{n}{2}$ samples for $2$ polynomials of degree $\frac{n}{2} - 1$. If we apply the formula to each of the smaller polynomials, then with a cost of $2 \times \frac{n}{2} = O(n)$, we can reduce the problem further to finding $\frac{n}{4}$ samples for $4$ polynomials of degree $\frac{n}{4} - 1$.

Eventually, after $k$ iterations of this, with each iteration incurring a cost of $O(n)$ steps, the problem is reduced to finding one sample for $n$ polynomials each of degree $0$. This is now trivial to do since a sample of a polynomial $f(x) = a_0$ of degree $0$ is just $a_0$, so this step takes $O(n)$ time. In total, since $n = 2^k$, then $k = \log n$, so we spent $O(n) \times O(\log n) = O(n \log n)$ time reducing the problem to the trivial form, and $O(n)$ time solving the trivial form. Therefore, we've found a way to take $n$ samples in just $O(n)$ time.

#block Sampling Algorithm
Let $n$ be a power of $2$, $f(x) = a_0 + \dots + a_{n-1}x^{n-1}$ be a polynomial of degree $n - 1$ and $\om_{n}$ be a primitive $n$-th root of unity.

To calculate $n$ samples $f(\om_n^0), f(\om_n^1), \dots, f(\om_n^{n-1})$:
<ul>
	<li>If $n = 1$, then the only sample we need is $f(\om_1^0) = f(1) = a_0$.</li>
	<li>
		Otherwise, let $m = \frac n2$ and $$\begin{align}f_e(x) &= a_0 + a_2x + a_4x^2 + \dots + a_{n-1}x^{m-1}\\f_o(x)&=a_1+a_3x+a_5x^2+\dots+a_nx^{m-1}\end{align}$$
		We recursively apply this algorithm on $f_e(x)$ and $f_o(x)$ to find $f_e(\om_{m}^0), f_e(\om_{m}^1), \dots, f_e(\om_{m}^{m - 1})$ and $f_o(\om_{m}^0), f_o(\om_{m}^1), \dots, f_o(\om_{m}^{m - 1})$.

		From these samples, we can calculuate $f(\om_n^0), f(\om_n^1), \dots, f(\om_n^{n-1})$:

		For all $0 \leq k < m$,
		$$
			\begin{align}
			f(\om_n^k)     &= f_e(\om^k_m) + \om^kf_o(\om^k_m) \\
			f(\om_n^{k+m}) &= f_e(\om^k_m) - \om^kf_o(\om^k_m)
			\end{align}
		$$
	</li>
</ul>
#end block

Of course, when we sample a polynomial, it's not always going to have a degree that's one less than a power of $2$. This isn't a problem since we can just "upgrade" the polynomial to one less than the next power of $2$.

For example, if we have a polynomial $f(x) = a_0 + \dots + a_nx^n$ of degree $n$ and $2^k$ is the smallest power of $2$ at least as big as $n - 1$, then we can interpret $f(x)$ as $f(x) = a_0 + \dots a_nx^n + 0x^{n+1} + \dots + 0x^{2^k - 1}$.

In the worst case, the new degree and the number of samples we'll have to take is doubled. This is fine because this is just a constant factor.
#end section

#section Reducing Interpolating to Sampling
While sampling can be easily done in $O(n^2)$, it seems like interpolating in any time complexity is a daunting task. However, in this section, we'll find that through the magic of primitive roots of unity, interpolating is just sampling in disguise.

Let's first recap what the problem asks us to do.
#block Interpolating Problem Statement
Let $f(x) = a_0 + \dots + a_{n-1}x^{n-1}$ be a polynomial of degree $n - 1$.
<br/>
Given $n$ sample points $s_0, \dots, s_{n-1}$ and $n$ samples $v_0, \dots, v_{n-1}$ where it is known that $f(s_0) = v_0, f(s_1) = v_1, \dots, f(s_{n-1}) = v_{n-1}$, we wish to find $a_0, \dots a_{n-1}$.
<br/><br/>
In other words, we want to solve the system of equations
$$
\begin{align}
a_0 + a_1s_0 + a_2s_0^2 + \dots + a_{n-1}s_0^{n-1} &= v_0 \\
a_1 + a_1s_1 + a_2s_1^2 + \dots + a_{n-1}s_1^{n-1} &= v_1 \\
			\vdots\phantom{+$a_{n-1}s_1^{n-1}$}& \\
a_1 + a_1s_{n-1} + a_2s_{n-1}^2 + \dots + a_{n-1}s_{n-1}^{n-1} &= v_{n-1} \\
\end{align}
$$
#end block

We note that by Uniqueness of Interpolation, that we're guaranteed exactly one possible value for $a_0, \dots, a_n$.

Let's prove an interesting property about combining interpolating problems:
#block Theorem - Additivity of Interpolation
Let $f(x)$ and $g(x)$ be polynomials of degree $n - 1$.
Suppose we are given sample points $s_0, \dots, s_n$ and we know that:
$$
u_0 = f(s_0), u_1 = f(s_1), \dots, u_{n-1} = f(s_{n-1}) \\
v_0 = f(s_0), v_1 = f(s_1), \dots, v_{n-1} = f(s_{n-1})
$$
and we've found $f(x)$ and $g(x)$.

Then the polynomial $h(x)$ that interpolates the samples $(u_0 + v_0), (u_1 + v_1), \dots, (u_{n-1}, v_{n-1})$ is $h(x) = f(x) + g(x)$.
#end block

The proof of this is pretty simple. At each of the sample points $s_i$ where $0 \leq i < n$, $h(s_i) = f(s_i) + g(s_i) = u_i + v_i$. Again, by the Uniquness of Interpolation, $h(x) = f(x) + g(x)$ is the only possible polynomial that interpolates the samples.

This theorem seems trivial but it lets us break down the problem into easier subproblems. Let $v_0, \dots, v_n$ be samples. For $0 \leq k < n$, we'll define the <i>$k$-th partial sample set</i> to be $0, \dots, 0, v_k, 0, \dots, 0$. In other words, it's only the $k$-th sample and every other sample has been set to $0$.

If we can solve the interpolation problem for all of the partial sample sets, we'll can just add the interpolating polynomials together to get the interpolation of $v_0, \dots, v_n$.

Recall that we've picked $s_0, \dots, s_{n-1}$ to be $\om_n^0, \dots, \om_n^{n-1}$ where $\om_n$ is a primitive $n$-th root of unity. Now let's try to interpolate the $0$-th partial sample set, that is, we want to solve the system
$$
\begin{align}
a_0 + a_1 + a_2 + \dots + a_{n-1}                                         &= v_0 \\
a_0 + a_1\om_n^1 + a_2\om_n^2 + \dots + a_{n-1}\om_n^{n-1}                &= 0 \\
			            \vdots\phantom{+$a_{n-1}s_1^{n-1}$}               & \\
a_0 + a_1\om_n^{n-1} + a_2\om_n^{2(n-1)} + \dots + a_{n-1}\om_n^{(n-1)^2} &= 0 \\
\end{align}
$$

This doesn't make the problem any easier, but if we try something silly, we'll see that everything works out. If we set $a_0 = a_1 = a_2 = \dots = a_{n-1} = \frac 1n v_0$, then we see that indeed $a_0 + a_1 + a_2 + \dots + a_{n-1} = \frac 1nv_0 + \dots + \frac 1nv_0 = \frac 1nv_0(n) = v_0$.

But do we satisfy the other equations? Well for $0 < k < n$, we have
$$
\begin{align}
&\phantom{=.}
   a_0 + a_1\om_n^k + a_2\om_n^{2k} + \dots + a_{n-1}\om_n^{(n-1)k} \\
&= \tfrac 1nv_0 + \tfrac 1nv_0\om_n^k + \tfrac 1nv_0\om_n^{2k} + \dots + \tfrac 1nv_0\om_n^{(n-1)k} \\
&= \tfrac 1nv_0 \left(1 + \om_n^k + \om_n^{2k} + \dots + \om_n^{(n-1)k} \right)
\end{align}
$$

By the fourth primitive root of unity property, for all $0 < k < n$, $\om_n^0 + \om_n^k + \om_n^{2k} + \dots + \om_n^{(n-1)k} = 0$, so

$$
\begin{align}
&\phantom{=.} 
   \tfrac 1nv_0 \left(1 + \om_n^k + \om_n^{2k} + \dots + \om_n^{(n-1)k}\right) \\
&= \tfrac 1nv_0 (0) \\
&= 0
\end{align}
$$

Now that we've solved the $0$-th partial sample set, we can also solve the $k$-th partial sample set for $0 < k < n$. This time, we want to solve the system
$$
\begin{align}
a_0 + a_1 + a_2 + \dots + a_{n-1}                                         &= 0 \\
                         \vdots\phantom{+$a_{n-1}s_1^{n-1}$}              & \\
a_0 + a_1\om_n^k + a_2\om_n^{2k} + \dots + a_{n-1}\om_n^{(n-1)k}          &= v_k \\
                         \vdots\phantom{+$a_{n-1}s_1^{n-1}$}              & \\
a_0 + a_1\om_n^{n-1} + a_2\om_n^{2(n-1)} + \dots + a_{n-1}\om_n^{(n-1)^2} &= 0 \\
\end{align}
$$

We can do something similar, but instead of setting $a_0 = \dots = a_n = \frac 1nv_0$, we'll set
$$\begin{align}a_0 &= \tfrac 1nv_k \\a_1 &= \tfrac 1nv_k\om_n^{-k}\\ a_2 &= \tfrac 1nv_k\om_n^{-2k}\\ &\phantom{/}\vdots\\ a_{n-1} &= \tfrac 1nv_k \om_n^{-(n-1)k}\end{align}$$

That way, we have
$$
\begin{align}
&\phantom{=.}
   a_0 + a_1\om_n^k + a_2\om_n^{2k} + \dots + a_{n-1}\om^{(n-1)k} \\
&= \tfrac 1nv_k + \tfrac 1nv_k\om_n^{-k}\om_n^k + \tfrac 1nv_k\om_n^{-2k}\om_n^{2k}+ \dots+ \tfrac 1nv_k \om_n^{-(n-1)k}\om_n^{-(n-1)k} \\
&= \tfrac 1nv_k\left( 1 + \om_n^{-k}\om_n^k + \om_n^{-2k}\om_n^{2k} + \dots + \om_n^{-(n-1)k}\om_n^{(n-1)k}\right)\\
&= \tfrac 1nv_k\left(1+1+1+\dots+1\right) \\
&= \tfrac 1nv_k(n) \\
&= v_k
\end{align}
$$

And see once again for any $i \neq k$,
$$
\begin{align}
&\phantom{=.}
   a_0 + a_1\om_n^i + a_2\om_n^{2i} + \dots + a_{n-1}\om_n^{(n-1)i} \\
&= \tfrac 1nv_k + \tfrac 1nv_k\om_n^{-k}\om_n^i + \tfrac 1nv_k\om_n^{-2k}\om_n^{2i} + \dots + a_{n-1}\om_n^{-(n-1)k}\om_n^{(n-1)i} \\
&= \tfrac 1nv_k \left(1 + \om_n^{-k}\om_n^i + \om_n^{-2k}\om_n^{2i} + \dots + \om_n^{-(n-1)k}\om_n^{(n-1)i}\right) \\
&= \tfrac 1nv_k \left(1 + \om_n^{i-k} + \om_n^{2(i-k)} + \dots + \om_n^{(n-1)(i-k)} \right)
\end{align}
$$

Let $j = i - k$, we have
$$ \tfrac 1nv_k \left(1 + \om_n^{j} + \om_n^{2j} + \dots + \om_n^{(n-1)j} \right) $$

We know that $0 \leq i, k < n$ and $i \neq k$, and there are 2 cases:
<ol>
	<li>
		If $i > k$, then $0 < i - k < n$ or $0 < j < n$. Therefore,
		$$
		\begin{align}
		&\phantom{=.}
		   \tfrac 1nv_k \left(1 + \om_n^{j} + \om_n^{2j} + \dots + \om_n^{(n-1)j} \right) \\
		&= \tfrac 1nv_k (0) \\
		&= 0
		\end{align}
		$$
		as required.
	</li>
	<li>
		If $i < k$, then $-n < i - k < 0$ or $-n < j < 0$. Adding $n$ to everything, we get $0 < j + n < n$.
		As a side note, we note that for any number $c$, $\om_n^{cn} = (\om_n^n)^c = 1^c = 1$.
		$$
		\begin{align}
		&\phantom{=.}
		   \tfrac 1nv_k \left(1 + \om_n^{j} + \om_n^{2j} + \dots + \om_n^{(n-1)j} \right) \\
		&= \tfrac 1nv_k \left(1 + \om_n^{j}\om_n^n + \om_n^{2j}\om_n^{2n} + \dots + \om_n^{(n-1)j}\om_n^{(n-1)n}\right) \\
		&= \tfrac 1nv_k \left(1 + \om_n^{j+n} + \om_n^{2(j + n)} +\dots+\om_n^{(n-1)(j + n)}\right) \\
		&= \tfrac 1nv_k (0) \\
		&= 0
		\end{align}
		$$
		as required.
	</li>
</ol>

To recap,
#block Interpolation Formula
Let $\om_n$ be a primitive $n$-th root of unity.
<br/>
Let $v_0, \dots, v_{n-1}$ $n$ samples, with $v_k = f(\om_n^k)$ for all $0 \leq k < n$.
<br/>
The solution to the $k$-th partial sample set is $a_i = \frac 1nv_k \om_n^{-ik}$ for all $0 \leq i < n$, that is
$$
\begin{align}
f(x) &= \tfrac 1nv_k + \tfrac 1nv_k\om_n^{-k} + \tfrac 1nv_k\om_n^{-2k} + \dots + \tfrac 1nv_k\om_n^{-(n-1)k} \\
     &= \tfrac 1nv_k \left(1 + \om_n^{-k} + \om_n^{-2k} + \dots + \om_n^{-(n-1)k} \right)
\end{align}
$$
By the Additivity of Interpolation, the solution to $a_0, \dots, a_{n-1}$ is the sum of interpolations of all $n$ partial sample sets, that is
$$
\begin{align}
a_0     &= \tfrac1n v_0 + \tfrac1n v_1 + \tfrac1n v_2 + \dots + \tfrac1n v_{n-1} \\
a_1     &= \tfrac1n v_0 + \tfrac1n v_1\om_n^{-k} + \tfrac1n v_2\om_n^{-2k} + \dots + \tfrac1n v_{n-1}\om_n^{-(n-1)k} \\
a_2     &= \tfrac1n v_0 + \tfrac1n v_1\om_n^{-2k} + \tfrac1n v_2\om_n^{-4k} + \dots + \tfrac1n v_{n-1}\om_n^{-2(n-1)k} \\
        &                              \phantom{XXXXXXXXXXXX}\vdots \\
a_{n-1} &= \tfrac1n v_0 + \tfrac1n v_1\om_n^{-(n-1)k} + \tfrac1n v_2\om_n^{-2(n-1)k} + \dots + \tfrac1n v_{n-1}\om_n^{-(n-1)^2k} \\
\end{align}
$$

Pulling out $\frac 1n$ from each term, we get

$$
\begin{align}
a_0     &= \tfrac 1n \left( v_0 +  v_1 +  v_2 + \dots +  v_{n-1} \right) \\
a_1     &= \tfrac 1n \left( v_0 +  v_1\om_n^{-k} +  v_2\om_n^{-2k} + \dots +  v_{n-1}\om_n^{-(n-1)k} \right) \\
a_2     &= \tfrac 1n \left( v_0 +  v_1\om_n^{-2k} +  v_2\om_n^{-4k} + \dots +  v_{n-1}\om_n^{-2(n-1)k} \right) \\
        &                           \phantom{XXXXXXXXXXXX}\vdots \\
a_{n-1} &= \tfrac 1n \left( v_0 +  v_1\om_n^{-(n-1)k} +  v_2\om_n^{-2(n-1)k} + \dots +  v_{n-1}\om_n^{-(n-1)^2k} \right)\\
\end{align}
$$
#end block

Ignoring the factor of $\frac 1n$, this equation looks an awful lot like the sampling problem.
#end section

#section Interpolating Quickly
We can now use the techniques we used to sample quickly to interpolate quickly. Let's pretend the factor of $\frac 1n$ doesn't exist. Then from the previous section, we found that for all $0 \leq k < n$,
$$ a_{k} = v_0 + v_1\om_n^{-k} + v_2\om_n^{-2k} + \dots + v_{n-1}\om_{n-1}^{-(n-1)k} $$
This is almost exactly what we wanted to compute when sampling, except $a_k$ and $v_k$ are swapped and the exponents are negative in this version. In fact, if we define a special polynomial
$$ v(x) = v_0 + v_1x + v_2x^2 + \dots + v_{n-1}x^{n-1} $$

Then we notice that $a_k = f(\om_n^{-k})$, and we want to find $a_k$ for all $0 \leq k < n$, which is a sampling problem.

Using the strategies from sampling quickly, we'll once again define
$$
\begin{align}
v_e(x) &= v_0 + v_2x^2 + \dots + v_{n-2}x^{n-2} \\
v_o(x) &= v_1x + v_3x^3 + \dots + v_{n-1}x^{n-1} \\
\end{align}
$$

It should come as no surprise that if $m = \frac n2$, $v(\om_n^{-k}) = v_e(\om_m^{-k}) + \om_n^{-k}v_o(\om_m^{-k})$, and we can verify this:

$$
\begin{align}
&\phantom{=.} v_e(\om_m^{-k}) + \om_n^{-k}v_o(\om_m^{-k}) \\
&=\mathbb{TODO}
\end{align}
$$

Consequently, we also have the useful formula:
$$
\begin{align}
v(\om_n^{-k})   &= f_e(\om^{-k}_m) + \om^{-k}_n f_o(\om^{-k}_m) \\
v(\om_n^{-k+m}) &= f_e(\om^{-k}_m) - \om^{-k}_nf_o(\om^{-k}_m)
\end{align}
$$
and so we also have a very similar algorithm for interpolating quickly:
#block Interpolating Algorithm
TODO
#end block
#end section

#section Complex Numbers
Now that we know how to sample and interpolate quickly using $n$-th roots of unity, we need to find a number system where these roots of unity exist.

Since for some $n$, we want to find some $\om_n$ that satisfies $\om_n^n = 1$, we can also think of this as solutions to the equation $x^n - 1 = 0$. 

The "regular" numbers such as $42$, $-\frac35$, $\sqrt 2$, and $\pi$ are usually collectively called the <i>real</i> numbers.

In the real numbers, negative numbers cannot have square roots, and we know that equations like $x^2 + 9 = 0$ and $x^2 - 6x + 34 = 0$ have no solutions. The complex numbers solve this problem by extending the real numbers and introducing the <i>imaginary unit</i> $i = \sqrt{-1}$. A multiple of this imaginary unit (e.g. $5i$, which is the square root of $-25$) is called an <i>imaginary number</i>.

If we add a real number and an imaginary number, we get a <i>complex number</i>. Complex numbers come in form of $x + iy$ where $x$ and $y$ are real numbers and $i$ is the imaginary unit.

Now we can solve many more equations. For example, the solutions to $x^2 + 9 = 0$ are $x = 3i$ and $x = -3i$ since
<table style="margin: 0px auto;"><tr>
<td style="width: 30%; margin: 0px auto;">
$$
\begin{align}
&\phantom{=|} (3i)^2 + 9 \\
&= (3)^2(i)^2 + 9 \\
&= (9)(-1) + 9 \\
&= -9 + 9 \\
&= 0 \\
\end{align}
$$
</td>
<td style="width: 30%; margin: 0px auto; text-align: center;">
and
</td>
<td style="width: 30%; margin: 0px auto;">
$$
\begin{align}
&\phantom{=|} (-3i)^2 + 9 \\
&= (-1)^2(3)^2(i)^2 + 9 \\
&= (1)(9)(-1) + 9 \\
&= -9 + 9 \\
&= 0 \\
\end{align}
$$
</td>
</tr></table>

The solutions to $x^2 - 6x + 34$ are $x = 3 + 5i$ and $x = 3 - 5i$ since
<table style="margin: 0px auto;"><tr>
<td style="width: 20%; margin: 0px auto;">
$$
\begin{align}
&\phantom{=|} (3 + 5i)^2 - 6(3 + 5i) + 34 \\
&= 3^2 + 2(3)(5i) + (5i)^2 - (18 + 30i) + 34 \\
&= 9 + 30i + (5)^2(i)^2 - 18 - 30i + 34 \\
&= 9 + 30i + (25)(-1) - 18 - 30i + 34 \\
&= 0
\end{align}
$$
</td>
<td style="width: 10%; margin: 0px auto; text-align: center;">
and
</td>
<td style="width: 20%; margin: 0px auto;">
$$
\begin{align}
&\phantom{=|} (3 - 5i)^2 - 6(3 - 5i) + 34 \\
&= 3^2 - 2(3)(5i) + (5i)^2 - (18 - 30i) + 34 \\
&= 9 - 30i + (5)^2(i)^2 - 18 + 30i + 34 \\
&= 9 - 30i + (25)(-1) - 18 + 30i + 34 \\
&= 0
\end{align}
$$
</td>
</tr></table>

If we plot the real numbers on a number line, centered at $0$ and going off into infinity on the left and right, we can plot the complex numbers by adding a second line at 90 degrees to the number line, intersecting at $0$. This line goes off into infinity to the top and bottom and is centered at $0$ as well. We can then think of complex numbers as coordinate points on a 2D plane where the number $x + iy$ can be thought of as the coordinate point $(x, y)$.

We're particularly interested in one mathematical result:

#block Euler's Formula
Let $(x, y)$ be a point that has a distance $1$ from $(0, 0)$ and makes an angle $\theta$ (in radians) from the standard position (counter-clockwise from the positive $x$-axis).

The complex number $x + iy$ can be computed using $e^{i\theta}$ where $e$ is Euler's constant.
#end block

You might know from trignometry that a point that has a distance $1$ from $(0, 0)$ and makes an angle $\theta$ from the standard position has the coordiante points $(\cos\theta,\sin\theta)$, which corresponds to the complex number $\cos\theta+i\sin\theta$. This is why Euler's Formula is usually written as
$$e^{i\theta} = \cos\theta + i\sin\theta$$

Euler's Formula is important to us because it gives us a suitable candidate for a primitive $n$-th root of unity in the complex numbers, namely $e^{i\frac{2\pi}n}$.

#block Theorem 3
In the complex numbers, $e^{i\frac{2\pi}n}$ is a primitive $n$-th root of unity.

<a href="proof3.html">Proof</a>
#end block
#end section

#section The Integers Modulo A Prime
The second system that allows for $n$-th roots of unity that we'll be looking comes from number theory.

Instead of expanding the real numbers into the complex numbers, this time we're restricting the integers into a smaller, finite collection. We pick a number $n$, and we only allow the integers $0, 1, \dots, n - 2, n - 1$ to exist. If a computation takes us outside of this range, we keep adding or subtracting $n$ until we're back within this range.

For example, if $n = 13$, then the addition $7 + 10$ would take us to $17$ which is outside of the range $0, 1, \dots, 11, 12$. We then subtract $13$ from $17$ to get $4$. Therefore, in this number system and the choice $n = 13$, $7 + 10 = 4$.

Other ways to think about
#end section

// sections:
// Integers modulo p
// Implementation (complex)
// Implementation (complex, improved)
// Implementation (Z/pZ)
// Applications
#end main

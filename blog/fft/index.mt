// TODO normalize phantoms to X's for readability
#site-title A Primitive Guide to FFT
#title A Primitive Guide to FFT
#latex-preamble
$$
\newcommand{\om}{\omega}
$$
#end latex-preamble
#toc

#warning

#main

#section Introduction
In competitive programming, FFT or Fast Fourier Transform is a technique that speeds up polynomial multiplication from $O(n^2)$ to $O(n \log n)$. This is useful because polynomial multiplication can be used to solve a variety of problems.

FFT is a fairly advanced topic, in the sense that it rarely shows up in problemsets, and if it does, it appears in more difficult problems.

While this article uses terms like "Theorem" and "Proof", you should expect its rigorousness to be around that of a high school math class.
#end section

#section Pre-Requisite Knowledge
Required:
<ul>
<li>Time complexity</li>
	<li>Summation ($\sum$) notation</li>
	<li>Divide and conquer</li>
</ul>

Helpful, but not required:
<ul>
	<li>Polynomials</li>
	<li>Complex numbers and trignometry</li>
	<li>Number theory, specifically, properties of $\mathbb Z/p\mathbb Z$</li>
</ul>

This article features code in C++.
#end section

#section Multiplying Polynomials
#block Definition - Polynomial

A polynomial $f(x)$ of degree $n$ is defined as

$$f(x) = a_0 + a_1x + a_2x^2 + \dots + a_nx^n$$


where $a_0, \dots, a_n$ are numbers called coefficients.
#end block

Some definitions for a polynomial also require that $a_n \neq 0$, but we don't. This allows us to "upgrade" polynomials to a higher degree by adding $0x^{n + 1} + 0x^{n + 2} + \dots$ to the end of it.

We can multiply polynomials to get a new polynomial:
$$
\begin{align}
h(x) &= f(x)g(x) \\
     &=(a_0 + a_1x + \dots + a_nx^n)(b_0 + b_1x + \dots + b_nx^n) \\
     &= \sum_{i = 0}^n \sum_{j = 0}^n a_ib_jx^{i+j}
\end{align}
$$

If we want to find the $k$-th coefficient of $h(x)$, denoted as $c_k$, we can rearrange the formula to get
$$ c_k = \sum_{i = 0}^k a_ib_{k - i} $$

Applying the formula directly, we need to add $k$ terms to compute $c_k$. To compute all coefficients, the time required is $O(n^2)$. If we avoid this direct formula, we can achieve $O(n \log n)$ using FFT.
#end section

#section Algorithm Overview
We now describe the steps in the $O(n \log n)$ way to multiply polynomials.

Let $f(x)$ and $g(x)$ be two polynomials, both with $n$ coefficients, that is, with degree $n - 1$.

<ol>
	<li>Pick $2n$ numbers $s_0, \dots, s_{2n - 1}$ as <b>sampling points</b>.
	<li>Compute $f(s_0), \dots, f(s_{2n - 1})$ and $g(s_0), \dots, g(s_{2n - 1})$ in $O(n \log n)$ time. These values are called <b>samples</b>. </li>
	<li>Compute $v_0 = f(s_0)g(s_0), \dots, v_{2n - 1} = f(s_{2n - 1})g(s_{2n - 1})$. This takes $O(n)$ time.
	<li>Find the unique polynomial $h(x)$ of degree $2n - 1$ that satisfies $h(s_0) = v_0, \dots h(s_{2n - 1}) = v_{2n - 1}$ in $O(n \log n)$ time. At this point, $h(x)$ is guaranteed to be $f(x)g(x)$ and we're done.
</ol>

The hard parts are Step 2 and Step 4. Step 2 is also called the <b>sampling</b> problem and Step 4 is also called the <b>interpolating</b> problem.
#end section

#section Picking Sampling Points
We can pick whichever sampling points $s_0, \dots, s_{2n-1}$ we want. The numbers with the best properties to do this in 
#end section 

#section Sampling
Our first problem is sampling. Suppose $f(x) = a_0 + a_1x + \dots + a_{n-1}x^{n-1}$ is a polynomial with $n$ coefficients (and therefore degree $n$).
#end section

#section Sampling and Interpolating
Let's say $f(x) = a_0 + a_1x + a_2x^2$ is a second degree polynomial. We don't know it's coefficients, but we know that $f(1) = 123$ and $f(3) = 456$. Is this enough to determine that $f(x)$ is? What if we also knew that $f(4) = 789$? There is a general result related to this:

#block Theorem 1: Uniqueness of Interpolation
Let $f(x)$ be a polynomial with degree $n$ whose coefficients $a_0, \dots, a_n$ are unknown.

For any choice of $n + 1$ distinct numbers $s_0, \dots, s_n$, if we know $f(s_0), \dots, f(s_n)$, then uniquely determine $a_0, \dots, a_n$.

<a href="proof1.html">Proof</a>
#end block

Let's call the choice of distinct numbers $s_0, \dots, s_n$ <b>sampling points</b> and the values of $f(s_0), \dots f(s_n)$ <b>samples</b>. The polynomial that satisfies the samples is said to <b>interpolate</b> the samples.
#end section

#section Trying to Sample Quickly
For some polynomial of degree $n - 1$, let's try to quickly find $n$ samples, that is, pick some $s_0, \dots, s_{k-1}$ and calculate $f(s_0), \dots, f(s_{n-1})$. For now, we'll also require:
<ul>
	<li>The number of samples is one more than the degree of the polynomial</li>
	<li>$n$ is a power of 2</li>
</ul>
We'll see later that this limited form can generalize pretty easily.

As an example, we'll try $n = 2$ and $s_0 = 1, s_1 = -1$. That is, we want to compute $f(1)$ and $f(-1)$.

We can see that $f(1) = a_0 + a_1 + a_2 + \dots + a_{n-1}$, which is a just the sum of coefficients. However, $f(-1) = a_0 - a_1 + a_2 - \dots + a_{n-1}$, which is the altenating sum of coefficients.

If we separate the coefficients that we add from the ones we subtract in the calculation $f(-1)$, we can split $f(x)$ into two polynomials: the even degree-terms and the odd-degree terms. For simplicity, we assume that $n$ is an even number.
$$
\begin{align}
	f_{even}(x) &= a_0 + a_2 + \dots + a_{n - 2} \\
	f_{odd}(x) &= a_1 + a_3 + \dots + a_{n - 1}
\end{align}
$$

With these definitions, we can write two equalities:
$$
\begin{align}
	f(1) &= f_{even}(1) + f_{odd}(1) \\
	f(-1) &= f_{even}(1) - f_{odd}(1)
\end{align}
$$

We've basically converted our original problem of calculating $f(1)$ and $f(-1)$ into two smaller problems: finding $f_{even}(1)$ and $f_{odd}(1)$ at a cost of $O(n)$ for combining the results. We notice that the two smaller problems have both half the size of the polynomial and half the number samples required. If you're familiar with divide and conquer (e.g. mergesort), we've split the problem into two versions that are half the size at a cost of $O(n)$. This yields a total time complexity of $O(n \log n)$.

But wait, we've only described a strategy for finding two samples. How can we scale this up to any number of samples? Before we do this, let's try to handle 4 samples. The reason why the above formulas work is because $(-1)^k$ is equal to $1$ for even $k$ and equal to $-1$ for odd $k$. If we wanted to extend this strategy, we'd have to find a number whose square is $-1$.

There is a number 
#end section

#section Primitive Roots of Unity

In general, we want an $n$-th root of the number $1$. This is called an $n$-th root of unity. This isn't too useful since 1

#block Definition - Roots of Unity and Primitivity
Let $n$ be a positive integer.
A number $\om_n$ is said to be an <b>n-th root of unity</b> if $\om_n^n =1 $.
In addition, a $n$-th root of unity $\om_n$ is said to be <b>primitive</b> if for all $0 < k < n$, $\om_n^k \neq 1$.
#end block

If we're using the real numbers, these don't exist for $n > 2$. That's not really a problem since we can just choose a number system where they do. For now, let's look at the properties of the numbers.

#block Theorem 2: Properties of Primitive Roots of Unity
Let $n$ be an even number, and $\om_n$ be a primitive $n$-th root of unity.
<div>
	<b>Theorem 2.1:</b> For all $0 < k < n$, the values of $\om_n^k$ are distinct $n$-th roots of unity.
</div>
<div style="margin: 5px 0px 7px 0px">
	<b>Theorem 2.2:</b> $\om_{n}^{n/2} = -1$.
</div>
<div>
	<b>Theorem 2.3:</b>
	<ol style="margin: 10px 2px 0px 2px">
		<li>$\om_n^2$ is an $n/2$-th root of unity. Let's call it $\om_{n/2}$.</li>
		<li>For all $0 < k < n$, $(\om_n^k)^2 = \om_{n/2}^k$</li>
		<li>For all $0 < k < n$, $(\om_n^{k + {n/2}})^2 = \om_{n/2}^k$</li>
	</ol>
</div>
<div>
<b>Theorem 2.4:</b> $\om_n^0 + \om_n^1 + \om_n^{2} + \dots + \om_n^{n-1} = 0$.
</div>

<div style="margin-top: 10px">
	<a href="proof2.html">Proof</a>
</div>
#end block

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
Now that we know how to sample and interpolate quickly using primitive $n$-th roots of unity, we need to find a number system where these primitive roots of unity exist.

For some given $n$, we want to find some $\om_n$ that satisfies $\om_n^n = 1$. This is equivalent to finding the solutions to the polynomial $x^n = 1$. We know from the Fundamental Theorem of Algebra that every polynomial of degree $n$ has exactly $n$ solutions, which is a good sign. We're also hoping that at least one of these solutions gives us a <i>primitive</i> $n$-th root of unity.

Using the Fundamental Theorem of Algebra on the polynomial $x^4 = 1$, we expect $4$ solutions for $x$, but we know that there are only two possible: $1$ and $-1$, so where are the other solutions?

It turns out the Fundamental Theorem of Algebra only works if we extend the regular numbers. Let's introduce a new number $i$ which is equal to $\sqrt{-1}$. Using regular numbers, the square root of any negative number doesn't exist, but allowing them to exist gives us interesting and useful properties.

For one, now we have $4$ solutions to the polynomial $x^4 = 1$. The solutions are $1$, $-1$, $i$, and $-i$. To verify this, we first note that since by definition $i = \sqrt{-1}, i^2 = -1$. Now, to verify that $i^4 = 1$, we show:
$$i^4 = (i^2)^2 = (-1)^2 = 1$$
Next, we verify that $(-i)^4 = 1$:
$$(-i)^4 = (-1)^4(i)^4 = (1)(1) = 1$$
In particular, $i$ is a primitive $4$-th root of unity since for all $0 < k < 4$, $i^k \neq 1$. We can verify these manually: $i^1 = i$, $i^2 = -1$, and $i^3 = (i^2)(i) = -i$. As a bonus, $-i$ is also a primitive $4$-th root of unity.

We can also mix regular numbers with multiples of $i$. For example, we can have the number $5 + 3i$ or $2.5 - \sqrt2 i$. These numbers are called <b>complex numbers</b>. This representation is important since all numbers involving $i$ in any way can be expresseed by $a + bi$ where $a$ and $b$ are regular numbers. For example, $7^{3i} \approx 0.9024 - 0.431i$.

In the complex numbers, we can guarantee $n$ solutions to the polynomial $x^n = 1$. 

For example, the $3$ solutions to $x^3 = 1$ are $1$, $\left(-\frac12 + \frac{\sqrt3}2i\right)$, and $\left(-\frac12 - \frac{\sqrt3}2i\right)$. We can verify that $\left(-\frac12 + \frac{\sqrt3}2i\right)^3 = 1$ by expanding using the Binomial Theorem:
$$
\begin{align}
&\phantom{=|} \left(-\frac12 + \frac{\sqrt3}2i\right)^3 \\ 
&= \left(-\frac 12\right)^3 + 3\left(-\frac 12\right)^2\left(\frac{\sqrt3}{2}i\right) + 3\left(-\frac 12\right)\left(\frac{\sqrt3}{2}i\right)^2 + \left(\frac{\sqrt3}2i\right)^3 \\
&= \left(-\frac 12\right)^3  + 3\left(-\frac12\right)^2\left(\frac{\sqrt3}2\right)i +
3\left(-\frac12\right)\left(\frac{\sqrt3}{2}\right)^2i^2 + \left(\frac{\sqrt3}{2}\right)^3i^3 \\
&= -\frac 18 + 3\left(\frac14\right)\left(\frac{\sqrt3}2\right)i +
3\left(-\frac12\right)\left(\frac 34\right)(-1) + \left(\frac{3\sqrt3}{8}\right)(-i) \\
&= -\frac18 + \frac{3\sqrt3}8i + \frac{9}{8} - \frac{3\sqrt3}8i \\
&= -\frac18 + \frac98 \\
&= 1
\end{align}
$$

The verification that $\left(-\frac12 - \frac{\sqrt3}2i\right)^3 = 1$ works pretty similarly. Also, both $-\frac12 + \frac{\sqrt3}2i$ and $-\frac12 - \frac{\sqrt3}2i$ are primitive third roots of unity.

In general, for all $n > 0$, we can find $n$ solutions to $x^n = 1$ and at least one of the solutions is a primitive $n$-th root of unity. To find the solutions and the primitive $n$-th root of unity, we can use the following theorem:

#block Theorem 4 - Complex Roots of Unity
For all integers $n > 0$, the solutions to the polynomial $x^n = 1$ are

$$\cos \theta + i \sin\theta $$ 

For all angles $\theta$ (in radians)
$$0, \frac{2\pi}{n}, \frac{4\pi}n, \frac{6\pi}n, \dots, \frac{(n-1)2\pi}n$$

In particular, for $\theta = \frac{2\pi}{n}$, ie. the number $\cos\left(\frac{2\pi}{n}\right) + i\sin\left(\frac{2\pi}{n}\right)$ is a primitive $n$-th root of unity.

<a href="proof4.html">Proof</a>
#end block
#end section

#section Implementation - Complex Numbers
Now that we have all the tools we need, let's look at how to construct the actual code to perform the polynomial multiplication. Here's a quick recap of how we'll handle the polynomials:

#block Summary of the Full Algorithm
Let $f(x) = a_0 + \dots + a_nx^n$ be a polynomial of degree $n$ and $g(x) = b_0 + \dots + b_mx^m$ be a polynomial of degree $m$. We wish to calculate $h(x) = f(x)g(x) = c_0 + \dots + c_{n + m}x^{n + m}$.
<ol>
	<li>Let $N$ be the smallest power of 2 that is greater or equal to $\max(n - 1, m - 1)$. We upgrade the degrees of $f(x)$ and $g(x)$ to degree $2N - 1$ by padding the higher degrees with zeroes.</li>
	<li>Choose $\om = \cos\left(\frac{2\pi}{2N}\right) + i\sin\left(\frac{2\pi}{2N}\right)$ to be the primitive $2N$-th root of unity.</li>
	<li>Using the above recursive strategy, sample both $f(x)$ and $g(x)$ at the roots of unity, calculating $f(1), f(\om), f(\om^2), \dots, f(\om^{N - 1})$ and $g(1), g(\om), g(\om^2), \dots, g(\om^{N - 1})$.</li>
	<li>Calculate $h(1) = f(1)g(1),\ \ h(\om) = f(\om)g(\om),\ \ h(\om^2) = f(\om^2)g(\om^2), \dots, h(\om^{N - 1}) = f(\om^{N - 1})g(\om^{N - 1})$</li>
	<li>Using the above strategy, interpolate the samples for $h(1), \dots, h(\om^{N - 1})$ to recover $h(x) = c_0 + \dots + c_{2N - 1}x^{2N - 1}$</li>
	<li>Remove the extra zeroes from the end of the polynomial to get $h(x) = c_0 + \dots c_{n + m}x^{n + m}$</li>
</ol>
#end block


#end section

#section The Integers Modulo A Prime Number
In the previous section, we saw a number system where $n$-th roots of unity exist by extending the regular numbers to include $i$, the square root of $-1$. In this section, we'll instead use <i>the integers modulo $p$</i>, number system with $n$-th roots of unity by restricting the integers.

To explain this system,  let's look at a real-wrold example. In military the 24 hours in a day are labelled from $0$ to $23$, where Hour $0$ is midnight. If the time right now is Hour $19$, then $9$ hours later, it'll be Hour $4$ (on the next day). We know it'll be Hour $4$ because $19 + 9 = 28$ but there are only $24$ hours in a day, so we subtract $24$ hours and we know that it must be Hour $4$ on the next day. Using similar logic, if it's Hour $3$, then $10$ hours ago, it was $17$ (on the previous day).

The general strategy when adding or subtracting hours together is add them regularly like numbers, then add or subtract multiples of $24$ until the number is between $0$ and $23$ inclusive. The integers modulo $24$ work the exact same way, except we also allow the multiplication of numbers. With multiplication, we also multiply the numbers normally, but we make sure to add or subtract mutiples of $24$ until the number is between $0$ and $23$ inclusive. For example, $6 \times 7 = 18$ since $6 \times 7$ is regularly $42$, but it's not between $0$ and $23$, so we subtract $24$ to get $18$, which is between $0$ and $23$.

In general for all $n > 0$, the integers modulo $n$ is a number system where we apply the rules above, except with any number $n$. In particular, we do every math operation as usual except if the number isn't between $0$ and $n - 1$ inclusive, we add or subtract a multiple of $n$ so that it is. Also, since operations work differently in the integers modulo $n$ than in regular numbers, we should use the triple equals $\equiv$ to show that we aren't using regular numbers and $(\text{mod } n)$ to show which $n$ we are using. For example, we write that $6 \times 7 \equiv 18 \pmod{24}$ to communicate the example above: in the integers modulo $24$, $6$ times $7$ is $18$.

In particular, if our choice of $n$ is a prime number, then we can also call the system "the integers modulo $p$". The reason why we give a different name for when $n$ is a prime number is because a lot of interesting properties arise. If $n = 7$, let's look at the exponents of each number:

<style> table{ border-collapse: collapse; margin: 0px auto; } th, td{ padding: 5px 10px 5px 10px; border: 1px solid black; text-align: center; } .th2 { background-color: #EED3AA; } th { font-weight: normal; background-color: #F3DEBE; } </style>

<table>
	<tr>
		<td style="border-width: 0px;"></td>
		<th class="th2" colspan="7">$b$</td>
	</tr>
	<tr>
		<th class="th2" rowspan="7">$a$</td>
		<th>$a^b$</td>
		<th>1</th>
		<th>2</th>
		<th>3</th>
		<th>4</th>
		<th>5</th>
		<th>6</th>
	</tr>
	<tr>
		<th>1</th>
		<td>1</td>
		<td>1</td>
		<td>1</td>
		<td>1</td>
		<td>1</td>
		<td>1</td>
	</tr>
	<tr>
		<th>2</th>
		<td>2</td>
		<td>4</td>
		<td>1</td>
		<td>2</td>
		<td>4</td>
		<td>1</td>
	</tr>
	<tr>
		<th>3</th>
		<td>3</td>
		<td>2</td>
		<td>6</td>
		<td>4</td>
		<td>5</td>
		<td>1</td>
	</tr>
	<tr>
		<th>4</th>
		<td>4</td>
		<td>2</td>
		<td>1</td>
		<td>4</td>
		<td>2</td>
		<td>1</td>
	</tr>
	<tr>
		<th>5</th>
		<td>5</td>
		<td>4</td>
		<td>6</td>
		<td>2</td>
		<td>3</td>
		<td>1</td>
	</tr>
	<tr>
		<th>6</th>
		<td>6</td>
		<td>1</td>
		<td>6</td>
		<td>1</td>
		<td>6</td>
		<td>1</td>
	</tr>
</table>

The way we should read this table is that excluding the darker header cells, the $a$-th row and $b$-th column gives $a^b \pmod 7$.

There are some observations we can make from the table:
<ol>
	<li>There are no zeroes</li>
	<li>The sixth column is filled with ones</li>
	<li>The third and fifth column cycle through all the numbers from $1$ to $6$</li>
</ol>

Observation 2 tells us that all numbers from $1$ to $6$ to the sixth power is $1$, which means these numbers are all sixth roots of unity.

Observation 3 tells us that $3$ and $5$ are primitive sixth roots of unity since for all $0 < k < 6$, $3^k$ and $5^k$ aren't equal to $1$.

In fact, similar results are guaranteed for the integers modulo $p$, where $p$ is any prime number.

#block Theorem 5 - Roots of Unity in the Integers Modulo p
<ol>
	<li>In the integers modulo $p$, where $p$ is any prime number, for all $0 < a < p$, $a$ is a $(p - 1)$-th root of unity.</li>
	<li>There's at least one number $0 < b < p$ such that $b$ is a <i>primitive</i> $(p - 1)$-th root of unity.</li>
</ol>

<a href="proof5.html">Proof</a>
#end block

Unfortunately, unlike with the complex numbers, there's no easy way to find a primitive $(p - 1)$-th root of unity. There is a more involved way, but we'll come back to this later.

In the previous sections, we found that sampling and interpolating is best done when the input size is a power of $2$ and that we use $2^k$-th roots of unity. By the theorem above, a prime number $p$ guarnatees a primitive $(p - 1)$-th root of unity for any prime number, so if we find a prime number of the form $2^k + 1$, we can get a primitve $2^k$-th root of unity, which is what we need.

However, we currently know a total of $5$ prime numbers of the $2^k + 1$: $3$, $5$, $17$, $257$, and $65537$. These are far too small since problems requiring the multiplication of polynomials in $O(N \log N)$ will often have the degree be at least $100\ 000$. 

To get around this, we relax the requirement to have a prime number be the form of $c \cdot 2^k + 1$ where $c$ is any odd integer. There are many primes of this form, but for this article, we'll use $p = 3 \cdot 2^{30} + 1 = 3221225473$. Since $p < 2^{32}$, this will allow us to use unsigned 64-bit integers without the possibility of integer overflow.

However, we're guaranteed a primitive $(p - 1)$-th root of unity, and in this case, $p - 1$ is $3 \cdot 2^{30}$, but what we really wanted was a $2^{30}$-th root of unity. Thankfully, there's an easy way to recover the root of unity we want.

#block Theorem 6 - Converting Primitive Roots of Unity
Let $p$ be a prime of the form $c \cdot 2^k + 1$ and $\om$ be a primitive $(p - 1)$-th root of unity in the integers modulo $p$.

$\om^c$ is a primitive $2^k$-th root of unity in the integers modulo $p$.

<a href="proof6.html">Proof</a>
#end block
#end section

// sections:
// Implementation (complex)
// Implementation (complex, improved)
// Other improvements
// Implementation (Z/pZ)
// Variants
// Applications
#end main

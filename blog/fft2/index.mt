// global notes:
// sometimes I use the word "function" but I should be using "polynomial"
// finding g_t(x) needs to be a little better motivated (e.g. say we want to "force" something)
// maybe change some \dots to \cdots

#site-title A Primitive Guide to FFT
#title A Primitive Guide to the Fast Fourier Transform
#latex-preamble
$$
\newcommand{\om}{\omega}
\newcommand{\up}{\upsilon}
\newcommand{\odd}{_{\text{odd}}}
\newcommand{\even}{_{\text{even}}}
$$
#end latex-preamble
#toc


#main

#section Introduction
In the context of competitive programming, the Fast Fourier Transform, or FFT, is a technique that speeds up polynomial multiplication from $O(n^2)$ to $O(n \log n)$. As the name suggests, this technique has to do with the Fourier Transform, which is a beautiful concept at the intersection of many fields of math. Thankfully, as competitive programmers, we can skip over most of this math.
#end section

#section Prerequisite Knowledge
You should be familiar with:
<ul>
<li>Time complexity</li>
	<li>Divide and conquer</li>
	<li>Polynomials</li>
	<li>Binary numbers and bitmasks</li>
</ul>

Knowledge of the these may help, but isn't required:
<ul>
	<li>Complex numbers and trigonometry</li>
	<li>Number theory, specifically, properties of $\mathbb Z/p\mathbb Z$</li>
</ul>

These topics are specifically avoided:
<ul>
	<li>Linear algebra</li>
	<li>Vandermonde Matrix</li>
</ul>

This article features code in C++.
#end section

// do we want a motivating example here?

#part Part 1: The Algorithm

#section Multiplying Polynomials
The goal of this article is describing how to quickly multiply polynomials, so we better define what a polynomial is first.


#block Definition - Polynomial
A polynomial $f(x)$ of degree $n$ is defined as
$$f(x) = a_0 + a_1x + a_2x^2 + \dots + a_nx^n$$
where $a_0, \dots, a_n$ are numbers called coefficients.
#end block

Most definitions will also require that $a_n \neq 0$, but we won't have that restriction. This means that we can "upgrade" a polynomial of degree $n$ to degree $n + m$ by adding $0x^{n + 1} + 0x^{n + 2} \dots + 0x^{n + m}$ to the end of the polynomial.

Polynomials can be nicely represented in code as arrays. For convenience, we'll now focus on polynomials of degree $n - 1$, since a polynomial $f(x) = a_0 + a_1 + \dots + a_{n-1}x^{n-1}$ can be represented in the size $n$ array $\text{arr} = [a_0, a_1, \dots, a_{n-1}]$. We'll also say the <i>size</i> of a polynomial is the size of the array representation, which is the degree plus one.

We can also multiply polynomials. Suppose $f(x) = a_0 + a_1x + a_2x^2$ and $g(x) = b_0 + b_1x + b_2x^2$, then
$$
\begin{align}
f(x) \times g(x) &= (a_0 + a_1x + a_2x^2)(b_0 + b_1x + b_2x^2) \\
&= a_0(b_0 + b_1x + b_2x^2) + a_1x(b_0 + b_1x + b_2x^2) + a_2x^2(b_0 + b_1x + b_2x^2) \\
&= a_0b_0 + a_0b_1x + a_0b_2x^2 + a_1b_0x + a_1b_1x^2 + a_1b_2x^3 + a_2b_0x^2 + a_2b_1x^3 + a_2b_2x^4 \\
&= (a_0b_0) + (a_0b_1 + a_1b_0)x + (a_0b_2 + a_1b_1 + a_2b_0)x^2 + (a_1b_2 + a_2b_1)x^3 + (a_2b_2)x^4
\end{align}
$$

If we think of a function $\text{Multiply}$ that takes in two arrays, each representing a polynomial, then we rewrite the example above as
$$\text{Multiply}( [a_0, b_1, a_2], [b_0, b_1, b_2] ) = [a_0b_0, a_0b_1 + a_1b_0, a_0b_2 + a_1b_1 + a_2b_0, a_1b_2 + a_2b_1, a_2b_2]$$

We note that even though size 
#end section

#section Algorithm Overview
Instead of multiplying polynomials directly, which will take us $O(n^2)$ time, we're going to take a roundabout route instead. Again, we want to multiply two polynomials $f(x)$ and $g(x)$, both size $n$.

<ol id="multlist">
	<li>Pick $m$ numbers numbers $s_0, s_1, \dots, s_{m-1}$. We'll call these <i>sampling points</i>.</li>
	<li>Evaluate $f(x)$ and $g(x)$ at all the sampling points. In other words, calculate $f(s_0), \dots, f(s_{m-1})$ and $g(s_0), \dots, f(s_{m-1})$. We'll call these value <i>samples</i>, and this step is called<i> sampling</i>.</li>
	<li>Multiply the samples together, computing $f(s_0)g(s_0), f(s_1)g(s_1), \dots, f(s_{m-1})g(s_{m-1})$. Also, lets call these values $v_0, v_1, \dots, v_{m-1}$. This step is also sometimes called <i>pointwise multiplication</i></li>
	<li>Find a polynomial $h(x)$ such that $h(s_k) = v_k$ for all $0 \leq k < m$. In other words, find a polynomial $h(x)$ and $f(x)g(x)$ that agree on all $m$ sampling points. This step is called <i>interpolation</i>.</li>
</ol>

This seems like a complicated way to do things, and we're not even sure if it works. Will $h(x) = f(x)g(x)$ just because they agree on the $m$ sampling points? More importantly, if it's possible, how can we choose an $m$ such that we can guarantee that $h(x)$ will equal $f(x)g(x)$?

The answer is surprisingly simple:

#block Uniqueness of Interpretation
Consider a polynomial $f(x)$. We know that it has size $n$ and therefore degree $n - 1$, but we do not know what it is.

If we have $n$ samples, that is, we know $f(s_k) = v_k$ for $0 \leq k < n$, for any choice of $s_0, \dots, s_n$, there is exactly one $f(x)$ that satisfy these equalities, which means we can determine $f(x)$.

<a href="#">Proof</a>
#end block

Since $f(x)$ and $g(x)$ are both degree $n - 1$ polynomials, $h(x) = f(x)g(x)$ has degree $2n - 2$ and therefore size $2n - 1$. Therefore, we only need $2n - 1$ samples to recreate $h(x)$. For the sake of convenience, we're going to be using $2n$ samples.

Now let's look at our refined algorithm, which is the same thing but with $2n$ instead of $m$:

#block Algorithm Overview
<ol id="multlist">
	<li>Pick $m$ numbers numbers $s_0, s_1, \dots, s_{2n-1}$ called <i>sampling points</i>.</li>
	<li>Evaluate $f(x)$ and $g(x)$ at all the sampling points. These values are called <i>samples</i></li>
	<li>Multiply the samples together, computing $f(s_0)g(s_0), f(s_1)g(s_1), \dots, f(s_{2n-1})g(s_{2n-1})$. Also, lets call these values $v_0, v_1, \dots, v_{2n-1}$.</li>
	<li>Find a polynomial $h(x)$ such that $h(s_k) = v_k$ for all $0 \leq k < m$. In other words, <i>interpolate</i> $h(x)$ from the samples.</li>
	<li>Based on the Uniqueness of Interpolation, we know that $h(x)$ must equal $f(x)g(x)$.</li>
</ol>
#end block

Let's briefly talk about a couple of these steps:

<ul>
	<li>Step 3, pointwise multiplication, is easy and can be done in $O(n)$ with just a loop over the $2n$ pairs of samples.</li>
	<li>Step 2, sampling, can be done in $O(n^2)$ easily since there are $n$ terms in $f(x)$ and $g(x)$ each, and each need to be evaluated at $2n$ sampling points. We aim to lower this down to $O(n \log n)$</li>
	<li>Step 4, interpolating, doesn't seem to have an easy algorithm in any time complexity. However, if we choose our sampling points wisely, we'll find that it's just as easy as sampling, and we can also do it in $O(n \log n)$.
</ul>

If we can somehow get Step 2 and Step 4 (sampling and interpolating) both down to $O(n \log n)$, we'll be able to multiply polynomials in $O(n \log n)$. But first, let's choose some nice sampling points.

#end section

#section The Roots of Unity
We get to choose what sampling points to use, so we better choose points that give us some nice properties to work with. We introduce the Roots of Unity.

#block Definition: Roots of Unity
Let $n$ be a positive integer. A number $\om$ is a $n$-th root of unity if $\om^n = 1$.
In addition, $\om$ is a <i>primitive</i> $n$-th root of unity if for all $0 < k < n$, $\om^k \neq 1$.
#end block

If you're familiar with the complex numbers or the integers modulo $p$, you might know some numbers that would satisfy the definition.  In the real numbers, there aren't any primitive $n$-th roots of unity for $n > 2$, but I promise these numbers are real even if they're not real numbers.

For now, let's assume that for any $n > 0$, there exists a primitive $n$-th root of unity. Just by the definition above, we can derive important properties.

#block Property 1

Let $\om$ be a primitive $n$-th root of unity.

 <b>Property 1.1:</b> $\om^0, \om^1, \om^2, \dots, \om^{n-1}$ are all distinct numbers, each of which are themselves $n$-th roots of unity.

 <b>Property 1.2:</b> $\om^0, \om^{-1}, \om^{-2}, \dots, \om^{-(n-1)}$ are also all the same distinct $n$-th roots of unity (but in a different order).

<a href="#">Proof</a>
#end block

This means that if we can find a primitive $n$-th root of unity, it gives us $n$ different $n$-th roots of unity (not necessarily primitive). So from now on, if $\om$ is a primitive $n$-th root of unity, we'll call $\om^0, \om^1, \dots, \om^{n-1}$ "the $n$ roots of unity".

Let's now look at properties to do with the squares of these numbers:

#block Property 2
Let $n$ be an even number and $\om$ be a primitive $n$-th root of unity. Let $\up = \om^2$.

 <b>Property 2.1:</b> $\om^{\frac n2} = -1$.

 <b>Property 2.2:</b> $\up$ is a primitive $\frac n2$-th root of unity.

 <b>Property 2.3:</b> For $0 \leq k < n$, $(\om^k)^2 = \up^k$. In particular, $\om^0, \om^1, \dots, \om^{n-1} = \up^0, \up^1, \dots, \up^{\frac n2 - 1}, \up^0, \up^1, \dots, \up^{\frac n2 - 1}$.

<a href="#">Proof</a>
#end block

Property 2.3 is quite interesting. In words, it means that if you square all the $n$ powers of $\om$ (from $0$ to $n - 1$), you get the $\frac n2$ powers of $\up$, but repeated twice. Onto the last property:

#block Property 3
Let $\om$ be a primitive $n$-th root of unity and $n > 1$.

 <b>Property 3.1:</b> If $k$ is multiple of $n$, then $\om^0 + \om^k + \om^{2k} + \dots + \om^{(n - 1)k} = n$.

 <b>Property 3.2:</b> If $k$ is multiple of $n$, then $\om^0 + \om^k + \om^{2k} + \dots + \om^{(n - 1)k} = 0$.

We can combine Property 3.1 and 3.2 succinctly as
$\om^0 + \om^k + \om^{2k} + \dots + \om^{(n - 1)k} = \begin{cases} n & \text{ if } k \equiv 0 \pmod n \\ 0 & \text{ if } k \not\equiv 0 \pmod n \end{cases}$

<a href="#">Proof</a>
#end block

Property 3.1 is not surprising at all. If $k$ is some multiple of $n$, then $\om^k = \om^{an}$ for some $a$, and $\om^{an} = (\om^n)^a = 1^a = 1$. Therefore $\om^0 + \om^k + \om^{2k} + \dots + \om^{(n - 1)k}$ = $1^0 + 1^1 + 1^2 + \dots + 1^{n-1} = n$.

On the other hand, Property 3.2 is surprising. One basic consequence is that setting $k = 1$, the sum of the $n$ roots of unity is 0. We won't get to applying this fact until the interpolation section, so don't worry too much about it for now.
#end section

#section Sampling Quickly

In this section, we'll discuss how to sample a polynomial in $O(n \log n)$. We'll be solving a specific version of this problem:

#block Sampling Problem
Given a polynomial $f(x)$ of size $n$, where $n$ is a power of two, compute $f(\om^0), f(\om^1), \dots, f(\om^{n-1})$, where $\om$ is a primitive $n$-th root of unity.
#end block 

We note that in this version, the number of coefficients of $f(x)$ equals the number of samples, and that this number must be a power of two. We'll discuss at the end of this section what to do if either of these conditions aren't met.

To achieve a time complexity of $O(n \log n)$, we're using a divide and conquer algorithm. Those familiar with divide and conquer might think of dividing $f(x)$ into two polynomials: one with the first $\frac n2$ coefficients and one with the last $\frac n2$, but we're going to be doing something different. We're instead going to split $f(x) = a_0 + \dots + a_{n-1}x^{n-1}$ into $f\even(x) = a_0 + a_2x + a_4x^2 + \dots + a_{n-2}x^{\frac n2 - 1}$ and $f\odd(x) = a_1 + a_3x + a_5x^2 + \dots + a_{n-1}x^{\frac n2 - 1}$. This gives us the following property:

#block Even-Odd Property
$$f(x) = f\even(x^2) + xf\odd(x^2)$$

<a href="#">Proof</a>
#end block

Applying this property to the sampling points $\om^0, \dots, \om^{n-1}$, we get that for all $0 \leq k < n$,
$$
\begin{align}
	f(x) &= f\even(x^2) + xf\odd(x^2) \\
	f(\om^k) &= f\even((\om^k)^2) + \om^k f\odd((\om^k)^2) \\
	&= f\even(\up^k) + \om^k f\odd(\up^k) \phantom{XXXX} \text{ where } \up = \om^2
\end{align}
$$

The last line in the equations above comes directly from Property 2.3 of roots of unity. Property 2.2 also tells us that $\up$ itself is a primitive $\frac n2$-th root of unity. Now we have a way to divide our problem in two subproblems and recombine their results to answer the problem.

#block Sampling Algorithm
We have an function $\text{Sample}$ that takes in $f(x) = a_0 + \dots + a_{n-1}x^{n-1}$ in the form of an array $[a_0, \dots, a_{n-1}]$ and a primitive $n$-th root of unity $\om$, and outputs the array of samples $[f(\om^0), \dots, f(\om^{n-1})]$. The algorithm is as follows:

<ol id="alglist">
	<li>Base case: If $n = 1$, then there's only one coefficient and $f(x) = a_0$, so we just return $[a_0]$.
	<li>Divide the array $[a_0, \dots, a_{n-1}]$ into $[a_0, a_2, \dots, a_{n-2}]$ and $[a_1, a_3, \dots, a_{n-1}]$, representing $f\even(x)$ and $f\odd(x)$.</li>
	<li>Recursively call $\text{Sample}$ on the two new arrays, passing in $\up = \om^2$ as the primitive $\frac n2$-th root of unity.</li>
	<li>The results that we get are the samples $[f\even(\up^0), \dots, f\even(\up^{\frac n2})]$ and $[f\odd(\up^0), \dots, f\odd(\up^{\frac n2})]$.</li>
	<li>Using the above formula, for each $0 \leq k < n$, compute $f(\om^k) =f\even(\up^k) + \om^k f\odd(\up^k)$.</li>
	<li>Return $[f(\om^0), \dots, f(\om^{n-1})]$.</li>
</ol>
#end block

There is one minor implementation issue we need to iron out. In Step 5, where we compute $f(\om^k) = f\even(\up^k) + \om^k f\odd(\up^k)$, $0 \leq k < n$, but 

The time complexity of this algorithm is $O(n \log n)$. This is for the same reason that mergesort is $O(n \log n)$: we split into two subproblems, each of half size, then spend $O(n)$ combining them, making the recursion tree $O(\log n)$ in height and $O(n)$ in width at each level.

Let's now discuss the more general cases:
<ul>
<li>If we wish to have more samples than the size of the polynomial, we can "upgrade" the polynomial by adding zeroes to the end of the array representation, as described in an earlier section.</li>
<li>If we wish to have fewer samples than the size, we can just run the algorithm and then ignore the samples we don't need.</li>
<li>If the number of samples and the size aren't a power of two, we can also "upgrade" the polynomial to the next power of two. This makes the polynomial at most around double size, which means the time complexity is still the same.</li>
</ul>
#end section

#section Interpolation in $O(n^2)$
While the difficulty with sampling in $O(n \log n)$ lies in getting a speedup over $O(n^2)$, it seems really difficult to interpolate, regardless of the time complexity. In this section, we'll discuss how to interpolate in $O(n^2)$. Here is a recap of the interpolation problem, once again with extra restrictions:

#block Interpolation Problem
Given $n$ samples $v_0, \dots, v_{n-1}$, where $n$ is a power of two, find the polynomial $f(x) = a_0 + a_1x + \dots + a_{n-1}x^{n-1}$ that satisfy $f(\om^k) = v_k$ for all $0 \leq k < n$.
#end block

How do you solve a difficult problem? One step at a time, of course. Let's interpolate the samples one at a time. Instead of finding $f(x)$ directly, we're doing to first find $n$ functions, each one satisfying $f(\om^k) = v_k$ for exactly one value of $k$ and equalling $0$ everywhere else. Let's look at a more formal definition:

#block Partial Interpolation Functions
For all $0 \leq t < n$, We define $f_t(x)$ as a function that satisfies $f(\om^k) = \begin{cases} v_k & \text{ if }k = t \\ 0 & \text{ if } k \neq t \end{cases}$
#end block

We note that importantly, since each $f_t(x)$ function interpolates one sample at a time, $f_0(x) + f_1(x) + \dots f_{n-1}(x) = f(x)$. Now how do we find these $f_t(x)$ functions? We note that what we want looks kind of similar to Property 3 of the roots of unity, so let's use it.

// this part is like really poorly motivated

Let's define a special function (actually a family of functions) $g_t(x) = \om^0 + \om^{-t}x + \om^{-2t}x^2 + \dots + \om^{-(n-1)t}x^{n-1}$.

Now if we plug in a root of unity, into $g_t(x)$, we get:

$$
\begin{align}
g_t(\om^k) &= \om^0 + \om^{-t}(\om^k) + \om^{-2t}(\om^{2k}) + \dots + \om^{-(n-1)t}\om^{(n-1)k} \\
\phantom{=} &= \om^0 + \om^{k - t} + \om^{2(k - t)} + \dots + \om^{(n-1)(k-1)}
\end{align}
$$

This is a perfect place to apply Property 3, which tells us that
$$
\begin{align}
g_t(\om^k)&= \om^0 + \om^{k - t} + \om^{2(k - t)} + \dots + \om^{(n-1)(k-1)} \\
&= \begin{cases} n & \text{ if } t - k \equiv 0 \pmod n \\ 0 & \text{ if } t - k \not\equiv 0 \pmod n \end{cases}
\end{align}
$$

Now since $0 \leq t, k < n$, that means $-n < t - k < n$, which means the only time $t - k \equiv 0 \pmod n$ is when $t = k$. In other words, 
$$
\begin{align}
g_t(\om^k) = \begin{cases} n & \text{ if } t = k  \\ 0 & \text{ if } t \neq k  \end{cases}
\end{align}
$$

We're very close to what we want. If we let $f_t(x) = \frac{v_t}n g_t(x)$, then
$$
\begin{align}
f_t(\om^k) = \frac{v_t}n g_t(x) &= \begin{cases} \frac{v_t}n n & \text{ if } t = k  \\ \frac{v_t} n 0 & \text{ if } t \neq k  \end{cases} \\
f_t(\om^k) &= \begin{cases} v_t & \text{ if } t = k  \\ 0 & \text{ if } t \neq k  \end{cases} \\
f_t(\om^k) &= \begin{cases} v_k & \text{ if } t = k  \phantom{XX} \text{ since } t = k, v_t = v_k \\ 0 & \text{ if } t \neq k  \end{cases} 
\end{align}
$$

which is exactly what we wanted. We're almost done, we just have to add all of it together and expand:
$$
\begin{align}
f(x) &= f_0(x) + f_1(x) + \dots + f_{n-1}(x) \\ \\
&= \frac{v_0}n g_0(x) + \frac{v_1}n g_1 (x) + \dots + \frac{v_{n-1}}n g_{n-1}(x) \\ \\
&= \frac 1n \left( v_0 g_0(x) + v_1 g_1(x) + \dots + v_{n-1} g_{n-1}(x) \right) \\ \\ 
&= \frac 1n ((v_0\om^0 + \om^0x + \dots + \om^0x^{n-1}) + v_1(\om^0 + \om^{-1}x + \dots + \om^{-(n-1)}x^{n-1}) + \dots + v_{n-1} (\om^0 + \om^{-(n-1)}x + \dots + \om^{-(n-1)(n-1)}x^{n-1}) ) \\ \\
&= \frac 1n ((v_0\om^0 + \om^0x + \dots + \om^0x^{n-1}) + (v_1\om^0 + v_1\om^{-1}x + \dots + v_1\om^{-(n-1)}x^{n-1}) + \dots + (v_{n-1}\om^0 + v_{n-1}\om^{-(n-1)}x + \dots + v_{n-1}\om^{-(n-1)(n-1)}x^{n-1}) )
\end{align}
$$

This is a very messy formula, but for now, we note that there are $n^2$ terms and each term can be easily calculated in $O(1)$ time, the time complexity for finding $f(x)$ is $O(n^2)$.
#end section

#section Interpolating Quickly
We left the previous section with quite a messy formula, so let's organize them in a table. Also, there's a common multiple of $\frac 1n$ for every term and we're going to completely ignore and multiply everything by $\frac 1n$ only at the very end.

<table style="margin: 0px auto 0px auto;">
<tr>
	<td>$v_0\om^0$</td>
	<td>$v_0\om^0x$</td>
	<td>$v_0\om^0x^2$</td>
	<td>$v_0\om^0x^3$</td>
	<td>$\dots$</td>
	<td>$v_0\om^0x^{n-1}$</td>
</tr>

<tr>
	<td>$v_1\om^0$</td>
	<td>$v_1\om^{-1}x$</td>
	<td>$v_1\om^{-2}x^2$</td>
	<td>$v_1\om^{-3}x^3$</td>
	<td>$\dots$</td>
	<td>$v_1\om^{-(n-1)}x^{n-1}$</td>
</tr>

<tr>
	<td>$v_2\om^0$</td>
	<td>$v_2\om^{-2}x$</td>
	<td>$v_2\om^{-4}x^2$</td>
	<td>$v_2\om^{-6}x^3$</td>
	<td>$\dots$</td>
	<td>$v_2\om^{-2(n-1)}x^{n-1}$</td>
</tr>

<tr>
	<td>$v_3\om^0$</td>
	<td>$v_3\om^{-3}x$</td>
	<td>$v_3\om^{-6}x^2$</td>
	<td>$v_3\om^{-9}x^3$</td>
	<td>$\dots$</td>
	<td>$v_3\om^{-3(n-1)}x^{n-1}$</td>
</tr>

<tr id="dotsrow">
	<td>$\vdots$</td>
	<td>$\vdots$</td>
	<td>$\vdots$</td>
	<td>$\vdots$</td>
	<td>$\ddots$</td>
	<td>$\vdots$</td>
</tr>

<tr>
	<td>$v_{n-1}\om^0$</td>
	<td>$v_{n-1}\om^{-(n-1)}x$</td>
	<td>$v_{n-1}\om^{-2(n-1)}x^2$</td>
	<td>$v_{n-1}\om^{-3(n-1)}x^3$</td>
	<td>$\dots$</td>
	<td>$v_{n-1}\om^{-(n-1)(n-1)}x^{n-1}$</td>
</tr>
</table>

Each row of the table is the expansion of one of the partial functions $f_t(x) = \frac{v_t}n g_t(x)$. If we look at columns instead, we notice that the power of $x$ in a column is the same. This is nice because ultimately we want to compute $f(x) = a_0 + a_1x + \dots + a_{n-1}x^{n-1}$, which in code is represented by an array $[a_0, a_1, \dots, a_n]$. The $k$-th column tells us what terms we need to add up to get the coefficient $a_k$.

Adding up the first column, we get the sum $v_0\om^0 + v_1\om^0 + \dots + v_{n-1}\om^0$. The second column sums up to $(v_0\om^0 + v_1\om^{-1} + \dots + v_{n-1}\om^{-(n-1)})x$, and so on. In particular, sum of elements in the $k$-th column is:

$$(v_0 \om^0 + v_1 \om^{-k} + v_2\om^{-2k} + \dots + v_{n-1}\om^{-(n-1)k})x^k$$

Therefore, if $f(x) = a_0 + a_1x + \dots + a_{n-1}x^{n-1}$,

$$a_k = v_0 \om^0 + v_1 \om^{-k} + v_2\om^{-2k} + \dots + v_{n-1}\om^{-(n-1)k}$$

This looks suspiciously like a sampling problem. In fact, if we define a special function $g(x) = v_0 + v_1x + \dots + v_{n-1}x^{n-1}$, then for all $0 \leq k < n$, we have $a_k = g(\om^{-k})$. This is really nice, since we've just shown that instead of solving the interpolating problem, we can just solve a modified version the sampling problem again.

The only difference is that unlike in the Sampling section, where we wanted $f(\om^0), f(\om^1)\, \dots, f(\om^{n-1})$, we now want $g(\om^0), g(\om^{-1}), \dots, g(\om^{-(n-1)})$. Also, we need to multiply back the $\frac 1n$ (or divide by $n$) at the end. Since from Property 1, the numbers $\om^0, \om^{-1}, \dots, \om^{-(n-1)}$ are the same as $\om^0, \om^1, \dots, \om^{n-1}$, just in a different order, Property 2 will hold just the same.

Let's look at what the algorithm looks like now, and how similar it is to the Sampling Algorithm:

#block Interpolating Algorithm
We have an function $\text{Interpolate}$ that takes in an array $[v_0, v_1, \dots v_{n-1}]$  and a primitive $n$-th root of unity $\om$, representing that $f(\om^k) = v_k$ for $0 \leq k < n$ and outputs $f(x) = a_0 + a_1x + \dots + a_{n-1}x^{n-1}$ in the form of an array $[a_0, a_1, \dots, a_{n-1}$.

We reinterpret the input array $[v_0, v_1, \dots, v_{n-1}$ as a polynomial $g(x) = v_0 + v_1x + \dots + v_{n-1}x^{n-1}$ and the output array $[a_0, a_1, \dots, a_{n-1}$ as samples where $a_k = g(\om^{-k})$ for $0 \leq k < n$.

<ol id="alglist">
	<li>Base case: If $n = 1$, then there's only one coefficient and $g(x) = v_0$, so we just return $[v_0]$.
	<li>Divide the array $[v_0, \dots, v_{n-1}]$ into $[v_0, v_2, \dots, v_{n-2}]$ and $[v_1, v_3, \dots, v_{n-1}]$, representing $g\even(x)$ and $g\odd(x)$.</li>
	<li>Recursively call $\text{Interpolate}$ on the two new arrays, passing in $\up = \om^2$ as the primitive $\frac n2$-th root of unity.</li>
	<li>The results that we get are the samples $[g\even(\up^0), \dots, g\even(\up^{\frac n2})]$ and $[g\odd(\up^0), \dots, g\odd(\up^{\frac n2})]$.</li>
	<li>Using the above formula, for each $0 \leq k < n$, compute $g(\om^{-k}) =g\even(\up^{-k}) + \om^{-k} g\odd(\up^{-k})$.</li>
	<li><b>Divide each $\mathbf{g(\om^{-k})}$ by $\mathbf n$.</b> Return $\left[\dfrac{g(\om^0)}n, \dfrac{g(\om^{-1})}n, \dots, \dfrac{g(\om^{-(n-1)})}n\right]$.</li>
</ol>
#end block

#end section

#section Introduction to Complex Numbers
If you're already familiar with complex numbers, feel free to skip this section.

Let's talk about polynomials in a different way. If we want to solve for $x$ in an equation where the degree of $x$ is at most $n$, we can rearrange the equation so that the right hand side is $0$. For example, solving for $x$ in the equation $x^2 + 5 = x - x^3$ is the same as solving for $x$ in $x^3 + x^2 - x + 5 = 0$.

Therefore if $f(x) = a_0 + a_1x + \dots + a_nx^n$, we call the numbers $r_1, r_2, \dots$ the roots or solutions of $f(x)$. For polynomials of degree two, (also called quadratic polynomials), the solutions to $f(x) = c + bx + ax^2$ are exactly
$$x = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}$$
which is commonly called the Quadratic Formula. Notably, if $b^2 - 4ac < 0$, there are no solutions since negative numbers have no square roots. However, by extending the real numbers by adding an imaginary unit $i$ that satisfies $i^2 = (-i)^2 = -1$, we have solutions for every quadratic polynomial.

// TODO: the caveat should link to a page discussing how to count the number of roots with multiplicity
It turns out that by introducing $i$ to solve polynomials of degree $2$, now every polynomial of degree $n$ has $n$ solutions (<a href="#">caveat</a>), and each solution can be expressed as $a + bi$ where $a$ and $b$ are regular numbers, and $i$ is the imaginary unit just described. These numbers are the complex numbers.
#end section

#section Using Complex Numbers
What we really want is to find primitive roots of unity in the complex numbers. For example, $i$ itself is a primitive fourth root of unity since $i^1 = i, i^2 = -1, i^3 = -1, i^4 = 1$. For the general case, we can use the following formula:

#block Primitive Roots of Unity in the Complex Numbers
For all $n \geq 1$, $\cos\left(\frac{2\pi}n\right) + \sin\left(\frac{2\pi}n\right) i$ is a primitive $n$-th root of unity.

<a href="#">Proof</a>
#end block

For those unfamiliar, $\cos$ and $\sin$ are functions that have to do with circles, triangles, and angles. In particular, they accept any number as input and output a number between $-1$ and $1$ inclusive.

Usually there's something deep to be said about circles and geometry here, but we'll skip past that in this article. All we really need to know is that we can use C++'s $\text{complex&lt;double&gt;}$ to store complex numbers, and $\cos$ and $\sin$ are available as functions in the $\text{&lt;cmath&gt;}$ header in C++, so we finally have a concrete representation of primitive roots of unity now.
#end section

#section Introduction to $\mathbb{Z} / p \mathbb{Z}$
If you're already familiar with the integers modulo a prime (or $\mathbb{Z} / p \mathbb{Z}$), feel free to skip this section.

There are an infinite number of integers, but if we restrict them to be between $0$ and $n - 1$ inclusive, interesting things happen. By "restrict to $0$ and $n - 1$, we mean that every time we do a math operation, if the result is outside of the range, we need to divide by $n$ and take the remainder. For example, if $n = 10$, then $3 \times 8 = 24$, but the remainder of $24$ dividing by $10$ is $4$, so our actual result is $4$.

Writing this as $3 \times 8 = 4$ is confusing, so we instead use the notation $3 \times 8 \equiv 4 \pmod{10}$. The $\pmod{10}$ stands for "modulo 10", which is a reminder that we're taking the remainder (also called modulus) dividing by $10$ at every point.

This new strange way of doing math is called "the integers modulo $n$" or by its fancy name $\mathbb{Z} / n \mathbb{Z}$. For example, we've just worked in $\mathbb{Z} / 10 \mathbb{Z}$. If the choice of $n$ is a prime number, we can instead call it "the integers modulo $p$" or $\mathbb{Z} / p \mathbb{Z}$.
#end section

#section Primitive Roots of Unity in $\mathbb{Z} / p \mathbb{Z}$
The important question once again is: can we get primitive roots of unity in $\mathbb{Z} / p \mathbb{Z}$? If so, how can we get them?

For example, since
$$
\begin{align}
2^1 &\equiv 2 \pmod 5 \\
2^2 &\equiv 4 \pmod 5 \\
2^3 &\equiv 3 \pmod 5 \\
2^4 &\equiv 1 \pmod 5
\end{align}
$$
$2$ is a primitive fourth root of unity in the integers modulo $5$. In general, we can say this:

#block Primitive Roots of Unity in $\mathbb{Z} / p \mathbb{Z}$
For any prime number $p$, there exists a primitive $(p - 1)$-th root of unity in $\mathbb{Z} / p \mathbb{Z}$.

These are often called the "primitive roots modulo $p$.

 <a href="#">Proof</a> <br/> <a href="#">Finding primitive roots modulo $p$</a>
#end block

Unfortunately, finding these primitive roots modulo $p$ takes us off the path of this article, so if you want to learn about that, you can click the link given above. In general, there are quite a few primitive roots modulo $p$, especially if $p$ is large, so we can usually find one that's pretty small. For example, there are $36738560$ primitive roots modulo the prime $91847201$, the smallest of which is $3$.

Unlike with complex numbers, we run into an issue. Because of our sampling and interpolating algorithms so far, we want to find a primitive $n$-th root of unity where $n$ is a power of two. Since every prime $p$ gives us a primitive $(p-1)$-th root of unity, we must find primes that a power of two, plus one. Unfortunately, there are only $5$ such numbers known: $3, 5, 17, 257, 65537$, which aren't large enough. Our fix comes from the next fact:

#block Primitive Root of Unity Fact
If $\om$ is a primitive $n$-th root of unity, and $n = am$, then $\om^a$ is a primitive $m$-th root of unity.

<a href="#">Proof</a>
#end block

We've actually seen a special case of this before when we said that if $\om$ is a primitive $n$-th root of unity, then $\om^2$ is a primitive $\frac n2$-th root of unity.

So how can we apply this here? Well if we instead look for primes of the form of $c \times 2^k + 1$ where $c$ is an odd number and $2^k$ is a power of two, it means there must exist an $\om$ that's a primitive $c \times 2^k$-th root of unity, which by the above fact means we can obtain a primitive $2^t$-th root of unity for any $t \leq k$.

There are a lot more primes of the form $c \times 2^k + 1$. The most notorious of these primes is $998244353 = 119 \times 2^{23} + 1$ with $\om = 3$, which is used by various competitive programming platforms. We'll be using this prime for the rest of the article. A full list of usable primes can be found <a href="#">here</a>.
#end section

#part Part 2: Implementation

#part Part 3: Limits

#end main

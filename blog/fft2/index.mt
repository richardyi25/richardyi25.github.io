// global notes:
// sometimes I use the word "function" but I should be using "polynomial"
// finding g_t(x) needs to be a little better motivated (e.g. say we want to "force" something)
// maybe change some \dots to \cdots
// maybe change some \text to \texttt
// maybe change texttt to some monospace text instead of mathjax

#site-title A Primitive Guide to FFT
#title A Primitive Guide to the Fast Fourier Transform
#latex-preamble
$$
\newcommand{\om}{\omega}
\newcommand{\up}{\upsilon}
\newcommand{\odd}{_{\text{odd}}}
\newcommand{\even}{_{\text{even}}}
\newcommand{\b}{\mathrm{b}}
\newcommand{\and}{\texttt{&}}
\newcommand{\or}{\texttt{|}}
$$
#end latex-preamble
#toc


#main

#section Introduction
In the context of competitive programming, the Fast Fourier Transform, or FFT, is a technique that speeds up polynomial multiplication from $O(n^2)$ to $O(n \log n)$. As the name suggests, this technique has to do with the Fourier Transform, which is a beautiful concept at the intersection of many fields of math. Thankfully, as competitive programmers, we can skip over most of this math.
#end section

#section Prerequisite Knowledge
You should be moderately familiar with:
<ul>
<li>Time complexity</li>
	<li>Divide and conquer</li>
	<li>Complex numbers</li>
	<li>Modulo arithmetic<li>
	<li>Binary numbers and bitmasks</li>
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

#section Sampling Algorithm Adjustment
We're almost ready to write real code. We just need two more adjustments before we can write our most basic implementation.

First, let's take one more look at the sampling algorithm from Part 1:

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

There's actually a hidden issue with in Step 5. We'd like to find $f\even(\up^k) + \om^kf\odd(\up^k)$ for all $0 \leq k < n$ but in Step 4 we only know $f\even(\up^k)$ and $f\odd(\up^k)$ for $0 \leq k < \frac n2$. So even if the math is correct, we need a different formula for all $\frac n2 \leq k < n$. Let's do a little bit of math:

// $$
// \begin{align}
// f(\om^k) &= f\even(\up^k) + \om^kf\odd(\up^k) \phantom{XXX} \text{ for } \frac n2 \leq k < n \\
// &= f\even(\up^{k - \frac nk}) + \om^kf\odd(\up^{k - \frac n2}) \phantom{XXX} \text{ for } \frac n2 \leq k < n \\
// \end{align}
// $$

Since $\up$ is a $\frac n2$-th root of unity, $\up^{\frac n2} = 1$. So for $\frac n2 \leq k < n$, we have the formula $f(\om^k) = f\even(\up^{k - \frac n2}) + \om^kf\odd(\up^{k - \frac n2})$, which fixes our issue.

We can take this one step further. Due to Property 2.1, $\om^{\frac n2} = -1$, $\om^{k} = -\om^{k - \frac n2}$. Therefore, we have the formula $f(\om^k) = f\even(\up^{k - \frac n2}) - \om^{k - \frac n2} f\odd(\up^{k - \frac n2})$ for all $\frac n2 \leq k < n$.  Shifting everything over by $\frac n2$, we get that $f(\om^{k + \frac n2}) = f\even(\up^k) - \om^k f\odd(\up^k)$ for all $0 \leq k < \frac n2$.

We're ready to see our final version of the sampling algorithm: 

#block Sampling Algorithm
We have an function $\text{Sample}$ that takes in $f(x) = a_0 + \dots + a_{n-1}x^{n-1}$ in the form of an array $[a_0, \dots, a_{n-1}]$ and a primitive $n$-th root of unity $\om$, and outputs the array of samples $[f(\om^0), \dots, f(\om^{n-1})]$. The algorithm is as follows:

<ol id="alglist">
	<li>Base case: If $n = 1$, then there's only one coefficient and $f(x) = a_0$, so we just return $[a_0]$.
	<li>Divide the array $[a_0, \dots, a_{n-1}]$ into $[a_0, a_2, \dots, a_{n-2}]$ and $[a_1, a_3, \dots, a_{n-1}]$, representing $f\even(x)$ and $f\odd(x)$.</li>
	<li>Recursively call $\text{Sample}$ on the two new arrays, passing in $\up = \om^2$ as the primitive $\frac n2$-th root of unity.</li>
	<li>The results that we get are the samples $[f\even(\up^0), \dots, f\even(\up^{\frac n2})]$ and $[f\odd(\up^0), \dots, f\odd(\up^{\frac n2})]$.</li>
	<li>Using the above formula, for each $0 \leq k < \frac n2$, compute
		<ul>
			<li>$f(\om^k) =f\even(\up^k) + \om^k f\odd(\up^k)$</li>
			<li>$f(\om^{k + \frac n2}) =f\even(\up^k) - \om^k f\odd(\up^k)$</li>
		</ul>
	</li>
	<li>Return $[f(\om^0), \dots, f(\om^{n-1})]$.</li>
</ol>
#end block
#end section

#section Interpolating Algorithm Adjustment
Let's look at our interpolating algorithm from Part 1:

#block Interpolating Algorithm
We have an function $\text{Interpolate}$ that takes in an array $[v_0, v_1, \dots v_{n-1}]$  and a primitive $n$-th root of unity $\om$, representing that $f(\om^k) = v_k$ for $0 \leq k < n$ and outputs $f(x) = a_0 + a_1x + \dots + a_{n-1}x^{n-1}$ in the form of an array $[a_0, a_1, \dots, a_{n-1}$.

We reinterpret the input array $[v_0, v_1, \dots, v_{n-1}$ as a polynomial $g(x) = v_0 + v_1x + \dots + v_{n-1}x^{n-1}$ and the output array $[a_0, a_1, \dots, a_{n-1}$ as samples where $a_k = g(\om^{-k})$ for $0 \leq k < n$.

<ol id="alglist">
	<li>Base case: If $n = 1$, then there's only one coefficient and $g(x) = v_0$, so we just return $[v_0]$.
	<li>Divide the array $[v_0, \dots, v_{n-1}]$ into $[v_0, v_2, \dots, v_{n-2}]$ and $[v_1, v_3, \dots, v_{n-1}]$, representing $g\even(x)$ and $g\odd(x)$.</li>
	<li>Recursively call $\text{Interpolate}$ on the two new arrays, passing in $\up = \om^2$ as the primitive $\frac n2$-th root of unity.</li>
	<li>The results that we get are the samples $[g\even(\up^0), \dots, g\even(\up^{\frac n2})]$ and $[g\odd(\up^0), \dots, g\odd(\up^{\frac n2})]$.</li>
	<li>Using the above formula, for each $0 \leq k < n$, compute $g(\om^{-k}) =g\even(\up^{-k}) + \om^{-k} g\odd(\up^{-k})$.</li>
	<li>Divide each $g(\om^{-k})$ by $n$. Return $\left[\dfrac{g(\om^0)}n, \dfrac{g(\om^{-1})}n, \dots, \dfrac{g(\om^{-(n-1)})}n\right]$.</li>
</ol>
#end block

We knew in Part 1 that this algorithm is extremely similar to the sampling algorithm, which is conceptually nice, but now that we're writing code, we want to reuse as much code as possible between these two algorithms.

In this case, we notice that since $\om^n = 1$, $\om^{n-k} = \om^k$. Therefore, $[g(\om^0), g(\om^{-1}), g(\om^{-2}), \dots, g(\om^{-(n-1)})]$ is the exact same as $[g(\om^0), g(\om^{n-1}), g(\om^{n-2}), \dots, g(\om^{1})]$. So instead of writing an interpolating algorithm, we can just call the sampling algorithm, switch up the order of the result, then divide everything by $n$. Our final version of the algorithm is much simpler:

#block Interpolating Algorithm
We have an function $\text{Interpolate}$ that takes in an array $[v_0, v_1, \dots v_{n-1}]$  and a primitive $n$-th root of unity $\om$, representing that $f(\om^k) = v_k$ for $0 \leq k < n$ and outputs $f(x) = a_0 + a_1x + \dots + a_{n-1}x^{n-1}$ in the form of an array $[a_0, a_1, \dots, a_{n-1}]$.

We reinterpret the input array $[v_0, v_1, \dots, v_{n-1}]$ as a polynomial $g(x) = v_0 + v_1x + \dots + v_{n-1}x^{n-1}$ and the output array $[a_0, a_1, \dots, a_{n-1}]$ as samples where $a_k = g(\om^{-k})$ for $0 \leq k < n$.

<ol id="alglist">
	<li>Call $\text{Sampling}(v_0, v_1, \dots, v_{n-1})$, giving us $[g(\om^0), g(\om^1), \dots, g^{n-1})]$.
	<li>Reverse indexes $1$ through $n - 1$, giving us $[g(\om^0), g(\om^{n-1}), g(\om^{n-2}), \dots, g(\om^1)]$, which is the same as $[g(\om^0), g(\om^{-1}), g(\om^{-2}), \dots, g(\om^{-(n-1)})]$.
	<li>Divide each $g(\om^{-k})$ by $n$. Return $\left[\dfrac{g(\om^0)}n, \dfrac{g(\om^{-1})}n, \dots, \dfrac{g(\om^{-(n-1)})}n\right]$.</li>
</ol>
#end block

#end section

#section Notation

#end section

#section Basic Recursive Implementation
For the rest of this part of the article, we'll be focusing on solving <a href="https://judge.yosupo.jp/problem/convolution_mod">this problem</a>.

While all the code samples have been tested to be correct implementations of the algorithm, it won't pass all the test cases for the problem. The reason why this is the case will be explained in Part 3: Limits. 

#code none
#include <cstdio>
#include <cmath>
#include <algorithm>
#include <complex>
#include <vector>
using namespace std;

const int MOD = 998244353;
const double PI = acos(-1);

vector<complex<double>> fft(vector<complex<double>> arr){
	int n = arr.size();
	// Base case is when n = 1
	if(n == 1) return arr;

	// Split into f_even and f_odd
	vector<complex<double>> arrEven(n/2), arrOdd(n/2);
	for(int i = 0; i < n/2; i++){
		arrEven[i] = arr[i * 2];
		arrOdd[i]  = arr[i * 2 + 1];
	}

	// Recursively call on both halves
	arrEven = fft(arrEven);
	arrOdd = fft(arrOdd);

	vector<complex<double>> result(n);

	// Primitive n-th root of unity
	complex<double> proot (cos(2 * M_PI / n), sin(2 * M_PI / n));
	// This variable keeps track of proot^k
	complex<double> root (1, 0);

	for(int k = 0; k < n/2; k++){
		result[k]       = arrEven[k] + root * arrOdd[k];
		result[k + n/2] = arrEven[k] - root * arrOdd[k];
		root *= proot;
	}

	return result;
}

vector<complex<double>> ifft(vector<complex<double>> arr){
	int n = arr.size();
	arr = fft(arr);
	// Reverse arr[1], arr[2], ... arr[n - 1]
	reverse(arr.begin() + 1, arr.end());
	for(int i = 0; i < n; i++)
		arr[i] /= n;

	return arr;
}

// The arguments and return value for this function will always
// remain the same throughout the article

vector<int> mult(vector<int> arr, vector<int> brr){
	int target = 2 * max(arr.size(), brr.size()), sz = 1;
	// The number of samples is the first power of 2 at least 2 * max(N, M)
	while(sz < target) sz *= 2;

	// Convert from int arrays to complex<double> arrays
	vector<complex<double>> arrc, brrc;
	for(int n : arr)
		arrc.push_back(n);
	for(int n : brr)
		brrc.push_back(n);

	// Resize array to the number of desired samples
	arrc.resize(sz);
	brrc.resize(sz);

	// Sample, pointwise multiply, and interpolate
	arrc = fft(arrc);
	brrc = fft(brrc);
	for(int i = 0; i < sz; i++)
		arrc[i] *= brrc[i];
	arrc = ifft(arrc);

	// Round result to int
	vector<int> result;
	// The product of polynomial of size N and M has size N + M - 1
	int realSz = arr.size() + brr.size() - 1;
	for(int i = 0; i < realSz; i++){
		long long rounded = arrc[i].real() + 0.5;
		result.push_back((rounded % MOD + MOD) % MOD);
	}

	return result;
}

int main(){
	int N, M, n;
	vector<int> arr, brr;
	scanf("%d %d", &N, &M);
	for(int i = 0; i < N; i++){
		scanf("%d", &n);
		arr.push_back(n);
	}
	for(int i = 0; i < M; i++){
		scanf("%d", &n);
		brr.push_back(n);
	}
	vector<int> crr = mult(arr, brr);
	for(int c : crr)
		printf("%d ", c);
}
#end code

The $\texttt{#include}$ lines and $\texttt{main()}$ are common to all the implementations, so we'll be omitting them from the code samples later on in the article. It's probably a good idea to use $\texttt{typedef}$ for things like $\texttt{complex&lt;double&gt;}$, but for the sake of clarity, we'll avoid using it in this article.

We've finally arrived at the goal set out at beginning of the article: this code multiplies two polynomials in $O(n \log n)$ time. However, we're far from done. We're not going to get any better than $O(n \log n)$, but we still have a lot to improve.
#end section

#section In-Place and $O(n)$ Space
As it stands, our implementation has some performance issues. We waste a lot of time passing in and returning arrays. Additionally, since we create a temporary array before the recursive calls, our space usage ends up being $O(n \log n)$.

To prevent this from happening, we're changing the $\texttt{fft}$ and $\texttt{ifft}$ function to be in-place, meaning the argument passed in will now be pass-by-reference and it doesn't return anything.

#code 1,4,14-15,29,31,55-56,59
void fft(vector<complex<double>> &arr){
	int n = arr.size();
	// Base case is when n = 1
	if(n == 1) return;

	// Split into f_even and f_odd
	vector<complex<double>> arrEven(n/2), arrOdd(n/2);
	for(int i = 0; i < n/2; i++){
		arrEven[i] = arr[i * 2];
		arrOdd[i]  = arr[i * 2 + 1];
	}

	// Recursively call on both halves
	fft(arrEven);
	fft(arrOdd);

	// Primitive n-th root of unity
	complex<double> proot (cos(2 * M_PI / n), sin(2 * M_PI / n));
	// This variable keeps track of proot^k
	complex<double> root (1, 0);

	for(int k = 0; k < n/2; k++){
		arr[k]       = arrEven[k] + root * arrOdd[k];
		arr[k + n/2] = arrEven[k] - root * arrOdd[k];
		root *= proot;
	}
}

void ifft(vector<complex<double>> &arr){
	int n = arr.size();
	fft(arr);
	// Reverse arr[1], arr[2], ... arr[n - 1]
	reverse(arr.begin() + 1, arr.end());
	for(int i = 0; i < n; i++)
		arr[i] /= n;
}

vector<int> mult(vector<int> arr, vector<int> brr){
	int target = 2 * max(arr.size(), brr.size()), sz = 1;
	// The number of samples is the first power of 2 at least 2 * max(N, M)
	while(sz < target) sz *= 2;

	// Convert from int arrays to complex<double> arrays
	vector<complex<double>> arrc, brrc;
	for(int n : arr)
		arrc.push_back(n);
	for(int n : brr)
		brrc.push_back(n);

	// Resize array to the number of desired samples
	arrc.resize(sz);
	brrc.resize(sz);

	// Sample, pointwise multiply, and interpolate
	fft(arrc);
	fft(brrc);
	for(int i = 0; i < sz; i++)
		arrc[i] *= brrc[i];
	ifft(arrc);

	// Round result to int
	vector<int> result;
	// The product of polynomial of size N and M has size N + M - 1
	int realSz = arr.size() + brr.size() - 1;
	for(int i = 0; i < realSz; i++){
		long long rounded = arrc[i].real() + 0.5;
		result.push_back((rounded % MOD + MOD) % MOD);
	}

	return result;
}
#end code

However, we haven't gotten rid of the temporary arrays, so the space usage is still $O(n \log n)$. What we need to do is use temporary arrays to rearrange $\texttt{arr}$ and reuse $\texttt{arr}$ as much as possible.

In particular, each $\texttt{fft}$ call won't do the sampling algorithm on the entire array, but will only do it on the part of $\texttt{arr}$ specified by the additional arguments.

#code None
// Moves elements around in arr[off], arr[off + 1], ... arr[off + n - 1]
// so that the first half represents arrEven and the second half represents arrOdd
void reorder(vector<complex<double>> &arr, int off, int n){
	// These temporary arrays will be deallocated when the function ends
	vector<complex<double>> arrEven(n/2), arrOdd(n/2);

	for(int i = 0; i < n/2; i++){
		arrEven[i] = arr[off + i * 2];
		arrOdd[i]  = arr[off + i * 2 + 1];
	}

	for(int i = 0; i < n/2; i++){
		arr[off + i]       = arrEven[i];
		arr[off + i + n/2] = arrOdd[i];
	}
}

// Now we aren't doing fft on the entire array, just a part of it
// Two new arguments: the offset (start index) and size that we're doing fft
// We only do fft on arr[off], arr[off + 1], ... arr[off + n - 1]
void fft(vector<complex<double>> &arr, int off, int n){
	// Base case is when n = 1
	if(n == 1) return;

	// Reorder arr so the first half is arrEven and second half is arrOdd
	reorder(arr, off, n);

	// Recursively call on both halves
	fft(arr, off, n/2);         // call on first half of arr (arrEven)
	fft(arr, off + n/2, n/2);   // call on second half of arr (arrOdd)

	// Primitive n-th root of unity
	complex<double> proot (cos(2 * M_PI / n), sin(2 * M_PI / n));
	// This variable keeps track of proot^k
	complex<double> root (1, 0);

	for(int k = 0; k < n/2; k++){
		// Since arrEven lies in the first half or arr and arrOdd lies in the second half of arr,
		// For 0 <= k < n/2, arr[k] = arrEven[k] and arr[k + n/2] = arrOdd[k]

		// Very conveniently, arr[k] and arr[k + n/2] only depend on arr[k] and arr[k + n/2]
		// so we don't need another temporary array
		complex<double> arrK         = arr[off + k];
		complex<double> arrKPlusHalf = arr[off + k + n/2];

		arr[off + k]       = arrK + root * arrKPlusHalf;
		arr[off + k + n/2] = arrK - root * arrKPlusHalf;

		root *= proot;
	}
}

// Overload with no additional arguments, fft the entire array
void fft(vector<complex<double>> &arr){
	fft(arr, 0, arr.size());
}
#end code

Since the temporary arrays are deallocated before the recursive call, the space usage is $O(n)$ and not $O(n \log n)$.
#end section

#section Iterative Implementation
Let's do some code tracing for our implementation in the previous section, for example, $\texttt{fft(arr)}$ on an 8-element array. For the sake of the illustration, we shorten $\texttt{fft}$ to $\texttt{f}$ and $\texttt{arr}$ to $\texttt{a}$.

<table class="trace">
	<tr>
		<td colspan="8">
			$\texttt{f(a, 0, 8)}$ <br/> $a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7]$
		</td>
	</tr>
	<tr class="shortrow">
		<td colspan="4">&LowerLeftArrow; </td>
		<td colspan="4">&LowerRightArrow;</td>
	</tr>
	<tr>
		<td colspan="4">$\texttt{f(a, 0, 4)}$ <br/> $a[0], a[2], a[4], a[6]$</td>
		<td colspan="4">$\texttt{f(a, 4, 4)}$ <br/> $a[1], a[3], a[5], a[7]$</td>
	</tr>
	<tr class="shortrow">
		<td colspan="2">&LowerLeftArrow; </td>
		<td colspan="2">&LowerRightArrow;</td>
		<td colspan="2">&LowerLeftArrow; </td>
		<td colspan="2">&LowerRightArrow;</td>
	</tr>
	<tr>
		<td colspan="2">$\texttt{f(a, 0, 2)}$ <br/> $a[0], a[4]$</td>
		<td colspan="2">$\texttt{f(a, 2, 2)}$ <br/> $a[2], a[6]$</td>
		<td colspan="2">$\texttt{f(a, 4, 2)}$ <br/> $a[1], a[5]$</td>
		<td colspan="2">$\texttt{f(a, 6, 2)}$ <br/> $a[3], a[7]$</td>
	</tr>
	<tr class="shortrow">
		<td colspan="1">&LowerLeftArrow; </td>
		<td colspan="1">&LowerRightArrow;</td>
		<td colspan="1">&LowerLeftArrow; </td>
		<td colspan="1">&LowerRightArrow;</td>
		<td colspan="1">&LowerLeftArrow; </td>
		<td colspan="1">&LowerRightArrow;</td>
		<td colspan="1">&LowerLeftArrow; </td>
		<td colspan="1">&LowerRightArrow;</td>
	</tr>
	<tr>
		<td colspan="1">$\texttt{f(a, 0, 1)}$ <br/> $a[0]$</td>
		<td colspan="1">$\texttt{f(a, 1, 1)}$ <br/> $a[4]$</td>
		<td colspan="1">$\texttt{f(a, 2, 1)}$ <br/> $a[2]$</td>
		<td colspan="1">$\texttt{f(a, 3, 1)}$ <br/> $a[6]$</td>
		<td colspan="1">$\texttt{f(a, 4, 1)}$ <br/> $a[1]$</td>
		<td colspan="1">$\texttt{f(a, 5, 1)}$ <br/> $a[5]$</td>
		<td colspan="1">$\texttt{f(a, 6, 1)}$ <br/> $a[3]$</td>
		<td colspan="1">$\texttt{f(a, 7, 1)}$ <br/> $a[7]$</td>
	</tr>
	<tr class="shortrow">
		<td colspan="1">&darr;</td>
		<td colspan="1">&darr;</td>
		<td colspan="1">&darr;</td>
		<td colspan="1">&darr;</td>
		<td colspan="1">&darr;</td>
		<td colspan="1">&darr;</td>
		<td colspan="1">&darr;</td>
		<td colspan="1">&darr;</td>
	</tr>
	<tr>
		<td colspan="1">Result of <br/> $\texttt{f(a, 0, 1)}$</td>
		<td colspan="1">Result of <br/> $\texttt{f(a, 1, 1)}$</td>
		<td colspan="1">Result of <br/> $\texttt{f(a, 2, 1)}$</td>
		<td colspan="1">Result of <br/> $\texttt{f(a, 3, 1)}$</td>
		<td colspan="1">Result of <br/> $\texttt{f(a, 4, 1)}$</td>
		<td colspan="1">Result of <br/> $\texttt{f(a, 5, 1)}$</td>
		<td colspan="1">Result of <br/> $\texttt{f(a, 6, 1)}$</td>
		<td colspan="1">Result of <br/> $\texttt{f(a, 7, 1)}$</td>
	</tr>
	<tr class="shortrow">
		<td colspan="1">&LowerRightArrow;</td>
		<td colspan="1">&LowerLeftArrow; </td>
		<td colspan="1">&LowerRightArrow;</td>
		<td colspan="1">&LowerLeftArrow; </td>
		<td colspan="1">&LowerRightArrow;</td>
		<td colspan="1">&LowerLeftArrow; </td>
		<td colspan="1">&LowerRightArrow;</td>
		<td colspan="1">&LowerLeftArrow; </td>
	</tr>
	<tr>
		<td colspan="2">Result of <br/> $\texttt{f(a, 0, 2)}$</td>
		<td colspan="2">Result of <br/> $\texttt{f(a, 2, 2)}$</td>
		<td colspan="2">Result of <br/> $\texttt{f(a, 4, 2)}$</td>
		<td colspan="2">Result of <br/> $\texttt{f(a, 6, 2)}$</td>
	</tr>
	<tr class="shortrow">
		<td colspan="2">&LowerRightArrow;</td>
		<td colspan="2">&LowerLeftArrow; </td>
		<td colspan="2">&LowerRightArrow;</td>
		<td colspan="2">&LowerLeftArrow; </td>
	</tr>
	<tr>
		<td colspan="4">Result of <br/> $\texttt{f(a, 0, 4)}$</td>
		<td colspan="4">Result of <br/> $\texttt{f(a, 4, 4)}$</td>
	</tr>
	<tr class="shortrow">
		<td colspan="4">&LowerRightArrow;</td>
		<td colspan="4">&LowerLeftArrow; </td>
	</tr>
	<tr>
		<td colspan="8">
			Result of <br/> $\texttt{f(a, 0, 8)}$
		</td>
	</tr>
</table>

We now can see that the "divide" part of our divide and conquer is just moving elements around. Here, with 8 elements, each element was moved at most 3 times. In general, we need to move all the elements $O(\log n)$ times each. Additionally, each time $\texttt{fft}$ was called with $\texttt{n = 1}$, we hit the base case, where the function just did nothing and returned.

Both of these seem wasteful, so now we want to devise an algorithm that does the following:
<ol>
	<li>Moves each element of $\texttt{arr}$ to where it will eventually end up at the end of all the "divide" steps of the divide and conquer</li>
	<li>Do the "merging" step of our divide and conquer, which is applying the formulas $f(\om^k) =f\even(\up^k) + \om^k f\odd(\up^k)$ and $f(\om^{k + \frac n2}) =f\even(\up^k) - \om^k f\odd(\up^k)$.</li>
	<li>We don't even need to do this recursively, we can do all the merges of size 2, then size 4, then 8, and so on up to the final size $n$ merge.</li>
</ol>
#end section

#section Iterative Implementation
In our iterative implementation, we want the logic to look something like this:

<table class="trace">
	<tr>
		<td colspan="1">$a[0]$</td>
		<td colspan="1">$a[1]$</td>
		<td colspan="1">$a[2]$</td>
		<td colspan="1">$a[3]$</td>
		<td colspan="1">$a[4]$</td>
		<td colspan="1">$a[5]$</td>
		<td colspan="1">$a[6]$</td>
		<td colspan="1">$a[7]$</td>
	</tr>
	<tr class="midrow">
		<td colspan="8">Rearrange $a[]$ so that elements end up where they need to be before merges</td>
	</tr>
	<tr>
		<td colspan="1">$a[0]$</td>
		<td colspan="1">$a[4]$</td>
		<td colspan="1">$a[2]$</td>
		<td colspan="1">$a[6]$</td>
		<td colspan="1">$a[1]$</td>
		<td colspan="1">$a[5]$</td>
		<td colspan="1">$a[3]$</td>
		<td colspan="1">$a[7]$</td>
	</tr>
	<tr class="shortrow">
		<td colspan="1">&LowerRightArrow;</td>
		<td colspan="1">&LowerLeftArrow; </td>
		<td colspan="1">&LowerRightArrow;</td>
		<td colspan="1">&LowerLeftArrow; </td>
		<td colspan="1">&LowerRightArrow;</td>
		<td colspan="1">&LowerLeftArrow; </td>
		<td colspan="1">&LowerRightArrow;</td>
		<td colspan="1">&LowerLeftArrow; </td>
	</tr>
	<tr>
		<td colspan="2">Result of <br/> $\texttt{f(a, 0, 2)}$</td>
		<td colspan="2">Result of <br/> $\texttt{f(a, 2, 2)}$</td>
		<td colspan="2">Result of <br/> $\texttt{f(a, 4, 2)}$</td>
		<td colspan="2">Result of <br/> $\texttt{f(a, 6, 2)}$</td>
	</tr>
	<tr class="shortrow">
		<td colspan="2">&LowerRightArrow;</td>
		<td colspan="2">&LowerLeftArrow; </td>
		<td colspan="2">&LowerRightArrow;</td>
		<td colspan="2">&LowerLeftArrow; </td>
	</tr>
	<tr>
		<td colspan="4">Result of <br/> $\texttt{f(a, 0, 4)}$</td>
		<td colspan="4">Result of <br/> $\texttt{f(a, 4, 4)}$</td>
	</tr>
	<tr class="shortrow">
		<td colspan="4">&LowerRightArrow;</td>
		<td colspan="4">&LowerLeftArrow; </td>
	</tr>
	<tr>
		<td colspan="8">
			Result of <br/> $\texttt{f(a, 0, 8)}$
		</td>
	</tr>
</table>

Our code is surprisingly shorter, with the un-highlighted lines being carried over from the previous implementation.

#code 1-15,30-31
// Reorder all elements to end up where they need to be right before merges
void reorder_all(vector<complex<double>> &arr){
	// To be filled in next section
}

void fft(vector<complex<double>> &arr){
	int total_sz = arr.size();

	// Reorder all elements first
	reorder_all(arr);

	// The two outer loops effectively replace the recursive calls
	// of fft(arr, off, n) from the previous implementation
	for(int n = 2; n <= total_sz; n *= 2){
		for(int off = 0; off < total_sz; off += n){
			// Primitive n-th root of unity
			complex<double> proot (cos(2 * M_PI / n), sin(2 * M_PI / n));
			// This variable keeps track of proot^k
			complex<double> root (1, 0);
			
			for(int k = 0; k < n/2; k++){
				complex<double> arrK         = arr[off + k];
				complex<double> arrKPlusHalf = arr[off + k + n/2];

				arr[off + k]       = arrK + root * arrKPlusHalf;
				arr[off + k + n/2] = arrK - root * arrKPlusHalf;

				root *= proot;
			}
		}
	}
}
#end code

We replace our recursive call structure using the two outer loops. The outermost loop iterates through merge sizes, going from 2, to 4, to 8, and so on until $n$. The second outermost loop iterates through the offset, or starting index of each merge, starting at 0, and increasing by $\texttt{sz}$ each iteration, up to $\texttt{n}$.

We've left out what the order of the elements of $\texttt{arr}$ should be as well as how to arrange the elements into that order. The answer surprisingly has to do with the binary representation of numbers.
#end section

// #section Binary Representation of Numbers
// If you are familiar with the binary representation of numbers, bitwise operations, and hexadecimal, you can skip this section.
// 
// When we write down numbers, we implicitly know that each digit has ten times the value as the one to the right. For example, the number $123$ means $(1 \times 10^2) + (2 \times 10^1) + (3 \times 10^0)$. The choice of $10$ is natural but ultimately arbitrary. In a base-$n$ system, the digits $d_kd_{k-1}\dots d_1d_0$ would represent $d_kn^k + d_{k-1}n^{k-1} + \dots + d_1n^1 + d_0n^0$, with the restriction that $0 \leq d_k, \dots, d_0 < n$.
// 
// For various reasons, computers internally store integers in base-2. This means a 32-bit number is stored as $d_{31}d_{30}\dots d_1d_0$ representing $d_{31}2^{31} + d_{30}2^{30} + \dots + d_12^1 + d_02^0$ with the restriction that each digit is either a 0 or a 1. As an example, the binary number $1101$ represents $(1 \times 2^3) + (1 \times 2^2) + (0 \times 2^1) + (1 \times 2^0) = 13$.
// 
// For notation, we'll add "$0\b$" to the start of a binary number for emphasis. For example, we might write the previous example as $0\b1101 = 13$. Additionally, the common name for the digit of a binary number is bit (short for binary digit).
// 
// // TODO explain bitwise operations
// Consider two 1-bit numbers, that is, two numbers in binary that are either 0 or 1. Let's call these numbers $a$ and $b$. In addition to being able to add, subtract, and multiply them normally, we also have the operation <i>bitwise OR</i> and <i>bitwise AND</i>. The output of $a$ bitwise OR $b$, (denoted as $a \and b$) is $1$
// 
// #end section

#part Part 3: Limits
#end main

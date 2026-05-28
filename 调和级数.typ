#set page(
  paper: "a4",
  flipped: false,
  margin: 1.5cm,
  numbering: "1/1",
  number-align: center,
  fill: rgb("#ffffff13"),
)

#set document(
  title: [调和级数],
  author: ("何雄武",),
  date: datetime(year: 2026, month: 5, day: 6),
)

#show title: it => {
  set align(center)
  set text(size: 18pt, weight: "bold", fill: rgb("#0066fff0"))
  it
  v(1em)
}

#set par(spacing: 2em, leading: 1em, justify: true)

#set heading(numbering: "1.1")

#show heading.where(level: 1): it => {
  v(1em)
  set text(size: 15pt, weight: "bold", fill: rgb("0066fff0"))
  it
  v(1em)
}

#show heading.where(level: 2): it => {
  set text(size: 10pt, weight: "bold", fill: rgb("0066fff0"))
  it
  v(0.5em)
}

#set text(
  lang: "zh",
  font: ("Cambria Math", "KaiTi", "DengXian", "New Computer Modern Sans", "Noto Sans Mono CJK SC", "SimSun"),
  size: 10pt,
)

#show table: it => {
  set align(center)
  it
}

#set math.equation(numbering: n => numbering("(1.1)", counter(heading).get().first(), n), supplement: [Eq.])

#show math.equation: set block(breakable: true)

#import "@preview/lilaq:0.6.0" as lq
#import "@preview/cetz:0.5.0"
#import "@preview/gentle-clues:1.3.1": *
#import "@preview/physica:0.9.8": *
#import "@preview/numty:0.1.0" as nt

#show: gentle-clues.with(
  breakable: true,
)

#title()

= 调和级数的定义

调和级数（Harmonic Series）是数学中最著名的无穷级数之一，其名称来源于音乐中的泛音（Harmonics）概念。在弦乐器中，一根弦振动时不仅发出基音，还会同时发出频率为基音整数倍的泛音，这些泛音的波长与弦长之比恰好构成了调和级数中各项的倒数。调和级数的数学定义是所有正整数倒数的无穷和：

$ H = sum_(n=1)^oo 1/n = 1 + 1/2 + 1/3 + 1/4 + dots.c $

其中前 $n$ 项的部分和称为调和数（Harmonic Number），通常记作 $H_n$：

$ H_n = sum_(k=1)^n 1/k = 1 + 1/2 + 1/3 + dots.c + 1/n $

= 调和级数的发散性

调和级数最引人注目的性质在于：尽管其通项 $a_n = 1/n$ 随着 $n$ 的增大而趋向于零，但整个级数却是发散的。这意味着，只要累加足够多的项，部分和 $H_n$ 可以超过任意大的数。这一看似反直觉的结论最早由法国学者尼克尔·奥雷姆（Nicole Oresme）在约1350年给出了严格证明。

奥雷姆的证明思路极为巧妙：他将调和级数的项按如下方式分组：

$ H = 1 + 1/2 + (1/3 + 1/4) + (1/5 + 1/6 + 1/7 + 1/8) + dots.c $

每一组括号内的项数逐组翻倍，而每一组的总和都大于 $1/2$。因此调和级数的部分和大于无穷多个 $1/2$ 之和，从而趋于无穷。

另一个经典的证明方法是利用积分判别法。由于函数 $f(x) = 1/x$ 在区间 $[1, oo)$ 上单调递减且恒为正，我们可以将级数与反常积分建立联系：

$ integral_1^oo 1/x dif x = lim_(b->oo) ln b = oo $

由于级数的部分和大于该积分，因此调和级数发散。

为了更直观地理解这一比较过程，我们可以在几何上考察函数 $f(x) = 1/x$ 的曲线与代表级数各项的矩形之间的关系。考虑区间 $[k, k+1]$（其中 $k$ 为自然数），由于 $f(x)$ 在该区间上单调递减，因此在子区间 $[k, k+1]$ 上恒有 $1/k >= 1/x$。由此可得，宽度为 $1$、高度为 $1/k$ 的矩形面积 $1/k$（即级数的第 $k$ 项）必然大于曲线下方从 $k$ 到 $k+1$ 的曲边梯形面积——也就是定积分 $integral_k^(k+1) 1/x dif x$。对所有 $k$ 从 $1$ 到 $n$ 求和，便得到如下不等式：

$ H_n = sum_(k=1)^n 1/k > sum_(k=1)^n integral_k^(k+1) 1/x dif x = integral_1^(n+1) 1/x dif x = ln (n+1) $

当 $n -> oo$ 时，$ln(n+1)$ 趋于无穷大，因而 $H_n$ 也必趋于无穷大，这就从积分比较的角度严格证明了调和级数的发散性。这条不等式还给出了调和数的一个下界估计：$H_n > ln(n+1)$，清晰地揭示了调和数至少以对数速度增长的事实。

#show lq.selector(lq.legend): set grid(row-gutter: 6pt)

#figure(
  lq.diagram(
    title: [],
    xlabel: [$x$],
    ylabel: [$y$],
    width: 80%,
    height: 6cm,
    xlim: (0, 12),
    ylim: (0, 1.2),
    xaxis: (
      ticks: range(1, 12),
    ),
    yaxis: (
      ticks: lq.linspace(0, 1, num: 3),
    ),
    grid: (stroke: luma(95%), stroke-sub: luma(98%) + 0.25pt),
    legend: (stroke: none),
    lq.plot(
      lq.linspace(0.9, 11.5, num: 100),
      x => 1 / x,
      stroke: 1pt + rgb("#0066ff"),
      label: [$f(x) = 1/x$],
      mark: none,
    ),
    lq.fill-between(
      lq.linspace(1, 11, num: 100),
      x => 1 / x,
      fill: rgb("#aaccff"),
      stroke: none,
      label: [曲线下方面积 $integral_1^(n+1) 1/x dif x$],
    ),
    lq.bar(
      range(1, 11),
      x => 1 / x,
      fill: rgb("#ffccaa2b"),
      stroke: 0.8pt + rgb("#ff6600"),
      align: left,
      width: 1,
      label: [矩形面积 $1/k$（调和级数各项）],
    ),
  ),
  caption: [积分判别法示意],
) <fig:integral-test>

在 @fig:integral-test 中，蓝色曲线为 $f(x)=1/x$，橙色矩形代表调和级数前 10 项（高度 $1/k$、宽度 $1$，左端位于 $x = k$ 处）。由于 $f(x)$ 单调递减，在区间 $[k, k+1]$ 上恒有 $1/k >= 1/x$，因此每个矩形面积均大于其下方曲边梯形的面积，求和即得 $H_n > integral_1^(n+1) 1/x dif x = ln(n+1)$，从而推出调和级数发散。


= 调和数的渐近行为

虽然调和级数是发散的，但它的发散速度非常缓慢。前 $n$ 项的和 $H_n$ 大约增长得像 $ln n$ 一样快。精确地，欧拉于1735年发现：

$ gamma = lim_(n->oo) (H_n - ln n) approx 0.5772156649 dots.c $

这个常数 $gamma$ 被称为欧拉—马歇罗尼常数（Euler-Mascheroni Constant），它是数学中最重要的常数之一。至今人们仍不知道 $gamma$ 是有理数还是无理数，这仍是数学界的一个未解之谜。

#let n = range(1, 101)
#let ln_n = n.map(it => calc.ln(it))
#let H_n = {
  let arr = ()
  let s = 0.0
  for k in range(1, 101) {
    s += 1.0 / k
    arr.push(s)
  }
  arr
}
#let diff = H_n.zip(ln_n).map(((a, b)) => a - b)

#show lq.selector(lq.legend): set grid(row-gutter: 2pt)

#figure(
  lq.diagram(
    title: [],
    xlabel: [$n$],
    ylabel: [],
    width: 80%,
    height: 7cm,
    xlim: (0, 105),
    ylim: (0, 6),
    xaxis: (
      ticks: range(0, 110, step: 10),
    ),
    yaxis: (
      ticks: lq.linspace(1, 5, num: 5),
    ),
    grid: (stroke: luma(95%), stroke-sub: luma(98%) + 0.25pt),
    legend: (stroke: none, position: left + top),
    lq.plot(
      n,
      H_n,
      stroke: 1.2pt + rgb("#ff6600"),
      mark: none,
      step: end,
      label: [$H_n$],
    ),
    lq.plot(
      n,
      ln_n,
      stroke: 1.2pt + rgb("#0066ff"),
      mark: none,
      label: [$ln n$],
    ),
    lq.plot(
      n,
      diff,
      stroke: 1pt + rgb("#aeaeae"),
      mark: none,
      label: [$H_n - ln n$],
      step: end,
    ),
    lq.plot(
      (1, 100),
      (0.5772156649, 0.5772156649),
      mark: none,
      stroke: (thickness: 0.5pt, paint: rgb("#7a7a7a"), dash: "dotted"),
      label: [$gamma approx 0.5772$],
    ),
  ),
  caption: [调和数 $H_n$、对数函数 $ln n$ 及其差值 $H_n - ln n$ 随 $n$ 的变化趋势。],
) <fig:harmonic-asymptotic>

由 @fig:harmonic-asymptotic 可见： $H_n$ 与 $ln n$ 均随 $n$ 增大而增长，但二者之差逐渐趋近于欧拉—马歇罗尼常数 $gamma$。

= 调和级数的推广

调和级数的概念可以自然地推广到所谓的 $p$-级数：

$ zeta(p) = sum_(n=1)^oo 1/n^p $

根据 $p$ 的取值不同，$p$-级数表现出截然不同的收敛行为：当 $p > 1$ 时级数收敛，当 $p <= 1$ 时级数发散。调和级数恰好对应于 $p = 1$ 这一临界情形，因此它是区分收敛与发散的边界案例。

特别地，当 $p = 2$ 时，我们得到著名的巴塞尔问题（Basel Problem），欧拉在1734年证明了其和为 $pi^2/6$。交替调和级数 $sum_(n=1)^oo (-1)^(n+1)/n$ 则是一个条件收敛的级数，其和为 $ln 2$，但通过重排其项可以使其收敛到任意实数甚至发散——这正是黎曼重排定理的一个经典示例。






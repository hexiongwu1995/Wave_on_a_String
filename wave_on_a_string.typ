#set page(
  paper: "a4",
  flipped: false,
  margin: 1.5cm,
  numbering: "1/1",
  number-align: center,
  fill: rgb("#ffffff13"),
)

#set document(
  title: [弦上波的数学模型],
  author: ("何雄武",),
  date: datetime(year: 2026, month: 5, day: 6),
  keywords: ("数学建模", "弦上波模型"),
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

#set math.equation(numbering: "(1)", supplement: [Eq.])

#show math.equation: set block(breakable: false)

#import "@preview/cetz:0.5.0"
#import "@preview/gentle-clues:1.3.1": *
#import "@preview/physica:0.9.8": *
#import "@preview/numty:0.1.0" as nt
#show: gentle-clues.with(
  breakable: true,
)

#title()


= 真实物理模型

+ 如@Schematic_Diagram_of_wave_on_a_string 所示，一根琴弦的两端被固定，弦长为$L(t)$，琴弦的线密度为$mu(x, t)$，弦上张力为$T(x,t)$。
+ 初始时刻$t=0$，将琴弦的位置$x_0$处向上拉伸至一个高度$A_0$，然后立刻释放琴弦。
+ 目标是求解琴弦的振动方程$y(x,t)$和琴弦单位长度上的回复力$f_y (x,t)$。

= 模型假设
+ 不考虑空气阻力、弦的内阻力和其它任何形式所造成的能量耗散。
+ 小振幅假设：将初始振幅$A_0$限定在较小的范围，比如：$A_0 /(L_0) < 1%$ ?
+ 当弦振动时，弦上各个位置处的受力和形变始终在随时间变化，因此，弦长$L(t)$是时间t的函数，琴弦上的张力$T(x,t)$是位置x和时间t的函数。
+ 在求解琴弦张力的竖直分量时，需要做两个近似：
  - 忽略琴弦的伸长，将$L(t)$近似为$L_0$
  - 将琴弦上的张力$T(x,t)$近似为静止时的琴弦预张力$T_0$
+ 当振幅较小时（小振幅假设），将琴弦上任意位置$x$处的线密度$mu(x, t)$近似为琴弦静止时的线密度$mu_0$。
+ 将$t=0$ 时刻的琴弦形状近似为三角形。




// CeTZ 绘图参数
#let L = 15
#let A = 0.5
#let H = 2
#let R = 1
#let bez-contr = (4, 1)
#let tube-pos = (10, 5)


// 真实数学建模时需要使用到的默认参数（与Javascript进行数据共享）
#let A_0 = 0.01           // 初始振幅，单位为 m，参数滑块数据范围：(0.005, 0.02)
#let L_0 = 0.6            // 弦长，单位为 m，参数滑块数据范围：(0.2, 1.0)
#let x_rel = 0.1          // 相对拨弦位置，无量纲，参数滑块数据范围：(0.1, 0.9)
#let x_0 = x_rel * L_0    // 拨弦位置，单位为 m，由相对拨弦位置计算得到
#let T_0 = 80             // 预张力，单位为 N，参数滑块数据范围：(70, 100)
#let mu_0 = 0.01          // 线密度，单位为 kg/m，参数滑块数据范围：(0.004, 0.01)
#let N_terms = 50           // 级数截断项数，无量纲，参数滑块数据范围：(1, 100)
#let simSpeed = 1e-4             // 动画速度系数，无量纲，参数滑块数据范围：(1e-4, 1e-3)



#figure(caption: [弦上波的示意图])[

  #align(center)[
    #cetz.canvas({
      import cetz.draw: *
      // 弦静止时的状态
      line((0, 0), (L, 0), stroke: (paint: gray, thickness: 2pt))
      // 绘制t=0时刻的三角波
      line((0, 0), (2, 0.35), (L, 0), stroke: (paint: rgb("#8d8d8d")), name: "Ini_Tri_Wave")
      circle((2, 0.35), radius: 0.2, name: "string_piece", stroke: (
        paint: rgb("#9d9d9d"),
        thickness: 1pt,
        dash: "dotted",
      ))
      circle(tube-pos, radius: 3, name: "string_detail")

      line("string_piece.10%", "string_detail.13%", stroke: (paint: rgb("#bcbcbc9a"), thickness: 1pt, dash: "dashed"))
      line("string_piece.55%", "string_detail.53%", stroke: (paint: rgb("#c0c0c0c3"), thickness: 1pt, dash: "dashed"))

      group({
        set-origin(tube-pos)
        line((-1.8, -1.7), (1.8, -1.7), mark: (end: (symbol: "stealth", fill: black)), name: "xaxis")
        move-to("xaxis.end")
        content((rel: (0.2, 0)), $x$)
        stroke(gray)
        // circle((0, 0), radius: 1pt)
        rotate(20deg)
        scale(0.8)
        arc((-1, -0.3), start: -90deg, stop: 90deg, radius: (0.1, 0.3), stroke: (
          paint: rgb("#5e5e5e8a"),
          dash: "densely-dotted",
        ))
        arc((1, 0.3), start: 90deg, stop: 270deg, radius: (0.1, 0.3), stroke: (paint: rgb("#5e5e5e8a"), dash: "solid"))
        merge-path(close: true, fill: rgb("#d6d6d67b"), stroke: rgb("#5e5e5e8a"), {
          // circle((0,0), radius:2pt, fill:orange, stroke:none)
          arc((-1, -0.3), start: 270deg, stop: 90deg, radius: (0.1, 0.3), name: "left")
          bezier((-1, 0.3), (1, 0.3), (0, 0.5))
          arc((1, 0.3), start: 90deg, stop: -90deg, radius: (0.1, 0.3), name: "right")
          bezier((1, -0.3), (-1, -0.3), (0, -0.1))
        })

        line("left.origin", (rel: (-2, 0)), mark: (end: (symbol: "stealth", fill: gray, scale: 0.5)), name: "a")
        line("right.origin", (rel: (2, 0)), mark: (end: (symbol: "stealth", fill: gray, scale: 0.5)), name: "b")
        rotate(-20deg)
        line("left.origin", (rel: (-2, 0)), stroke: (dash: "densely-dotted"), name: "c")
        line("right.origin", (rel: (2, 0)), stroke: (dash: "densely-dotted"), name: "d")
        cetz.angle.angle(
          "a.start",
          "a.end",
          "c.end",
          direction: "cw",
          radius: 80%,
          mark: (end: (symbol: "stealth", scale: 0.3)),
          label: $alpha$,
          label-radius: 80%,
        )
        cetz.angle.angle(
          "b.start",
          "b.end",
          "d.end",
          direction: "cw",
          radius: 80%,
          mark: (end: (symbol: "stealth", scale: 0.3)),
          label: $beta$,
          label-radius: 80%,
        )
        anchor("HL", (project: "left.origin", onto: ("xaxis.start", "xaxis.end")))
        anchor("HR", (project: "right.origin", onto: ("xaxis.start", "xaxis.end")))
        anchor("HC", (project: (0, 0), onto: ("xaxis.start", "xaxis.end")))
        set-style(stroke: (dash: "densely-dotted"))
        line("left.origin", (rel: (0, -25pt), to: "HL"))
        line("right.origin", (rel: (0, -25pt), to: "HR"))
        line((0, 0), "HC", mark: (start: (symbol: "stealth", scale: 0.5)), name: "y")
        set-style(content: (frame: "rect", fill: white, strike: none, padding: 1pt))
        // content("yaxis.mid", $y$)
        set-style(stroke: none)
        content("a.end", $T_1$, anchor: "east")
        content("b.end", $T_2$, anchor: "west")
        set-style(content: (frame: "rect", fill: white))
        content((rel: (0, -2pt), to: "HC"), $x$, anchor: "north")

        line(
          (rel: (0, -20pt), to: "HL"),
          (rel: (0, -20pt), to: "HR"),
          stroke: (paint: gray),
          mark: (symbol: "stealth", scale: 0.3),
          name: "Delta",
        )
        content("Delta.mid", $Delta x$)
        content("y.mid", $y$)
      })
      rect((-0.1, -H / 2), (0.1, H / 2), fill: gradient.linear(gray, white))
      rect((L - 0.1, -H / 2), (L + 0.1, H / 2), fill: gradient.linear(gray, white))
    })]
]<Schematic_Diagram_of_wave_on_a_string>





= 微元受力分析

== 建立坐标系
如@Schematic_Diagram_of_wave_on_a_string 所示，将静止时琴弦的水平向右方向取为$x$轴正向，竖直向上的方向取为$y$轴正向，取琴弦的左侧固定点作为坐标系原点。

== 取一小段微元做受力分析

在琴弦的任意位置$x$处取一段微元，长度为$Delta x$，质量近似为$mu_0 Delta x$。由于这段微元在实际的振动过程中几乎只沿$y$方向振动，在$x$方向的位移很小，因此，可近似将该段微元在$x$方向的合外力视为零？


即：$T_2 cos(beta) - T_1 cos(alpha) =0$ <x-component>

记：$ T_x = T_1 cos(alpha) = T_2 cos(beta) $ <x-constant>

这段微元在$y$方向的受力情况为：

$ T_2 sin(beta) - T_1 sin(alpha) = mu_0 Delta x (partial^2 y)/(partial t^2) $<y-component>

#abstract(title: "等式右侧是否需要带负号？")[
  上述等式@y-component  是根据牛顿第二定律 $F = m a$，分别在等式两侧代入定义表达式后得到，不需要考虑符号。
  右侧的表达式$(partial^2 y)/(partial t^2)$ 就是加速度的定义，不需要额外添加符号。
]

在等式 @y-component 两端同时除以 $T_x$得：

$
  (T_2 sin(beta))/(T_2 cos(beta)) - (T_1 sin(alpha))/(T_1 cos(alpha)) = (mu_0 Delta x)/(T_x) dot (partial^2 y)/(partial t^2)
$

等价变形得： $ (tan(beta) - tan(alpha) )/(Delta x) = mu_0 / T_x dot (partial^2 y)/(partial t^2) $<slope>

进一步变形得：$ ( lr((partial y)/(partial x)|)_(x+ 0.5 times Delta x) - lr((partial y)/(partial x) |)_(x - 0.5 times Delta x) )/(Delta x) = mu_0/T_x dot (partial^2 y)/(partial t^2) $ <Second-Partial-Derivative>

等式 @Second-Partial-Derivative 左侧是 y 对 x的二阶偏导。整理得：


$ (partial^2 y)/(partial x^2) = mu_0/T_x dot (partial^2 y)/(partial t^2) $<wave_equation>

#question(title: [琴弦张力的水平分量$T_x$是否等于琴弦的静止预张力$T_0$？])[
  上式@wave_equation 是琴弦振动的波动方程，其中：$mu_0$是琴弦静止状态下的线密度，$T_x$是琴弦振动时的张力在水平方向上的分量，不确定它是否等于琴弦静止状态下的预张力$T_0$？

  GPT-5.5 解答：由 @x-constant 可知，当忽略x方向的加速度时，琴弦振动时，琴弦上各个位置处的张力的水平分量为恒定值$T_x$。在小振幅、忽略弦伸长和水平运动的线性模型中，$T_x$ 可近似等于静止预张力 $T_0$。即，在小振幅线性波动方程中，可以取 $T_x approx T_0$。在有限振幅或非线性模型中，不能严格认为二者恒等。
]


= 解偏微分方程


等式 @wave_equation 可以写成如下形式：

#abstract(title: [波动方程])[
  $
    (partial^2 y)/(partial x^2) &= mu_0/T_0 dot (partial^2 y)/(partial t^2) #linebreak() &= 1/c^2 (partial^2 y)/(partial t^2) #h(1cm) inline(c= sqrt(T_0/mu_0) "是波速")
  $<Wave_Equation>]


这是一个二阶线性偏微分方程，尝试使用分离变量法求解：

假设函数$y(x,t)$可以写成这种分离变量的形式：$ y(x,t) = X(x) dot T(t) $<seperation_of_variables>


注意：这里的$T(t)$指的不是张力T随时间t变化的函数，而是关于单一自变量-时间t的未知函数。

对x求导得：$(partial y)/(partial x) = T(t) (d X)/(d x)$

继续对x求导得：$(partial^2 y)/(partial x^2) = T(t) (d^2 X)/(d x^2)$

同理可得：$(partial^2 y)/(partial t^2) = X(x) dot (d^2 T)/(d t^2)$

代入 @Wave_Equation 得：$ T(t) (d^2 X)/(d x^2) = 1/c^2 dot X(x) (d^2 T)/(d t^2) $

等式两端同除 @seperation_of_variables 得：$ 1/X dot (d^2 X)/(d x^2) = 1/c^2 dot 1/T (d^2 T)/(d t^2) $

由于等式左侧仅与自变量x有关，等式右侧仅与自变量t有关。当 x 和 t 独立变化时，要使等式恒成立，两侧只能等于同一个常数C。令等式两侧都等于常数C可得如下微分方程组。

#question(title: [这里是否需要考虑C是虚数或复数的情况？])[
  答：不需要考虑C是虚数或复数的情况，因为目标函数y(x,t)是一个实函数，而且，波动解的物理意义要求X(x)与T(t)都是实函数。因此，只需要考虑常数C为实数的情况。而且，即使强行引入复数情况，也无法同时满足实边界条件和实初值条件。
]

== 解微分方程组

#abstract(title: [二阶常系数齐次线性微分方程组])[
  方程 @Eq-Space 对应的是空间部分，方程 @Eq-Time 对应的是时间部分。
  $ (d^2 X)/(d x^2) - C X =0 $<Eq-Space>

  $ (d^2 T)/(d t^2) - C dot c^2 dot T = 0 #h(1cm) "其中：" c = sqrt(T_0/mu_0) $<Eq-Time>
]

== 微分方程组的边界条件

由于物理模型是一个两端被固定的琴弦，这对应的边界条件是：


#set math.cases(reverse: true, gap: 1em)

$ cases(y(0,t)= X(0)T(t)= 0, T(t)"为非零解")#h(1cm) arrow.r.double.long #h(1cm) X(0)=0 $<BCs_0>

$ cases(y(L_0, t) = X(L_0)T(t) =0, T(t) "为非零解") #h(1cm) arrow.r.double.long #h(1cm) X(L_0) =0 $<BCs_L0>



== 求解空间微分方程

对于空间部分的微分方程 @Eq-Space ，相应的特征方程为：$r^2 = C$， 特征方程的解为：$r_(1,2) = plus.minus sqrt(C)$

当 $C > 0$时，对应的微分方程的通解为：$X(x) = C_1 e^(sqrt(C)x) + C_2 e^(-sqrt(C)x)$

当 $C = 0$时，对应的微分方程的通解为：$X(x) = C_1 + C_2 x$

当 $C < 0$时，对应的微分方程的通解为：$X(x) = C_1 cos(sqrt(-C)x) + C_2 sin(sqrt(-C)x)$

#abstract(
  title: [注意],
)[这里的$C_1$和$C_2$都必须是实常数，因为原微分方程中的函数X(x)是实函数，系数C也是实数，对于实初值条件，解也一定是实函数，这要求通解形式能产生实函数。]




#{
  set text(size: 0.8em)

  table(
    columns: 5,
    inset: 1em,
    fill: (_, y) => { if y == 0 { rgb("#79bdc946") } else { none } },
    align: (x, y) => { if x == 2 and y != 0 { right + horizon } else { center + horizon } },
    "常数C", "通解形式", "代入边界条件", "系数", "满足边界条件的特解",
    [$C>0$],
    [$X(x) = C_1 e^(sqrt(C)x) + C_2 e^(-sqrt(C)x)$],
    [$cases(C_1 + C_2 =0, C_1(e^(sqrt(C) L_0)- e^(-sqrt(C) L_0))=0, L_0 >0)$],
    [$C_1 =C_2=0$],
    [$X(x)=0$],

    [$C=0$], [$X(x) = C_1 + C_2 x$], [$cases(C_1 =0, C_2 L_0=0, L_0>0)$], [$C_1=C_2=0$], [$X(x)=0$],
    [$C<0$],
    [$X(x) = C_1 cos(sqrt(-C)x) + C_2 sin(sqrt(-C)x)$],
    [$cases(C_1=0, C_2 sin(sqrt(-C) L_0)=0, L_0>0)$],
    [可令$C = -k^2, k>0$ \ 得：$k= (n pi)/L_0$],
    [得非零特解：$X_n (x) = C_(2, n) sin((n pi)/L_0 x)$ \ 其中$C_(2, n)$可取任意常数 \ 其中 $n in NN^+$],
  )
}

即，满足边界条件的空间微分方程的特解为：
$ X_n (x) =C_(2, n) sin(k_n x) #h(1cm) "其中：" k_n = (n pi)/L_0 $<Particular_Solution_of_Space_Differential_Equation>




#abstract(title: [空间微分方程的解])[
  X(x)可以取下面这种通解形式，但是由这种通解形式构造出的完整解形式太复杂，不利于在代入初始三角波条件后求解系数。因此，需要先构造出特殊的完整解形式，然后代入初始的三角波条件求解系数。
  $
    cancel(X(x) = sum_(n=1)^(infinity) C_(2, n) sin(k_n x) #h(1cm) "其中：" k_n = (n pi)/L_0, cross: #true)
  $<Solution_of_Space_Differential_Equation>
]


== 微分方程组的初始条件

// 这个位置初始条件隐含在初始三角波的初始条件当中
// $
//   y(x_0, 0)= X(x_0) T(0) = A
// $<Initial_Condition_position>

$
  cases(lr((partial y)/(partial t)|)_(t=0) = X(x) dot lr((d T)/(d t) |)_(t=0) =0, X(x) equiv.not 0) #h(1cm) arrow.double.long.r #h(1cm) lr((d T)/(d t)|)_(t=0) =0
$<Initial_Condition_velocity>

#set math.cases(reverse: false)
$
  y(x,0)= X(x) T(0)= cases(A_0/x_0 x #h(3.7cm) 0<= x<= x_0, A_0/(L_0 - x_0) (L_0 - x) #h(1.9cm) x_0 < x <= L_0)
$<Initial_Triangle_Wave>


== 求解时间微分方程

对于时间微分方程 @Eq-Time ，相应的特征方程为：$r^2 - c^2 dot C=0$，代入 $C= -k_n^2, #h(1em) k_n= (n pi)/L_0$，解得：

$ r_(1,2)= plus.minus i dot c dot k_n $

则时间微分方程的特解为：

$ T_n (t)= D_(1, n) cos(omega_n t) + D_(2, n) sin(omega_n t) #h(1cm) "其中：" omega_n = c dot k_n $

对时间t求导得：

$ (d T_n )/(d t) = D_(2, n) omega_n cos(omega_n t) - D_(1, n) omega_n sin(omega_n t) $

代入初始速度条件 @Initial_Condition_velocity ，解得：$D_(2, n) =0$

因此：$ T_n (t) = D_(1, n) cos(omega_n t) #h(1cm) "其中：" omega_n = c dot k_n #h(1cm) k_n= (n pi)/L_0 $

为了确定系数 $D_(1, n)$和$C_(2, n)$，需要先构造完整解形式。

== 构造完整解

由于每一个 $X_n (x) dot T_n (t) = C_(2,n) sin(k_n x) dot D_(1,n) cos(omega_n t)$ 都是波动方程 @Wave_Equation 的线性无关的特解，则可取 $y(x,t)$的通解形式为：

$
  y(x, t) & = sum_(n=1)^(infinity) X_n (x) T_n (t) #linebreak() & = sum_(n=1)^(infinity) (C_(2, n) D_(1, n) sin(k_n x) cos(omega_n t) ) #h(1cm)
$

其中：  $k_n = (n pi)/L_0 #h(1cm) omega_n = c dot k_n #h(1cm) n in NN^+$

则：

$ y(x,0) = sum_(n=1)^(infinity) (C_(2, n) D_(1, n) sin((n pi)/L_0 x)) $

结合等式 @Initial_Triangle_Wave 得：

$
  sum_(n=1)^(infinity) (C_(2, n) D_(1, n) sin((n pi x)/L_0)) = cases(A_0/x_0 x #h(3.7cm) 0<= x<= x_0, A_0/(L_0 - x_0) (L_0 - x) #h(1.9cm) x_0 < x <= L_0)
$<Fourier_Series_Form>

这是一个傅里叶正弦级数展开的形式，可以由傅里叶正弦级数的系数公式确定 $C_(2, n) D_(1, n)$的值。

对比傅里叶正弦级数的展开形式可知：

#text(size: 8pt)[$
  b_n &= C_(2, n) D_(1, n) #linebreak() &= 2/L_0 integral_(0)^(L_0) y(x,0) sin((n pi x)/L_0) d x #linebreak() &= 2/L_0 (A_0/x_0 integral_0^(x_0) x sin((n pi x)/L_0) d x + (A_0 L_0)/(L_0 -x_0) integral_(x_0)^(L_0) sin((n pi x)/L_0) d x - A_0/(L_0 - x_0) integral_(x_0)^(L_0) x sin((n pi x)/L_0) d x ) #linebreak() &= (2A_0)/(L_0 x_0) integral_0^(x_0) x sin(k_n x) d x + (2A_0)/(L_0 - x_0) integral_(x_0)^(L_0) sin(k_n x) d x - (2A_0)/(L_0 (L_0 - x_0)) integral_(x_0)^(L_0) x sin(k_n x) d x #linebreak() &= - (2A_0)/(L_0 x_0 k_n) ( (x cos(k_n x)) lr(|, size: #200%)_0^(x_0) - integral_0^(x_0) cos(k_n x) d x) - (2A_0)/((L_0 - x_0)k_n) cos(k_n x) lr(|, size: #200%)_(x_0)^(L_0) + (2A_0)/(L_0 (L_0 - x_0) k_n) (x cos(k_n x) lr(|, size: #200%)_(x_0)^(L_0) - integral_(x_0)^(L_0) cos(k_n x) d x) #linebreak() &= - (2A_0)/(L_0 x_0 k_n) (x_0 cos(k_n x_0) - 1/k_n sin(k_n x_0)) - (2A_0)/((L_0 -x_0)k_n) (cos(k_n L_0) - cos(k_n x_0)) #linebreak() & + (2A_0)/(L_0(L_0 - x_0)k_n) (L_0 cos(k_n L_0) - x_0 cos(k_n x_0) - 1/k_n (sin(k_n L_0) - sin(k_n x_0)))
  #linebreak() &= 2(- A_0/(L_0 k_n) + A_0/((L_0 - x_0)k_n) - (A_0 x_0)/(L_0(L_0 - x_0)k_n)) cos(k_n x_0) + 2(- A_0/((L_0 - x_0)k_n) + A_0/((L_0 - x_0)k_n))cos(k_n L_0) #linebreak() & + 2(A_0/(L_0 x_0 k_n^2) + A_0/(L_0 (L_0 -x_0) k_n^2)) sin(k_n x_0) - (2A_0)/(L_0(L_0 - x_0) k_n^2) sin(k_n L_0)
  #linebreak() &= 0 + 0 + (2A_0)/(L_0 k_n^2) dot L_0/(x_0(L_0- x_0)) sin(k_n x_0) - 0
  #linebreak() &= (2A_0)/(x_0(L_0 - x_0) k_n^2 ) sin(k_n x_0) #h(1cm) "其中：" k_n= (n pi)/L_0 #linebreak() &= (2 A_0 L_0^2)/(x_0(L_0 - x_0) pi^2 n^2) sin((n pi x_0)/L_0)
$]


则，完整解为：

#abstract(title: [满足所有边界条件和初始条件（初始三角波）的完整解$y(x,t)$为：])[
  $
    y(x,t) & = sum_(n=1)^(infinity) X_n (x) T_n (t) #linebreak() & = underbrace(sum_(n=1)^(infinity) (b_n sin(k_n x) cos(omega_n t)), "驻波") #linebreak() &= 1/2 sum_(n=1)^(infinity) (b_n ( underbrace(sin(k_n x + omega_n t), "左行波") + underbrace(sin(k_n x - omega_n t), "右行波") ) )
  $<Complete_Solution>

  核心物理意义：两端固定的弦在初始三角波激励下的自由振动，可以分解为无穷多个简正模态的驻波叠加，而每个驻波又可以进一步分解为一对反向传播的行波。系数 $b_n$ 随 $1/n^2$衰减，说明高阶谐波的贡献迅速减小，实际振动主要由前几阶模态主导。
]


#abstract(title: [驻波形式（级数叠加和模态分析）])[
  物理意义：
  - 每个 n 对应一个谐波（第 n 阶模态），弦的振动被分解为无穷多个驻波模式（即简正模）的线性叠加：
    - $sin(k_n x)$：空间形状因子（波节在两端，中间有 n−1 个节点），决定了弦上各点的振动幅度分布（波节和波腹位置固定）。
    - $cos(omega_n t)$：时间振动因子，$omega_n$为角频率，决定了每个模态随时间简谐振动的快慢。
    - $b_n$：该模态的振幅系数（由初始三角波决定）
  - 驻波的特点是波节和波腹位置固定，不随时间移动。
]

#abstract(title: [行波形式])[
  利用三角恒等式$sin A cos B = 1/2 (sin(A+B)+sin(A−B))$，将驻波分解为两个反向传播的行波：

  - $sin(k_n x + omega_n t)$：左行波（向左传播，+ 号表示波随时间增加向左移动）
  - $sin(k_n x - omega_n t)$：右行波（向右传播，− 号表示波随时间增加向右移动）
  - 这表明：驻波可以看作两列振幅相同、传播方向相反的行波的叠加，这是波动理论中的一个核心结论。
]




其中：

$ b_n = (2 A_0 L_0^2)/(x_0(L_0 - x_0) pi^2 n^2) sin(k_n x_0) #h(1cm) n in NN^+ $

$ k_n = (n pi)/L_0 $

$ omega_n = c dot k_n $


注意到：$k_n lambda_n = 2 pi$， $omega_n T_n = 2 pi$ （这里的$T_n$代表时间周期）

因此，$k_n$称为波数？？？ $omega_n$称为角频率，$c= sqrt(T_0/mu_0)$称为波速（相速度）。

可以确认：$k_n$ 确实被称为波数（angular wave number），这是标准物理术语。

= 求解思路解析

求解思路正确，边界条件和初始条件是偏微分方程定解问题的两个独立组成部分。

- 边界条件决定了空间基函数（特征函数系）
- 初始条件决定了叠加系数（以及时间演化形式)

#table(
  columns: 3,
  inset: 1em,
  fill: (_, y) => { if y == 0 { rgb("#79bdc946") } else { none } },
  align: left + horizon,
  table.header("", "边界条件", "初始条件"),
  [约束对象], [$X(x)$（空间函数）], [$T(t)$ 和 $b_n$（时间函数和系数）],
  [时间范围], [对所有 $t≥0$], [仅在 $t=0$],
  [在分离变量法中的角色], [确定特征值 $k_n$ 和特征函数 $sin(k_n x)$], [确定傅里叶系数 $b_n$ 和时间函数 $T_n (t)$],
  [物理意义], [决定弦的振动模式（驻波形状）], [决定每个模式的振幅和时间演化],
)

= 琴弦上的张力在竖直方向上的分量 $T_y (x, t)$

#abstract(title: "张力的严格数学定义")[
  如弦上波模型的示意图 @Schematic_Diagram_of_wave_on_a_string 所示：
  - 取微元段右侧截面处受到的截面右侧弦的拉力作为张力$arrow(T)(x,t) = |T(x,t)| vec(cos theta, sin theta)$。
  - 根据这个定义，张力的竖直分量

  $
    T_y (x,t) &= arrow(T)(x,t) dot hat(y) #linebreak() &= |T(x,t)| vec(cos theta, sin theta) dot vec(0, 1) #linebreak() &= |T(x,t)| sin theta
  $

  - 张力的竖直分量的方向是否总与位移的方向相反？类似于弹簧的回复力？
  - 提供回复力的不是单点的 $T_y$ ，而是微元段两端 $T_y$ 的差值（净力）。所以净力确实与位移相反（回复力），但单点的 $T_y$ 不是这样。
]

则：

$
  T_y (x, t) & = |T(x, t)| dot sin [theta^#footnote[$theta$ 是指弦的切线方向与水平线之间的夹角 $- pi/2 < theta < pi/2$] (x, t)] #linebreak() & = |T(x, t)| dot cos[theta(x, t)] dot tan[theta(x, t)]
$



#abstract(title: [近似])[
  由小振幅假设：
  - 将 $cos(theta(x, t))$ 近似为 1
  - 将琴弦上的张力的模长 $|T(x ,t)|$近似为静止预张力$T_0$
]

则：

$ T_y (x,t) & = T_0 tan(theta(x, t)) $

$ T_y (x,t) = T_0 dot (partial y)/(partial x) $<Y_component_of_Tension>


对等式 @Complete_Solution 的行波形式求偏导得：

$
  (partial y)/(partial x) = 1/2 sum_(n=1)^(infinity) lr({ b_n k_n lr([ cos(k_n x + omega_n t) + cos(k_n x - omega_n t) ], size: #200%) }, size: #150%)
$


#abstract(title: [琴弦张力的竖直分量$T_y (x,t)$])[
  $
    T_y (x,t) &= T_0/2 dot sum_(n=1)^(infinity) lr({ b_n k_n lr([ underbrace(cos(k_n x + omega_n t), "左行波") + underbrace(cos(k_n x - omega_n t), "右行波") ], size: #100%) }, size: #110%) #linebreak() &= T_0 dot sum_(n=1)^(infinity) lr({ underbrace(b_n k_n dot cos(k_n x) cos(omega_n t), "驻波形式") }, size: #100%)
  $
]

= 琴弦上的回复力

如弦上波模型的示意图 @Schematic_Diagram_of_wave_on_a_string 所示，琴弦微元段上的回复力：$ F_y & = T_2 sin beta - T_1 sin alpha #linebreak() & = T_x (tan beta - tan alpha) #linebreak() $

将 $T_x$ 近似为静止时的琴弦预张力$T_0$，则：

$
  F_y approx T_0 (partial^2 y)/(partial x^2) Delta x
$

琴弦单位长度上的回复力$f_y$
$ f_y & = F_y / (Delta x) #linebreak() & approx T_0 (partial^2 y)/(partial x^2) $


对等式 @Complete_Solution 的行波形式求偏导得：

$
  (partial y)/(partial x) = 1/2 sum_(n=1)^(infinity) lr({ b_n k_n lr([ cos(k_n x + omega_n t) + cos(k_n x - omega_n t) ], size: #200%) }, size: #150%)
$

继续求二阶偏导得：

$
  (partial^2 y)/(partial x^2) &= - 1/2 sum_(n=1)^(infinity) lr({ b_n k_n^2 lr([ sin(k_n x + omega_n t) + sin(k_n x - omega_n t) ], size: #150%) }, size: #110%) #linebreak() &= - sum_(n=1)^(infinity) lr({ b_n k_n^2 dot sin(k_n x) cos(omega_n t) }, size: #110%)
$


则：

#abstract(title: [琴弦单位长度上的回复力$f_y$])[
  $
    f_y & approx T_0 (partial^2 y)/(partial x^2) #linebreak() & = - T_0 sum_(n=1)^(infinity) lr({ underbrace(b_n k_n^2 dot sin(k_n x) cos(omega_n t), "驻波形式") }, size: #100%) #linebreak() &= - T_0/2 sum_(n=1)^(infinity) lr({ b_n k_n^2 lr([ underbrace(sin(k_n x + omega_n t), "左行波") + underbrace(sin(k_n x - omega_n t), "右行波") ], size: #100%) }, size: #100%)
  $
]


= 弦上波的能量

由初始假设，初始时刻 t=0 时，琴弦的形状为三角形，需要求解此时琴弦上的能量。




#pagebreak()


= 附录一：周期函数 $f(x)$ 的傅里叶级数

//以下为傅里叶级数的一般理论，上文求解中使用的正弦级数展开即基于此。

== 基本定理陈述

设 $f(x)$ 是以 $T$ 为周期的周期函数，且在任意一个长度为 $T$ 的区间上绝对可积，则 $f(x)$ 可以展开为傅里叶级数：

$ f(x) tilde frac(a_(0), 2) + sum_(n = 1)^(infinity)[ a_(n) cos(frac(2 pi n x, T)) + b_(n) sin(frac(2 pi n x, T)) ] $

其中符号 $tilde$ 表示右边的级数是由 $f$ 的傅里叶系数形式构造的，要使其真正等于 $f(x)$，还需附加收敛条件。

#abstract(title: [绝对可积])[
  可积 (Integrable)的直觉含义：函数 $f(x)$ 在区间 [a,b] 上的积分存在（有限值）。

  绝对可积 (Absolutely Integrable)的直觉含义：$|f(x)|$是可积的，即$display(integral)_a^b |f(x)| d x < infinity$

  傅里叶级数展开定理要求$f(x)$在$[x_0, x_0 +T]$上是绝对可积的，即$display(integral)_(x_0)^(x_0 +T) |f(x)|d x < infinity$

  绝对可积要求$|f(x)|$的积分有限，而可积只要求$f(x)$本身的积分有限（可能通过正负抵消而收敛）。

  这比"可积"的要求更强 —— 它排除了条件收敛的情形，确保：傅里叶系数（含 $|f(x) cos|$、$|f(x) sin|$）的积分绝对收敛，系数定义良好？？？

  傅里叶级数理论要求绝对可积，是为了保证系数公式在更一般的意义下成立？？？
]

== 傅里叶系数公式

利用三角函数系在区间 $[x_(0), x_(0) + T ]$ 上的正交性，可得系数公式（与起点 $x_(0)$ 无关）：

$ a_(0) = 2/T integral_(x_(0))^(x_(0)+ T) f(x) thin d x #h(3.8cm) $

$ a_(n) = 2/T integral_(x_(0))^(x_(0)+ T) f(x) cos(frac(2 pi n x, T)) d x #h(1cm) n >= 1 $

$ b_(n) = 2/T integral_(x_(0))^(x_(0)+ T) f(x) sin(frac(2 pi n x, T)) d x #h(1cm) n >= 1 $





== 正交性基础（为什么系数公式成立）

三角函数系

$ { 1,thick cos frac(2 pi n x, T),thick sin frac(2 pi n x, T) quad(n = 1, 2, 3, ...) } $

在任意长度为 $T$ 的区间 $[x_(0), x_(0)+ T ]$ 上满足正交关系，且结果与起点 $x_(0)$ 无关：

① 余弦-余弦正交：

$
  integral_(x_(0))^(x_(0)+ T) cos frac(2 pi m x, T) cos frac(2 pi n x, T) d x = cases(0 #h(1cm) & m != n, display(frac(T, 2)) #h(1cm) & m = n != 0, T #h(1cm) & m = n = 0) #h(1cm) forall m,n in NN
$

#abstract(title: [证明])[
  证明：$display(integral_(x_(0))^(x_(0)+ T) cos frac(2 pi m x, T) cos frac(2 pi n x, T) d x =0 #h(1cm) "当" m!=n "时")$

  提示：使用积化和差公式 $display(cos A cos B = 1/2 [cos(A+B) + cos(A-B)])$
]

② 正弦-正弦正交：

$
  integral_(x_(0))^(x_(0)+ T) sin frac(2 pi m x, T) sin frac(2 pi n x, T) d x = cases(0 #h(1cm) & m != n, display(frac(T, 2)) #h(1cm) & m = n != 0, 0 #h(1cm) & m = n = 0) #h(1cm) forall m,n in NN
$

#abstract(title: [证明])[
  证明：$display(integral_(x_(0))^(x_(0)+ T) sin frac(2 pi m x, T) sin frac(2 pi n x, T) d x =0 #h(1cm) "当" m!=n "时")$

  提示：使用积化和差公式 $display(sin A sin B = 1/2 [cos(A-B) - cos(A+B)])$
]


③ 余弦-正弦正交（跨族正交）：

$ integral_(x_(0))^(x_(0)+ T) cos frac(2 pi m x, T) sin frac(2 pi n x, T) d x = 0 #h(1cm) forall m \, n in NN $

#abstract(title: [证明])[
  证明：$display(integral_(x_(0))^(x_(0)+ T) cos frac(2 pi m x, T) sin frac(2 pi n x, T) d x =0 #h(1cm) forall m \, n in NN)$

  提示：使用积化和差公式 $display(cos A sin B = 1/2[sin(B+A) + sin(B-A)])$
]

== 推导思路（求解系数）

=== 正交展开法

假设 $f(x)$ 可以展开为：

$
  f(x) tilde frac(A_(0), 2) + sum_(n = 1)^(infinity)[ A_(n) cos(frac(2 pi n x, T)) + B_(n) sin(frac(2 pi n x, T)) ]
$<Fourier_Series_Expansion>

#abstract(title: [$n in NN^+$])[
  不需要求解 $B_0$
]

两边同乘 $cos((2 pi m x) / T)$ 并在 $[x_(0), x_(0)+ T ]$ 上积分，利用正交性，只有 $n = m$ 的项非零，得到：

$
  integral_(x_(0))^(x_(0)+ T) f(x) cos(frac(2 pi m x, T)) d x =cases(A_n T/2 #h(1cm) & m !=0, A_0 T/2 #h(1cm) &m=0) #h(1cm) = #h(0.5cm) A_(m) dot T/2
$

因此，$A_m$ 也即$A_n$等于：

$ A_(m) = 2/T integral_(x_(0))^(x_(0)+ T) f(x) cos(frac(2 pi m x, T)) d x #h(1cm) m in NN $


等式 @Fourier_Series_Expansion 两端同乘 $sin((2 pi m x)/T)$，并在区间 $[x_0, x_0 +T]$上积分，利用正交性，只有 $m=n$ 的项非零，得到：

$ integral_(x_0)^(x_0 +T) f(x) sin((2 pi m x)/T)d x = cases(B_n T/2 #h(1cm) & m!=0, 0 #h(1cm) & m=0) #h(1cm) = B_m T/2 $

因此，$B_m$也即$B_n$等于：

$ B_m = 2/T integral_(x_0)^(x_0 +T) f(x) sin((2 pi m x)/T)d x #h(1cm) m in NN^+ $


== 收敛条件（狄利克雷条件）

若 $f(x)$ 在 $[x_(0), x_(0)+ T ]$ 上满足：

+ 绝对可积：$display(integral_(x_(0))^(x_(0)+ T) | f(x)| d x < infinity)$
+ 有限个极值点：在任意有限区间内只有有限个极大值和极小值
+ 有限个第一类间断点：在任意有限区间内只有有限个跳跃间断点

则傅里叶级数收敛，且：

$ S(x) = frac(f(x^(+)) + f(x^(-)), 2) $

- 若 $f$ 在 $x$ 处连续，则 $S(x) = f(x)$
- 若 $x$ 是间断点，则 $S(x)$ 收敛于左右极限的算术平均值
- 在端点 $x_(0)$ 和 $x_(0)+ T$ 处（由于周期性，本质是同一点），$S(x_(0)) = display(frac(f(x_(0)^(+)) + f((x_0 + T)^-), 2))$

#abstract(title: [傅里叶级数的和函数$S(x)$])[
  S(x)就是式 @Fourier_Series_Expansion 右侧的函数值，它是由傅里叶系数构造出来的级数在点 x 处的收敛值。
  简单直觉：你不能直接用 f(x) 表示傅里叶级数的和，因为在间断点处级数不会收敛到 f(x) 本身（会 overshoot，即 Gibbs 现象），而是收敛到跳跃两边的"中间值"。所以引入 S(x) 来精确描述级数实际收敛到的值。
]

核心原理：三角函数在任意一个完整周期上的积分结果相同，因为被积函数是周期函数，积分值只依赖于区间长度 $T$，不依赖于起点 $x_(0)$。这就是为什么系数公式中的积分区间可以取任意起点。


== 复数形式

=== 级数展开为

$ f(x) tilde sum_(n = - infinity)^(infinity) c_(n) thin e^(i frac(2 pi n x, T)) $

=== 系数

$ c_(n) = 1/T integral_(x_(0))^(x_(0)+ T) f(x) thin e^(- i frac(2 pi n x, T)) d x $

=== 三角形式与复数形式的关系：

$ c_(n) = frac(a_(n) - i b_(n), 2), quad c_(- n) = frac(a_(n) + i b_(n), 2), quad c_(0) = frac(a_(0), 2) $



#pagebreak()

= 附录二： 傅里叶正弦级数

== 定义

若 $f(x)$ 定义在区间 $[0, L]$ 上，且满足狄利克雷条件，则 $f(x)$ 可以展开为**傅里叶正弦级数**（Fourier Sine Series）：

$ f(x) tilde sum_(n = 1)^(infinity) b_(n) sin(frac(n pi x, L)) $ <Sine_Series>

其中系数公式为：

$ b_(n) = 2/L integral_(0)^(L) f(x) sin(frac(n pi x, L)) d x #h(1cm) n in NN^+ $ <Sine_Coefficient>

== 物理意义

傅里叶正弦级数对应的是将 $f(x)$ 先做**奇延拓**到 $[-L, L]$，再做周期为 $2L$ 的周期延拓后展开为完整傅里叶级数，恰好只保留正弦项（$a_n = 0$）。

#abstract(title: [奇延拓])[
  构造一个奇函数 $F(x)$，使其在 $(0, L]$ 上等于 $f(x)$，且在 $x=0$ 处 $F(0)=0$：

  $ F(x) = cases(f(x) #h(3cm) & 0 < x <= L, -f(-x) #h(2cm) & -L <= x < 0, 0 #h(3cm) & x = 0) $

  将 $F(x)$ 以 $2L$ 为周期延拓到整个实数轴，展开成完整傅里叶级数后，所有余弦项系数 $a_n$ 均为零，只剩下正弦项。
]

== 在本文中的应用

在求解两端固定的弦振动问题时：

- 空间特征函数为 $X_n (x) = sin(frac(n pi x, L_0))$，这就是傅里叶正弦级数的基函数。
- 初始位移 $y(x,0)$ 在 $[0, L_0]$ 上展开为正弦级数，恰好对应了边界条件 $y(0,t)=y(L_0,t)=0$。
- 系数 $b_n$ 由公式 @Sine_Coefficient 给出，即：

$ b_n = 2/L_0 integral_(0)^(L_0) y(x,0) sin(frac(n pi x, L_0)) d x $

这正是本文求解 $C_(2,n) D_(1,n)$ 时使用的公式。

#abstract(title: [对比完整傅里叶级数])[
  完整傅里叶级数的基函数为 $sin(frac(2 pi n x, T))$（周期 $T$），而傅里叶正弦级数的基函数为 $sin(frac(n pi x, L))$（半周期 $L$）。二者不可混淆：
  - 完整傅里叶级数的周期为 $T$，频率为 $frac(2 pi n, T)$；
  - 傅里叶正弦级数的"周期"为 $2L$（奇延拓后），半区间 $[0, L]$ 上的频率为 $frac(n pi, L)$。

  在本文中，弦长 $L_0$ 对应的是半区间长度，基函数 $sin(frac(n pi x, L_0))$ 的频率为 $frac(n pi, L_0) = frac(2 pi n, 2 L_0)$，即完整傅里叶级数中周期 $T=2L_0$ 的情形。
]







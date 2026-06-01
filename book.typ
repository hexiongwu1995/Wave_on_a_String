#import "@preview/shiroa:0.3.1": *

#show: book

#book-meta(
  title: "弦上波的数学模型",
  authors: ("何雄武",),
  language: "zh",
  summary: [
    = 弦上波的数学模型
    - #chapter("src/wave_on_a_string.typ", section: "1")[弦上波的数学模型]
    = 数学常识
    - #chapter("src/数学常识.typ", section: "2")[数学常识]
  ],
)

#build-meta(
  dest-dir: "book",
)

// 导入页面模板并注册为 book-page
#import "/templates/page.typ": project
#let book-page = project

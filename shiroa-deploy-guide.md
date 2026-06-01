# 使用 Shiroa 将 Typst 文档构建为在线网站 — 标准化操作流程

## 目录

1. [前置条件](#1-前置条件)
2. [项目结构初始化](#2-项目结构初始化)
3. [配置 `book.typ`（书籍入口）](#3-配置-booktyp书籍入口)
4. [配置页面模板 `templates/page.typ`](#4-配置页面模板-templatespagetyp)
5. [中文字体配置](#5-中文字体配置)
6. [编写 Typst 章节源文件](#6-编写-typst-章节源文件)
7. [本地构建与预览](#7-本地构建与预览)
8. [配置 GitHub Pages 自动部署](#8-配置-github-pages-自动部署)
9. [主题颜色配置](#9-主题颜色配置)
10. [常见问题排查](#10-常见问题排查)

---

## 1. 前置条件

### 1.1 安装 Shiroa

Shiroa 是一个将 Typst 文档编译为交互式网站的 CLI 工具，底层依赖 `typst-ts` WebAssembly 渲染引擎。

**方式一：从预编译二进制安装（推荐）**

从 [Shiroa Releases](https://github.com/Myriad-Dreamin/shiroa/releases) 下载对应平台的二进制文件，放置到 PATH 目录中。

**方式二：通过 Cargo 安装**

```bash
cargo install --git https://github.com/Myriad-Dreamin/shiroa --locked shiroa
```

验证安装：

```bash
shiroa --version
# 输出示例: shiroa version 0.3.1-rc4 (features: embedded_fonts)
```

> **注意**：输出中应包含 `features: embedded_fonts`，表示 Shiroa 内嵌了中文字体（Source Han Serif SC 等），这对中文网站至关重要。

### 1.2 安装 Typst（可选，用于本地预览 PDF）

```bash
cargo install typst-cli
```

---

## 2. 项目结构初始化

推荐的项目目录结构如下：

```
my-book/
├── book.typ                  # 书籍入口文件（shiroa 配置文件）
├── templates/
│   ├── page.typ              # 页面模板
│   ├── ebook.typ             # 电子书模板（可选）
│   ├── theme-style.toml      # 主题颜色配置
│   └── tokyo-night.tmTheme   # 代码高亮主题
├── src/
│   ├── chapter1.typ          # 第1章源文件
│   └── chapter2.typ          # 第2章源文件
├── images/                   # 图片资源目录
├── docs/                     # 其他静态文件（可选）
├── .github/workflows/
│   └── deploy.yml            # GitHub Pages 自动部署
└── book/                     # 构建输出目录（自动生成，无需提交到 Git）
```

---

## 3. 配置 `book.typ`（书籍入口）

`book.typ` 是 Shiroa 的入口文件，定义书籍元数据和章节结构。

```typst
#import "@preview/shiroa:0.3.1": *

#show: book

#book-meta(
  title: "你的书籍标题",
  authors: ("作者名",),
  language: "zh",
  summary: [
    = 第一部分
    - #chapter("src/chapter1.typ", section: "1")[第一章标题]
    = 第二部分
    - #chapter("src/chapter2.typ", section: "2")[第二章标题]
  ],
)

#build-meta(
  dest-dir: "book",          // 构建输出目录
)

// 导入页面模板并注册为 book-page
#import "/templates/page.typ": project
#let book-page = project
```

### 关键参数说明

| 参数 | 说明 |
|------|------|
| `title` | 网站标题，显示在浏览器标签页和顶部导航栏 |
| `authors` | 作者列表 |
| `language` | 语言代码，中文设为 `"zh"` |
| `dest-dir` | 构建输出目录，默认为 `"book"` |

---

## 4. 配置页面模板 `templates/page.typ`

页面模板控制网站的整体布局、字体、颜色和样式。

### 4.1 完整的模板结构

```typst
#import "@preview/shiroa:0.3.1": (
  get-page-width, is-html-target, is-pdf-target, is-web-target,
  plain-text, shiroa-sys-target, templates,
)
#import templates: *

// === 主题检测 ===
#let web-theme = if is-html-target(exclude-wrapper: true) {
  "starlight"
} else {
  "mdbook"
}

// === 元数据 ===
#let page-width = get-page-width()
#let is-html-target = is-html-target()
#let is-pdf-target = is-pdf-target()
#let is-web-target = is-web-target()
#let sys-is-html-target = ("target" in dictionary(std))

// === 主题颜色（从 theme-style.toml 加载） ===
#let themes = theme-box-styles-from(toml("theme-style.toml"), read: it => read(it))
#let (default-theme: (style: theme-style, ...)) = themes;
#let theme-box = theme-box.with(themes: themes)

// === 字体配置 ===
#let main-font = (
  "Charter",
  "Source Han Serif SC",       // Shiroa 内嵌的宋体风格中文字体
  "Source Han Sans SC",        // Shiroa 内嵌的黑体风格中文字体
  "Noto Serif CJK SC",
  "Noto Sans CJK SC",
  "KaiTi",                     // Windows 楷体（本地构建时生效）
  "DengXian",                  // Windows 等线（本地构建时生效）
  "SimSun",                    // Windows 宋体（本地构建时生效）
  "Libertinus Serif",          // Shiroa 内嵌的西文字体
)
#let code-font = (
  "BlexMono Nerd Font Mono",
  "DejaVu Sans Mono",          // Shiroa 内嵌的等宽字体
)

// === 字号配置 ===
#let main-size = if is-web-target {
  20pt                          // 网页正文字号
} else {
  10.5pt                        // PDF 正文字号
}
#let heading-sizes = if is-web-target {
  (2, 1.5, 1.17, 1, 0.83).map(it => it * main-size)
} else {
  (26pt, 22pt, 14pt, 12pt, main-size)
}
#let list-indent = 0.5em

// === 自定义 CSS ===
#let extra-css = ```css
.site-title {
  font-size: 1.2rem;
  font-weight: 600;
  font-style: italic;
}
:root {
  font-size: 62.5%;
}
```

### 4.2 项目模板函数

```typst
#let project(title: "Typst Book", description: auto, authors: (), kind: "page", plain-body) = {
  set document(author: authors, title: title) if not is-pdf-target

  set page(numbering: none, number-align: center, width: page-width)
    if not (sys-is-html-target or is-html-target)

  set page(
    margin: (top: 20pt, left: 20pt, bottom: 0.5em, rest: 0pt),
  ) if is-web-target and not is-html-target

  let common = (web-theme: web-theme)

  show: template-rules.with(
    book-meta: include "/book.typ",
    title: title,
    description: description,
    plain-body: plain-body,
    extra-assets: (extra-css,),
    ..common,
  )

  set text(font: main-font, size: main-size, fill: main-color, lang: "en")

  show: markup-rules.with(
    ..common, themes: themes, heading-sizes: heading-sizes,
    list-indent: list-indent, main-size: main-size,
  )
  show: equation-rules.with(..common, theme-box: theme-box)
  show: code-block-rules.with(..common, themes: themes, code-font: code-font)

  set par(justify: true)
  plain-body
}

#let part-style = heading
```

---

## 5. 中文字体配置

### 5.1 原理说明

Shiroa 的 `dyn-paged` 模式使用 WebAssembly（WASM）在浏览器端渲染 Typst 页面。渲染流程如下：

1. **构建阶段**：Typst 编译器将 `.typ` 源文件编译为 `.multi.sir.in` 文件（序列化中间表示），其中包含文本内容和字体字形数据。
2. **运行时阶段**：浏览器加载 WASM 渲染模块，读取 `.multi.sir.in` 文件，在 Canvas 上渲染页面。

**中文字体显示为方框的原因**：如果构建环境中缺少中文字体，Typst 编译器无法获取中文字符的字形数据，导致 WASM 渲染器在浏览器中无法正确渲染中文字符（显示为带 X 的方框）。

### 5.2 字体配置策略

为确保中文字体在本地开发和 CI 部署中均能正常工作，采用**多层回退**策略：

#### 第 1 层：在 `templates/page.typ` 的 main-font 列表中

```typst
#let main-font = (
  "Source Han Serif SC",   // Shiroa 内嵌字体，CI 中可用
  "Source Han Sans SC",    // Shiroa 内嵌字体，CI 中可用
  "Noto Serif CJK SC",     // CI 中通过 fonts-noto-cjk 安装
  "Noto Sans CJK SC",      // CI 中通过 fonts-noto-cjk 安装
  "KaiTi",                 // Windows 本地字体
  "DengXian",              // Windows 本地字体
  "SimSun",                // Windows 本地字体
  "Libertinus Serif",      // Shiroa 内嵌西文字体
)
```

#### 第 2 层：在章节源文件的 `#set text` 中

```typst
#set text(
  lang: "zh",
  font: (
    "Cambria Math",
    "Source Han Serif SC",
    "Source Han Sans SC",
    "Noto Serif CJK SC",
    "Noto Sans CJK SC",
    "KaiTi",
    "DengXian",
    "SimSun",
  ),
  size: 20pt,
)
```

#### 第 3 层：在 CI 中安装中文字体

在 GitHub Actions 工作流中添加步骤（详见第 8 节）：

```yaml
- name: Install Chinese fonts
  run: sudo apt-get update && sudo apt-get install -y fonts-noto-cjk fonts-noto-cjk-extra
```

### 5.3 字体选择说明

| 字体名称 | 类型 | 可用平台 | 说明 |
|----------|------|----------|------|
| `Source Han Serif SC` | 宋体/衬线 | **Shiroa 内嵌**、Windows、Linux | Adobe 思源宋体，CI 中最可靠的选择 |
| `Source Han Sans SC` | 黑体/无衬线 | **Shiroa 内嵌**、Windows、Linux | Adobe 思源黑体 |
| `Noto Serif CJK SC` | 宋体/衬线 | Linux (apt) | Google Noto 中日韩宋体 |
| `Noto Sans CJK SC` | 黑体/无衬线 | Linux (apt) | Google Noto 中日韩黑体 |
| `KaiTi` | 楷体 | Windows 专属 | 仅在 Windows 本地构建时有效 |
| `DengXian` | 等线 | Windows 专属 | 仅在 Windows 本地构建时有效 |
| `SimSun` | 宋体 | Windows 专属 | 仅在 Windows 本地构建时有效 |
| `Cambria Math` | 数学 | Windows 专属 | 数学公式字体 |

> **重要**：字体列表按优先级排列。Typst 会从左到右依次查找，使用第一个找到的字体。因此，将 Shiroa 内嵌字体放在前面可确保 CI 构建也能正确渲染中文。

---

## 6. 编写 Typst 章节源文件

每个章节源文件以 `#import "../book.typ": book-page` 开头，应用模板样式。

### 示例：`src/chapter1.typ`

```typst
#import "../book.typ": book-page

#show: book-page.with(title: "第一章标题")

// 页面设置（会被模板覆盖，但用于 PDF 导出）
#set page(paper: "a4", margin: 1.5cm)

#set par(spacing: 2em, leading: 1em, justify: true)
#set heading(numbering: "1.1")

// 标题样式（仅影响 PDF，网页端由模板控制）
#show heading.where(level: 1): it => {
  counter(math.equation).update(0)
  v(1em)
  set text(size: 15pt, weight: "bold", fill: rgb("0066fff0"))
  it
  v(1em)
}

// 正文字体配置
#set text(
  lang: "zh",
  font: (
    "Cambria Math",
    "Source Han Serif SC",
    "Source Han Sans SC",
    "Noto Serif CJK SC",
    "Noto Sans CJK SC",
    "KaiTi",
    "DengXian",
    "SimSun",
  ),
  size: 20pt,
)

// ===== 正文内容开始 =====

= 一级标题

== 二级标题

这是正文内容。行内公式 $E = m c^2$，独立公式：

$
  integral_0^oo e^(-x) dif x = 1
$

// ... 更多内容
```

### 关键注意事项

1. **章节源文件位于 `src/` 目录**，与 `book.typ` 平级。
2. **`#import "../book.typ": book-page`** 路径是相对于 `src/` 目录的。
3. **`#show: book-page.with(title: "...")`** 为每个页面设置标题。
4. **网页端的字体和字号由 `templates/page.typ` 控制**，章节源文件中的 `#set text(size: ...)` 主要影响 PDF 导出。

---

## 7. 本地构建与预览

### 7.1 构建网站

在项目根目录执行：

```bash
# 基本构建（dyn-paged 模式，输出到 book/ 目录）
shiroa build --mode dyn-paged

# 指定输出目录
shiroa build --mode dyn-paged --dest-dir book

# 指定路径前缀（用于 GitHub Pages 子路径部署）
shiroa build --mode dyn-paged --path-to-root /your-repo-name/
```

### 7.2 构建模式说明

| 模式 | 说明 | 适用场景 |
|------|------|----------|
| `dyn-paged` | 动态分页渲染，使用 WASM 在浏览器中渲染 Typst 页面 | **推荐**，支持完整的 Typst 特性（数学公式、CeTZ 绘图等） |
| `static-html` | 静态 HTML 导出（实验性） | **不推荐**，数学公式等复杂元素会被忽略 |
| `static-html-dyn-paged` | 混合模式 | 介于两者之间 |

### 7.3 本地预览

使用 Python 的 HTTP 服务器预览构建结果：

```bash
# 从 book/ 目录启动服务器
cd book
python -m http.server 25522 --bind 127.0.0.1
```

然后打开浏览器访问 `http://127.0.0.1:25522`。

### 7.4 导出 PDF

```bash
typst compile src/chapter1.typ chapter1.pdf
```

---

## 8. 配置 GitHub Pages 自动部署

### 8.1 完整工作流文件

创建 `.github/workflows/deploy.yml`：

```yaml
name: Deploy shiroa book to GitHub Pages

on:
  push:
    branches: ["main"]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: true

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      # ===== 关键步骤：安装中文字体 =====
      - name: Install Chinese fonts
        run: sudo apt-get update && sudo apt-get install -y fonts-noto-cjk fonts-noto-cjk-extra

      - name: Install Rust toolchain
        uses: actions-rust-lang/setup-rust-toolchain@v1

      - name: Install shiroa
        run: cargo install --git https://github.com/Myriad-Dreamin/shiroa --locked shiroa

      - name: Build book
        run: shiroa build --mode dyn-paged --path-to-root /your-repo-name/

      - name: Upload Pages artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: ./book

  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

### 8.2 关键配置说明

| 配置项 | 说明 |
|--------|------|
| `fonts-noto-cjk` | Google Noto CJK 字体包，包含 Noto Serif CJK SC 和 Noto Sans CJK SC |
| `--path-to-root /your-repo-name/` | 仓库名称，用于将资源路径前缀设置为 `/your-repo-name/` |
| `path: ./book` | 上传 `book/` 目录作为 Pages 部署内容 |
| `branches: ["main"]` | 推送到 main 分支时自动部署 |

### 8.3 GitHub Pages 仓库设置

1. 进入仓库 **Settings → Pages**
2. **Source** 选择 **GitHub Actions**
3. 推送代码到 `main` 分支后，工作流自动执行

---

## 9. 主题颜色配置

创建 `templates/theme-style.toml`：

```toml
[light]
color-scheme = "light"
main-color = "#000"
dash-color = "#20609f"
code-theme = ""

[rust]
color-scheme = "light"
main-color = "#262625"
dash-color = "#2b79a2"
code-theme = ""

[coal]
color-scheme = "dark"
main-color = "#98a3ad"
dash-color = "#2b79a2"
code-theme = "tokyo-night.tmTheme"

[navy]
color-scheme = "dark"
main-color = "#bcbdd0"
dash-color = "#2b79a2"
code-theme = "tokyo-night.tmTheme"

[ayu]
color-scheme = "dark"
main-color = "#c5c5c5"
dash-color = "#0096cf"
code-theme = "tokyo-night.tmTheme"
```

| 字段 | 说明 |
|------|------|
| `color-scheme` | `"light"` 或 `"dark"`，控制浏览器默认配色方案 |
| `main-color` | 正文字体颜色 |
| `dash-color` | 链接和强调色 |
| `code-theme` | 代码块语法高亮主题文件路径（可省略） |

---

## 10. 常见问题排查

### 10.1 中文字符显示为方框（带 X 的方框）

**原因**：构建环境中缺少中文字体，导致 WASM 渲染器无法获取字形数据。

**解决方案**：
1. 在 CI 中添加 `sudo apt-get install -y fonts-noto-cjk fonts-noto-cjk-extra`
2. 将 `Source Han Serif SC`（Shiroa 内嵌字体）放在字体列表最前面
3. 本地验证：`shiroa build` 后检查 `book/` 目录中是否有字体警告

### 10.2 网页加载极慢/卡顿

**原因**：模板中使用了 `height: auto`，导致整个文档渲染为一张巨大的 Canvas。

**解决方案**：在 `templates/page.typ` 中**移除** `height: auto`：

```typst
// ❌ 错误：整个文档渲染为单张巨型 Canvas
set page(margin: (...), height: auto) if is-web-target and not is-html-target

// ✅ 正确：每个 A4 页面独立渲染
set page(margin: (...)) if is-web-target and not is-html-target
```

移除后，文档将按 A4 纸大小分页渲染，每张 Canvas 尺寸约为 2250×2525px（A4 比例），而非整个文档拼成一张 2250×58639px 的巨型 Canvas。

### 10.3 构建时出现 "unknown font family" 警告

**原因**：字体列表中某些字体在当前系统上不可用。

**解决方案**：
- Windows 上的 `KaiTi`、`DengXian`、`SimSun` 在 Linux CI 上不可用，这是**正常现象**
- Typst 会自动跳过不可用字体，使用列表中下一个可用字体
- 确保 `Source Han Serif SC` 排在列表最前面（Shiroa 内嵌，CI 和本地均可用）

### 10.4 资源文件 404 错误

**原因**：`--path-to-root` 参数不正确，导致 HTML 中的资源路径与实际路径不匹配。

**解决方案**：
- 本地预览：构建时**省略** `--path-to-root` 参数
- GitHub Pages 部署：设置为 `--path-to-root /仓库名称/`
- 确保路径以 `/` 开头和结尾（例如 `/Wave_on_a_String/`）

### 10.5 图片显示问题

- 图片路径使用相对路径，相对于 `book.typ` 所在目录
- 支持的格式：PNG、JPEG、GIF、SVG、WebP
- 建议将图片放在 `images/` 目录下，引用方式：`#image("images/example.webp")`

---

## 附录：完整文件清单

项目构建后，以下是仓库中应包含的核心文件：

```
my-book/
├── book.typ                          # 手动编写
├── templates/
│   ├── page.typ                      # 手动编写
│   ├── theme-style.toml              # 手动编写
│   └── tokyo-night.tmTheme           # 下载（可选）
├── src/
│   ├── chapter1.typ                  # 手动编写
│   └── chapter2.typ                  # 手动编写
├── images/
│   └── example.webp                  # 手动添加
├── docs/
│   └── index.html                    # 手动编写（可选）
├── .github/workflows/
│   └── deploy.yml                    # 手动编写
├── book/                             # 自动生成（无需提交）
└── .gitignore                        # 建议添加 "book/"
```

### `.gitignore` 建议

```gitignore
# Shiroa 构建输出
book/
book-new/
dist/

# Typst 编译缓存
typst-cache/
```

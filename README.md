# 弦上波的数学模型 — Mathematical Modeling of Waves on a String

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## 概述 | Overview

本项目从物理定律出发，系统推导了**弦上波的数学模型**，涵盖真实物理模型的建立、模型假设的线性化处理、振动方程求解、以及单位长度回复力的计算。项目中还包含数学基础知识的整理（如级数、调和级数等），以及一个基于 **p5.js** 的交互式 HTML 可视化页面，用于直观展示琴弦的振动过程。

## 内容结构 | Repository Structure

| 文件/目录 | 说明 |
|-----------|------|
| `wave_on_a_string.typ` | 弦上波数学模型的主文档（Typst 源码） |
| `template.typ` | 自定义 Typst 文档模板，提供页面样式、标题页、目录等 |
| `数学常识.typ` | 数学基础知识整理，包括级数定义、调和级数的发散性证明等 |
| `clean-math-paper/` | 基于 `clean-math-paper` 包的国际数学论文模板示例 |
| `docs/Wave_on_a_string.html` | 基于 p5.js + MathJax 的琴弦振动交互式可视化页面 |
| `docs/guitar.svg` | 可视化页面使用的图标 |
| `Quantum_Chemistry.pdf` | 量子化学相关 PDF 文档 |

## 构建方式 | Building

本项目使用 [Typst](https://typst.com/) 进行排版。要编译文档，请确保已安装 Typst，然后运行：

```bash
typst compile wave_on_a_string.typ
```

或使用 Typst 的实时预览功能：

```bash
typst watch wave_on_a_string.typ
```

## 交互式可视化 | Interactive Visualization

打开 `docs/Wave_on_a_string.html` 即可在浏览器中查看琴弦振动的交互式模拟。该页面使用 [p5.js](https://p5js.org/) 进行图形渲染，使用 [MathJax](https://www.mathjax.org/) 显示数学公式。

## 作者 | Author

**何雄武** (Xiongwu He)

## 许可 | License

本项目采用 MIT 许可证。详见 [LICENSE](LICENSE) 文件。

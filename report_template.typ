// COD 实验报告 Typst 模板
// 用法：复制本文件到实验目录，修改封面信息和正文即可。
// 图标文件 icon_ZJU.png 需放在同目录下。

// ===== 全局样式 =====

// 代码块：浅灰底、小字号、等宽字体
#show raw.where(block: true): set block(
  fill: luma(250),
  inset: 6pt,
  radius: 3pt,
)
#show raw.where(block: true): set text(
  size: 9pt,
  font: ("Courier New", "NSimSun", "SimSun", "Microsoft YaHei UI"),
)
#show raw.where(block: false): set text(
  font: ("Courier New", "NSimSun", "SimSun", "Microsoft YaHei UI"),
)
#show raw.where(block: true): set par(leading: 1.15em)

// 表格：统一边框、字号与行距
#show table: set table(stroke: 0.2pt)
#show table.cell: set text(size: 12pt)
#show table.cell: set par(leading: 0.3em, spacing: 0.5em)
#show table.cell.where(y: 0): set block(above: 0.5em, below: 0.5em)

// 公式：块级公式加浅灰底、降字号；行内公式仅降字号
#show math.equation.where(block: true): set text(size: 12pt)
#show math.equation.where(block: true): it => block(
  fill: luma(245),
  inset: 8pt,
  radius: 3pt,
)[#it]
#show math.equation.where(block: false): set text(size: 12pt)

// 页面：A4、页码、页眉页脚
#set page(
  paper: "a4",
  margin: (left: 2.6cm, right: 2.6cm, top: 2.4cm, bottom: 2.8cm),
  numbering: "1",
  number-align: bottom + center,
  header: context [
    #text(size: 12pt, fill: gray.darken(25%))[ZJUSCT / HPC101]
    #h(1fr)
    #text(size: 12pt, fill: gray.darken(25%))[#datetime.today().display("[month repr:short] [day], [year]")]
  ],
  footer: context align(center)[
    #text(size: 11pt, fill: gray.darken(50%))[#counter(page).display()]
  ],
)

// 正文：字体、字号、段落
#set text(
  font: ("Times New Roman", "Georgia"),
  size: 14pt,
  lang: "en",
)
#set par(
  justify: true,
  first-line-indent: 0em,
  leading: 0.75em,
  spacing: 1em,
)

// 标题层级
// 一级标题（大章节）自动从新页开始：weak pagebreak 在标题已处于页首时自动折叠，不产生空白页
#set heading(numbering: "1.")
#show heading.where(level: 1): it => [
  #pagebreak(weak: true)
  #v(0.9em)
  #text(size: 20pt, weight: "bold", it.body)
  #v(0.35em)
]
#show heading.where(level: 2): it => [
  #v(0.55em)
  #text(size: 15pt, weight: "semibold", it.body)
  #v(0.25em)
]
#show heading.where(level: 3): it => [
  #v(0.35em)
  #text(size: 13pt, weight: "semibold", it.body)
  #v(0.15em)
]

// 图表标题
#show figure.caption: it => [
  #set text(size: 10pt, fill: gray.darken(40%))
  #it.supplement
  #context it.counter.display(it.numbering)
  #it.separator
  #it.body
]

// ===== 封面 =====
// 修改以下三行为你的实验信息
#align(center + horizon)[
  #v(0%)
  #text(size: 35pt, weight: "bold")[
    Lab X
    \
    实验标题
  ]
  #image("icon_ZJU.png", width: 40%)
  #v(2em)
  #text(size: 20pt)[作者：姓名 学号]
  #v(0.5em)
  #text(size: 20pt)[时间：YYYY-MM-DD]
  #v(0.5em)
]

#pagebreak()

// ===== 正文从此处开始 =====

= 一、实验背景与目标

在此撰写正文……

// 表格示例
#figure(
  table(
    columns: (auto, auto, auto),
    align: center + horizon,
    stroke: 0.3pt,
    table.header([列1], [列2], [列3]),
    table.hline(),
    [数据], [数据], [数据],
  ),
  caption: [表格示例],
)

// 公式示例（块级）
$ E = m c^2 $

行内公式 $a^2 + b^2 = c^2$ 示例。

// 代码块示例
```python
print("hello")
```

#pagebreak()

// ===== 生成式AI工具使用声明 =====

= 生成式AI工具使用声明

本次实验在实施与报告撰写过程中使用了大型语言模型作为辅助工具，以下按工具概况与具体辅助作用分述。

== 使用工具概况

- 实验执行、代码编写与报告撰写：Anthropic 的 Claude Code（命令行客户端），模型为 glm-5.2，在本地工作目录与远程计算集群之间交互，贯穿实验全过程。

== 补充说明

以上所有 AI 工具生成的技术方案与代码均经过实验者的实际操作验证。AI 工具在本实验中充当技术顾问与写作辅助角色，所有实验操作的实施、数据的采集与分析、以及最终结论的得出，均由实验者本人独立完成。
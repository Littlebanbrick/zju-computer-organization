// COD 实验报告 —— Lab 2：CPU 实验环境搭建
// 本文件基于 report_template.typ 撰写

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
    #text(size: 12pt, fill: gray.darken(25%))[ZJU / Computer Organization]
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
#set heading(numbering: "1.")
#show heading.where(level: 1): it => [
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
#align(center + horizon)[
  #v(0%)
  #text(size: 35pt, weight: "bold")[
    Lab 2
    \
    CPU 实验环境搭建
  ]
  #image("icon_ZJU.png", width: 40%)
  #v(2em)
  #text(size: 20pt)[作者：王传宇 3250102681]
  #v(0.5em)
  #text(size: 20pt)[指导教师：杨坤]
  #v(0.5em)
  #text(size: 20pt)[时间：2026-10-19]
  #v(0.5em)
]

#pagebreak()

// ===== 正文 =====

= 一、实验背景与目标

本实验把已经实现好的 11 个模块连接成一台能运行程序的计算机。CPU 与多数模块以黑箱形式提供，只有端口声明和综合后的网表；需要编写的代码只有顶层 `src/CSSTE.v`，其性质是一张接线图，而不是行为描述。

实验目标是掌握顶层模块的编写，完成地址、数据与控制信号的正确连接；学会使用在线 RISC-V 32 汇编器生成机器码并初始化 ROM；并借助数码管与 VGA 观察 CPU 的运行现象。器件为 xc7a100tcsg324-1，工具为 Vivado，代码使用 Verilog HDL。

= 二、系统结构与顶层设计

== 1. 十一个子模块

顶层 `CSSTE` 连接 11 个子模块，其中 8 个为黑箱，3 个提供源码。

#figure(
  table(
    columns: (auto, auto, auto, auto),
    align: center + horizon,
    table.header([编号], [功能], [模块名], [提供形式]),
    table.hline(),
    [U1], [CPU], [`SCPU`], [黑箱（网表）],
    [U2], [指令存储器], [`ROM_D`], [源码],
    [U3], [数据存储器], [`RAM_B`], [黑箱（网表）],
    [U4], [总线], [`MIO_BUS`], [黑箱（网表）],
    [U5], [七段显示接口], [`Multi_8CH32`], [黑箱（网表）],
    [U6], [七段显示设备], [`Seg7_Dev`], [源码],
    [U7], [GPIO 接口], [`SPIO`], [黑箱（网表）],
    [U8], [时钟分频], [`clk_div`], [黑箱（网表）],
    [U9], [按键去抖], [`SAnti_jitter`], [黑箱（网表）],
    [U10], [通用计数器], [`Counter_x`], [黑箱（网表）],
    [U11], [VGA 显示接口], [`VGA`], [源码],
  ),
  caption: [顶层例化的 11 个子模块],
  supplement: [表],
  kind: table,
)

黑箱模块以「`.v` 接口声明 + `.edf` 网表」的形式提供：前者供综合器识别接口，后者是已经综合好的门级电路。

\

\

== 2. 数据通路

取指时，`PC_out` 取 `[11:2]` 作为 ROM 的字地址，ROM 组合输出 32 位指令 `Inst_in`。CPU 译码后由 ALU 算出 `Addr_out`，同时给出 `Data_out` 与 `MemRW`。这三个信号先进入总线 `MIO_BUS`，由总线按地址译码决定访问 RAM 还是某个外设，读回的数据再经总线返回 CPU。

== 3. 三个时钟域

顶层的时钟并非只有一个。观察各实例的 `clk` 接法可以看到三组：

#figure(
  table(
    columns: (auto, auto, auto),
    align: center + horizon,
    table.header([时钟], [连接的模块], [作用]),
    table.hline(),
    [`clk_100mhz`], [`MIO_BUS`、`SAnti_jitter`、`clk_div`、`VGA`], [板载晶振原频],
    [`Clk_CPU`], [`SCPU`、`ROM_D`], [CPU 主时钟（分频或单步）],
    [`~Clk_CPU`], [`RAM_B`、`Multi_8CH32`、`SPIO`、`Counter_x`], [与 CPU 错开半拍],
  ),
  caption: [三个时钟域的划分],
  supplement: [表],
  kind: table,
)

`Clk_CPU` 由 U8（`clk_div`）产生，受 `SW[8]`、`SW[2]` 与 `SW[10]` 控制，可以是 100 MHz、自动单步（2²⁴ 分频）或手动单步。RAM 与所有外设统一使用 `~Clk_CPU`，在 CPU 的下降沿动作。

#pagebreak(weak: true)
= 三、顶层连线实现

== 1. 模板已提供的部分

课程提供的 `CSSTE.v` 已经完成了 U4 至 U11 的连线，并声明了顶层所需的全部 wire，例如 `Addr_out`、`Data_out`、`PC_out`、`MemRW`、`Inst_in`、`Data_in`、`ram_addr`、`ram_data_in`、`RAM_B_0_douta`、`U4_data_ram_we` 等。留给学生补全的只有 U1、U2、U3 三个实例。

== 2. 补全的连线

U1、U2、U3 的端口连接如下。

```verilog
    SCPU U1(
        .Addr_out(Addr_out),
        .Data_in(Data_in),
        .Data_out(Data_out),
        .MIO_ready(1'b0),
        .MemRW(MemRW),
        .PC_out(PC_out),
        .clk(Clk_CPU),
        .inst_in(Inst_in),
        .rst(rst)
    );

    ROM_D U2(
        .a(PC_out[11:2]),
        .spo(Inst_in)
    );

    RAM_B U3(
        .addra(ram_addr),
        .clka(~Clk_CPU),
        .dina(ram_data_in),
        .douta(RAM_B_0_douta),
        .wea(U4_data_ram_we)
    );
```

\

\

== 3. 每根线的依据

连线的依据是 `appendix/CSSTE.pdf` 中的接线图；下表在其基础上补充每根线的作用，便于核对。

#figure(
  table(
    columns: (auto, auto, auto, auto),
    align: (left + horizon, center + horizon, left + horizon, left + horizon),
    table.header([端口], [方向], [连接], [依据]),
    table.hline(),
    [`U1.PC_out`], [输出], [`PC_out`], [送 ROM 取指，同时供数码管与 VGA 显示],
    [`U1.inst_in`], [输入], [`Inst_in`], [由 U2 的 `spo` 驱动],
    [`U1.Addr_out`], [输出], [`Addr_out`], [送总线，再由总线分发到 RAM 或外设],
    [`U1.Data_out`], [输出], [`Data_out`], [送总线作为写数据],
    [`U1.Data_in`], [输入], [`Data_in`], [由总线的 `Cpu_data4bus` 驱动],
    [`U1.MemRW`], [输出], [`MemRW`], [送总线作为读写控制],
    [`U1.MIO_ready`], [输入], [`1'b0`], [实验要求接常量 0],
    [`U1.clk`], [输入], [`Clk_CPU`], [CPU 必须使用分频/单步时钟],
    [`U1.rst`], [输入], [`rst`], [由 U9 去抖后给出],
    [`U2.a`], [输入], [`PC_out[11:2]`], [字节地址取高 10 位得字地址],
    [`U2.spo`], [输出], [`Inst_in`], [指令送 CPU 与显示模块],
    [`U3.addra`], [输入], [`ram_addr`], [总线译码后的字地址],
    [`U3.dina`], [输入], [`ram_data_in`], [总线送来的写数据],
    [`U3.douta`], [输出], [`RAM_B_0_douta`], [回送总线，经 `Cpu_data4bus` 进 CPU],
    [`U3.wea`], [输入], [`U4_data_ram_we`], [总线的 RAM 写使能],
    [`U3.clka`], [输入], [`~Clk_CPU`], [负边沿写入，与 CPU 错开半拍],
  ),
  caption: [U1、U2、U3 的端口连接依据],
  supplement: [表],
  kind: table,
)

三条最关键的判断：

- `MIO_ready` 接常量。它是输入端口，没有任何模块产生这个信号，实验文档明确规定接 `1'b0`，因此括号里写常量而不是 wire。
- ROM 地址取 `PC_out[11:2]`。`PC_out` 是 32 位字节地址，而 ROM 只有 1024 个 32 位字；指令 4 字节对齐，`PC_out[1:0]` 恒为 0，故取 `[11:2]` 恰好是字地址。
- RAM 的 `clka` 取反。RAM 的写入发生在 `~Clk_CPU` 的上升沿，即 CPU 时钟的下降沿。


#pagebreak(weak: true)
= 四、上板验证

== 1. 时钟模式与显示通道

板上的拨码开关控制时钟与数码管的显示内容。

#figure(
  table(
    columns: (auto, auto, auto),
    align: center + horizon,
    table.header([`SW[8]`], [`SW[2]`], [时钟模式]),
    table.hline(),
    [`0`], [`0`], [全速时钟 100 MHz],
    [`0`], [`1`], [自动单步时钟（$2^(24)$ 分频）],
    [`1`], [`X`], [手动单步时钟，`SW[10]` 每从关到开产生一个上升沿],
  ),
  caption: [时钟模式选择],
  supplement: [表],
  kind: table,
)

#figure(
  table(
    columns: (auto, auto),
    align: center + horizon,
    table.header([`SW[7:5]`], [数码管显示内容]),
    table.hline(),
    [`001`], [`PC_out[31:2]`（指令字地址）],
    [`010`], [`Inst_in`（指令字）],
    [`100`], [`addr_bus`（ALU 输出 / 数据地址）],
    [`111`], [`PC_out`（字节地址）],
  ),
  caption: [数码管显示通道],
  supplement: [表],
  kind: table,
)

== 2. 单步操作

为观察稳定现象并避免全速运行时可能出现的时序问题，验证全部采用手动单步模式。操作顺序为：先置 `SW[8] = 1`、`SW[2] = 1`、`SW[7:5] = 111`，按一次板上的 CPU RESET（DONE 灯右侧红色按钮）；此后每次拨动 `SW[10]`，CPU 走一条指令，`PC_out` 加 4。

由于复位后 `PC_out = 0`，第 1 条指令无需拨动开关即可观察；第 2 条指令需要拨 1 次；第 31 条指令位于字节地址 `0x78`，需要拨 30 次。

#figure(
  table(
    columns: (auto, auto, auto),
    align: center + horizon,
    table.header([目标指令], [`SW[10]` 拨动次数], [`PC_out`]),
    table.hline(),
    [第 1 条], [0], [`00000000`],
    [第 2 条], [1], [`00000004`],
    [第 31 条], [30], [`00000078`],
  ),
  caption: [指令与单步次数的对应关系],
  supplement: [表],
  kind: table,
)

到达目标 PC 后，只改变 `SW[7:5]`（不动 `SW[10]`），即可在同一个时钟状态下依次读出 `PC_out`、`Inst_in` 与 `addr_bus`，并拍摄 VGA 画面。

== 3. 现象记录

=== 第 1 条指令（复位后，拨 0 次）

#figure(image("0-111.jpg", width: 70%), caption: [第 1 条指令：`SW[7:5]=111`，`PC_out = 00000000`], supplement: [图])

#figure(image("0-010.jpg", width: 70%), caption: [第 1 条指令：`SW[7:5]=010`，`Inst_in = 00100093`], supplement: [图])

#figure(image("0-100.jpg", width: 70%), caption: [第 1 条指令：`SW[7:5]=100`，`addr_bus = 00000001`], supplement: [图])

#figure(image("0-vga.jpg", width: 70%), caption: [第 1 条指令的 VGA 输出，画面中可读出 `00000000` 与 `00100093`], supplement: [图])

#pagebreak()

=== 第 2 条指令（拨 1 次）

#figure(image("1-111.jpg", width: 70%), caption: [第 2 条指令：`SW[7:5]=111`，`PC_out = 00000004`], supplement: [图])

#figure(image("1-010.jpg", width: 70%), caption: [第 2 条指令：`SW[7:5]=010`，`Inst_in = 00102133`], supplement: [图])

#figure(image("1-100.jpg", width: 70%), caption: [第 2 条指令：`SW[7:5]=100`，`addr_bus = 00000001`], supplement: [图])

#figure(image("1-vga.jpg", width: 70%), caption: [第 2 条指令的 VGA 输出], supplement: [图])

#pagebreak()

=== 第 31 条指令（拨 30 次）

#figure(image("31-111.jpg", width: 70%), caption: [第 31 条指令：`SW[7:5]=111`，`PC_out = 00000078`], supplement: [图])

#figure(image("31-010.jpg", width: 70%), caption: [第 31 条指令：`SW[7:5]=010`，`Inst_in = 01df0fb3`], supplement: [图])

#figure(image("31-100.jpg", width: 70%), caption: [第 31 条指令：`SW[7:5]=100`，`addr_bus = 00148add`], supplement: [图])

#figure(image("31-vga.jpg", width: 70%), caption: [第 31 条指令的 VGA 输出], supplement: [图])

#pagebreak()

== 4. 结果比对

三条指令的读数与实验文档给出的参考值完全一致。

#figure(
  table(
    columns: (auto, auto, auto, auto),
    align: center + horizon,
    table.header([指令], [`PC_out`（111）], [`Inst_in`（010）], [`addr_bus`（100）]),
    table.hline(),
    [第 1 条], [`00000000`], [`00100093`], [`00000001`],
    [第 2 条], [`00000004`], [`00102133`], [`00000001`],
    [第 31 条], [`00000078`], [`01df0fb3`], [`00148add`],
  ),
  caption: [三条指令的实测读数（与文档参考值一致）],
  supplement: [表],
  kind: table,
)

三点观察：

- PC 每次加 4。`PC_out` 从 `00000000` 到 `00000004` 再到 `00000078`（即十进制的 0、4、120），说明指令按 32 位对齐存储，程序被顺序取指。
- 指令与 ROM 内容一一对应。第 1 条 `00100093` 对应 `addi x1, x0, 1`，第 2 条 `00102133` 对应 `slt x2, x0, x1`，第 31 条 `01df0fb3` 对应 `add x31, x30, x29`，与 `I_mem.mem` 的第 1、2、31 行逐条吻合。
- VGA 画面与数码管读数一致。

#pagebreak(weak: true)
= 五、汇编器与 ROM 初始化

`ROM_D` 的初值由 `$readmemh("I_mem.mem", rom)` 从文本文件载入，而 `.mem` 中的机器码需要由汇编器生成。本实验使用课程推荐的在线 RISC-V 32 汇编器 https://venus.cs61c.org/。

操作步骤如下：

+ 在 Editor 界面粘贴 `appendix/example.asm` 中的内容；
+ 切换到 Simulator 界面，点击 Assemble & Simulate from Editor；
+ 点击 Dump，在 console output 中得到机器码；
+ 点击 Copy 复制，去掉每行开头的 `0x`，即可得到可直接使用的 `.mem` 文件。

将 `example.asm` 汇编后共得到 32 行机器码，与本工程 `I_mem.mem` 中的 32 行逐字节相同。前几行对照如下。

#figure(
  table(
    columns: (auto, auto, auto, auto),
    align: (center + horizon, left + horizon, center + horizon, center + horizon),
    table.header([序号], [指令], [汇编器输出], [`I_mem.mem` 内容]),
    table.hline(),
    [1], [`addi x1,x0,1`], [`0x00100093`], [`00100093`],
    [2], [`slt x2,x0,x1`], [`0x00102133`], [`00102133`],
    [3], [`add x3,x2,x2`], [`0x002101B3`], [`002101B3`],
    [4], [`beq x0,x0,loop`], [`0xF80002E3`], [`F80002E3`],
  ),
  caption: [汇编结果与 `I_mem.mem` 的对照（节选）],
  supplement: [表],
  kind: table,
)

#pagebreak(weak: true)
= 六、问题与总结

== 1. 遇到的问题

1、面对 `.Data_in()` 这样的空括号，最初我并不清楚该填什么。真正起决定作用的是 `appendix/CSSTE.pdf` 中的接线图：它标明了每个模块的每根引脚连到哪一根线上，顶层的 wire 声明与 U4~U11 的已有连接都是照它画的，补全 U1~U3 时同样以它为准。

2、对 `.edf` 与 `.mem` 的作用不了解。后面询问 AI 得知：`.edf` 是已经综合好的门级网表，用来替代 RTL 源码，使黑箱模块的电路与课程提供的版本完全一致；`.mem` 是纯文本的初值文件，由 `$readmemh` 读入，内容就是程序的机器码。

== 2. 实验总结

略。

#pagebreak(weak: true)
= 七、思考题

== 1. 为什么 RAM 的时钟需要取反（负边沿触发）？这样设计有什么好处？

单周期 CPU 的所有状态（比如 PC 和寄存器堆）都在 `Clk_CPU` 的上升沿更新。同一个上升沿之后，组合逻辑才开始重新计算地址、写数据与读写控制信号，这些信号要经过若干级门延迟才能稳定。如果 RAM 也在 `Clk_CPU` 的上升沿写入，那么采样时刻恰好是地址与数据刚刚开始变化的时刻，写入的值可能是旧值，也可能处于不稳定状态，存在竞争与建立时间不足的风险。因此负边沿触发相当于让 RAM 慢半拍，可以避免上述问题。

== 2. ROM 为什么使用 `PC_out[11:2]` 作为字地址，而不是 `PC_out[9:0]`？

因为地址的单位必须与被寻址对象的单位一致。RISC-V 的指令长度为 32 位（4 字节），且指令地址必须 4 字节对齐，因此 `PC_out` 的低两位恒为 0。ROM 的组织方式则是 1024 个 32 位字，其地址应当是"第几个字"，宽度 10 位。

把一个字节地址换算成字地址，等价于除以 4，即右移两位。因此取 `PC_out[11:2]`可以丢弃低两位的字节偏移，再用接下来的 10 位作为字索引，恰好覆盖所有的地址空间。

== 3. 在非访存指令（如 `add`）中，`addr_bus` 也有值，这正常吗？为什么？

这是正常现象：`Addr_out` 直接就是 ALU 的输出，不是"地址寄存器"。单周期 CPU 每个周期都在计算：`add`、`addi`、`slt` 这类指令的结果要写回寄存器堆，同时也一直送到地址总线上；只有 `lw`、`sw` 才把这个值当作访存地址。是否真正访存由 `MemRW` 和地址译码决定，与 `addr_bus` 有没有值无关。

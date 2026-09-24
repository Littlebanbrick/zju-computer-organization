// COD 实验报告 —— Lab 1：ALU、RegFile 与有限状态机设计
// 本文件基于 report_template.typ 撰写
// 同目录所需图片：icon_ZJU.png、alu_wave.png、reg_file_wave.png、fsm_wave.png

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
#align(center + horizon)[
  #v(0%)
  #text(size: 35pt, weight: "bold")[
    Lab 1
    \
    ALU、RegFile 
    \
    与有限状态机设计
  ]
  #image("icon_ZJU.png", width: 40%)
  #v(2em)
  #text(size: 20pt)[作者：王传宇 3250102681]
  #v(0.5em)
  #text(size: 20pt)[指导教师：杨坤]
  #v(0.5em)
  #text(size: 20pt)[时间：2026-09-24]
  #v(0.5em)
]

#pagebreak()

// ===== 正文 =====

= 一、实验背景与目标

本实验是《计算机组成》课程 Lab 1，围绕数字系统中最基础的三类部件展开：组合逻辑（ALU）、时序逻辑（寄存器堆）以及二者结合的有限状态机（FSM）。三个实验恰好对应"纯组合""纯时序""组合加时序"三种设计形态。

实验目标如下：

+ 掌握组合逻辑与时序逻辑的基本设计方法；
+ 理解 ALU 的功能，掌握加减法器复用、有符号比较与零标志位的实现方法；
+ 理解寄存器堆的结构，掌握双端口组合读、单端口同步写及异步复位的实现方法；
+ 理解 Moore 型有限状态机，能够使用三段式写法实现序列检测；
+ 能够编写或补全 testbench，并根据仿真波形验证设计功能。

本实验不进行上板验证，全部功能通过 Verilog HDL 描述、在 Vivado 中以行为级仿真（Run Simulation → Run Behavioral Simulation）验证：每个模块配一个独立的 testbench，运行至 testbench 的 `$finish` 后缩放查看完整波形。阅读后续仿真结果时，有三点约定需要留意：三个 testbench 的时间单位均为 1 ns；RegFile 与 FSM 的 testbench 均以 `always #10 clk = ~clk;` 产生周期为 20 ns 的时钟，上升沿位于 10、30、50 ns 等时刻；两个时序模块的复位极性相反——RegFile 使用高有效异步复位 `rst`，FSM 使用低有效异步复位 `reset`，二者不可混用。

= 二、实验一：ALU 设计

== 1. 设计任务与接口

设计一个 32 位组合逻辑 ALU，支持 AND、OR、ADD、XOR、NOR、SRL、SUB 和 SLT 共 8 种运算，并输出零标志位 `zero`。模块接口如下：

```verilog
module ALU(
    input  [31:0] A,             // 操作数 A
    input  [2:0]  ALU_operation, // 操作码
    input  [31:0] B,             // 操作数 B
    output reg [31:0] res,       // 运算结果
    output            zero       // 零标志位
);
```

操作码定义见下表。

#figure(
  table(
    columns: (auto, auto, auto),
    align: center + horizon,
    table.header([操作码], [运算], [功能说明]),
    table.hline(),
    [`000`], [AND], [按位与 `A & B`],
    [`001`], [OR], [按位或 `A | B`],
    [`010`], [ADD], [加法，输出低 32 位结果],
    [`011`], [XOR], [按位异或 `A ^ B`],
    [`100`], [NOR], [按位或非 `~(A | B)`],
    [`101`], [SRL], [逻辑右移，移位量仅取 `B[4:0]`],
    [`110`], [SUB], [减法，输出低 32 位结果],
    [`111`], [SLT], [有符号比较，`A < B` 时输出 32 位的 1，否则输出 0],
  ),
  caption: [ALU 操作码定义],
  supplement: [表],
  kind: table,
)

== 2. 设计思路与关键代码

按照"各运算分支并行形成候选结果，再根据操作码选择输出"的思路，把八种运算拆成并行候选与结果选择两部分实现。

(1) 并行产生候选结果。 与操作码无关（或只依赖操作码最高位）的中间结果全部用连续赋值 `assign` 并行产生，各分支之间互不影响：

```verilog
assign and_res = A & B;
assign or_res  = A | B;
assign xor_res = A ^ B;
assign nor_res = ~(A | B);
assign srl_res = A >> B[4:0];
```

(2) 加减法器复用。 利用补码关系 `A - B = A + ~B + 1`，由操作码最高位 `ALU_operation[2]` 同时控制加法器的第二操作数与输入进位：

```verilog
assign add_sub_res =
    (ALU_operation[2] == 1) ? (A + ~B + 1) : (A + B);
```

当 `op[2] = 0` 时计算 `A + B`（ADD）；当 `op[2] = 1` 时计算 `A + ~B + 1`（SUB）。SLT 的操作码最高位同样为 1，因此可以直接复用这条减法结果，无需再引入一个减法器。

(3) 有符号比较。 SLT 要求把两个操作数视为 32 位补码有符号数：

```verilog
assign compare_res =
    ($signed(A) < $signed(B)) ? 1'b1 : 1'b0;
```

比较结果为 1 位，赋给 32 位的 `res` 时高位自动补零。

(4) 结果选择与零标志位。 用组合 `always` 加 `case` 按操作码选择输出；`case` 覆盖全部八种操作码并带 `default`，保证所有分支都有明确赋值，不会产生锁存器。零标志位基于最终输出 `res` 生成：

```verilog
always @(*) begin
    case (ALU_operation)
        3'b000: res = and_res;     // AND
        3'b001: res = or_res;      // OR
        3'b010: res = add_sub_res; // ADD
        3'b011: res = xor_res;     // XOR
        3'b100: res = nor_res;     // NOR
        3'b101: res = srl_res;     // SRL
        3'b110: res = add_sub_res; // SUB
        3'b111: res = compare_res; // SLT
        default: res = 32'b0;
    endcase
end

assign zero = (res == 32'b0) ? 1'b1 : 1'b0;
```

== 3. 仿真结果与分析

我们以： 

`A = 32'hCAFEBABE`、`B = 32'hDEADBEEF` 

为固定操作数，每 10 ns 切换一次操作码，依次验证八种运算；随后以四组操作数验证 SLT；最后补充一组 `A = B = 32'hFACEFACE` 的 SUB，用于验证零标志位。

#figure(
  table(
    columns: (auto, auto, auto, auto),
    align: center + horizon,
    table.header([操作码], [运算], [预期 `res`], [实测 `res`]),
    table.hline(),
    [`000`], [AND], [`CAACBAAE`], [`CAACBAAE`],
    [`001`], [OR], [`DEFFBEFF`], [`DEFFBEFF`],
    [`010`], [ADD], [`A9AC79AD`], [`A9AC79AD`],
    [`011`], [XOR], [`14530451`], [`14530451`],
    [`100`], [NOR], [`21004100`], [`21004100`],
    [`101`], [SRL], [`000195FD`], [`000195FD`],
    [`110`], [SUB], [`EC50FBCF`], [`EC50FBCF`],
    [`111`], [SLT], [`00000001`], [`00000001`],
  ),
  caption: [八种运算的预期与实测结果（`A = 32'hCAFEBABE`，`B = 32'hDEADBEEF`）],
  supplement: [表],
  kind: table,
)

#figure(
  table(
    columns: (auto, auto, auto, auto, auto),
    align: center + horizon,
    table.header([编号], [操作码], [`A`], [`B`], [实测 `res` / `zero`]),
    table.hline(),
    [1], [`111`], [`00000000`], [`00000001`], [`00000001` / `0`],
    [2], [`111`], [`80000001`], [`00000000`], [`00000001` / `0`],
    [3], [`111`], [`76543210`], [`01234567`], [`00000000` / `1`],
    [4], [`111`], [`FEDCBA98`], [`89ABCDEF`], [`00000000` / `1`],
    [5], [`110`], [`FACEFACE`], [`FACEFACE`], [`00000000` / `1`],
  ),
  caption: [SLT 用例与补充的零标志位用例],
  supplement: [表],
  kind: table,
)

#figure(
  image("alu_wave.png", width: 100%),
  caption: [ALU 八种运算、SLT 用例与零标志位用例的仿真波形],
  supplement: [图],
)

结果分析：

- ALU 是纯组合逻辑。波形上 `res` 与 `zero` 随 `A`、`B`、`ALU_operation` 同步变化，不依赖任何时钟沿，这一点与后面两个时序模块形成鲜明对比。
- 加减法器复用正确。ADD 与 SUB 共用同一个加法器表达式 `(op[2] == 1) ? (A + ~B + 1) : (A + B)`，由 `op[2]` 同时控制第二操作数取反与输入进位，与补码减法的定义一致。
- SRL 的移位量只取低 5 位。`B = 32'hDEADBEEF` 的低 5 位为 `5'b01111`，即十进制 15；`32'hCAFEBABE` 逻辑右移 15 位得到 `32'h000195FD`，与实测一致，说明"移位量仅取 `B[4:0]`"实现正确。
- 有符号比较正确。四组用例覆盖了正与正、负与非负、负与负等符号组合：`0 < 1` 成立、`32'h80000001`（负数）`< 0` 成立，而 `32'h76543210 > 32'h01234567`、`32'hFEDCBA98 > 32'h89ABCDEF`，与补码有符号比较的规则一致。
- 零标志位正确。八种运算的结果均非零，因此 `zero` 全部为 0；补充的 `32'hFACEFACE - 32'hFACEFACE = 0` 用例中 `zero` 由 0 变为 1，说明 `zero` 是根据最终输出 `res` 生成的，而不是根据某个中间结果。

= 三、实验二：RegFile 设计

== 1. 设计任务与接口

设计一个 32 位寄存器堆：包含 31 个可读写通用寄存器 x1 至 x31，以及恒为 0 的 x0；支持两个读端口与一个写端口。模块接口如下：

```verilog
module Regs(
    input clk,              // 时钟
    input rst,              // 高有效异步复位
    input [4:0] Rs1_addr,   // 读端口 1 地址
    input [4:0] Rs2_addr,   // 读端口 2 地址
    input [4:0] Wt_addr,    // 写端口地址
    input [31:0] Wt_data,   // 写端口数据
    input RegWrite,         // 写使能
    output [31:0] Rs1_data, // 读端口 1 数据
    output [31:0] Rs2_data  // 读端口 2 数据
);
```

== 2. 设计思路与关键代码

(1) 存储结构。 只为 x1 至 x31 分配存储单元，不为 x0 分配：

```verilog
reg [31:0] register [1:31];
```

x0 的"恒为 0"完全由读逻辑与写逻辑保证，不占用任何触发器。

(2) 组合读。 两个读端口都用连续赋值实现，读数据不经过触发器，因此"随地址及对应寄存器内容变化，不需要等待时钟边沿"。地址为 0 时用三目运算符直接输出 0，这一处同时解决了"读 x0 恒为 0"与"`register[0]` 不存在、不能越界读"两个问题：

```verilog
assign Rs1_data = (Rs1_addr == 5'd0) ? 32'h0 : register[Rs1_addr];
assign Rs2_data = (Rs2_addr == 5'd0) ? 32'h0 : register[Rs2_addr];
```

(3) 同步写与高有效异步复位。 写入与复位共用一个 `always` 块：敏感列表中同时包含时钟上升沿与复位上升沿，后者使复位"不等待时钟沿"；块内 `if / else if` 的先后顺序决定优先级，复位写在最前面，因此复位优先于写入：

```verilog
always @(posedge clk or posedge rst) begin
    if (rst) begin
        for (i = 1; i <= 31; i = i + 1)
            register[i] <= 32'h0;      // 异步复位：一次清空 31 个寄存器
    end
    else if (RegWrite && (Wt_addr != 5'd0)) begin
        register[Wt_addr] <= Wt_data;  // 同步写：仅在时钟上升沿发生
    end
end
```

其中 `for` 循环在综合时会被展开为 31 条并行赋值，正好对应 31 组触发器的复位端；写条件中的 `Wt_addr != 5'd0` 用于屏蔽对 x0 的写入，使其"写入无效但不抛异常"。

== 3. 仿真结果与分析

testbench 的激励流程如下：

#figure(
  table(
    columns: (auto, auto),
    align: (center + horizon, left + horizon),
    table.header([时刻], [激励与操作]),
    table.hline(),
    [0 ns], [置 `rst = 1`、`RegWrite = 0`，进入复位状态],
    [100 ns], [释放复位（`rst = 0`），使能写入，向 x5 写入 `32'hA5A5A5A5`],
    [110 ns], [复位后的首个时钟上升沿],
    [150 ns], [切换为向 x10 写入 `32'h5A5A5A5A`（该时刻与时钟上升沿重合）],
    [170 / 190 ns], [激励稳定后的时钟上升沿],
    [200 ns], [关闭写使能，读地址分别设为 5 与 10],
    [250 ns], [尝试向 x0 写入 `32'h91789178`],
    [300 ns], [读地址设为 0，读取 x0],
    [350 至 400 ns], [拉高 `rst` 执行异步复位，随后扫描地址 0 至 31],
  ),
  caption: [RegFile testbench 激励流程],
  supplement: [表],
  kind: table,
)

#figure(
  table(
    columns: (auto, auto, auto),
    align: (left + horizon, center + horizon, center + horizon),
    table.header([观察信号 / 检查项], [预期结果], [实测结果]),
    table.hline(),
    [`Rs1_data`（200 ns 读 x5）], [`32'hA5A5A5A5`], [`32'hA5A5A5A5`],
    [`Rs2_data`（200 ns 读 x10）], [`32'h5A5A5A5A`], [`32'h5A5A5A5A`],
    [向 x0 写入（250 ns）], [写操作被屏蔽，x0 不变], [读出仍为 `32'h0`],
    [读 x0（300 ns）], [`32'h0`], [`32'h0`],
    [复位后扫描地址 0 至 31], [全部为 `32'h0`], [全部为 `32'h0`],
  ),
  caption: [RegFile 各检查项的预期与实测结果],
  supplement: [表],
  kind: table,
)

#figure(
  image("reg_file_wave.png", width: 100%),
  caption: [RegFile 的复位、写入与读出的仿真波形],
  supplement: [图],
)

结果分析：

- 组合读：200 ns 时读地址被设为 5 与 10，`Rs1_data` 与 `Rs2_data` 立即变为 `32'hA5A5A5A5` 与 `32'h5A5A5A5A`，变化位置不在时钟沿上，也不需要等待时钟或写使能——读数据是读地址与寄存器内容的纯组合函数。
- 写入生效：写地址与写数据在 100 ns、150 ns 先后给出，读地址在 200 ns 指向 x5 与 x10，此时已经读到新数据。
- x0 的读写：250 ns 时令 `RegWrite = 1`、写地址为 0，300 ns 读出的 x0 仍为 0；算上 200 ns 的读数，两次读 x0 均为 0。写 x0 被屏蔽，读 x0 恒为 0。
- 复位：350 ns 拉高 `rst`，从 400 ns 起把读地址由 0 依次递增到 31，读出的数据全部为 0，说明复位清空了全部 31 个可写寄存器。

= 四、实验三：有限状态机设计

== 1. 设计任务与接口

设计一个 Moore 型序列检测器，按顺序逐位接收输入，检测目标序列 `1110010`：检测到完整序列时输出 `out = 1`，其余状态输出 `out = 0`；设计应允许连续输入并保留可能的后续匹配（即重叠检测），并采用三段式写法。

Moore 型与 Mealy 型的区别在于：Mealy 型的输出与当前状态及当前输入有关，Moore 型的输出仅与当前状态有关。本设计采用 Moore 型，输出只由状态译码得到。

模块接口如下：

```verilog
module fsm(
    input  wire clk,
    input  wire reset,   // 低有效异步复位
    input  wire in,      // 串行输入，每次采样一位
    output wire out      // 检测结果，仅在 S7 为 1
);
```

== 2. 状态定义与转移

状态的物理含义是"已接收输入的后缀与目标序列前缀的最长匹配长度"：S0 表示尚未匹配任何前缀，Sk 表示已匹配目标序列的前 k 位，S7 表示完整匹配。由于目标序列长度为 7，因此需要 8 个状态，采用 3 位二进制编码（`3'b000` 至 `3'b111`）。

#figure(
  table(
    columns: (auto, auto, auto, auto, auto),
    align: center + horizon,
    table.header([当前状态], [已匹配前缀], [输入 0 的次态], [输入 1 的次态], [`out`]),
    table.hline(),
    [S0], [空], [S0], [S1], [0],
    [S1], [`1`], [S0], [S2], [0],
    [S2], [`11`], [S0], [S3], [0],
    [S3], [`111`], [S4], [S3], [0],
    [S4], [`1110`], [S5], [S1], [0],
    [S5], [`11100`], [S0], [S6], [0],
    [S6], [`111001`], [S7], [S2], [0],
    [S7], [`1110010`], [S0], [S1], [1],
  ),
  caption: [Moore 型序列检测器的状态转移表],
  supplement: [表],
  kind: table,
)

转移的一般规律是：次态由"已匹配前缀 + 新输入位"这个串中最长的、同时又是目标序列前缀的后缀决定，该后缀的长度即次态编号。例如：

- S3 收到 `1`：`111` + `1` = `1111`，其后缀 `111` 仍是目标序列的前缀，因此保持在 S3；
- S4 收到 `1`：`1110` + `1` = `11101`，最长且为目标前缀的后缀只有 `1`，因此回到 S1；
- S6 收到 `1`：`111001` + `1` = `1110011`，最长且为目标前缀的后缀是 `11`，因此回到 S2。

这正是"保留可能的后续匹配"的体现：不匹配时并不简单地回到 S0，而是尽可能多地保留已经匹配的前缀。

== 3. 三段式实现

设计按"状态寄存—次态逻辑—输出逻辑"三段划分：

```verilog
// 第一段：状态寄存（唯一的记忆，低有效异步复位）
always @(posedge clk or negedge reset) begin
    if (!reset)
        curr_state <= S0;
    else
        curr_state <= next_state;
end

// 第二段：次态逻辑（纯组合查表，阻塞赋值）
always @(*) begin
    case (curr_state)
        S0: next_state = in ? S1 : S0;
        S1: next_state = in ? S2 : S0;
        S2: next_state = in ? S3 : S0;
        S3: next_state = in ? S3 : S4;
        S4: next_state = in ? S1 : S5;
        S5: next_state = in ? S6 : S0;
        S6: next_state = in ? S2 : S7;
        S7: next_state = in ? S1 : S0;
        default: next_state = S0;
    endcase
end

// 第三段：输出逻辑（Moore 型，只由现态译码）
assign out = (curr_state == S7);
```

三段各自的职责与实现要点：

- 第一段（时序段）：整个设计中唯一的"记忆"。敏感列表包含 `negedge reset`，因此复位不需要等待时钟沿；复位分支写在最前面，优先于状态更新。`curr_state` 由 `next_state` 驱动，体现了"每个时钟沿把算好的下一步变成现在"。
- 第二段（组合段）：`always @(*)` 不含任何时钟，是纯组合的查表逻辑，内部使用阻塞赋值 `=`；`case` 覆盖全部八个状态并带 `default`，保证所有分支都有明确赋值，避免推断出锁存器。
- 第三段（输出段）：Moore 型的输出只对现态译码，`assign out = (curr_state == S7)` 与输入 `in` 完全无关，因此输出只在时钟沿附近变化，不会因输入的变化产生组合毛刺。

== 4. 仿真结果与分析

testbench 从左到右依次输入 16 位序列 `1110010011110010`（该序列在第 1 至 7 位与第 9 至 15 位各包含一次完整的目标序列）。复位在 20 ns 释放，第 1 位输入在 20 ns 加于 `in`，并在 30 ns 的时钟上升沿被采样；第 $n$ 位的采样时刻为 30 + 20 × (n - 1) ns。

#figure(
  table(
    columns: 17,
    inset: 5.4pt,
    column-gutter: 0pt,
    align: center + horizon,
    table.header([位序], [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16]),
    table.hline(),
    [输入], [1], [1], [1], [0], [0], [1], [0], [0], [1], [1], [1], [1], [0], [0], [1], [0],
    [采样后状态], [S1], [S2], [S3], [S4], [S5], [S6], [S7], [S0], [S1], [S2], [S3], [S3], [S4], [S5], [S6], [S7],
  ),
  caption: [输入序列与采样后的状态轨迹],
  supplement: [表],
  kind: table,
)

#figure(
  table(
    columns: (auto, auto, auto),
    align: (left + horizon, left + horizon, left + horizon),
    table.header([检查项目], [预期行为], [实测结果]),
    table.hline(),
    [复位], [`curr_state = S0`，`out = 0`], [0 至 20 ns 复位期间 `curr_state = 3'b000`，`out = 0`],
    [第一次匹配], [采样第 7 位后进入 S7，输出为 1], [150 ns 进入 S7，`out = 1`；170 ns 恢复为 0],
    [连续输入 1], [在 S3 接收到 1 时保持 S3], [250 ns（第 12 位）`curr_state = 3'b011`，`out = 0`],
    [第二次匹配], [采样第 16 位后进入 S7，输出为 1], [330 ns 进入 S7，`out = 1`，保持至 340 ns 仿真结束],
    [非匹配状态], [输出为 0], [状态编码为 `000` 至 `110` 时 `out` 均为 0；全程共匹配 2 次],
  ),
  caption: [FSM 各检查项的预期与实测结果],
  supplement: [表],
  kind: table,
)

#figure(
  image("fsm_wave.png", width: 100%),
  caption: [序列检测器的输入、状态与输出的仿真波形],
  supplement: [图],
)

结果分析：

- 输出与状态的对应关系：波形中只有 `curr_state = 3'b111`（即 S7）时 `out` 为 1，与输入 `in` 无关，完全符合 Moore 型"输出仅与当前状态有关"的定义。
- 两次匹配的时刻：采样第 7 位后（150 ns）状态由 S6 进入 S7，`out` 立即拉高，并保持一个完整的时钟周期（至 170 ns）后随状态离开 S7 而恢复为 0；采样第 16 位后（330 ns）再次进入 S7。全程共匹配成功两次，与预期一致。
- 重叠检测正确：输入序列中第 9 至第 15 位再次构成 `1110010`。状态机在 S7 之后正常回到 S0 并重新开始匹配，且中途在第 12 位出现 `S3` 接收到 `1` 保持 S3 的自环（`1111` 中仍包含前缀 `111`），说明状态转移表（尤其是 S3 的自环、S6 到 S7 以及 S7 的回退）实现正确。

= 五、思考题

== 1. 为什么补码减法可以与加法复用同一个加法器？

因为在补码表示中，减法可以转化为加负数：$A - B = A + (-B)$，而一个数的相反数的补码等于"按位取反再加一"，即 `-B = ~B + 1`。于是减法可以写成 `A + ~B + 1`，与加法共用同一个加法器，只需在加法器的第二操作数前加一级"取反 / 不取反"的选择逻辑，并把最低位的输入进位置为 1 或 0 即可。
== 2. 为什么不能直接用 $A - B$ 的符号位判断任意两个有符号数的大小？

因为 $A - B$ 的结果可能超出 32 位有符号数的表示范围而发生溢出，一旦溢出，符号位就不再反映真实的大小关系。最典型的情形是两个异号数相减：例如 $A$ 为正数、$B$ 为负数时，$A - B$ 实际上是两个正数相加，结果可能超过 $2^{31} - 1$，此时符号位会由 0 翻转为 1，看起来像"负数"，但它其实大于 $B$。因此正确的判断需要分情况：

- $A$ 为负、$B$ 为非负：一定有 $A < B$；
- $A$ 为非负、$B$ 为负：一定有 $A > B$；
- 两者同号：同号相减不会产生有符号溢出；

本设计直接使用 `$signed(A) < $signed(B)` 完成比较，综合工具会据此生成包含上述溢出处理的比较逻辑。

== 3. 为什么逻辑右移只使用 `B[4:0]` 作为移位量？

因为操作数是 32 位，有意义的最大移位量是 31 位，而 5 位二进制刚好可以表示 0 至 31 共 32 种取值。

== 4. RegFile 的组合读与同步写在波形上分别有什么特点？

组合读：读数据是读地址与寄存器内容的纯组合函数，不经过任何触发器。波形上表现为读地址一改变（或写操作改变了对应寄存器的内容），读数据立刻在同一时刻更新，变化位置不对齐时钟沿；读操作不受时钟与写使能的约束，任何时刻都能反映出当前寄存器的真实内容。

同步写：写入只在时钟上升沿发生，并且要求复位无效、`RegWrite = 1`、`Wt_addr != 0` 同时成立。波形上表现为：写地址与写数据可以在任意时刻给出，但寄存器内容的更新严格出现在时钟上升沿之后，并保持到下一次写入；在非时钟上升沿改变写信号时，寄存器内容保持不变。因此波形上可以清楚地看到"读是连续的、写是离散的"这一区别。

== 5. 为什么 S3 接收到 1 时保持 S3，而 S6 接收到 1 时转移到 S2？

因为次态由"已匹配前缀 + 新输入位"中最长的、同时是目标序列前缀的后缀决定。

- 状态 S3 表示已匹配 `111`。再接收到一个 `1` 后得到 `1111`，它的后缀 `111` 恰好仍是目标序列 `1110010` 的前缀（长度为 3），所以状态仍然停留在表示"已匹配 3 位"的 S3，即形成自环。
- 状态 S6 表示已匹配 `111001`。再接收到一个 `1` 后得到 `1110011`，它的各个后缀中，只有 `1` 和 `11` 是目标序列的前缀，其中最长的是 `11`（长度为 2），所以状态退回到 S2。

== 6. Moore 型序列检测器的输出在完整序列的最后一位被采样前后如何变化？

在 Moore 型中输出只由现态决定，而现态只在时钟上升沿更新，因此：

- 完整序列的最后一位（本设计中的 `0`）被采样之前，状态还停留在 S6（已匹配前 6 位），此时 `out = 0`；
- 该位在时钟上升沿被采样之后，状态才由 S6 进入 S7，`out` 随即变为 1，并保持一个完整的时钟周期，直到状态离开 S7（下一次采样）才恢复为 0。

# 模型结构图评审标准（Review Rubric）

本评审用于检查模型结构图是否：

1. 与源码实现一致
2. 结构表达完整
3. 论文级可读性
4. 满足 layout-rules.md 中的几何约束

评审结论必须明确：**通过 / 不通过**

## 一、结构正确性（Architecture Correctness）

检查模型结构是否与源码和 config 一致。

重点检查：

- 模型范式是否正确
  - Decoder-only
  - Encoder-decoder
  - Vision-Language
  - Hybrid

- 主干路径是否正确
  - Input → Embedding → Blocks → Output

- Decoder / Encoder 层数是否正确

- Attention 类型是否正确
  - Self Attention
  - GQA
  - MQA
  - Linear Attention
  - DeltaNet 等

- Norm 类型是否正确
  - RMSNorm
  - LayerNorm

- FFN / MLP 结构是否正确
  - Gate
  - Activation
  - Projection

- Residual 路径是否完整

- 输出 Head 是否正确
  - LM Head
  - Classification Head

如果存在结构性错误 → **严重问题**

---

## 二、Vision Encoder 检查（VLM 专项）

- 如果模型是 VLM / MLLM，必须检查 Vision Encoder。
- 禁止仅使用文字说明框描述 Vision Encoder。
- Vision Encoder 必须包含结构路径：
```
Image / Video Input
↓
Patch / Tubelet Embedding
↓
Positional / Rotary Encoding
↓
Vision Transformer Block × N
↓
Spatial Merge / Projector
↓
Visual Tokens
```
- 同时必须展开 **一个 Vision Block 内部结构**，例如：
    - Norm
    - Self Attention
    - Residual Add
    - Norm
    - MLP / FFN
    - Residual Add
- 如果 Vision Encoder 仅为说明卡片 → **严重问题**


## 三、模块完整性（Module Completeness）

检查关键模块是否缺失。

至少应包含：

- Embedding
- Positional Encoding
- Transformer Block
- Attention
- Norm
- Residual
- MLP / FFN
- Output Head

多模态模型必须包含：

- Vision Encoder
- Multi-modal Integration
- Projector / Connector

缺失关键模块 → **严重问题**


## 四、抽象合理性（Abstraction Quality）

检查重复模块的抽象。

例如：

Transformer Block × 64

必须：

- 只展开一个 Block
- 标注重复次数

禁止：

- 画 64 个重复模块
- 或完全隐藏 Block 结构

抽象误导读者 → **中等问题**


## 五、数据流清晰度（Data Flow Clarity）

检查数据流是否清晰。要求：

- 输入在上
- 输出在下
- 主干垂直流

Residual Add 必须：

- 明确两个输入来源
- 不产生歧义

如果读者无法快速理解数据流 → **中等问题**


## 六、版式与几何规则（Layout Rules）

必须符合 `layout-rules.md`。重点检查：

### 1 模块边界

所有子模块必须完全在父容器内部。禁止：

- FFN 超出 Decoder Layer
- Attention 超出 Block
- 文本越界

如果存在模块越界 → **严重问题**

### 2 Residual 连线

Residual 连线必须：

- 沿模块边缘走线
- 不穿过模块正文
- 不产生混乱交叉

Add 节点必须：

- 位于主干中心线
- 连线清晰

若 Residual 连线混乱 → **严重问题**

### 3 注释卡片

Specifications / Config 卡片：

- 不得遮挡主网络结构。
- 只允许放在：
    - 左侧留白
    - 右侧留白
    - 图底部
- 如果遮挡主图 → **严重问题**

### 4 主干对齐

Decoder 主干必须：

- 垂直居中
- 上下对齐

关键节点：

- Residual Add
- Norm
- FFN
- LM Head

若明显错位 → **中等问题**

### 5 文本密度

模块内部文字不应过长。

如果文本过多导致：

- 模块失衡
- 版式混乱

→ **轻微问题**


## 七、论文表达质量（Paper-level Quality）

结构图应达到论文级表达质量：

- 模块层级清晰
- 结构逻辑清楚
- 数据流明确
- 没有视觉混乱

如果整体阅读困难 → **中等问题**


## 八、评审输出格式（必须遵守）

评审结果必须严格按以下格式输出：

### 结论

通过 / 不通过

### 严重问题

列出所有必须修复的问题。

例如：

- Vision Encoder 未展开
- FFN 模块越界
- Residual 连线混乱
- Specifications 卡片遮挡结构

### 中等问题

需要改进，但不影响结构正确性。

例如：

- Block 抽象不清
- 主干对齐略偏

### 轻微问题

排版或文本问题。

### 必须修改项

列出需要修复的具体操作。

### 建议修改项

优化建议。

### 可以保留项

当前设计合理的部分。

### 修订后是否需要复审

是 / 否


## 一句话总结

例如：

"结构正确，但 Vision Encoder 未展开且 FFN 越界，需要重新排版。"
# 强制版式与布局约束

以下约束为硬性要求，违反任一项都不得交付：

## 1. 父子容器边界约束
- 所有子模块必须完整包含在所属父模块边界内。
- 不允许任何模块、文字框、说明框、连接节点超出父模块边界。
- 如果内容过长，优先：
  1. 缩短标签文本
  2. 分成两行或三行
  3. 增大父容器尺寸
- 禁止通过“让子模块溢出边界”来容纳内容。

## 2. 主干居中约束
- Decoder 主干必须沿画布垂直中心线自上而下排列。
- Residual Add、Norm、FFN、LM Head 等核心节点必须上下对齐。
- 不允许核心主干节点左右漂移。

## 3. Residual 连线约束
- Residual 支路必须沿模块外边缘或留白区域走线。
- 不允许残差线穿过模块正文区域。
- Add 节点必须位于主干中心线上。
- 左右支路回流到 Add 节点时，必须使用规整折线，尽量左右对称。
- 若一个模块内部存在两个主要分支（如 attention 分支与 FFN 分支），每个 Add 节点都必须清楚标示其输入来源。

## 4. 注释卡片约束
- Specifications、配置摘要、实现说明等卡片不得遮挡主网络结构。
- 注释卡片只能放在：
  - 右侧留白区
  - 左侧留白区
  - 图底部附录区
- 若空间不足，优先精简卡片内容，不得压住主图。
- 注释卡片与主图之间必须留出明显间距。

## 5. Vision Encoder 展开约束
- 对于 VLM / MLLM，Vision Encoder 不能只写摘要说明，必须画出结构主干。
- 至少要展示：
  1. Image / Video Input
  2. 3D Patch Embedding 或 Patch Embedding
  3. Positional / Rotary Encoding
  4. Vision Block × N
  5. 展开一个典型 Vision Block 的内部结构
  6. Merger / Spatial Merge / Projector
  7. 输出视觉 token / feature
- Vision Block 的内部至少体现：
  - Norm
  - Vision Self-Attention
  - Residual
  - MLP / FFN
  - Activation
  - Residual
- 如果主图空间不足，应将 Vision Encoder 单独做成左侧展开区，而不是退化成说明文字框。

## 6. 模块尺寸策略
- 先确定父模块尺寸，再放置子模块。
- 对于 Decoder Layer、Vision Block 等容器：
  - 必须预留顶部标题区
  - 必须预留内部垂直间距
  - 必须预留支路线通道
- 不允许先放满内容后再勉强套容器。

## 7. 文字密度控制
- 结构图优先展示模块关系，而不是堆砌参数文字。
- 每个模块内部文字应控制在可读范围。
- 若某模块说明超过 5~6 行，应优先：
  - 抽成要点
  - 拆到旁注
  - 缩成“结构标签 + 关键参数”
- 不要让长文本破坏模块尺寸与布局。

## 8. 交付前几何检查
提交前必须逐项检查：
- 是否有任何模块越界
- 是否有任何说明卡遮挡主图
- 是否有连线交叉核心模块正文
- 是否有 Add 节点走线混乱
- 是否有应展开的 Vision / Decoder 内部没有展开
- 注意 Resiual Add 连线正确
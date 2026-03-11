# 最终模型结构图输出规范

## 总体风格
- 目标是“论文常见的 LLM / VLM 架构图”
- 清晰、规整、工程感强
- 不是 UI 流程图，不是业务流程图

## 方向要求
- 输入在上
- 输出在下
- 主干自上而下

## 展示粒度
- 展开一个典型重复 Block 的内部
- 标注重复次数，例如 ×32、×48
- 不重复画大量同构模块

## 必须尽量体现的细节
- Embedding
- Position / Rotary / Patch Embedding
- Attention 类型
- Norm 类型
- MLP / FFN / Gate / Activation
- Residual
- Vision tower / Projector / Merger / Connector
- LM Head / 输出头

## 连线规则
- 连线优先沿模块边缘或空白区域走
- 避免穿过模块
- 避免杂乱交叉
- 支路合并关系明确

## 标签规则
- 标签准确
- 尽量简洁
- 避免把实现细节压缩成模糊大词，如“Processing”
- 应优先使用真实模块名或规范化模块名，例如：
  - RMSNorm
  - SwiGLU FFN
  - Grouped Query Attention
  - Rotary Positional Embedding
  - Vision Projector

## 多模态模型要求
若模型是 VLM / MLLM，必须清楚展示：
- 图像输入
- 视觉编码器
- 视觉特征投影 / 对齐
- 文本 token 输入
- 语言模型主干
- 跨模态融合接口
- 最终输出

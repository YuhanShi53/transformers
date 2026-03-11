---
name: draw-model-architecture
description: 分析模型源码与 HuggingFace config，使用 drawio MCP 绘制论文风格的 LLM/VLM 模型结构图，并调用 review-model-diagram Skill 进行结构评审，循环修正直到通过。
disable-model-invocation: true
---

# 模型结构图自动生成 Skill

此 Skill 用于 **自动生成论文级模型结构图**。

用户只需提供：

- 模型源码目录
- HuggingFace config 目录
- 模型名称（可选）

调用方式：

/draw-model-architecture <model_name> <config_dir>


## 工作流程

完整流程定义在：references/workflow.md，你必须严格按 workflow 执行。

### 第一阶段：信息收集

#### 1. 在当前 workspace 中寻找模型

**源码：**
- model.py
- modeling_*.py
- architecture.py
- module.py
- block.py

**配置文件：**
- config.json
- preprocessor.json
- tokenizer_config.json
- generation_config.json

#### 2. 提取信息

**模型类型：**
- Decoder-only
- Encoder-decoder
- Vision-language
- Hybrid
- MoE
- 其他

**关键结构：**
- Embedding
- Attention
- Norm
- FFN
- Residual
- Vision Encoder
- Projector
- Output Head

**关键信息：**
- 层数
- attention 类型
- norm 类型
- 激活函数
- 特殊模块


### 第二阶段：生成结构蓝图

在绘图之前必须生成 **文字蓝图**，蓝图内容：

1. 输入结构
2. 模型主干
3. Transformer Block
4. 多模态路径
5. 输出结构

示例：

```
Input Tokens  
↓  
Embedding + Positional Encoding  
↓  
Transformer Block × 32  
  ├─ RMSNorm  
  ├─ Self Attention (GQA)  
  ├─ Residual  
  ├─ RMSNorm  
  ├─ SwiGLU FFN  
  └─ Residual  
↓  
LM Head  
↓  
Output Tokens
```

### 第三阶段：调用 drawio MCP

根据蓝图绘制第一版结构图。要求：

- 输入在上  
- 输出在下  
- 数据流自上而下
- 展开 Transformer Block 内部结构
- 不要重复绘制：Block × N

必须包含：

- Attention 类型
- Norm 类型
- Activation
- Residual

多模态模型必须包含：

Vision Encoder  
Projector  
Language Model

### 第四阶段：导出图片

使用 drawio MCP 导出 PNG。记录 diagram_path。

### 第五阶段：调用评审 Skill

调用 `/review-model-diagram`，并提供：

- 模型名称
- 源码摘要
- config 摘要
- diagram_path
- 结构蓝图

### 第六阶段：处理评审结果

如果 review 返回 "通过"，流程结束；如果返回 "不通过"，则：

1. 提取严重问题
2. 提取中等问题
3. 根据问题修改结构图
4. 再次调用 drawio MCP

然后重新调用 review-model-`/review-model-diagram`，循环直到 review 通过。

### 第七阶段：在线展示

最终完成后，通过 drawio MCP 提供 drawio server 展示，返回以下内容：

结构图
在线展示方式
codex 评审结论
关键结构说明

## 绘图要求

绘图必须同时遵守以下两个规范文件：

- references/output-spec.md （模型结构图表达规范）
- references/layout-rules.md （强制版式与布局约束）

开始绘图之前必须先读取以上文件。如果文件之间出现冲突，优先级如下：

1. references/layout-rules.md
2. references/output-spec.md

## 出图前自检

详见：references/checklist.md

## 终止条件

以下任一满足即可结束：

1 review 通过  
2 仅剩轻微排版建议  
3 源码存在歧义无法确定

如果存在歧义，必须列出不确定项。如果生成的结构图违反 references/layout-rules.md 中任何规则：不得交付。必须重新调用 drawio MCP 修图。

## 布局失败回退策略

如果首次绘图出现以下任一情况：
- 模块越界
- 说明卡遮挡主图
- Vision Encoder 未展开
- 残差走线混乱

则不要在原图上局部打补丁式修复，优先采用以下策略之一重排：

1. 扩大画布并重建布局
2. 将 Vision 分支单独放到左侧展开区
3. 将 Specifications 移到底部附录区
4. 缩短模块内部长文本，只保留关键结构标签
5. 将 Decoder Layer 重新设为“固定容器 + 内部垂直流布局”

## 图片导出路径

图片必须导出到当前 workspace 的 `tmp/diagrams/` 目录下，文件名格式为：

{model_name}_architecture_{version}.png

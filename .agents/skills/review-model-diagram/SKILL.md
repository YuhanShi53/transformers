---
name: review-model-diagram
description: 对照源码实现，使用 codex MCP 对模型结构图进行严格评审，检查结构正确性、实现一致性、论文级表达质量，并给出修改建议。
---

# 模型结构图评审 Skill

该 Skill 用于对 **模型结构图进行严格技术评审**。

输入：

- 模型名称
- 模型源码摘要
- config 摘要
- diagram_path
- 结构蓝图


## 调用 codex MCP

调用 codex MCP，为 codex 提供：

- 模型名称
- 源码结构：
- 结构蓝图
- 结构图图片：diagram_path


## 评审标准

详见：references/review-rubric.md


## codex 评审输出格式

必须严格要求 codex 返回：

结论:
通过 / 不通过

严重问题:
...

中等问题:
...

轻微问题:
...

必须修改项:
...

建议修改项:
...

可以保留项:
...

修订后是否需要复审:
是/否

一句话总结:

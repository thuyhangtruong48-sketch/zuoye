# 上海胶州路火灾救援路径规划一键流水线 流水线摘要

## 数据来源
- 道路数据：OpenStreetMap / Overpass API 区域路网抽取。
- 历史灾害：公开资料：上海胶州路 11.15 特别重大火灾。
- 灾害资料链接：https://zh.wikipedia.org/wiki/%E4%B8%8A%E6%B5%B7%E2%80%9C11%C2%B715%E2%80%9D%E7%89%B9%E5%88%AB%E9%87%8D%E5%A4%A7%E7%81%AB%E7%81%BE

## 空间映射方法
- 灾害类型：fire。
- 影响半径：0.45 km。
- 映射规则：以火灾点为中心建立消防响应影响缓冲区，道路边进入缓冲区则标记为 fire 风险路段；若存在交通状态 CSV，则按道路名称匹配拥堵信息。
- 道路坐标由 OSM 的 WGS84 转为 GCJ-02，再与灾害缓冲区做叠加判断。

## 路网规模
- 节点数量：17644
- 道路边数量：19502
- 灾害影响道路边数量：301
- 交通匹配道路边数量：6559

## Dijkstra 结果
### 普通最短路径
- 距离：2.001 km
- 综合代价：2.001
- 危险边数量：13
- 危险类型：fire
### 安全路径
- 距离：3.725 km
- 综合代价：16.804
- 危险边数量：6
- 危险类型：fire

## 生成文件
- 数据目录：D:\lihao\作业\data\demo_shanghai_fire_pipeline
- 结果目录：D:\lihao\作业\outputs\demo_shanghai_fire_pipeline
- 路径结果：D:\lihao\作业\outputs\demo_shanghai_fire_pipeline\path_results.json
- 对比表：D:\lihao\作业\outputs\demo_shanghai_fire_pipeline\path_comparison.csv
- 可视化图：D:\lihao\作业\outputs\demo_shanghai_fire_pipeline\route_map_abstract.png
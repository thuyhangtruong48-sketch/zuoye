# 北京洪水救援路径规划一键流水线示例 流水线摘要

## 数据来源
- 道路数据：OpenStreetMap / Overpass API 区域路网抽取。
- 历史灾害：北京 2012 年 7 月 21 日特大暴雨公开资料。
- 灾害资料链接：https://zh.wikipedia.org/wiki/2012%E5%B9%B4%E5%8C%97%E4%BA%AC%E7%89%B9%E5%A4%A7%E6%9A%B4%E9%9B%A8

## 空间映射方法
- 灾害类型：flood。
- 影响半径：2.4 km。
- 映射规则：以历史洪水影响点为中心建立缓冲区，道路边进入缓冲区则标记为 flood 风险路段。
- 道路坐标由 OSM 的 WGS84 转为 GCJ-02，再与灾害缓冲区做叠加判断。

## 路网规模
- 节点数量：52755
- 道路边数量：58975
- 灾害影响道路边数量：4708
- 交通匹配道路边数量：0

## Dijkstra 结果
### 普通最短路径
- 距离：19.905 km
- 综合代价：19.905
- 危险边数量：0
- 危险类型：无
### 安全路径
- 距离：19.91 km
- 综合代价：20.755
- 危险边数量：0
- 危险类型：无

## 生成文件
- 数据目录：D:\lihao\作业\data\demo_beijing_flood_pipeline
- 结果目录：D:\lihao\作业\outputs\demo_beijing_flood_pipeline
- 路径结果：D:\lihao\作业\outputs\demo_beijing_flood_pipeline\path_results.json
- 对比表：D:\lihao\作业\outputs\demo_beijing_flood_pipeline\path_comparison.csv
- 可视化图：D:\lihao\作业\outputs\demo_beijing_flood_pipeline\route_map_abstract.png
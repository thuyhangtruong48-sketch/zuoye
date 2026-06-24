let scenarios = [];
let currentId = null;
let running = false;

const $ = (id) => document.getElementById(id);

function formatNumber(value) {
  const number = Number(value || 0);
  return number.toLocaleString("zh-CN");
}

function valueOrNone(value) {
  if (value === undefined || value === null || value === "") return "无";
  return value;
}

async function loadScenarios() {
  const response = await fetch("/api/scenarios");
  scenarios = await response.json();
  renderMarkers();
  renderScenarioList();
  selectScenario(scenarios[0].id);
}

function renderMarkers() {
  const box = $("mapMarkers");
  box.innerHTML = "";
  scenarios.forEach((scene) => {
    const marker = document.createElement("button");
    marker.className = `map-marker ${scene.type}`;
    marker.style.left = `${scene.marker.x}%`;
    marker.style.top = `${scene.marker.y}%`;
    marker.title = scene.title;
    marker.innerHTML = `<span>${scene.province}</span>`;
    marker.addEventListener("click", () => selectScenario(scene.id));
    marker.dataset.id = scene.id;
    box.appendChild(marker);
  });
}

function renderScenarioList() {
  const list = $("scenarioList");
  list.innerHTML = "";
  scenarios.forEach((scene) => {
    const card = document.createElement("div");
    card.className = "scenario-card";
    card.dataset.id = scene.id;
    card.innerHTML = `<strong>${scene.title}</strong><span>${scene.event}｜${scene.start} → ${scene.target}</span>`;
    card.addEventListener("click", () => selectScenario(scene.id));
    list.appendChild(card);
  });
}

async function selectScenario(id) {
  currentId = id;
  const scene = scenarios.find((item) => item.id === id);
  updateActiveState(id);
  renderScene(scene);
}

function updateActiveState(id) {
  document.querySelectorAll(".scenario-card").forEach((item) => {
    item.classList.toggle("active", item.dataset.id === id);
  });
  document.querySelectorAll(".map-marker").forEach((item) => {
    item.classList.toggle("active", item.dataset.id === id);
  });
}

function renderScene(scene) {
  $("typeBadge").textContent = scene.type_label;
  $("sceneTitle").textContent = scene.title;
  $("sceneSummary").textContent = scene.summary;
  $("sceneDate").textContent = scene.date;
  $("scenePlace").textContent = `${scene.province} · ${scene.city}`;
  $("routeImage").src = `${scene.routeImage}&t=${Date.now()}`;

  $("nodeCount").textContent = formatNumber(scene.stats.nodes);
  $("edgeCount").textContent = formatNumber(scene.stats.edges);
  $("riskEdgeCount").textContent = formatNumber(scene.stats.mappedDangerEdges);
  $("trafficEdgeCount").textContent = formatNumber(scene.stats.trafficMappedEdges);

  const distance = scene.result.distance || {};
  const safe = scene.result.safe || {};
  $("distanceKm").textContent = `${valueOrNone(distance.total_distance)} km`;
  $("distanceDanger").textContent = valueOrNone(distance.dangerous_edge_count);
  $("distanceTypes").textContent = valueOrNone(distance.danger_types);
  $("safeKm").textContent = `${valueOrNone(safe.total_distance)} km`;
  $("safeCost").textContent = valueOrNone(safe.total_cost);
  $("safeTypes").textContent = valueOrNone(safe.danger_types);

  renderPipeline(scene.pipeline);
  $("logBox").textContent = [
    `当前场景：${scene.title}`,
    `历史灾害：${scene.event}`,
    `重点风险：${scene.hazard}`,
    `数据目录：${scene.dataDir}`,
  ].join("\n");
}

function renderPipeline(steps, activeIndex = -1) {
  const box = $("pipeline");
  box.innerHTML = "";
  steps.forEach((step, index) => {
    const item = document.createElement("div");
    item.className = `pipe-step ${index === activeIndex ? "active" : ""}`;
    item.textContent = `${index + 1}. ${step}`;
    box.appendChild(item);
  });
}

async function runDemo() {
  if (running || !currentId) return;
  running = true;
  const scene = scenarios.find((item) => item.id === currentId);
  $("demoBtn").disabled = true;
  $("runBtn").disabled = true;

  const steps = scene.pipelineSteps || [];
  const totalSteps = steps.length || scene.pipeline.length;
  const logs = [];

  for (let i = 0; i < totalSteps; i += 1) {
    const stepLabel = scene.pipeline[i] || `步骤 ${i + 1}`;
    renderPipeline(scene.pipeline, i);
    logs.push(`[${new Date().toLocaleTimeString()}] ${stepLabel}`);
    $("logBox").textContent = logs.join("\n");

    // 切换中间图片到对应步骤图
    if (steps[i]) {
      $("routeImage").src = `/artifact?path=${steps[i]}&t=${Date.now()}`;
    }

    await new Promise((resolve) => setTimeout(resolve, 1800));
  }

  logs.push("[完成] 已输出普通最短路径、安全路径、对比表和可视化图。");
  $("logBox").textContent = logs.join("\n");
  renderPipeline(scene.pipeline, -1);

  // 最后恢复完整最终图
  if (scene.routeImage) {
    $("routeImage").src = `${scene.routeImage}&t=${Date.now()}`;
  }

  $("demoBtn").disabled = false;
  $("runBtn").disabled = false;
  running = false;
}

async function recalculate() {
  if (running || !currentId) return;
  running = true;
  $("demoBtn").disabled = true;
  $("runBtn").disabled = true;
  $("logBox").textContent = "正在调用本地 Dijkstra 重新计算，请稍等...";
  const response = await fetch(`/api/recalculate/${currentId}`, { method: "POST" });
  const payload = await response.json();
  const message = payload.ok ? "重新计算完成" : "重新计算失败";
  $("logBox").textContent = [
    `[${message}] 用时 ${payload.elapsed || 0} 秒`,
    ...(payload.logs || []),
  ].join("\n");
  const refreshed = await fetch(`/api/scenarios/${currentId}`).then((res) => res.json());
  scenarios = scenarios.map((item) => (item.id === currentId ? refreshed : item));
  renderScene(refreshed);
  $("demoBtn").disabled = false;
  $("runBtn").disabled = false;
  running = false;
}

$("demoBtn").addEventListener("click", runDemo);
$("runBtn").addEventListener("click", recalculate);

loadScenarios().catch((error) => {
  $("logBox").textContent = `平台加载失败：${error}`;
});

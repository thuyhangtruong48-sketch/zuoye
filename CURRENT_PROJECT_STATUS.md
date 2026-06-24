# Current Project Status

## Current Priority

The current work focuses only on the project implementation itself:

- real AMap road data acquisition;
- historical earthquake and flood scenario data;
- Dijkstra route planning;
- route result data outputs;
- map and route visualization quality.

## Important Boundary

Do not update or regenerate presentation/report deliverables for now.

Specifically, do not work on these unless the user explicitly asks later:

- PPT files;
- presentation outline;
- report manuscript;
- DOCX manuscript;
- demo script;
- final presentation package.

## Current Visualization Direction

The preferred visualization is the real-road 2D abstract map:

- `outputs/amap_earthquake/route_map_abstract.png`
- `outputs/amap_flood/route_map_abstract.png`

These maps should keep using real AMap road geometry, but with simplified and polished visual styling for clearer course-project presentation.

## Notes For Future Work

- Keep using Dijkstra only.
- Do not reintroduce A*.
- Keep AMap Key out of source files, docs, and output materials.
- Continue treating `context_` routes as background-only roads; they should not participate in Dijkstra path planning.
- Before touching PPT/report materials, confirm with the user first.

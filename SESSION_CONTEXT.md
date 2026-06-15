# Session Context - Love2D Platformer

## Estado del proyecto

### Stack
- Love2D + Lua
- Arch Linux
- Editor: Kate
- **Problema conocido de Kate**: al pegar snippets mezcla código nuevo con viejo. Siempre dar archivos completos.

### Estructura actual
```
game/
├── conf.lua
├── main.lua
├── map.lua
├── player.lua
├── camera.lua
├── bullet.lua
├── weapon.lua
├── level.lua (vacío/ignorar)
├── levels/
│   └── level1.lua
├── entities/
│   └── runner.lua  ← recién creado, sin integrar a main.lua
└── weapons/
    ├── semiauto.lua
    ├── shotgun.lua
    ├── fullauto.lua
    └── flamethrower.lua
```

### Filosofía
Mismo enfoque que el motor C/Raylib anterior:
- Módulos ciegos, cada sistema expone solo su interfaz
- Data-driven levels
- Pool pre-alocado para balas (100 slots, sin GC en game loop)
- Zero garbage en game loop

### Formato de nivel
String multilínea con `[[]]` en Lua, sin comas, idéntico al `.txt` anterior:
```lua
return {
    name = "World 1-1",
    tileLength = 32,
    gravity = 1100,
    grid = [[
########################################
#......................................#
#................P.....................#
########################################
]]
}
```

Tokens activos: `#` (sólido), `P` (spawn). Más por venir.

### Grid cacheado
`Map.load` parsea el string y cachea `Map.current.rows` como tabla indexada. `isSolid` accede por índice O(1).

### Cámara
- `camera.lua` separado
- Deadzone + lerp
- ZOOM fijo = 2.0
- Clamp a límites del nivel
- `SetExitKey` equivalente: `love.event.quit()` en keypressed escape

### Balas
- Pool de 100 slots en `bullet.lua`
- `Bullet.createPool()`, `Bullet.spawn()`, `Bullet.update()`, `Bullet.draw()`
- Pool creado en `main.lua`, pasado como parámetro a `Player.update`

### Armas
- Factory en `weapon.lua`, perfiles en `weapons/*.lua`
- 4 perfiles: semiauto, shotgun, fullauto, flamethrower
- Mismo sistema polimórfico que antes: `fireFunc(origin, dir, pool, spawnFunc)`
- `tileSize = 32` hardcodeado en cada perfil (no hay TILE_SIZE global en Lua)

### Player
- Inventario: 2 slots, swap con Q
- `spacePressed` flag para distinguir press (semiauto) vs hold (automático)
- Muzzle origin basado en `facing`: sale del borde derecho/izquierdo del sprite
- `aimDir` = `{x = facing, y = 0}` por ahora (sin aim diagonal todavía)
- Jump: W o Space (solo W para saltar, Space reservado para disparo)

### Runner (entities/runner.lua)
- Recién creado, NO integrado a main.lua todavía
- Patrulla con detección de bordes (checkEdge)
- Gravedad aplicada, colisión vertical con tiles
- `solid()` duplicado localmente (pendiente extraer a world.lua)
- Estado: solo patrulla. Pendiente: detección de jugador, aggro, memoria, freeze

## Próximo paso
Integrar runner a `main.lua` con un runner de prueba y llamar update/draw.
Después: detección de jugador, aggro, memoria, freeze (igual que motor anterior).

## Deuda técnica abierta
- `solid()` duplicado en runner.lua e isSolid en player.lua → extraer a `world.lua`
- `tileSize = 32` hardcodeado en cada weapon → considerar pasar como parámetro
- Aim diagonal no implementado
- Drops de armas pendientes (necesita enemigos primero)
- Tileset system pendiente
- Scene manager / menú pendiente
- Victory conditions pendientes

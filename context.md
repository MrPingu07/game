# PROJECT_CONTEXT.md

# Relampago Custom Engine

## Objetivo

Este proyecto es un port progresivo de un juego anterior en C hacia un nuevo motor basado en LÖVE2D.

La prioridad NO es reescribir todo desde cero.

La prioridad es portar comportamiento existente de forma incremental manteniendo el juego siempre ejecutable.

---

# Filosofía

Principios del proyecto:

1. El juego debe compilar después de cada commit.
2. El juego debe ser jugable después de cada commit.
3. Primero funcionalidad.
4. Después feedback visual.
5. Después contenido.
6. Finalmente optimización.
7. No introducir abstracciones prematuras.
8. No realizar refactors grandes mientras existan funcionalidades sin portar.

Preferimos:

Implementar → Probar → Commit

antes que:

Diseñar → Refactorizar → Reescribir

---

# Workflow

## Regla principal

El juego debe correr después de cada commit.

## Regla para modificaciones

Cuando se indique un cambio de código:

* Especificar archivo.
* Especificar bloque anterior.
* Especificar bloque a reemplazar.
* Especificar bloque posterior.
* Evitar instrucciones ambiguas.

Si una respuesta requiere demasiados cambios:

* Dividir en varios pasos.
* Mantener cada paso compilable.

## Nota sobre Kate

Kate mezcla código nuevo con viejo al pegar snippets sobre archivos existentes.
Solución: siempre dar el archivo completo y borrar el contenido antes de pegar.

## Objetivo

Nunca quedar atrapados en un estado donde el juego no corre.

---

# Estado actual del port

## Player

Implementado:

* Movimiento horizontal
* Salto
* Agacharse con squash (altura y ancho reducidos, centrado)
* Disparo con muzzle basado en facing
* Press vs Hold para semiauto vs automático (spacePressed flag)
* Inventario de 2 slots, swap con Q
* Sistema de armas polimórfico
* Health
* Damage por contacto con cooldown (0.5s)
* Death State (isDead)
* HUD HP
* YOU DIED

Comportamiento actual:

* El jugador recibe daño por contacto con enemigos.
* Al llegar a 0 HP: isDead = true, controles bloqueados, aparece YOU DIED.

Campos relevantes:

* fullHeight = 32, crouchHeight = 24
* fullWidth = 32, crouchWidth = 24
* isCrouching flag

---

## Runner

Implementado:

* Spawn desde token R en mapa
* Movimiento con gravedad
* Detección de bordes (raycast de 60 grados)
* FSM: patrol, freeze (0.5s), aggro
* Detección de jugador por radio
* Chase con salto hacia plataformas superiores
* Health (muere en 3 impactos de semiauto)
* Damage recibido (solo balas fromPlayer)
* Death y cleanup automático
* Color por estado: patrol=púrpura, freeze=amarillo, aggro=rojo
* Radio de detección debug en amarillo fijo

---

## Gunner

Implementado:

* Spawn desde token G en mapa
* Movimiento con gravedad
* FSM: patrol, freeze (0.5s), aggro_cooldown (3s), aggro_burst
* Mantiene distancia preferida del jugador (PREFERRED_DIST)
* Apunta directo al jugador con vector normalizado durante burst
* Dispara ráfaga de 3 balas con 0.25s entre cada una
* Cooldown de 3s entre ráfagas
* Balas propias NO se dañan a sí mismo (fromPlayer flag)
* Health = 60
* Damage recibido (solo balas fromPlayer)
* Death y cleanup automático
* Color por estado: patrol=marrón, freeze=amarillo, aggro=naranja
* Radio de detección debug en amarillo fijo

Pendiente:

* Facing para sprites

---

## Colisiones

Archivo: entities/collisions/collision.lua

Implementado:

* Bullet vs Runner (solo fromPlayer=true)
* Bullet vs Gunner (solo fromPlayer=true)
* Runner vs Player (AABB, aplica daño con cooldown)
* Gunner vs Player: pendiente

---

## Balas

Pool de 100 slots en bullet.lua.
Campo fromPlayer distingue origen para evitar friendly fire entre enemigos.
Balas del jugador: fromPlayer=true via wrapper en player.lua.
Balas de enemigos: fromPlayer=false (default).

---

## HUD

Archivo: ui/hud.lua

Implementado:

* HP centrado abajo
* YOU DIED centrado en rojo

---

## Armas

Todas funcionales:

* Semiauto: press, 34 dmg, amarillo
* Shotgun: press, 5 pellets, 15 dmg c/u, dorado
* Fullauto: hold, 10 dmg, naranja
* Flamethrower: hold, 5 dmg, rojo, tamaño aleatorio

---

## Mapa

Tokens activos: #, P, R, G
Parser: gmatch("[^\n]+") sobre string multilínea [[]]
Grid cacheado en Map.current.rows para isSolid O(1)
enemySpawns retornado por Map.load para spawn en love.load

---

# Estructura actual

```
game/
├── entities/
│   ├── enemy.lua (vacío, refactor diferido)
│   ├── enemies/
│   │   ├── runner.lua
│   │   ├── gunner.lua
│   │   └── mosquito.lua (vacío)
│   └── collisions/
│       └── collision.lua
├── ui/
│   └── hud.lua
├── weapons/
│   ├── semiauto.lua
│   ├── shotgun.lua
│   ├── fullauto.lua
│   └── flamethrower.lua
├── levels/
│   └── level1.lua
├── player.lua
├── bullet.lua
├── map.lua
├── world.lua
├── camera.lua
├── weapon.lua
├── conf.lua
└── main.lua
```

---

# Roadmap

## En progreso

Nada actualmente.

---

# Pendiente

## Enemigos

### Mosquito

* Ignora gravedad e ignora geometría
* Patrulla
* Detecta jugador
* Ataque errático al detectar
* Puede recibir daño y morir

Estado: No implementado.

---

## Colisiones pendientes

* Gunner vs Player (contacto, daño)
* Verificar tunneling en player, runner, drops
* Verificar colisiones laterales (tiles atravesables lateralmente)

---

## Sistema de Drops

* Física
* Spawn al morir enemigo
* Recolección
* Probabilidad dinámica

---

## Victory Conditions

* kill_all: pendiente
* collect_keys:N: pendiente
* break_all_boxes: pendiente
* reach_exit: pendiente
* kill_boss: pendiente
* Condiciones AND/OR: pendiente

---

## Exit Tile

Token E en mapa, transición de nivel condicional.

---

## Scene System

* Scene Manager
* Menú principal (Main, Settings, Resolution)

---

## Tilesets

Sustituir tiles coloreados por sprites.
Ubicación prevista: assets/tilesets/<name>/tileset.png

---

## Plataformas especiales

* Plataforma rompible: token X, estados IDLE > SHAKING > BROKEN

---

## Feedback Visual

Player:
* Flash al recibir daño
* Knockback
* Sonidos

Enemigos:
* Flash al recibir daño
* Animaciones de muerte
* Sonidos

---

## HUD Futuro

* Arma actual
* Enemigos restantes
* Objetivos
* Estado de victoria

---

## Game Over

* Respawn
* Checkpoints
* Reinicio de nivel
* Pantalla Game Over

---

# Refactors diferidos

NO realizar antes de tener Mosquito funcionando.

enemy.lua: posible extracción de health, isDead, takeDamage si hay duplicación real.

---

# Próxima tarea recomendada

1. Gunner vs Player (colisión de contacto)
2. Mosquito
3. Victory Conditions + Exit Tile
4. Scene Manager
5. Menús

---

# Resumen rápido para un nuevo chat

* El juego corre.
* El jugador camina, salta, se agacha y dispara.
* 4 armas funcionales con sistema polimórfico.
* Runner funcional con FSM completa.
* Gunner funcional con FSM, mantiene distancia, dispara ráfagas apuntadas al jugador.
* Sistema de colisiones con fromPlayer flag para evitar friendly fire.
* HUD funcional.
* Siguiente objetivo: colisión Gunner vs Player, luego Mosquito.

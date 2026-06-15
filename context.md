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

## Objetivo

Nunca quedar atrapados en un estado donde el juego no corre.

---

# Estado actual del port

## Player

Implementado:

* Movimiento horizontal
* Salto
* Disparo
* Inventario básico
* Sistema de armas
* Health
* Damage
* Damage Cooldown
* Death State
* isDead
* HUD HP
* YOU DIED

Comportamiento actual:

* El jugador recibe daño por contacto.
* El daño posee cooldown.
* Al llegar a 0 HP:

  * isDead = true
  * se muestran controles bloqueados
  * aparece YOU DIED

---

## Runner

Implementado:

* Spawn desde mapa
* Movimiento
* Detección de jugador
* Health
* Damage recibido
* Death
* Cleanup automático

Configuración actual:

* Muere en 3 impactos.

---

## Colisiones

Archivo:

entities/collisions/collision.lua

Implementado:

### Bullet ↔ Runner

* Detecta impacto
* Aplica daño
* Destruye bala
* Elimina runner muerto

### Runner ↔ Player

* Detecta contacto
* Aplica daño
* Respeta damage cooldown

---

## HUD

Archivo:

ui/hud.lua

Implementado:

* HP centrado abajo
* YOU DIED centrado

---

## Armas

Existentes:

* Semiauto
* Shotgun
* Fullauto
* Flamethrower

Estado:

* Semiauto funcional
* Shotgun funcional
* Fullauto funcional
* Flamethrower pendiente de completar

---

# Estructura actual

game/

├── entities/
│   ├── enemy.lua
│   ├── enemies/
│   │   ├── runner.lua
│   │   ├── gunner.lua
│   │   └── mosquito.lua
│   └── collisions/
│       └── collision.lua
│
├── ui/
│   └── hud.lua
│
├── weapons/
│   ├── semiauto.lua
│   ├── shotgun.lua
│   ├── fullauto.lua
│   └── flamethrower.lua
│
├── levels/
│   └── level1.lua
│
├── player.lua
├── bullet.lua
├── map.lua
├── world.lua
├── camera.lua
└── main.lua

---

# Roadmap

## En progreso

Nada actualmente.

---

# Pendiente

## Bug heredado

### win=kill_all

Proyecto original:

La condición se cumple.

El tile cambia de color.

La transición de nivel no ocurre.

Estado del port:

No implementado.

---

# Enemigos

## Gunner

Prioridad actual.

Descripción original:

Variante del Runner.

Características:

* Mantiene distancia.
* Dispara ráfagas.
* Utiliza el sistema de balas existente.
* Puede recibir daño.
* Puede morir.

Estado:

No implementado.

---

## Mosquito

Descripción original:

Enemigo volador.

Características:

* Ignora gravedad.
* Ignora geometría.
* Patrulla.
* Detecta jugador.
* Ataque errático.
* Puede recibir daño.
* Puede morir.

Estado:

No implementado.

---

# Física y colisiones

## Tunneling

Detectado en proyecto original.

Afecta:

* Player
* Runner
* Drops

Estado:

Pendiente de verificar en el port.

---

## Colisiones laterales

Problema detectado en el proyecto original.

Los tiles sólidos son atravesables lateralmente.

Estado:

Pendiente de verificar en el port.

---

# Sistema de Drops

Pendiente.

Características esperadas:

* Física
* Spawn
* Recolección
* Probabilidad dinámica

Problema heredado:

Escalado incorrecto con TILE_SIZE altos.

---

# Victory Conditions

## kill_all

Eliminar todos los enemigos.

Estado:

Parcialmente iniciado.

---

## collect_keys:N

Pendiente.

---

## break_all_boxes

Pendiente.

---

## reach_exit

Pendiente.

---

## kill_boss

Pendiente.

---

## Condiciones AND/OR

Pendiente.

Ejemplos:

win=(kill_all AND reach_exit)

win=(collect_keys OR kill_boss)

---

# Scene System

## Scene Manager

Proyecto original:

Implementación básica.

Pendiente:

* Registro por ID
* Stack de escenas
* Transiciones

Estado:

No implementado.

---

## Menú Principal

Proyecto original:

* Main
* Settings
* Resolution

Estado:

No implementado.

---

# Tilesets

Objetivo:

Sustituir tiles coloreados por sprites.

Ubicación prevista:

assets/tilesets/<name>/tileset.png

Estado:

No implementado.

---

# Plataformas especiales

## Plataforma rompible

Token:

X

Estados:

IDLE
→ SHAKING
→ BROKEN

Estado:

No implementado.

---

# Feedback Visual

## Player

Pendiente:

* Flash al recibir daño
* Knockback
* Sonidos

## Enemigos

Pendiente:

* Flash al recibir daño
* Animaciones de muerte
* Sonidos

---

# HUD Futuro

Pendiente:

* Munición
* Arma actual
* Enemigos restantes
* Objetivos
* Estado de victoria

---

# Game Over

Implementado:

* Death State
* Controles bloqueados
* YOU DIED

Pendiente:

* Respawn
* Checkpoints
* Reinicio de nivel
* Pantalla Game Over

---

# Refactors diferidos

NO realizar antes de tener:

* Runner
* Gunner
* Mosquito

funcionando.

## enemy.lua

Posible extracción futura:

* health
* isDead
* takeDamage

Solo si existe duplicación real.

---

# Próxima tarea recomendada

1. Gunner
2. Mosquito
3. Victory Conditions
4. Exit Tile
5. Scene Manager
6. Menús

---

# Resumen rápido para un nuevo chat

Estado actual:

* El juego corre.
* El jugador puede caminar, saltar y disparar.
* Los runners reciben daño y mueren.
* El jugador recibe daño y puede morir.
* Existe HUD funcional.
* Existe sistema de colisiones funcional.
* El siguiente objetivo importante es implementar Gunner.

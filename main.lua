local PlayerModule = require("player")
local MapModule = require("map")
local CameraModule = require("camera")
local BulletModule = require("bullet")
local RunnerModule = require("entities.enemies.runner")
local CollisionModule = require("entities.collisions.collision")
local HUDModule = require("ui.hud")

local player
local cam
local bullets
local runners = {}

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    -- Recibimos las posiciones detectadas en el archivo de texto
    local spawnX, spawnY, enemySpawns = MapModule.load("levels.level1")

    player = PlayerModule.create(spawnX, spawnY)
    cam = CameraModule.create(love.graphics.getWidth(), love.graphics.getHeight())
    bullets = BulletModule.createPool()

    -- Poblamos el juego con los enemigos del mapa
    runners = {}
    for _, e in ipairs(enemySpawns) do
        if e.type == "runner" then
            table.insert(runners, RunnerModule.create(e.x, e.y, 1))
        end
    end
end

function love.update(dt)
    local currentGravity = MapModule.current.gravity
    PlayerModule.update(player, dt, currentGravity, MapModule, bullets)
    BulletModule.update(bullets, dt)

    for i = 1, #runners do
        RunnerModule.update(runners[i], dt, MapModule.current.gravity, MapModule, player)
    end

    CollisionModule.bulletsVsRunners(bullets, runners)

    for i = #runners, 1, -1 do
        if runners[i].isDead then
            table.remove(runners, i)
        end
    end

    local playerHit =
    CollisionModule.playerVsRunners(player, runners)

    if playerHit then
        PlayerModule.takeDamage(player, 1)
        end

    local levelW = #MapModule.current.rows[1] * MapModule.current.tileLength
    local levelH = #MapModule.current.rows * MapModule.current.tileLength
    CameraModule.update(cam, player.x, player.y, levelW, levelH, dt)
end

function love.keypressed(key)
    PlayerModule.handleJump(player, key)
    if key == "escape" then
        love.event.quit()
    end
end

function love.draw()
    love.graphics.clear(0.4, 0.6, 0.9)
    CameraModule.apply(cam)
    MapModule.draw()
    PlayerModule.draw(player)
    BulletModule.draw(bullets)

    for i = 1, #runners do
        RunnerModule.draw(runners[i])
        end

        CameraModule.release()

        HUDModule.draw(player)
        end

local PlayerModule = require("player")
local MapModule = require("map")
local CameraModule = require("camera")
local BulletModule = require("bullet")
local RunnerModule = require("entities.runner")

local penguin
local cam
local bullets
local runners = {}

function love.load()
love.graphics.setDefaultFilter("nearest", "nearest")
local spawnX, spawnY = MapModule.load("levels.level1")
penguin = PlayerModule.create(spawnX, spawnY)
cam = CameraModule.create(love.graphics.getWidth(), love.graphics.getHeight())
bullets = BulletModule.createPool()
runners[1] = RunnerModule.create(300, 400, 1)
end

function love.update(dt)
local currentGravity = MapModule.current.gravity
PlayerModule.update(penguin, dt, currentGravity, MapModule, bullets)
BulletModule.update(bullets, dt)
for i = 1, #runners do
    RunnerModule.update(runners[i], dt, MapModule.current.gravity, MapModule)
    end
local levelW = #MapModule.current.rows[1] * MapModule.current.tileLength
local levelH = #MapModule.current.rows * MapModule.current.tileLength
CameraModule.update(cam, penguin.x, penguin.y, levelW, levelH, dt)
end

function love.keypressed(key)
PlayerModule.handleJump(penguin, key)
if key == "escape" then
    love.event.quit()
    end
    end

    function love.draw()
    love.graphics.clear(0.4, 0.6, 0.9)
    CameraModule.apply(cam)
    MapModule.draw()
    PlayerModule.draw(penguin)
    BulletModule.draw(bullets)
    for i = 1, #runners do
        RunnerModule.draw(runners[i])
        end
    CameraModule.release()
    end

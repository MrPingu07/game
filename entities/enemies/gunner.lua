local World = require("world")
local Gunner = {}

local SPEED = 60
local TILE_SIZE = 32
local DETECT_RADIUS = TILE_SIZE * 5
local PREFERRED_DIST = TILE_SIZE * 5
local BULLET_SPEED = TILE_SIZE * 14

function Gunner.create(x, y, facing)
    return {
        x = x,
        y = y,
        width = 32,
        height = 32,
        vx = 0,
        vy = 0,
        facing = facing or 1,
        speed = SPEED,
        health = 60,
        isDead = false,
        state = "patrol",
        freezeTimer = 0,
        fireCooldown = 0,
        burstCount = 0,
        burstTimer = 0,
        attackCooldown = 0,
        isOnGround = false,
    }
end

function Gunner.update(g, dt, gravity, mapModule, player, bulletPool, spawnFunc)
    if g.isDead then return end

    g.vy = g.vy + gravity * dt
    g.fireCooldown = math.max(0, g.fireCooldown - dt)

    local dx, dy, dist = 0, 0, math.huge
    if player then
        local gCX = g.x + g.width / 2
        local gCY = g.y + g.height / 2
        local pCX = player.x + player.width / 2
        local pCY = player.y + player.height / 2
        dx = pCX - gCX
        dy = pCY - gCY
        dist = math.sqrt(dx * dx + dy * dy)
    end

    -- FSM transitions
    if g.state == "patrol" then
        if dist <= DETECT_RADIUS then
            g.state = "freeze"
            g.freezeTimer = 0.5
        end
    elseif g.state == "freeze" then
        g.freezeTimer = g.freezeTimer - dt
        if g.freezeTimer <= 0 then
            g.state = "aggro_cooldown"
            g.attackCooldown = 3.0
        end
    elseif g.state == "aggro_cooldown" then
        if dist > DETECT_RADIUS then
            g.state = "patrol"
        else
            g.attackCooldown = g.attackCooldown - dt
            if g.attackCooldown <= 0 then
                g.state = "aggro_burst"
                g.burstCount = 0
                g.burstTimer = 0
            end
        end
    elseif g.state == "aggro_burst" then
        if dist > DETECT_RADIUS then
            g.state = "patrol"
        end
    end

    -- Behavior
    if g.state == "patrol" then
        g.vx = g.facing * g.speed
    elseif g.state == "freeze" then
        g.vx = 0
    elseif g.state == "aggro_cooldown" and player then
        g.facing = dx >= 0 and 1 or -1
        if dist < PREFERRED_DIST - TILE_SIZE then
            g.vx = -g.facing * g.speed
        elseif dist > PREFERRED_DIST + TILE_SIZE then
            g.vx = g.facing * g.speed
        else
            g.vx = 0
        end
    elseif g.state == "aggro_burst" and player then
        g.vx = 0
        g.facing = dx >= 0 and 1 or -1

        g.burstTimer = g.burstTimer - dt
        if g.burstTimer <= 0 and g.burstCount < 3 then
            local len = math.sqrt(dx * dx + dy * dy)
            local aimX = len > 0 and dx / len or g.facing
            local aimY = len > 0 and dy / len or 0
            local origin = {
                x = g.facing == 1 and g.x + g.width or g.x,
                y = g.y + g.height * 0.5
            }
            spawnFunc(bulletPool,
                origin.x, origin.y,
                aimX * BULLET_SPEED, aimY * BULLET_SPEED,
                3, 10, 2.0,
                0.2, 0.8, 1)
            g.burstCount = g.burstCount + 1
            g.burstTimer = 0.25
        end

        if g.burstCount >= 3 and g.burstTimer <= 0 then
            g.state = "aggro_cooldown"
            g.attackCooldown = 3.0
        end
    end

    -- Horizontal collision
    local tileSize = mapModule.current.tileLength
    g.x = g.x + g.vx * dt
    if g.vx > 0 then
        if World.isSolid(g.x + g.width, g.y, mapModule) or
            World.isSolid(g.x + g.width, g.y + g.height - 1, mapModule) then
            g.x = math.floor((g.x + g.width) / tileSize) * tileSize - g.width
            if g.state == "patrol" then g.facing = -1 end
        end
    elseif g.vx < 0 then
        if World.isSolid(g.x, g.y, mapModule) or
            World.isSolid(g.x, g.y + g.height - 1, mapModule) then
            g.x = (math.floor(g.x / tileSize) + 1) * tileSize
            if g.state == "patrol" then g.facing = 1 end
        end
    end

    -- Vertical collision
    g.y = g.y + g.vy * dt
    g.isOnGround = false
    if g.vy > 0 then
        if World.isSolid(g.x, g.y + g.height, mapModule) or
            World.isSolid(g.x + g.width - 1, g.y + g.height, mapModule) then
            g.y = math.floor((g.y + g.height) / tileSize) * tileSize - g.height
            g.vy = 0
            g.isOnGround = true
        end
    elseif g.vy < 0 then
        if World.isSolid(g.x, g.y, mapModule) or
            World.isSolid(g.x + g.width - 1, g.y, mapModule) then
            g.y = (math.floor(g.y / tileSize) + 1) * tileSize
            g.vy = 0
        end
    end
end

function Gunner.draw(g)
    if g.isDead then return end
    local color
    if g.state == "patrol" then
        color = { 0.5, 0.3, 0.1 }
    elseif g.state == "freeze" then
        color = { 1.0, 1.0, 0.0 }
    elseif g.state == "aggro_cooldown" or g.state == "aggro_burst" then
        color = { 1.0, 0.5, 0.0 }
    end
    love.graphics.setColor(color)
    love.graphics.rectangle("fill", g.x, g.y, g.width, g.height)
    local centerX = g.x + g.width / 2
    local centerY = g.y + g.height / 2
    love.graphics.setColor(1, 1, 0, 0.3)
    love.graphics.circle("line", centerX, centerY, DETECT_RADIUS)
end

return Gunner

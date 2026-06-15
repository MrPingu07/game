local WeaponModule = require("weapon")
local BulletModule = require("bullet")
local World = require("world")
local Player = {}

function Player.create(x, y)
    return {
        x = x,
        y = y,
        vx = 0,
        vy = 0,

        health = 100,
        damageCooldown = 0,
        isDead = false,

        width = 32,
        height = 32,
        speed = 200,
        jumpForce = -400,
        isGrounded = false,
        facing = 1,
        aimDir = { x = 1, y = 0 },
        inventory = { WeaponModule.create("semiauto"), WeaponModule.create("shotgun") },
        currentSlot = 1,
        spacePressed = false,
    }
end

function Player.update(instance, dt, gravity, mapModule, bulletPool)
    if instance.isDead then
        return
    end

    instance.damageCooldown =
        math.max(0, instance.damageCooldown - dt)
    instance.vy = instance.vy + gravity * dt

    instance.vx = 0
    if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
        instance.vx = -instance.speed
        instance.facing = -1
    elseif love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        instance.vx = instance.speed
        instance.facing = 1
    end

    instance.aimDir = { x = instance.facing, y = 0 }

    local tileSize = mapModule.current.tileLength
    instance.x = instance.x + instance.vx * dt
    if instance.vx > 0 then
        if World.isSolid(instance.x + instance.width, instance.y, mapModule) or
            World.isSolid(instance.x + instance.width, instance.y + instance.height - 1, mapModule) then
            instance.x = math.floor((instance.x + instance.width) / tileSize) * tileSize - instance.width
            instance.vx = 0
        end
    elseif instance.vx < 0 then
        if World.isSolid(instance.x, instance.y, mapModule) or
            World.isSolid(instance.x, instance.y + instance.height - 1, mapModule) then
            instance.x = (math.floor(instance.x / tileSize) + 1) * tileSize
            instance.vx = 0
        end
    end

    instance.y = instance.y + instance.vy * dt
    if instance.vy > 0 then
        if World.isSolid(instance.x, instance.y + instance.height, mapModule) or
            World.isSolid(instance.x + instance.width - 1, instance.y + instance.height, mapModule) then
            instance.y = math.floor((instance.y + instance.height) / tileSize) * tileSize - instance.height
            instance.vy = 0
            instance.isGrounded = true
        end
    elseif instance.vy < 0 then
        if World.isSolid(instance.x, instance.y, mapModule) or
            World.isSolid(instance.x + instance.width - 1, instance.y, mapModule) then
            instance.y = (math.floor(instance.y / tileSize) + 1) * tileSize
            instance.vy = 0
        end
    end

    local w = instance.inventory[instance.currentSlot]
    if w then
        if w.cooldown > 0 then w.cooldown = w.cooldown - dt end
        local wantsToFire = w.isAutomatic
            and love.keyboard.isDown("space")
            or instance.spacePressed
        if wantsToFire and w.cooldown <= 0 then
            local muzzleX = instance.facing == 1
                and instance.x + instance.width
                or instance.x
            local origin = { x = muzzleX, y = instance.y + instance.height * 0.5 }
            w.fireFunc(origin, instance.aimDir, bulletPool, BulletModule.spawn)
            w.cooldown = w.fireRate
        end
        instance.spacePressed = false
    end

    if love.keyboard.isDown("s") then
        instance.height = 48 * 0.75
        instance.x = instance.x - 16 * 0.25
        instance.y = instance.y + 8
    elseif instance.height == 48 * 0.75 then
        instance.height = 48
        instance.x = instance.x + 16 * 0.25
        instance.y = instance.y - 8
    end
end

function Player.handleJump(instance, key)
    if (key == "w") and instance.isGrounded then
        instance.vy = instance.jumpForce
        instance.isGrounded = false
    end
    if key == "space" then
        instance.spacePressed = true
    end
    if key == "q" and instance.inventory[2] then
        instance.currentSlot = instance.currentSlot == 1 and 2 or 1
    end
end

function Player.draw(instance)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", instance.x, instance.y, instance.width, instance.height)
end

function Player.takeDamage(player, amount)
    if player.isDead then
        return
    end

    if player.damageCooldown > 0 then
        return
    end

    player.health = player.health - amount
    player.damageCooldown = 0.5

    if player.health < 0 then
        player.health = 0
    end

    if player.health == 0 then
        player.isDead = true
    end

    print("PLAYER HP:", player.health)
end

return Player

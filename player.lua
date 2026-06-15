local WeaponModule = require("weapon")
local BulletModule = require("bullet")
local Player = {}

local function isSolid(x, y, mapModule)
    if not mapModule or not mapModule.current then return false end
    local tileSize = mapModule.current.tileLength
    local col = math.floor(x / tileSize) + 1
    local row = math.floor(y / tileSize) + 1
    local rows = mapModule.current.rows
    if row < 1 or row > #rows then return false end
    local rowString = rows[row]
    if col < 1 or col > #rowString then return false end
    return rowString:sub(col, col) == "#"
end

function Player.create(x, y)
    return {
        x = x,
        y = y,
        width = 32,
        height = 48,
        vx = 0,
        vy = 0,
        speed = 200,
        jumpForce = -400,
        isGrounded = false,
        facing = 1,
        aimDir = { x = 1, y = 0 },
        inventory = {WeaponModule.create("semiauto"), WeaponModule.create("shotgun")},
        currentSlot = 1,
        spacePressed = false,
    }
end

function Player.update(instance, dt, gravity, mapModule, bulletPool)
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
        if isSolid(instance.x + instance.width, instance.y, mapModule) or
            isSolid(instance.x + instance.width, instance.y + instance.height - 1, mapModule) then
            instance.x = math.floor((instance.x + instance.width) / tileSize) * tileSize - instance.width
            instance.vx = 0
        end
    elseif instance.vx < 0 then
        if isSolid(instance.x, instance.y, mapModule) or
            isSolid(instance.x, instance.y + instance.height - 1, mapModule) then
            instance.x = (math.floor(instance.x / tileSize) + 1) * tileSize
            instance.vx = 0
        end
    end

    instance.y = instance.y + instance.vy * dt
    instance.isGrounded = false
    if instance.vy > 0 then
        if isSolid(instance.x, instance.y + instance.height, mapModule) or
            isSolid(instance.x + instance.width - 1, instance.y + instance.height, mapModule) then
            instance.y = math.floor((instance.y + instance.height) / tileSize) * tileSize - instance.height
            instance.vy = 0
            instance.isGrounded = true
        end
    elseif instance.vy < 0 then
        if isSolid(instance.x, instance.y, mapModule) or
            isSolid(instance.x + instance.width - 1, instance.y, mapModule) then
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
                or  instance.x
                local origin = {x = muzzleX, y = instance.y + instance.height * 0.5}
                w.fireFunc(origin, instance.aimDir, bulletPool, BulletModule.spawn)
                w.cooldown = w.fireRate
                end
                instance.spacePressed = false
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

return Player

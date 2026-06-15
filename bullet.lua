local Bullet = {}

local POOL_SIZE = 100

function Bullet.createPool()
    local pool = {}
    for i = 1, POOL_SIZE do
        pool[i] = {
            x = 0,
            y = 0,
            vx = 0,
            vy = 0,
            radius = 4,
            damage = 0,
            lifetime = 0,
            isActive = false,
            fromPlayer = false,
            r = 1,
            g = 1,
            b = 0
        }
    end
    return pool
end

function Bullet.spawn(pool, x, y, vx, vy, radius, damage, lifetime, r, g, b_color, fromPlayer)

    for i = 1, POOL_SIZE do
        if not pool[i].isActive then
            local slot = pool[i]
            slot.x = x
            slot.y = y
            slot.vx = vx
            slot.vy = vy
            slot.radius = radius
            slot.damage = damage
            slot.lifetime = lifetime
            slot.r = r
            slot.g = g
            slot.b = b_color
            slot.isActive = true
            slot.fromPlayer = fromPlayer or false
            return
        end
    end
end

function Bullet.update(pool, dt)
    for i = 1, POOL_SIZE do
        local b = pool[i]
        if b.isActive then
            b.x = b.x + b.vx * dt
            b.y = b.y + b.vy * dt
            b.lifetime = b.lifetime - dt
            if b.lifetime <= 0 then
                b.isActive = false
            end
        end
    end
end

function Bullet.draw(pool)
    for i = 1, POOL_SIZE do
        local b = pool[i]
        if b.isActive then
            love.graphics.setColor(b.r, b.g, b.b)
            love.graphics.circle("fill", b.x, b.y, b.radius)
        end
    end
end

return Bullet

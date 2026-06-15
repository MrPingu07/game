local Runner = {}

local SPEED = 80
local EDGE_CHECK = 16

local function checkEdge(r, mapModule)
    local tileSize = mapModule.current.tileLength
    local checkX = r.facing == 1
        and r.x + r.width + EDGE_CHECK
        or r.x - EDGE_CHECK
    local checkY = r.y + r.height + 4
    local col = math.floor(checkX / tileSize) + 1
    local row = math.floor(checkY / tileSize) + 1
    local rows = mapModule.current.rows
    if row < 1 or row > #rows then return true end
    local rowString = rows[row]
    if col < 1 or col > #rowString then return true end
    return rowString:sub(col, col) ~= "#"
end

function Runner.create(x, y, facing)
    return {
        x = x,
        y = y,
        width = 32,
        height = 32,
        vx = 0,
        vy = 0,
        facing = facing or 1,
        speed = SPEED,
        health = 100,
        isDead = false
    }
end

function Runner.update(r, dt, gravity, mapModule)
    if r.isDead then return end

    r.vy = r.vy + gravity * dt

    if checkEdge(r, mapModule) then
        r.facing = -r.facing
    end

    r.vx = r.facing * r.speed
    r.x = r.x + r.vx * dt
    r.y = r.y + r.vy * dt

    local tileSize = mapModule.current.tileLength
    local rows = mapModule.current.rows

    local function solid(x, y)
        local col = math.floor(x / tileSize) + 1
        local row = math.floor(y / tileSize) + 1
        if row < 1 or row > #rows then return false end
        local rs = rows[row]
        if col < 1 or col > #rs then return false end
        return rs:sub(col, col) == "#"
    end

    if r.vy > 0 then
        if solid(r.x, r.y + r.height) or solid(r.x + r.width - 1, r.y + r.height) then
            r.y = math.floor((r.y + r.height) / tileSize) * tileSize - r.height
            r.vy = 0
        end
    end
end

function Runner.draw(r)
    if r.isDead then return end
    love.graphics.setColor(1, 0.2, 0.2)
    love.graphics.rectangle("fill", r.x, r.y, r.width, r.height)
end

return Runner

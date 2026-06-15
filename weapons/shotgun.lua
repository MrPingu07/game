local tileSize = 32

local function fire(origin, dir, pool, spawnFunc)
local perp = {x = -dir.y, y = dir.x}
local spreads = {0.0, -0.3, 0.3, -0.15, 0.15}
local baseSpeed = tileSize * 12.5
for i = 1, 5 do
    local s = spreads[i]
    spawnFunc(pool,
              origin.x, origin.y,
              (dir.x + perp.x * s) * baseSpeed,
              (dir.y + perp.y * s) * baseSpeed,
              3, 15, 0.5,
              1, 0.8, 0)
    end
    end

    return {
        name = "Shotgun",
        fireRate = 0.6,
        isAutomatic = false,
        fireFunc = fire
    }

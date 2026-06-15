local tileSize = 32

local function fire(origin, dir, pool, spawnFunc)
local perp = {x = -dir.y, y = dir.x}
local speed = love.math.random(math.floor(tileSize * 10), math.floor(tileSize * 12.5))
local spread = love.math.random(math.floor(-tileSize * 2.5), math.floor(tileSize * 2.5))
local size = tileSize * love.math.random(10, 35) * 0.01
spawnFunc(pool,
          origin.x, origin.y,
          dir.x * speed + perp.x * spread,
          dir.y * speed + perp.y * spread,
          size, 5, 0.8,
          1, 0.2, 0)
end

return {
    name = "Flamethrower",
    fireRate = 0.05,
    isAutomatic = true,
    fireFunc = fire
}

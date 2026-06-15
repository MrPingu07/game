local tileSize = 32

local function fire(origin, dir, pool, spawnFunc)
local spread = love.math.random(-math.floor(tileSize * 0.75), math.floor(tileSize * 0.75))
local vx = dir.x * tileSize * 13.75 + (dir.y ~= 0 and spread or 0)
local vy = dir.y * tileSize * 13.75 + (dir.x ~= 0 and spread or 0)
spawnFunc(pool,
          origin.x, origin.y,
          vx, vy,
          3, 10, 1.5,
          1, 0.5, 0)
end

return {
    name = "Full-Auto",
    fireRate = 0.1,
    isAutomatic = true,
    fireFunc = fire
}

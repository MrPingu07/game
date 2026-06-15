local tileSize = 32

local function fire(origin, dir, pool, spawnFunc)
spawnFunc(pool, origin.x, origin.y, dir.x * tileSize * 15, dir.y * tileSize * 15, 3, 34, 2.0, 1, 1, 0)
end

return {
    name = "Semi-Auto",
    fireRate = 0.25,
    isAutomatic = false,
    fireFunc = fire
}

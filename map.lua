local Map = {}
Map.current = nil

function Map.load(levelPath)
    Map.current = require(levelPath)
    local tileSize = Map.current.tileLength
    local spawnX, spawnY = 100, 100
    local enemySpawns = {}

    Map.current.rows = {}
    for rowString in Map.current.grid:gmatch("[^\n]+") do
        Map.current.rows[#Map.current.rows + 1] = rowString

        -- Escaneamos la fila entera posición por posición
        for colIdx = 1, #rowString do
            local char = rowString:sub(colIdx, colIdx)
            if char == "P" then
                spawnX = (colIdx - 1) * tileSize
                spawnY = (#Map.current.rows - 1) * tileSize
            elseif char == "R" then
                table.insert(enemySpawns, {
                    type = "runner",
                    x = (colIdx - 1) * tileSize,
                    y = (#Map.current.rows - 1) * tileSize
                })
            end
        end
    end

    return spawnX, spawnY, enemySpawns
end

function Map.draw()
    if not Map.current then return end
    local tileSize = Map.current.tileLength
    for rowIdx, rowString in ipairs(Map.current.rows) do
        for colIdx = 1, #rowString do
            local char = rowString:sub(colIdx, colIdx)
            local drawX = (colIdx - 1) * tileSize
            local drawY = (rowIdx - 1) * tileSize
            if char == "#" then
                love.graphics.setColor(0.5, 0.5, 0.5)
                love.graphics.rectangle("fill", drawX, drawY, tileSize, tileSize)
            end
        end
    end
end

return Map

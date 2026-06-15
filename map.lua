local Map = {}
Map.current = nil

function Map.load(levelPath)
Map.current = require(levelPath)
local tileSize = Map.current.tileLength
local spawnX, spawnY = 100, 100

Map.current.rows = {}
for rowString in Map.current.grid:gmatch("[^\n]+") do
    Map.current.rows[#Map.current.rows + 1] = rowString
    local colIdx = rowString:find("P")
    if colIdx then
        spawnX = (colIdx - 1) * tileSize
        spawnY = (#Map.current.rows - 1) * tileSize
        end
        end

        return spawnX, spawnY
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

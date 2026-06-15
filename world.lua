local World = {}

function World.isSolid(x, y, mapModule)
if not mapModule or not mapModule.current then
    return false
    end

    local tileSize = mapModule.current.tileLength

    local col = math.floor(x / tileSize) + 1
    local row = math.floor(y / tileSize) + 1

    local rows = mapModule.current.rows

    if row < 1 or row > #rows then
        return false
        end

        local rowString = rows[row]

        if col < 1 or col > #rowString then
            return false
            end

            return rowString:sub(col, col) == "#"
            end

            return World

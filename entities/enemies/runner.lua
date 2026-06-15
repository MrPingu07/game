local World = require("world")
local Runner = {}

-- Basic configuration
local SPEED = 80
local TILE_SIZE = 32
local RAY_LENGTH = TILE_SIZE * 2
local DETECT_RADIUS = TILE_SIZE * 8 -- Distance to notice the player
local CHASE_RADIUS = TILE_SIZE * 10 -- Distance willing to pursue before giving up

-- Calculates the origin (front-top corner) and destination of the 60-degree ray
local function getRayEndpoints(r)
    -- Front-top corner depending on facing direction
    local originX = r.facing == 1 and (r.x + r.width) or r.x
    local originY = r.y

    -- 60 degrees downwards
    local angle = math.rad(60)
    local dx = math.cos(angle) * r.facing
    local dy = math.sin(angle)

    local endX = originX + dx * RAY_LENGTH
    local endY = originY + dy * RAY_LENGTH

    return originX, originY, endX, endY
end

-- Advances safely only if the ray touches solid ground.
local function checkEdge(r, mapModule)
    local oX, oY, eX, eY = getRayEndpoints(r)
    local steps = 15 -- High precision to prevent the ray from skipping over corners
    local detectedFloor = false

    -- Check multiple points along the ray to ensure robust detection
    for i = 1, steps do
        local t = i / steps
        local checkX = oX + (eX - oX) * t
        local checkY = oY + (eY - oY) * t

        if World.isSolid(checkX, checkY, mapModule) then
            detectedFloor = true
            break
        end
    end

    -- Returns true if NO floor was detected (meaning there is an edge/cliff)
    return not detectedFloor
end

-- Runner initialization
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
        isDead = false,
        state = "patrol",      -- Finite State Machine initial state
        freezeTimer = 0,
        isOnGround = false     -- Dedicated flag to fix jump physics
    }
end

function Runner.update(r, dt, gravity, mapModule, player)
    if r.isDead then return end

    -- 1. Check distance to player to feed the FSM
    local inDetectRange = false
    local inChaseRange = false

    if player then
        local rCenterX = r.x + r.width / 2
        local rCenterY = r.y + r.height / 2
        local pCenterX = player.x + player.width / 2
        local pCenterY = player.y + player.height / 2

        local dx = pCenterX - rCenterX
        local dy = pCenterY - rCenterY
        local distance = math.sqrt(dx * dx + dy * dy)

        inDetectRange = (distance <= DETECT_RADIUS)
        inChaseRange = (distance <= CHASE_RADIUS)
    end

    -- 2. FSM state transitions
    if r.state == "patrol" then
        if inDetectRange then
            r.state = "freeze"
            r.freezeTimer = 0.5
        end
    elseif r.state == "freeze" then
        if not inDetectRange then
            r.state = "patrol"                     -- Cancel aggro if player leaves during freeze
        else
            r.freezeTimer = r.freezeTimer - dt
            if r.freezeTimer <= 0 then
                r.state = "aggro"
            end
        end
    elseif r.state == "aggro" then
        if not inChaseRange then
            r.state = "patrol"                                     -- Return to patrol when losing sight of the player entirely
        end
    end

    -- 3. Apply gravity continuously
    r.vy = r.vy + gravity * dt

    -- 4. Behavior execution based on current state
    if r.state == "patrol" then
        -- Turn around if reaching a cliff
        if checkEdge(r, mapModule) then
            r.facing = -r.facing
        end
        r.vx = r.facing * r.speed
    elseif r.state == "freeze" then
        -- Stop entirely while processing the player presence
        r.vx = 0
    elseif r.state == "aggro" then
        if player then
            -- Track player horizontal position
            if player.x < r.x then
                r.facing = -1
            else
                r.facing = 1
            end

            -- Detect if blocked by a wall in the current facing direction
            local isBlocked = false
            if r.facing == 1 then
                isBlocked = World.isSolid(r.x + r.width + 1, r.y, mapModule) or
                    World.isSolid(r.x + r.width + 1, r.y + r.height - 1, mapModule)
            else
                isBlocked = World.isSolid(r.x - 1, r.y, mapModule) or
                    World.isSolid(r.x - 1, r.y + r.height - 1, mapModule)
            end

            local atEdge = checkEdge(r, mapModule)

            -- Base chase speed (75% faster)
            r.vx = r.facing * (r.speed * 1.75)

            -- Verticality logic handling
            if player.y < r.y - 16 then
                -- Player is ABOVE (using a 16px threshold to prevent micro-jumps)
                -- Jump only if physically grounded AND either blocked by a wall or reached an edge
                if (atEdge or isBlocked) and r.isOnGround then
                    r.vy = -450
                end
            elseif player.y > r.y + 16 then
                -- Player is BELOW
                -- Do nothing special, let vx carry the runner off the edge
            else
                -- Player is at the SAME LEVEL
                -- Stop at edges to avoid falling unnecessarily
                if atEdge then
                    r.vx = 0
                end
            end
        else
            r.vx = 0
        end
    end

    -- 5. Horizontal movement and collision (Walls)
    r.x = r.x + r.vx * dt
    local tileSize = mapModule.current.tileLength

    if r.vx > 0 then
        if World.isSolid(r.x + r.width, r.y, mapModule) or
            World.isSolid(r.x + r.width, r.y + r.height - 1, mapModule) then
            r.x = math.floor((r.x + r.width) / tileSize) * tileSize - r.width
            -- Only turn around on collision if patrolling
            if r.state == "patrol" then
                r.facing = -1
            end
        end
    elseif r.vx < 0 then
        if World.isSolid(r.x, r.y, mapModule) or
            World.isSolid(r.x, r.y + r.height - 1, mapModule) then
            r.x = (math.floor(r.x / tileSize) + 1) * tileSize
            -- Only turn around on collision if patrolling
            if r.state == "patrol" then
                r.facing = 1
            end
        end
    end

    -- 6. Vertical movement and collision (Floor and Ceilings)
    r.y = r.y + r.vy * dt
    r.isOnGround = false                                                                                                                                 -- Reset ground flag every frame

    if r.vy > 0 then
        -- Floor collision
        if World.isSolid(r.x, r.y + r.height, mapModule) or
            World.isSolid(r.x + r.width - 1, r.y + r.height, mapModule) then
            r.y = math.floor((r.y + r.height) / tileSize) * tileSize - r.height
            r.vy = 0
            r.isOnGround = true                                                                                                                                 -- Confirms solid contact with the floor
        end
    elseif r.vy < 0 then
        -- Ceiling collision
        if World.isSolid(r.x, r.y, mapModule) or
            World.isSolid(r.x + r.width - 1, r.y, mapModule) then
            r.y = (math.floor(r.y / tileSize) + 1) * tileSize
            r.vy = 0
        end
    end
end

function Runner.draw(r)
    if r.isDead then return end

    -- Base enemy render
    love.graphics.setColor(1, 0.2, 0.2)
    love.graphics.rectangle("fill", r.x, r.y, r.width, r.height)

    ---------------------------------------------------------
    -- DEBUG SECTION
    ---------------------------------------------------------
    local showDebug = true
    if showDebug then
        local centerX = r.x + r.width / 2
        local centerY = r.y + r.height / 2

        -- 1. Detection and Chase radius indicators
        if r.state == "patrol" then
            love.graphics.setColor(1, 1, 0, 0.15)
            love.graphics.circle("line", centerX, centerY, DETECT_RADIUS)
        elseif r.state == "freeze" then
            love.graphics.setColor(0, 0, 1, 0.5)
            love.graphics.circle("line", centerX, centerY, DETECT_RADIUS)
        elseif r.state == "aggro" then
            -- Expand the circle to show the full chase range
            love.graphics.setColor(1, 0, 0, 0.5)
            love.graphics.circle("line", centerX, centerY, CHASE_RADIUS)
        end

        -- 2. 60-degree ray indicator projecting from top-front corner
        local oX, oY, eX, eY = getRayEndpoints(r)
        love.graphics.setColor(0, 1, 0, 0.8)
        love.graphics.line(oX, oY, eX, eY)
        love.graphics.circle("fill", eX, eY, 3)                                                                                                                                                                 -- Endpoint check
    end
    ---------------------------------------------------------
end

return Runner

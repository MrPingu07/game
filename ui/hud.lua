local HUD = {}

function HUD.draw(player)
local text = "HP: " .. player.health

local screenW = love.graphics.getWidth()
local screenH = love.graphics.getHeight()

if player.health <= 0 then
    local deathText = "YOU DIED"

    local deathWidth =
    love.graphics.getFont():getWidth(deathText)

    love.graphics.setColor(1, 0, 0)

    love.graphics.print(
        deathText,
        (screenW - deathWidth) * 0.5,
                        screenH * 0.5
    )
    end

local textW = love.graphics.getFont():getWidth(text)
local margin = 16

love.graphics.setColor(1, 1, 1)

love.graphics.print(
    text,
    (screenW - textW) * 0.5,
                    screenH - margin - 20
)
end

return HUD

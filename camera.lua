local Camera = {}

local LERP = 6.0
local ZOOM = 2.0

function Camera.create(screenW, screenH)
return {
    x = 0, y = 0,
    screenW = screenW,
    screenH = screenH,
    deadzone = 0.01
}
end

function Camera.update(cam, targetX, targetY, levelW, levelH, dt)
local viewW = cam.screenW / ZOOM
local viewH = cam.screenH / ZOOM

local targetScreenX = targetX - cam.x
local targetScreenY = targetY - cam.y

local deadzoneX = viewW * cam.deadzone
local deadzoneY = viewH * cam.deadzone

local desiredX = cam.x
local desiredY = cam.y

if targetScreenX < viewW * 0.5 - deadzoneX then
    desiredX = targetX - (viewW * 0.5 - deadzoneX)
    elseif targetScreenX > viewW * 0.5 + deadzoneX then
        desiredX = targetX - (viewW * 0.5 + deadzoneX)
        end

        if targetScreenY < viewH * 0.5 - deadzoneY then
            desiredY = targetY - (viewH * 0.5 - deadzoneY)
            elseif targetScreenY > viewH * 0.5 + deadzoneY then
                desiredY = targetY - (viewH * 0.5 + deadzoneY)
                end

                cam.x = cam.x + (desiredX - cam.x) * LERP * dt
                cam.y = cam.y + (desiredY - cam.y) * LERP * dt

                cam.x = math.max(0, math.min(cam.x, levelW - viewW))
                cam.y = math.max(0, math.min(cam.y, levelH - viewH))
                end

                function Camera.apply(cam)
                love.graphics.push()
                love.graphics.scale(ZOOM, ZOOM)
                love.graphics.translate(-math.floor(cam.x), -math.floor(cam.y))
                end

                function Camera.release()
                love.graphics.pop()
                end

                return Camera

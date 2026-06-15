local Collision = {}

function Collision.circleRect(circle, rect)
    local closestX =
        math.max(rect.x,
            math.min(circle.x, rect.x + rect.width))

    local closestY =
        math.max(rect.y,
            math.min(circle.y, rect.y + rect.height))

    local dx = circle.x - closestX
    local dy = circle.y - closestY

    return dx * dx + dy * dy <= circle.radius * circle.radius
end

function Collision.bulletsVsRunners(bullets, runners)
    for i = 1, #bullets do
        local bullet = bullets[i]

        if bullet.isActive and bullet.fromPlayer then
            for j = 1, #runners do
                local runner = runners[j]

                if not runner.isDead and
                    Collision.circleRect(bullet, runner) then
                    runner.health =
                        runner.health - bullet.damage

                    bullet.isActive = false

                    if runner.health <= 0 then
                        runner.isDead = true
                    end

                    break
                end
            end
        end
    end
end

function Collision.aabb(a, b)
    return
        a.x < b.x + b.width and
        a.x + a.width > b.x and
        a.y < b.y + b.height and
        a.y + a.height > b.y
end

function Collision.playerVsRunners(player, runners)
    for i = 1, #runners do
        local runner = runners[i]

        if Collision.aabb(player, runner) then
            return true
        end
    end

    return false
end

function Collision.bulletsVsGunners(bullets, gunners)
    for i = 1, #bullets do
        local bullet = bullets[i]
        if bullet.isActive and bullet.fromPlayer then
            for j = 1, #gunners do
                local gunner = gunners[j]
                if not gunner.isDead and
                    Collision.circleRect(bullet, gunner) then
                    gunner.health = gunner.health - bullet.damage
                    bullet.isActive = false
                    if gunner.health <= 0 then
                        gunner.isDead = true
                    end
                    break
                end
            end
        end
    end
end

return Collision

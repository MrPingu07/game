local Weapon = {}

local profiles = {
    semiauto    = require("weapons.semiauto"),
    shotgun     = require("weapons.shotgun"),
    fullauto    = require("weapons.fullauto"),
    flamethrower = require("weapons.flamethrower"),
}

function Weapon.create(type)
local p = profiles[type]
return {
    type        = type,
    name        = p.name,
    fireRate    = p.fireRate,
    isAutomatic = p.isAutomatic,
    fireFunc    = p.fireFunc,
    cooldown    = 0
}
end

return Weapon

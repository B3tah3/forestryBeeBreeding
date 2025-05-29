
climate = {}
c = require("component")
sides = require("sides")
wetSide = sides.south
drySide = sides.north
hotSide = sides.east
coldSide = sides.west

function climate.defaultBee()
    return c.transposer.getStackInSlot(sides.west, 1)
end


function climate.setHumidity(bee)
    local h = {
        Humid  = function(redstone)
            redstone.setOutput(drySide, 0)
            redstone.setOutput(wetSide, 10)
            print("Humid")
        end,
        Arid   = function(redstone)
            redstone.setOutput(wetSide, 0)
            redstone.setOutput(drySide, 10)
            print("Arid")
        end,
        Normal = function(redstone)
            redstone.setOutput(wetSide, 0)
            redstone.setOutput(drySide, 0)
            print("Normal")
        end
    }
    return h[bee.individual.active.species.humidity](c.redstone)
end

function climate.setTemperature(bee)
    local t = {
        Icy = function(redstone)
            redstone.setOutput(hotSide, 0)
            redstone.setOutput(coldSide, 2)
            print("Icy")
        end,
        Cold = function(redstone)
            redstone.setOutput(hotSide, 0)
            redstone.setOutput(coldSide, 1)
            print("Cold")
        end,

        Warm = function(redstone)
            redstone.setOutput(coldSide, 0)
            redstone.setOutput(hotSide, 1)
            print("Warm")
        end,

        Hot = function(redstone)
            redstone.setOutput(coldSide, 0)
            redstone.setOutput(hotSide, 2)
            print("Hot")
        end,

        Normal = function(redstone)
            redstone.setOutput(hotSide, 0)
            redstone.setOutput(coldSide, 0)
            print("Normal")
        end,
    }
    return t[bee.individual.active.species.temperature](c.redstone)
end

return climate

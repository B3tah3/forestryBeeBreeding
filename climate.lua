
climate = {}
climate.light = true
c = require("component")
sides = require("sides")
os = require("os")
wetSide = sides.south
hotSide = sides.east
hellishSide = sides.west
lightSide = sides.north

function climate.defaultBee()
    return c.transposer.getStackInSlot(sides.east, 1)
end


function climate.setHumidity(bee)
    local h = {
        Humid  = function(redstone)
            redstone.setOutput(wetSide, 3)
            print("Humid")
        end,
        Arid   = function(redstone)
            redstone.setOutput(wetSide, 0)
            print("Arid")
        end,
        Normal = function(redstone)
            redstone.setOutput(wetSide, 2)
            print("Normal")
        end
    }
    return h[bee.individual.active.species.humidity](c.redstone)
end

function climate.setTemperature(bee)
    local t = {
        Icy = function(redstone)
            redstone.setOutput(hotSide, 0)
            redstone.setOutput(hellishSide, 0)
            print("Icy")
        end,
        Cold = function(redstone)
            redstone.setOutput(hotSide, 2)
            redstone.setOutput(hellishSide, 0)
            print("Cold")
        end,

        Warm = function(redstone)
            redstone.setOutput(hotSide, 3)
            redstone.setOutput(hellishSide, 0)
            print("Warm")
        end,

        Hot = function(redstone)
            redstone.setOutput(hotSide, 4)
            redstone.setOutput(hellishSide, 0)
            print("Hot")
        end,

        Normal = function(redstone)
            redstone.setOutput(hotSide, 5)
            redstone.setOutput(hellishSide, 0)
            print("Normal")
        end,
        Hellish = function(redstone)
            redstone.setOutput(hotSide, 0)
            redstone.setOutput(hellishSide, 2)
            print("Hellish")
        end,
    }
    return t[bee.individual.active.species.temperature](c.redstone)
end

function climate.setLight(bee)
  if (bee.individual.active.nocturnal and climate.light) or (not bee.individual.active.nocturnal and not climate.light)then
    c.redstone.setOutput(lightSide, 10)
    os.sleep(0.5)
    climate.light = not climate.light
    c.redstone.setOutput(lightSide, 0)
    end
end

return climate

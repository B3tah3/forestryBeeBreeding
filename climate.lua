
Climate = {}
Climate.light = true
C = require("component")
Sides = require("sides")
os = require("os")
WetSide = Sides.north
HotSide = Sides.south
HellishSide = Sides.east
LightSide = Sides.west

function Climate.defaultBee()
    return C.transposer.getStackInSlot(Sides.east, 1)
end


function Climate.setHumidity(bee)
    local h = {
        Humid  = function(redstone)
            redstone.setOutput(WetSide, 3)
            print("Humid")
        end,
        Arid   = function(redstone)
            redstone.setOutput(WetSide, 0)
            print("Arid")
        end,
        Normal = function(redstone)
            redstone.setOutput(WetSide, 2)
            print("Normal")
        end
    }
    return h[bee.individual.active.species.humidity](C.redstone)
end

function Climate.setTemperature(bee)
    local t = {
        Icy = function(redstone)
            redstone.setOutput(HotSide, 0)
            redstone.setOutput(HellishSide, 0)
            print("Icy")
        end,
        Cold = function(redstone)
            redstone.setOutput(HotSide, 2)
            redstone.setOutput(HellishSide, 0)
            print("Cold")
        end,
        Normal = function(redstone)
            redstone.setOutput(HotSide, 3)
            redstone.setOutput(HellishSide, 0)
            print("Normal")
        end,

        Warm = function(redstone)
            redstone.setOutput(HotSide, 4)
            redstone.setOutput(HellishSide, 0)
            print("Warm")
        end,

        Hot = function(redstone)
            redstone.setOutput(HotSide, 5)
            redstone.setOutput(HellishSide, 0)
            print("Hot")
        end,

        Hellish = function(redstone)
            redstone.setOutput(HotSide, 0)
            redstone.setOutput(HellishSide, 2)
            print("Hellish")
        end,
    }
    return t[bee.individual.active.species.temperature](C.redstone)
end

function Climate.setLight(bee)
  if (bee.individual.active.nocturnal and Climate.light) or (not bee.individual.active.nocturnal and not Climate.light)then
    C.redstone.setOutput(LightSide, 10)
    os.sleep(0.5)
    print("[DEBUG] Changed Light from: " , Climate.light , "to: " , not Climate.light)
    Climate.light = not Climate.light
    C.redstone.setOutput(LightSide, 0)
    end
end

return Climate

Random = {}

local seed

--[[function Random.random()
    print("after  5 left="..seed)
    seed = seed ~ (seed << 13)
    print("after 13 left="..seed)
    seed = seed ~ (seed >> 17)
    print("after 17right="..seed)
    seed = seed ~ (seed << 5)
    return (seed%2)+1
end--]]


function Random.random()
    seed = seed ~ ((seed << 13) & 0xFFFFFFFF)
    --print(seed)
    seed = seed ~ ((seed >> 17) & 0xFFFFFFFF)
    --print(seed)
    seed = seed ~ ((seed << 5) & 0xFFFFFFFF)
    --print(seed)
    seed = seed & 0xFFFFFFFF  -- mask to 32-bit
    return (seed % 2) + 1
end

function Random.getSeed()
    return seed
end
function Random.setSeed(setseed)
    seed = setseed
end

--[[for i = 1,10000 do
    seed = seed ~ (seed << 13)
    seed = seed ~ (seed >> 17)
    seed = seed ~ (seed << 5)
    --print((seed%2)+1)
    --local coin = math.random(2)
end--]]

return Random
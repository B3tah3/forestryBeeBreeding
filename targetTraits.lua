IO = require("io")
TargetTraits = {}
function TargetTraits.QueryTargetStats(InputDrawer)
    --let user decide target traits
    TypeOneDrones = InputDrawer[2]
    TypeTwoDrones = InputDrawer[3]
    if not TypeOneDrones.individual or not TypeOneDrones.individual.active then
        print("Missing or unscanned Drone in Slot 1")
        return
    end
    if not TypeTwoDrones.individual or not TypeTwoDrones.individual.active then
        print("Missing or unscanned Drone in Slot 2")
        return
    end
    print("Answer A, B or [blank] to choose genes")
    for k, TypeOneTrait in pairs(TypeOneDrones.individual.active) do
        TypeTwoTrait = TypeTwoDrones.individual.active[k]
        TypeOneTraitDescription = TypeOneTrait
        TypeTwoTraitDescription = TypeTwoTrait
        
        if k == "species" then
            TypeOneTraitDescription = TypeOneTrait.name
            TypeTwoTraitDescription = TypeTwoTrait.name
        end
        if k == "territory" then
            TypeOneTraitDescription = TypeOneTrait[1] .. "x" .. TypeOneTrait[2] .. "x" .. TypeOneTrait[3]
            TypeTwoTraitDescription = TypeTwoTrait[1] .. "x" .. TypeTwoTrait[2] .. "x" .. TypeTwoTrait[3]
        end
        if k == "effect" then
            TypeOneTraitDescription = TypeOneTrait:match("^[^%.]*%.[^%.]*%.[^%.]*%.(.*)")
            TypeTwoTraitDescription = TypeTwoTrait:match("^[^%.]*%.[^%.]*%.[^%.]*%.(.*)")
        end
        if k == "speed" then
            TypeOneTraitDescription = string.format("%.5f", TypeOneTrait)
            TypeTwoTraitDescription = string.format("%.5f", TypeTwoTrait)
        end
        if TypeOneTraitDescription ~= TypeTwoTraitDescription then
            local formatted = string.format("%-22s %-15s %-15s", k, TypeOneTraitDescription, TypeTwoTraitDescription)
            print(formatted)
            Input = io.read()
            if Input == "A" or Input == "a" then
                Input = "A="..TypeOneTraitDescription
                TargetTraits.A[k] = TypeOneTrait
            elseif Input == "B" or Input == "b"  then
                Input = "B="..TypeTwoTraitDescription
                TargetTraits.B[k] = TypeTwoTrait
            else
                Input = "Ignored"
            end
            print("Choosing " .. Input)
        end
    end
    --check if more type B than A traits have been chose
    TargetTraits.ASlot = 2
    TargetTraits.BSlot = 3
    if #TargetTraits.B > #TargetTraits.A then
        local swap = TargetTraits.A
        TargetTraits.A = TargetTraits.B
        TargetTraits.B = swap
        TargetTraits.BSlot = 2
    end
    
end
return TargetTraits
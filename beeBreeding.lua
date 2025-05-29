IO = require("io")
sides = require("sides")
component = require("component")

print("Component: ",component)
print("Sides: ",sides)
print("West: ",sides.west)

--tasks for setup
-- read princess, drones a and b, read target (from arguments?)
--tasks for one breeding cycle:
-- scan -> read new princess and drones
-- sort new drones based on usefulness, enter to table
-- trash useless drones
-- read princess state to decide either drone queue or pure drones a
-- put princess and selected drones into apiary (alveary)
-- change alveary climate to support the princess / swap oblivion frame
-- wait for breeding to finish

--BeeFile = IO.open("bees.txt", "r")
--BeeChest = Serialize.unserialize(BeeFile:read("*all"))
--BeeFile:close()

--TargetTrait = {effect="forestry.allele.effect.none",territory={9,6,9},species={temperature="Normal",humidity="Damp",name="Clay",uid="gregtech.bee.speciesClay"},flowering=10,lifespan=20,temperatureTolerance="NONE",fertility=2,humidityTolerance="NONE",speed=0.30000001192093,tolerantFlyer=false,flowerProvider="flowersVanilla",caveDwelling=false,nocturnal=false}

-- create a salt drone with flowers
TargetTraitsA = {flowerProvider="flowersVanilla"}
TargetTraitsB = {species={temperature="Warm",humidity="Arid",name="Salt",uid="gregtech.bee.speciesSalty"}}

function DeepEquals(a, b, visited)
    if a == b then return true end
    if type(a) ~= type(b) then return false end
    if type(a) ~= "table" then return false end

    visited = visited or {}
    if visited[a] and visited[a] == b then return true end
    visited[a] = b

    -- Compare keys and values
    for k in pairs(a) do
        if not DeepEquals(a[k], b[k], visited) then
            return false
        end
    end
    for k in pairs(b) do
        if not DeepEquals(a[k], b[k], visited) then
            return false
        end
    end

    return true
end

function IsDroneMissingBTrait(bee)
    --check if bee b is missing any traits from target in both active and inactive states
    for k, v in pairs(TargetTraitsB) do
        if not DeepEquals(v, bee.individual.active[k]) and not DeepEquals(v, bee.individual.inactive[k]) then
            return true
        end
    end
    return false
end
--target(B,B,A,A,A)
--princs(A,A,A,A,A) passes
--princs(B,A,A,A,A) passes
--princs(A,A,A,B,A) fails
function HasPrincessAllTargetA(bee)
    for k, v in pairs(TargetTraitsA) do
        if not DeepEquals(v, bee.individual.active[k]) or not DeepEquals(v, bee.individual.inactive[k]) then
            return false
        end
    end
    return true
end

function MeasureDroneDistanceToTarget(bee) Distance = 0
    for k, v in pairs(TargetTraitsA) do
        if not DeepEquals(v, bee.individual.active[k]) then
            Distance = Distance + 1
        end
        if not DeepEquals(v, bee.individual.inactive[k]) then
            Distance = Distance + 1
        end
    end
    for k, v in pairs(TargetTraitsB) do
        if not DeepEquals(v, bee.individual.active[k]) then
            Distance = Distance + 1
        end
        if not DeepEquals(v, bee.individual.inactive[k]) then
            Distance = Distance + 1
        end
    end
    return Distance
end

function Main()
    print("Forestry Bee Breeding\n-------------------------------\n ©B3tah3 , XI_Wizzard\n")
    BeeChest = component.transposer.getAllStacks(sides.west).getAll()
    Princess = nil

    --loop over every inventory slot and check if the individual is missing B Target Genes --TODO trash drones
    for i=0,26 do
        print("BeeChest[i]:", BeeChest[i], "[", i, "]")
        bee = BeeChest[i]
        if bee.individual then
            if bee.individual.active and bee.individual.inactive then
                print("Slot " .. tostring(i) .. " trash=" .. tostring(IsDroneMissingBTrait(bee)))
            end
            --identify and save princess data, move to output
            if not Princess and bee.name == "Forestry:beePrincessGE" then
                Princess = bee
                --move slot i to output
                print("Args:", sides.west,sides.top, 1,i+1, 1)
                result = component.transposer.transferItem(sides.west,sides.top, 1,i+1, 1)
                print("[DEBUG]:    Moved Princess", result)
            end
        end
    end
    if Princess then
        
        if HasPrincessAllTargetA(Princess)then
            --choose best drone
            BestDroneIndex = 0
            BestDistance = 999
            for i = 0, 26 do

                if BeeChest[i] and BeeChest[i].name == "Forestry:beeDroneGE" then
                    local bee = BeeChest[i]
                    if bee.individual and bee.individual.active and bee.individual.inactive then
                        DistanceToTarget = MeasureDroneDistanceToTarget(bee)
                        if DistanceToTarget < BestDistance then
                            BestDistance = DistanceToTarget
                            BestDroneIndex = i
                        end
                    end
                end
            end
            --move chosen drone to output chest
            if BestDistance == 0 then
                PrincessDistance = MeasureDroneDistanceToTarget(Princess)
                if PrincessDistance == 0 then
                    print("Breeding Done")
                    return 1
                end
            end
            print("Args:", sides.west,sides.top, 1,BestDroneIndex+1, 2)
                result = component.transposer.transferItem(sides.west,sides.top, 1,BestDroneIndex+1, 2)
                print("[DEBUG]:    Moved Drone", result)

        else
            --choose pure A drone
            --move pure a drone to output chest
            print("Args", sides.south, sides.top, 1, 1, 2)
            result = component.transposer.transferItem(sides.south,sides.top, 1,3, 2)
            print("[DEBUG]:    Moved Fallback Drone" , result)
        end
    end
end
--[[
{[0]=
    {maxDamage=0,damage=0,outputs={},
        individual={maxHealth=20,hasEffect=false,health=20,isNatural=true,displayName="Salt",isSecret=false,type="bee",isAnalyzed=false,canSpawn=false,isAlive=true,generation=0,ident="gregtech.bee.speciesSalty"},maxSize=64,label="Salt Drone",name="Forestry:beeDroneGE",size=1,inputs={},isCraftable=false,hasTag=true,tag="\31�\8\0\0\0\0\0\0����N�@\16\6�A*B���\31^��#\16\8�\1.�\7Xʴ�d�!�\27�>�E�S��\11���ͯ��\13\1�\16,��\28\0�Mh�Q(�\30\15\13\8\23v���>q\11!�^Q�\14;Н��vd�\13�f�\13��b:�Ab0q\24��\13���1�h׹��\26/�4\26\16�\0219�\2��d�:�\29k���\3�©\12=�`�[J�h�B�S2�dj\11����b4N*�\21��P�ԟ���L=qӑB#t�S:�Q!��\30\n\24���Ḧ́�X\24\21�\31������H3Q\19{�治h_6���r��߀����B�N=\18Vl�T�:�\9��7�+�L��A�14F:2��=�\\�OT���-c�\\�8���|5U�\7z���\5�`�]�\3\0\0"
        },
    {maxDamage=0,damage=0,outputs={}, 
        individual={ maxHealth=20,hasEffect=false,health=20,isNatural=true,
            active={effect="forestry.allele.effect.none",territory={9,6,9},species={temperature="Normal",humidity="Damp",name="Clay",uid="gregtech.bee.speciesClay"},flowering=10,lifespan=20,temperatureTolerance="NONE",fertility=2,humidityTolerance="NONE",speed=0.30000001192093,tolerantFlyer=false,flowerProvider="flowersVanilla",caveDwelling=false,nocturnal=false},displayName="Clay",isSecret=false,isAnalyzed=true,type="bee",
            inactive={effect="forestry.allele.effect.none",territory={9,6,9},species={temperature="Normal",humidity="Damp",name="Clay",uid="gregtech.bee.speciesClay"},flowering=10,lifespan=20,temperatureTolerance="NONE",fertility=2,humidityTolerance="NONE",speed=0.30000001192093,tolerantFlyer=false,flowerProvider="flowersVanilla",caveDwelling=false,nocturnal=false},canSpawn=false,isAlive=true,generation=0,ident="gregtech.bee.speciesClay"},maxSize=64,label="Clay Drone",name="Forestry:beeDroneGE",size=1,inputs={},isCraftable=false,hasTag=true,tag="\31�\8\0\0\0\0\0\0����N�@\16���\"\20��\23_��#\16��A.D�K���lw��F�Oo���`{����͗��4\6\8!z\17�s\0�\n�7G�\\^\23\1�\11;�B�_�\9b�=�6\5\14`8��\20�V��+rԇ�u��\0�0s��5��n1�hgJ�?�}7\16@�R�\0014���\16ZGeM�\n?���^\18�d̘�)ڭЫܐC�y�\0�:iQ�HN*�ʥ�B���\3��BV�0�B\18:���؈:b��Xs���\24�$�eEK��O�g����\31�>������\19 �&�TJ4��܋��݁Rg��j��\3������o\14��3TN߫\13f�e݄����QLSL��'j˼`T��ߗ�ܵ�\3\0\0"
        },
    {maxDamage=0,damage=0,outputs={},
        individual={maxHealth=20,hasEffect=false,health=20,isNatural=true,
            active={effect="forestry.allele.effect.none",territory={9,6,9},species={temperature="Warm",humidity="Arid",name="Salt",uid="gregtech.bee.speciesSalty"},flowering=25,lifespan=20,temperatureTolerance="DOWN_1",fertility=2,humidityTolerance="NONE",speed=0.60000002384186,tolerantFlyer=false,flowerProvider="flowersCacti",caveDwelling=false,nocturnal=false},displayName="Salt",isSecret=false,isAnalyzed=true,type="bee",
            inactive={effect="forestry.allele.effect.none",territory={9,6,9},species={temperature="Warm",humidity="Arid",name="Salt",uid="gregtech.bee.speciesSalty"},flowering=25,lifespan=20,temperatureTolerance="DOWN_1",fertility=2,humidityTolerance="NONE",speed=0.60000002384186,tolerantFlyer=false,flowerProvider="flowersCacti",caveDwelling=false,nocturnal=false},canSpawn=false,isAlive=true,generation=0,ident="gregtech.bee.speciesSalty"},maxSize=64,label="Salt Drone",name="Forestry:beeDroneGE",size=1,inputs={},isCraftable=false,hasTag=true,tag="\31�\8\0\0\0\0\0\0����N�@\16\6�T�\"\23�?�\4�G \16�\3\\�\15��i�ɲCv7b}z�l\7��\11���ͯ���\0\26\16.��\12\0z\13h�P(�\29\14\1Ds;�B埸\9\"h���-��3�\12m�\22\7\27\21�n\11·�d\8��`�0�\6kā�a,Ѯ\n/?6^�i\4\16�\0209�\18�%d�:�\31j�)�=�ҩ\12=\0170��-%\19�;�W\25\25wbj\11����\0184N*��%��P�ԟ��\26L=qӑB#t�\19��a)��\30\n\25���HM��X\26\21�\31������,I3Q\19{�治h]6����ڿ�\1;\22���P�z$��ı&u:\21֝o�W�\0143����\24����bs)?Q}�c���s\21�\4c���Te\30�\22��\23FG�\"�\3\0\0"
    },{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{}}
]]--
Main()

--[[TargetString = "forestry.allele.effect.none"
GivenString = "forestry.allele.effect.none"
BeeChest = {[0]={maxDamage=0,damage=0,outputs={},individual={maxHealth=20,hasEffect=false,health=20,isNatural=true,displayName="Salt",isSecret=false,type="bee",isAnalyzed=false,canSpawn=false,isAlive=true,generation=0,ident="gregtech.bee.speciesSalty"},maxSize=64,label="Salt Drone",name="Forestry:beeDroneGE",size=1,inputs={},isCraftable=false,hasTag=true,tag="\31�\8\0\0\0\0\0\0����N�@\16\6�A*B���\31^��#\16\8�\1.�\7Xʴ�d�!�\27�>�E�S��\11���ͯ��\13\1�\16,��\28\0�Mh�Q(�\30\15\13\8\23v���>q\11!�^Q�\14;Н��vd�\13�f�\13��b:�Ab0q\24��\13���1�h׹��\26/�4\26\16�\0219�\2��d�:�\29k���\3�©\12=�`�[J�h�B�S2�dj\11����b4N*�\21��P�ԟ���L=qӑB#t�S:�Q!��\30\n\24���Ḧ́�X\24\21�\31������H3Q\19{�治h_6���r��߀����B�N=\18Vl�T�:�\9��7�+�L��A�14F:2��=�\\�OT���-c�\\�8���|5U�\7z���\5�`�]�\3\0\0"},{maxDamage=0,damage=0,outputs={},individual={maxHealth=20,hasEffect=false,health=20,isNatural=true,active={effect="forestry.allele.effect.none",territory={9,6,9},species={temperature="Normal",humidity="Damp",name="Clay",uid="gregtech.bee.speciesClay"},flowering=10,lifespan=20,temperatureTolerance="NONE",fertility=2,humidityTolerance="NONE",speed=0.30000001192093,tolerantFlyer=false,flowerProvider="flowersVanilla",caveDwelling=false,nocturnal=false},displayName="Clay",isSecret=false,isAnalyzed=true,type="bee",inactive={effect="forestry.allele.effect.none",territory={9,6,9},species={temperature="Normal",humidity="Damp",name="Clay",uid="gregtech.bee.speciesClay"},flowering=10,lifespan=20,temperatureTolerance="NONE",fertility=2,humidityTolerance="NONE",speed=0.30000001192093,tolerantFlyer=false,flowerProvider="flowersVanilla",caveDwelling=false,nocturnal=false},canSpawn=false,isAlive=true,generation=0,ident="gregtech.bee.speciesClay"},maxSize=64,label="Clay Drone",name="Forestry:beeDroneGE",size=1,inputs={},isCraftable=false,hasTag=true,tag="\31�\8\0\0\0\0\0\0����N�@\16���\"\20��\23_��#\16��A.D�K���lw��F�Oo���`{����͗��4\6\8!z\17�s\0�\n�7G�\\^\23\1�\11;�B�_�\9b�=�6\5\14`8��\20�V��+rԇ�u��\0�0s��5��n1�hgJ�?�}7\16@�R�\0014���\16ZGeM�\n?���^\18�d̘�)ڭЫܐC�y�\0�:iQ�HN*�ʥ�B���\3��BV�0�B\18:���؈:b��Xs���\24�$�eEK��O�g����\31�>������\19 �&�TJ4��܋��݁Rg��j��\3������o\14��3TN߫\13f�e݄����QLSL��'j˼`T��ߗ�ܵ�\3\0\0"},{maxDamage=0,damage=0,outputs={},individual={maxHealth=20,hasEffect=false,health=20,isNatural=true,active={effect="forestry.allele.effect.none",territory={9,6,9},species={temperature="Warm",humidity="Arid",name="Salt",uid="gregtech.bee.speciesSalty"},flowering=25,lifespan=20,temperatureTolerance="DOWN_1",fertility=2,humidityTolerance="NONE",speed=0.60000002384186,tolerantFlyer=false,flowerProvider="flowersCacti",caveDwelling=false,nocturnal=false},displayName="Salt",isSecret=false,isAnalyzed=true,type="bee",inactive={effect="forestry.allele.effect.none",territory={9,6,9},species={temperature="Warm",humidity="Arid",name="Salt",uid="gregtech.bee.speciesSalty"},flowering=25,lifespan=20,temperatureTolerance="DOWN_1",fertility=2,humidityTolerance="NONE",speed=0.60000002384186,tolerantFlyer=false,flowerProvider="flowersCacti",caveDwelling=false,nocturnal=false},canSpawn=false,isAlive=true,generation=0,ident="gregtech.bee.speciesSalty"},maxSize=64,label="Salt Drone",name="Forestry:beeDroneGE",size=1,inputs={},isCraftable=false,hasTag=true,tag="\31�\8\0\0\0\0\0\0����N�@\16\6�T�\"\23�?�\4�G \16�\3\\�\15��i�ɲCv7b}z�l\7��\11���ͯ���\0\26\16.��\12\0z\13h�P(�\29\14\1Ds;�B埸\9\"h���-��3�\12m�\22\7\27\21�n\11·�d\8��`�0�\6kā�a,Ѯ\n/?6^�i\4\16�\0209�\18�%d�:�\31j�)�=�ҩ\12=\0170��-%\19�;�W\25\25wbj\11����\0184N*��%��P�ԟ��\26L=qӑB#t�\19��a)��\30\n\25���HM��X\26\21�\31������,I3Q\19{�治h]6����ڿ�\1;\22���P�z$��ı&u:\21֝o�W�\0143����\24����bs)?Q}�c���s\21�\4c���Te\30�\22��\23FG�\"�\3\0\0"},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{}}

print(IsBeeMissingBTrait(BeeChest[1].individual))
print(IsBeeMissingBTrait(BeeChest[2].individual))
]]--

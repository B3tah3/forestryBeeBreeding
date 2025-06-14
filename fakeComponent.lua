os = require("os")
Config = require("fakeConfig")
math = require('math')
math.randomseed(os.time())
math.random(); math.random(); math.random()

FakeComponent = {}
function FakeComponent.readInventory(side)
  return FakeComponent[side]
end
function FakeComponent.transferItem(fromSide, toSide, amount, fromSlot, toSlot)
  fromSlot = fromSlot -1
  toSlot = toSlot -1
  if next(FakeComponent[toSide][toSlot]) ~= nil then
    print('Move failed because target slot full')
    return 0
  end
  if next(FakeComponent[fromSide][fromSlot]) == nil then
    print('Move failed because origin slot empty')
    return 0
  end
  --print("Moving from "..Config[fromSide]..":"..fromSlot.." to "..Config[toSide]..":"..toSlot)
  
  FakeComponent[toSide][toSlot] = {}
  for k,v in pairs(FakeComponent[fromSide][fromSlot]) do
    FakeComponent[toSide][toSlot][k] = v
  end
  local fromAmount = FakeComponent[fromSide][fromSlot].size
  if fromAmount > amount then
    FakeComponent[toSide][toSlot].size = amount
    FakeComponent[fromSide][fromSlot].size = FakeComponent[fromSide][fromSlot].size - amount
    return amount
  else
    FakeComponent[fromSide][fromSlot] = {}
    return fromAmount
  end
end
function FakeComponent.TransferItemToFirstFreeSlot(sourceSide, sinkSide, count, sourceSlot)
  local sinkData = FakeComponent.readInventory(sinkSide)
  for i = 0, 1000 do
    local slot = sinkData[i]
    if next(slot) == nil then
      FakeComponent.transferItem(sourceSide, sinkSide, count, sourceSlot, i + 1)
      return i
    end
  end
  return 0
end
function FakeComponent.breedBees()
  local alveary = FakeComponent[Config.Alveary]
  local parent1 = alveary[0]
  local parent2 = alveary[1]
  local names = {[1]="Forestry:beePrincessGE",[2]="Forestry:beeDroneGE",[3]="Forestry:beeDroneGE",[4]="Forestry:beeDroneGE",[5]="Forestry:beeDroneGE"}
  for i = 1,5 do
    local child = FakeComponent.createChild(parent1, parent2, names[i])
    FakeComponent[Config.Alveary][2+i] = child
  end
  --delete parents
  FakeComponent[Config.Alveary][0] = {}
  FakeComponent[Config.Alveary][1] = {}
  --move children to storage
  FakeComponent.TransferItemToFirstFreeSlot(Config.Alveary, Config.Storage, 1, 4)
  FakeComponent.TransferItemToFirstFreeSlot(Config.Alveary, Config.Storage, 1, 5)
  FakeComponent.TransferItemToFirstFreeSlot(Config.Alveary, Config.Storage, 1, 6)
  FakeComponent.TransferItemToFirstFreeSlot(Config.Alveary, Config.Storage, 1, 7)
end
function FakeComponent.createChild(parent1, parent2, name)
  local child = {
    individual={
      active={effect="forestry.allele.effect.none",territory={9,6,9},species={temperature="Normal",humidity="Damp",name="Clay",uid="gregtech.bee.speciesClay"},flowering=10,lifespan=20,temperatureTolerance="NONE",fertility=2,humidityTolerance="NONE",speed=0.30000001192093,tolerantFlyer=false,flowerProvider="flowersVanilla",caveDwelling=false,nocturnal=false},
      inactive={effect="forestry.allele.effect.none",territory={9,6,9},species={temperature="Normal",humidity="Damp",name="Clay",uid="gregtech.bee.speciesClay"},flowering=10,lifespan=20,temperatureTolerance="NONE",fertility=2,humidityTolerance="NONE",speed=0.30000001192093,tolerantFlyer=false,flowerProvider="flowersVanilla",caveDwelling=false,nocturnal=false},
      },
    name=name,
    size=1
  }
  for k,v in pairs(parent1.individual.active) do
    local parent1Genes = {[1]=parent1.individual.active[k], [2]=parent1.individual.inactive[k]}
    local parent2Genes = {[1]=parent2.individual.active[k], [2]=parent2.individual.inactive[k]}
    child.individual.active[k] = parent1Genes[math.random(2)]
    child.individual.inactive[k] = parent2Genes[math.random(2)]
  end
  return child
end

-- Convert a lua table into a lua syntactically correct string
function FakeComponent.table_to_string(tbl)
    local result = "{"
    for k, v in pairs(tbl) do
        -- Check the key type (ignore any numerical keys - assume its an array)
        if type(k) == "string" then
            result = result.."[\""..k.."\"]".."="
        end
        -- Check the value type
        if type(v) == "table" then
            result = result..FakeComponent.table_to_string(v)
        elseif type(v) == "boolean" then
            result = result..tostring(v)
        else
            result = result.."\""..v.."\""
        end
        result = result..","
    end
    -- Remove leading commas from the result
    if result ~= "{" then
        result = result:sub(1, result:len()-1)
    end
    return result.."}"
end
function FakeComponent.BeeToGeneString(bee, targetTraits)
  local geneString = ''
  for k,activeGene in pairs(bee.individual.active) do
    local inactiveGene = bee.individual.inactive[k]
    if targetTraits.A[k] ~= nil then
      if DeepEquals(targetTraits.A[k], activeGene) then
        geneString = geneString..'[A,'
      else
        geneString = geneString..'[B,'
      end
      if DeepEquals(targetTraits.A[k], inactiveGene) then
        geneString = geneString..'A],'
      else
        geneString = geneString..'B],'
      end
    elseif targetTraits.B[k] ~= nil then
      if DeepEquals(targetTraits.B[k], activeGene) then
        geneString = geneString..'[B,'
      else
        geneString = geneString..'[A,'
      end
      if DeepEquals(targetTraits.B[k], inactiveGene) then
        geneString = geneString..'B],'
      else
        geneString = geneString..'A],'
      end
    end
  end
  return geneString
end
function FakeComponent.printInventory(side, targetTraits)
  print('Inventory '..Config[side]..':')
  for k,v in pairs(FakeComponent[side]) do
    if next(v) ~= nil then
      print('Slot '..tostring(k+1)..' has '..FakeComponent.BeeToGeneString(v, targetTraits))--..' with '..FakeComponent.table_to_string(v)..'\n')
    end
  end
end
function FakeComponent.initializeInput()
  local clayDrone = {
    individual={
      active={effect="forestry.allele.effect.none",territory={9,6,9},species={temperature="Normal",humidity="Damp",name="Clay",uid="gregtech.bee.speciesClay"},flowering=10,lifespan=20,temperatureTolerance="NONE",fertility=2,humidityTolerance="NONE",speed=0.30000001192093,tolerantFlyer=false,flowerProvider="flowersVanilla",caveDwelling=false,nocturnal=false},
      inactive={effect="forestry.allele.effect.none",territory={9,6,9},species={temperature="Normal",humidity="Damp",name="Clay",uid="gregtech.bee.speciesClay"},flowering=10,lifespan=20,temperatureTolerance="NONE",fertility=2,humidityTolerance="NONE",speed=0.30000001192093,tolerantFlyer=false,flowerProvider="flowersVanilla",caveDwelling=false,nocturnal=false},
      },
    name="Forestry:beeDroneGE",
    size=128
  }
  local antiSaltDrone = {
    individual={
      active={effect="forestry.allele.effect.poison",territory={15,13,15},species={temperature="Normal",humidity="Damp",name="Clay",uid="gregtech.bee.speciesClay"},flowering=10,lifespan=70,temperatureTolerance="NONE",fertility=3,humidityTolerance="UP_2",speed=0.30000001192093,tolerantFlyer=true,flowerProvider="flowersVanilla",caveDwelling=true,nocturnal=true},
      inactive={effect="forestry.allele.effect.poison",territory={15,13,15},species={temperature="Normal",humidity="Damp",name="Clay",uid="gregtech.bee.speciesClay"},flowering=10,lifespan=70,temperatureTolerance="NONE",fertility=3,humidityTolerance="UP_2",speed=0.30000001192093,tolerantFlyer=true,flowerProvider="flowersVanilla",caveDwelling=true,nocturnal=true},
      },
    name="Forestry:beeDroneGE",
    size=64
  }
  local saltDrone = {
    individual={
      active={effect="forestry.allele.effect.none",territory={9,6,9},species={temperature="Warm",humidity="Arid",name="Salt",uid="gregtech.bee.speciesSalty"},flowering=25,lifespan=20,temperatureTolerance="DOWN_1",fertility=2,humidityTolerance="NONE",speed=0.60000002384186,tolerantFlyer=false,flowerProvider="flowersCacti",caveDwelling=false,nocturnal=false},
      inactive={effect="forestry.allele.effect.none",territory={9,6,9},species={temperature="Warm",humidity="Arid",name="Salt",uid="gregtech.bee.speciesSalty"},flowering=25,lifespan=20,temperatureTolerance="DOWN_1",fertility=2,humidityTolerance="NONE",speed=0.60000002384186,tolerantFlyer=false,flowerProvider="flowersCacti",caveDwelling=false,nocturnal=false},
    },
    name="Forestry:beeDroneGE",
    size=1280,
  }
  local saltPrincess = {
    individual={
      active={effect="forestry.allele.effect.none",territory={9,6,9},species={temperature="Warm",humidity="Arid",name="Salt",uid="gregtech.bee.speciesSalty"},flowering=25,lifespan=20,temperatureTolerance="DOWN_1",fertility=2,humidityTolerance="NONE",speed=0.60000002384186,tolerantFlyer=false,flowerProvider="flowersCacti",caveDwelling=false,nocturnal=false},
      inactive={effect="forestry.allele.effect.none",territory={9,6,9},species={temperature="Warm",humidity="Arid",name="Salt",uid="gregtech.bee.speciesSalty"},flowering=25,lifespan=20,temperatureTolerance="DOWN_1",fertility=2,humidityTolerance="NONE",speed=0.60000002384186,tolerantFlyer=false,flowerProvider="flowersCacti",caveDwelling=false,nocturnal=false},
    },
    name="Forestry:beePrincessGE",
    size=1,
  }
  FakeComponent[Config.Trash] = {[0]={}}
  FakeComponent[Config.Output] = {[0]={},{},{}}
  FakeComponent[Config.Alveary] = {[0]={},{},{},{},{},{},{}}
  FakeComponent[Config.Input] = {[0]={}}
  FakeComponent[Config.Storage] = {[0]={}}
  for i =1,1000 do
    --FakeComponent[Config.Output][i] = {}
    --FakeComponent[Config.Alveary][i] = {}
    FakeComponent[Config.Storage][i] = {}
  end
  FakeComponent[Config.Input][3] = antiSaltDrone
  FakeComponent[Config.Input][2] = saltDrone
  FakeComponent[Config.Storage][0] = saltPrincess
end
return FakeComponent
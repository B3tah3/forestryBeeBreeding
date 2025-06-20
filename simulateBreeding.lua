TargetTraits = require("targetTraits")
Component = require("fakeComponent")
Config = require("fakeConfig")
Io = require("io")
Decider = require("decideV12")

Verbose = false
DecisionLogging = false
Logfile = io.open('multi11decision.log','a')

if not Logfile then return end
function DeepEquals(a, b, visited)
	if a == b then
		return true
	end
	if type(a) ~= type(b) then
		return false
	end
	if type(a) ~= "table" then
		return false
	end

	visited = visited or {}
	if visited[a] and visited[a] == b then
		return true
	end
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
function IsDroneMissingAllBTraits(bee)
	--check if bee is missing all traits from target in both active and inactive states
	for k, v in pairs(TargetTraits.B) do
		if DeepEquals(v, bee.individual.active[k]) or DeepEquals(v, bee.individual.inactive[k]) then
			return false
		end
	end
	return true
end
function MeasureDroneDistanceToTarget(bee)
	Distance = 0
	for k, v in pairs(TargetTraits.A) do
		if not DeepEquals(v, bee.individual.active[k]) then
			Distance = Distance + 1
		end
		if not DeepEquals(v, bee.individual.inactive[k]) then
			Distance = Distance + 1
		end
	end
	for k, v in pairs(TargetTraits.B) do
		if not DeepEquals(v, bee.individual.active[k]) then
			Distance = Distance + 1
		end
		if not DeepEquals(v, bee.individual.inactive[k]) then
			Distance = Distance + 1
		end
	end
	return Distance
end

function FindPrincessAndTrashDrones(BeeChest)
	local princess = nil
	for i, bee in pairs(BeeChest) do
		if bee.individual then
			if bee.individual.active and bee.individual.inactive and not (bee.name == "Forestry:beePrincessGE") then
				--print("Slot " .. tostring(i) .. " trash=" .. tostring(IsDroneMissingBTrait(bee)))
				--if IsDroneMissingBTrait(bee) then
				if IsDroneMissingAllBTraits(bee) then
					Component.TransferItemToFirstFreeSlot(Config.Storage, Config.Trash, 64, i + 1)
					Component[Config.Trash] = {[0]={}}
					--if Verbose then print('moved drone to trash', i+1)end
				end
			end
			if not princess and bee.name == "Forestry:beePrincessGE" then
				princess = { princess = bee, slot = i + 1 }
			end
		end
	end
	return princess
end

function Iterate()
	-- Analyze State
	BeeChest = Component.readInventory(Config.Storage)
	InputDrawer = Component.readInventory(Config.Input)
	local fallbackDrone = InputDrawer[TargetTraits.ASlot-1]

	local searchResult = FindPrincessAndTrashDrones(BeeChest)
	if searchResult == nil then
		print('Princess not in Storage. Skipping Iteration')
		return true
	end
	local princess = searchResult.princess
	if princess == nil then
		return true
	end
	local princessSlot = searchResult.slot
	local princessDistance = MeasureDroneDistanceToTarget(princess)

	-- Leave slot decision to library file
	local finished
	local bestDroneIndex
	bestDroneIndex, finished = Decider.ChooseFather(BeeChest, fallbackDrone, princess, princessDistance)

	-- react to decision by moving bees
	if finished then
		--print("Breeding Done")
		--move princess and result drones to output
		Component.transferItem(Config.Storage, Config.Output, 1, princessSlot, 1)
		Component.transferItem(Config.Storage, Config.Output, 1, bestDroneIndex + 1, 2)
		if DecisionLogging then Logfile:flush() end
		return false
	end
	if bestDroneIndex == -1 then
		--print("Using Fallback drone")
		Result = Component.transferItem(Config.Input, Config.Alveary, 1, TargetTraits.ASlot, 2)
		if DecisionLogging then
			Logfile:write('chosen='..Component.BeeToGeneString(fallbackDrone, TargetTraits)..'\n\n')
			Logfile:flush()
		end
		if Result ~= 1 then
			print("Ran out of Super Drones. Programm halting.")
			return false
		end
	else
		--Component.printInventory(Config.Storage)
		if Verbose then print('Chosen Drone '..tostring(bestDroneIndex+1)..' has gene='..Component.BeeToGeneString(Component[Config.Storage][bestDroneIndex], TargetTraits)) end
		if DecisionLogging then 
			Logfile:write('chosen='..Component.BeeToGeneString(Component[Config.Storage][bestDroneIndex], TargetTraits)..'\n\n')
			Logfile:flush()
		end
		Result = Component.transferItem(Config.Storage, Config.Alveary, 1, bestDroneIndex + 1, 2)
		--print("[DEBUG]:    Moved Drone Dist="..tostring(BestDistance).."", Result, "From Slot", BestDroneIndex + 1)
		if Result ~= 1 then
			print("Ran out of Other Drones. Programm halting.")
			return false
		end
	end

	Result = Component.transferItem(Config.Storage, Config.Alveary, 1, princessSlot, 1)
	--print("[DEBUG]:    Moved Princess", Result)
	return true
end
function Simulate_with_paramters(retainedGenes, superGenes)
	if Verbose then print("Forestry Bee Breeding\n-------------------------------\n ©B3tah3 , XI_Wizzard\n")end
	Component.initializeInput()
	--Component.printInventory(Config.Input)
	InputDrawer = Component.readInventory(Config.Input)
	TargetTraits.QueryTargetStats(InputDrawer, retainedGenes, superGenes)
	--print(Component.table_to_string(TargetTraits.A), TargetTraits.ASlot, TargetTraits.BSlot)
	--TargetTraits.useDefaultTarget()
	--print(Component.table_to_string(TargetTraits.A), TargetTraits.ASlot, TargetTraits.BSlot)
	--for k,v in pairs(TargetTraits) do
	--	print(k,v)
	--end

	-- send Type B drones to storage
	Component.transferItem(Config.Input, Config.Storage, 64, TargetTraits.BSlot, 2)

	MakeIterations = true
	local i = 0
	while MakeIterations do
		--print("---------------------------------")
		--print("Iteration: ", i)
		--print("---------------------------------")
		i = i + 1
		MakeIterations = Iterate()
		--Component.printInventory(Config.Alveary)
		if MakeIterations then
			Component.breedBees(TargetTraits)
		end
		--[[if i == 500 then
			print('=500 iterations hit, printing state:')
			Verbose = true
		else Verbose = false
		end--]]
		--if i >= 10 then return 999 end
	end
	--print(i)
	--io.write(i..', ')
	--io.flush()
	if Verbose then Component.printInventory(Config.Output, TargetTraits)end
	--print('Target Traits were A='..Component.table_to_string(TargetTraits.A)..' and B='..Component.table_to_string(TargetTraits.B))
	return i
end

function Main(retainedGenes, superGenes)
	print("Genes: "..retainedGenes.." / "..superGenes.." | Fertility: "..Fertility)
	local average = 0
	local occuranceCounter = {[0]=nil}
	if Verbose then TrialAmount = 1 end
	for i = 1,TrialAmount do
		local generations = Simulate_with_paramters(retainedGenes, superGenes)
		average = (average*(i-1) + generations ) / i
		if occuranceCounter[generations] then
			occuranceCounter[generations] = occuranceCounter[generations] + 1
		else
			occuranceCounter[generations] = 1
		end
	end
	local occurenceString = ''
	local medianCounter = 0
	local median = 0
	for i = 0,200 do
		if occuranceCounter[i] ~= nil then
			occurenceString = occurenceString..tostring(i)..':'..tostring(occuranceCounter[i])..', '
			medianCounter = medianCounter + occuranceCounter[i]
			if medianCounter < TrialAmount/2 then
				median = i
			end
		end
	end
	--print(occurenceString)
	--print('Average= '..tostring(average))
	--print('Median= '..tostring(median))
	print('Average: '..tostring(average)..', Median: '..tostring(median)..'\n\n')

	if DecisionLogging then Logfile:close() end
end

TrialAmount = 100
Fertility = 4
for numberOfRetainedGenes = 1,13 do
	for numberOfSuperGenes = 1,13 do
		if numberOfRetainedGenes + numberOfSuperGenes < 14 then
			Main(numberOfRetainedGenes, numberOfSuperGenes)
		end
	end
end
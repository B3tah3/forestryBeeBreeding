TargetTraits = require("targetTraits")
Component = require("fakeComponent")
Config = require("fakeConfig")
Io = require("io")
Verbose = false
DecisionLogging = true
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

--[[function IsDroneMissingBTrait(bee)
	--check if bee is missing any traits from target in both active and inactive states
	for k, v in pairs(TargetTraits.B) do
		if not DeepEquals(v, bee.individual.active[k]) and not DeepEquals(v, bee.individual.inactive[k]) then
			return true
		end
	end
	return false
end--]]
function IsDroneMissingAllBTraits(bee)
	--check if bee is missing all traits from target in both active and inactive states
	for k, v in pairs(TargetTraits.B) do
		if DeepEquals(v, bee.individual.active[k]) or DeepEquals(v, bee.individual.inactive[k]) then
			return false
		end
	end
	return true
end
--[[function IsDroneMissingAllRelevantTargetGenes(drone, princess)
	--drone is irrelevant if it does not have any genes which the princess is missing
	for k,v in pairs(TargetTraits.B) do
		-- is the princess missing a B gene		
		if not DeepEquals(v, princess.individual.active[k]) or not DeepEquals(v, princess.individual.inactive[k]) then
			--does the drone have a B gene to contribute
			if DeepEquals(v, drone.individual.active[k]) or DeepEquals(v, drone.individual.inactive[k]) then
				return false
			end
		end
	end
	return true
end--]]
function IsDroneMissingAllRelevantTargetGenes(drone, princess)
	local isPrincessMissingAnyBGenes = false
	--drone is irrelevant if it does not have any genes which the princess is missing
	for k,v in pairs(TargetTraits.B) do
		-- is the princess missing a B gene		
		if not DeepEquals(v, princess.individual.active[k]) or not DeepEquals(v, princess.individual.inactive[k]) then
			isPrincessMissingAnyBGenes = true
			--does the drone have a B gene to contribute
			if DeepEquals(v, drone.individual.active[k]) or DeepEquals(v, drone.individual.inactive[k]) then
				return false
			end
		end
		--if not DeepEquals(v, princess.individual.active[k]) and not DeepEquals(v, princess.individual.inactive[k]) then
		--	isPrincessMissingAnyBGenes = true
		--end
	end
	return true --and isPrincessMissingAnyBGenes
end
--target(B,B,A,A,A)
--princs(A,A,A,A,A) passes
--princs(B,A,A,A,A) passes
--princs(A,A,A,B,A) fails
--[[function HasPrincessAllTargetA(bee)
	for k, v in pairs(TargetTraits.A) do
		if not DeepEquals(v, bee.individual.active[k]) or not DeepEquals(v, bee.individual.inactive[k]) then
			return false
		end
	end
	return true
end--]]

function IsPrincessPureA(princess)
	for k, v in pairs(TargetTraits.B) do
		if DeepEquals(v, princess.individual.active[k]) or DeepEquals(v, princess.individual.inactive[k]) then
			return false
		end
	end
	for k, v in pairs(TargetTraits.A) do
		if not DeepEquals(v, princess.individual.active[k]) or not DeepEquals(v, princess.individual.inactive[k]) then
			return false
		end
	end
	return true
end

function IsPrincessMissingAllTargetBGenes(princess)
	for k, v in pairs(TargetTraits.B) do
		if DeepEquals(v, princess.individual.active[k]) or DeepEquals(v, princess.individual.inactive[k]) then
			return false
		end
	end
	return true
end

function IsPrincessWorseThanPure(princess)
	return not IsPrincessPureA(princess) and IsPrincessMissingAllTargetBGenes(princess)
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
	Princess = nil
	for i, bee in pairs(BeeChest) do
		if bee.individual then
			if bee.individual.active and bee.individual.inactive and not (bee.name == "Forestry:beePrincessGE") then
				--print("Slot " .. tostring(i) .. " trash=" .. tostring(IsDroneMissingBTrait(bee)))
				--if IsDroneMissingBTrait(bee) then
				if IsDroneMissingAllBTraits(bee) then
					--FakeComponent.TransferItemToFirstFreeSlot(Config.Storage, Config.Trash, 64, i + 1)
					--FakeComponent[Config.Trash] = {[0]={}}
					--if Verbose then print('moved drone to trash', i+1)end
				end
			end
			if not Princess and bee.name == "Forestry:beePrincessGE" then
				Princess = { princess = bee, slot = i + 1 }
			end
		end
	end
	return Princess
end

function Iterate()
	BeeChest = Component.readInventory(Config.Storage)
	InputDrawer = FakeComponent.readInventory(Config.Input)
	local fallbackDrone = InputDrawer[TargetTraits.ASlot-1]


	SearchResult = FindPrincessAndTrashDrones(BeeChest)
	if SearchResult == nil then
		print('Princess not in Storage. Skipping Iteration')
		return true
	end
	Princess = SearchResult.princess
	if Princess == nil then
		return true
	end
	PrincessSlot = SearchResult.slot
	PrincessDistance = MeasureDroneDistanceToTarget(Princess)

	--log state, later append decision
	if Verbose then print('Princess has distance='..PrincessDistance..' and gene='..FakeComponent.BeeToGeneString(Princess, TargetTraits)) end
	local logfile = nil
	if DecisionLogging then
		logfile = io.open('multi11decision.log','a')
		if not logfile then return end
		logfile:write('princess='..FakeComponent.BeeToGeneString(Princess, TargetTraits)..'\n')
	end
	if not IsPrincessWorseThanPure(Princess) then
		--choose best valid drone from storage chest or fallback input, or default to fallback drone
		BestDroneIndex = -1
		BestDistance = 999

		--check if input drones are valid, and use as baseline distance
		local fallbackDistance = MeasureDroneDistanceToTarget(fallbackDrone)
		IsFallbackRelevant = not IsDroneMissingAllRelevantTargetGenes(fallbackDrone, Princess)
		if IsFallbackRelevant then
			BestDistance = fallbackDistance
		end
		if Verbose then print('FallbackDrone has distance='..fallbackDistance..' and gene='..FakeComponent.BeeToGeneString(fallbackDrone, TargetTraits)..' and is relevant='..tostring(IsFallbackRelevant)) end	
		for i = 0, #BeeChest do
			if BeeChest[i] and BeeChest[i].name == "Forestry:beeDroneGE" then
				local bee = BeeChest[i]
				if bee.individual and bee.individual.active and bee.individual.inactive then
					
					local distanceToTarget = MeasureDroneDistanceToTarget(bee)
					local isDroneRelevant = not IsDroneMissingAllRelevantTargetGenes(bee, Princess) or (distanceToTarget == 0)
					if DecisionLogging then logfile:write('drone='..FakeComponent.BeeToGeneString(bee, TargetTraits)..'='..tostring(isDroneRelevant)..'='..tostring(distanceToTarget)..'\n')end
					--if isDroneRelevant then
						--if Verbose then print('Drone '..tostring(i+1)..' has distance='..distanceToTarget..' and amount='..tostring(bee.size)..' and gene='..FakeComponent.BeeToGeneString(bee, TargetTraits)) end--..' with '..FakeComponent.table_to_string(bee)..'\n')
					--end
					if isDroneRelevant and (distanceToTarget < BestDistance) then
						BestDistance = distanceToTarget
						BestDroneIndex = i
					end
				end
			end
		end
		if BestDistance == 0 then
			PrincessDistance = MeasureDroneDistanceToTarget(Princess)
			if PrincessDistance == 0 then
				--print("Breeding Done")
				--move princess and result drone to output
				FakeComponent.transferItem(Config.Storage, Config.Output, 1, PrincessSlot, 1)
				FakeComponent.transferItem(Config.Storage, Config.Output, 1, BestDroneIndex + 1, 2)
				if DecisionLogging then logfile:flush()logfile:close() end
				return false
			end
		end
		if BestDroneIndex == -1 then
			--print("No eligable Drone found. Using Fallback drone")
			Result = FakeComponent.transferItem(Config.Input, Config.Alveary, 1, TargetTraits.ASlot, 2)
			if DecisionLogging then 
				logfile:write('chosen='..FakeComponent.BeeToGeneString(fallbackDrone, TargetTraits)..'\n')
				logfile:flush()logfile:close()
			end
			if Result ~= 1 then
				print("Ran out of Super Drones. Programm halting.")
				return false
			end
		else
			--FakeComponent.printInventory(Config.Storage)
			if Verbose then print('Drone has distance='..BestDistance..' and gene='..FakeComponent.BeeToGeneString(FakeComponent[Config.Storage][BestDroneIndex], TargetTraits)) end
			if DecisionLogging then 
				logfile:write('chosen='..FakeComponent.BeeToGeneString(FakeComponent[Config.Storage][BestDroneIndex], TargetTraits)..'\n')
				logfile:flush()logfile:close()
			end
			Result = FakeComponent.transferItem(Config.Storage, Config.Alveary, 1, BestDroneIndex + 1, 2)
			--print("[DEBUG]:    Moved Drone Dist="..tostring(BestDistance).."", Result, "From Slot", BestDroneIndex + 1)
			if Result ~= 1 then
				print("Ran out of Other Drones. Programm halting.")
				return false
			end
		end
	else
		--choose pure A drone
		--move pure a drone to output chest
		Result = FakeComponent.transferItem(Config.Input, Config.Alveary, 1, TargetTraits.ASlot, 2)
		if DecisionLogging then 
			logfile:write('chosen='..FakeComponent.BeeToGeneString(fallbackDrone, TargetTraits)..'\n')
			logfile:flush()logfile:close()
		end
			--print("[DEBUG]:    Moved Fallback Drone", Result)
		if Result ~= 1 then
			print("Ran out of Super Drones. Programm halting.")
			return false
		end
	end
	Result = FakeComponent.transferItem(Config.Storage, Config.Alveary, 1, PrincessSlot, 1)
	--print("[DEBUG]:    Moved Princess", Result)
	return true
end
function Main()
	if Verbose then print("Forestry Bee Breeding\n-------------------------------\n ©B3tah3 , XI_Wizzard\n")end
	FakeComponent.initializeInput()
	--FakeComponent.printInventory(Config.Input)
	InputDrawer = FakeComponent.readInventory(Config.Input)
  TargetTraits.QueryTargetStats(InputDrawer)
	--print(FakeComponent.table_to_string(TargetTraits.A), TargetTraits.ASlot, TargetTraits.BSlot)
	--TargetTraits.useDefaultTarget()
	--print(FakeComponent.table_to_string(TargetTraits.A), TargetTraits.ASlot, TargetTraits.BSlot)
	--for k,v in pairs(TargetTraits) do
	--	print(k,v)
	--end

	-- send Type B drones to storage
	FakeComponent.transferItem(Config.Input, Config.Storage, 64, TargetTraits.BSlot, 2)

	MakeIterations = true
	local i = 0
	while MakeIterations do
		--print("---------------------------------")
		--print("Iteration: ", i)
		--print("---------------------------------")
		i = i + 1
		MakeIterations = Iterate()
		--FakeComponent.printInventory(Config.Alveary)
		if MakeIterations then
			FakeComponent.breedBees()
		end
		
		--[[if i == 500 then
			print('=500 iterations hit, printing state:')
			Verbose = true
		else Verbose = false
		end--]]
		--if i >= 40 then return 999 end
	end
	--print(i)
	io.write(i..', ')
	io.flush()
	if Verbose then FakeComponent.printInventory(Config.Output, TargetTraits)end
	--print('Target Traits were A='..FakeComponent.table_to_string(TargetTraits.A)..' and B='..FakeComponent.table_to_string(TargetTraits.B))
	return i
end

Trials = {}
Average = 0
OccuranceCounter = {[0]=nil}
TrialAmount = 1000
if Verbose then TrialAmount = 1 end
for i = 1,TrialAmount do
	local generations = Main()
	Trials[i] = generations
	Average = (Average*(i-1) + generations ) / i
	if OccuranceCounter[generations] then
		OccuranceCounter[generations] = OccuranceCounter[generations] + 1
	else
		OccuranceCounter[generations] = 1
	end
	
end
print('Average= '..tostring(Average))

local occurenceString = ''
local medianCounter = 0
local median = 0
for i = 0,200 do
	if OccuranceCounter[i] ~= nil then
		occurenceString = occurenceString..tostring(i)..':'..tostring(OccuranceCounter[i])..', '
		medianCounter = medianCounter + OccuranceCounter[i]
		if medianCounter < TrialAmount/2 then
			median = i
		end
	end
end
print(occurenceString)
print('Median= '..tostring(median))

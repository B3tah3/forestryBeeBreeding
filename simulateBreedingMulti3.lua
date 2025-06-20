TargetTraits = require("targetTraits")
Component = require("fakeComponent")
Config = require("fakeConfig")
local verbose = false
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
	--these can definitly be trashed
	for k, v in pairs(TargetTraits.B) do
		if DeepEquals(v, bee.individual.active[k]) or DeepEquals(v, bee.individual.inactive[k]) then
			return false
		end
	end
	return true
end
function IsDroneMissingAllRelevantTargetGenes(drone, princess)
	--drone is irrelevant if it does not have any genes which the princess is missing, unless the princess isnt missing any
	local isPrincessMissingAnyBGenes = false
	for k,v in pairs(TargetTraits.B) do
		-- is the princess missing a B gene		
		if not DeepEquals(v, princess.individual.active[k]) or not DeepEquals(v, princess.individual.inactive[k]) then
			isPrincessMissingAnyBGenes = true
			--does the drone have a B gene to contribute
			if DeepEquals(v, drone.individual.active[k]) or DeepEquals(v, drone.individual.inactive[k]) then
				return false
			end
		end
	end
	local isPrincessMissingAnyAGenes = false
	for k,v in pairs(TargetTraits.A) do
		-- is the princess missing a A gene
		if not DeepEquals(v, princess.individual.active[k]) or not DeepEquals(v, princess.individual.inactive[k]) then
			isPrincessMissingAnyAGenes = true
		end
	end
	--if not isPrincessMissingAnyBGenes then
	--	print('princess almost done, all drones accepted')
	--end
	return isPrincessMissingAnyAGenes or isPrincessMissingAnyBGenes
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

function IsPrincessWorseThanPure(bee)
	for k, v in pairs(TargetTraits.B) do
		if DeepEquals(v, bee.individual.active[k]) or DeepEquals(v, bee.individual.inactive[k]) then
			return false
		end
	end
	for k, v in pairs(TargetTraits.A) do
		if not DeepEquals(v, bee.individual.active[k]) or not DeepEquals(v, bee.individual.inactive[k]) then
			return true
		end
	end
	return false
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
					FakeComponent.TransferItemToFirstFreeSlot(Config.Storage, Config.Trash, 64, i + 1)
					FakeComponent[Config.Trash] = {[0]={}}
					if verbose then print('moved drone to trash', i+1)end
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
	--InputDrawer = Component.readInventory(Config.InputDrawer)
	--FallbackDrone = InputDrawer[TargetTraits.ASlot-1]

	SearchResult = FindPrincessAndTrashDrones(BeeChest)
	if SearchResult == nil then
		print('Princess not in Storage. Skipping Iteration')
		return true
	end
	Princess = SearchResult.princess
	PrincessSlot = SearchResult.slot
	PrincessDistance = MeasureDroneDistanceToTarget(Princess)
	if verbose then print('Princess has distance='..PrincessDistance..' and gene='..FakeComponent.BeeToGeneString(Princess, TargetTraits)) end

	if Princess and not IsPrincessWorseThanPure(Princess) then --HasPrincessAllTargetA
		--choose best drone from storage chest
		BestDroneIndex = -1
		BestDistance = 999
		--if IsDroneMissingAllRelevantTargetGenes(FallbackDrone, Princess) then BestDistance
		--MeasureDroneDistanceToTarget(FallbackDrone)
		for i = 0, #BeeChest do
			if BeeChest[i] and BeeChest[i].name == "Forestry:beeDroneGE" then
				local bee = BeeChest[i]
				if bee.individual and bee.individual.active and bee.individual.inactive then
					local distanceToTarget = MeasureDroneDistanceToTarget(bee)
					local isDroneRelevant = not IsDroneMissingAllRelevantTargetGenes(bee, Princess)
					if isDroneRelevant then
						if verbose then print('Drone '..tostring(i+1)..' has distance='..distanceToTarget..' and amount='..tostring(bee.size)..' and gene='..FakeComponent.BeeToGeneString(bee, TargetTraits)) end--..' with '..FakeComponent.table_to_string(bee)..'\n')
					end
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
				return false
			end
		end
		if BestDistance == 999 then
			--print("No eligable Drone found. Using Fallback drone")
			Result = FakeComponent.transferItem(Config.Input, Config.Alveary, 1, TargetTraits.ASlot, 2)
			if Result ~= 1 then
				print("Ran out of Super Drones. Programm halting.")
				return false
			end
		else
			--FakeComponent.printInventory(Config.Storage)
			Result = FakeComponent.transferItem(Config.Storage, Config.Alveary, 1, BestDroneIndex + 1, 2)
			--print("[DEBUG]:    Moved Drone Dist="..tostring(BestDistance).."", Result, "From Slot", BestDroneIndex + 1)
			if Result ~= 1 then
				print("Ran out of Other Drones. Programm halting.")
				return false
			end
		end
	elseif Princess then
		--choose pure A drone
		--move pure a drone to output chest
		Result = FakeComponent.transferItem(Config.Input, Config.Alveary, 1, TargetTraits.ASlot, 2)
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
	if verbose then print("Forestry Bee Breeding\n-------------------------------\n ©B3tah3 , XI_Wizzard\n")end
	
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
			FakeComponent.breedBees(TargetTraits)
		end
	end
	io.write(i..', ')
	io.flush()
	if verbose then FakeComponent.printInventory(Config.Output, TargetTraits)end
	--print('Target Traits were A='..FakeComponent.table_to_string(TargetTraits.A)..' and B='..FakeComponent.table_to_string(TargetTraits.B))
	return i
end

Trials = {}
Average = 0
for i = 1,1000 do
	Trials[i] = Main()
	Average = (Average*(i-1) + Trials[i] ) / i

end
print(Average)
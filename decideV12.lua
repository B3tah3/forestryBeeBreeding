Decider = {}
--[[function IsDroneMissingBTrait(bee)
	--check if bee is missing any traits from target in both active and inactive states
	for k, v in pairs(TargetTraits.B) do
		if not DeepEquals(v, bee.individual.active[k]) and not DeepEquals(v, bee.individual.inactive[k]) then
			return true
		end
	end
	return false
end--]]

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
local function isDroneMissingAllRelevantTargetGenes(drone, princess)
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

local function isPrincessPureA(princess)
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


local function isPrincessMissingAllTargetBGenes(princess)
	for k, v in pairs(TargetTraits.B) do
		if DeepEquals(v, princess.individual.active[k]) or DeepEquals(v, princess.individual.inactive[k]) then
			return false
		end
	end
	return true
end

function IsPrincessWorseThanPure(princess)
	return not isPrincessPureA(princess) and isPrincessMissingAllTargetBGenes(princess)
end


function Decider.ChooseFather(BeeChest, fallbackDrone, Princess, PrincessDistance)
    --log state, later append decision
	if Verbose then print('Princess has distance='..PrincessDistance..' and gene='..Component.BeeToGeneString(Princess, TargetTraits)) end
	if DecisionLogging then
		Logfile:write('princess='..Component.BeeToGeneString(Princess, TargetTraits)..'\n')
	end
	if not IsPrincessWorseThanPure(Princess) then
		--choose best valid drone from storage chest or fallback input, or default to fallback drone
		local bestDroneIndex = -1
		local bestDistance = 999

		--check if input drones are valid, and use as baseline distance
		local fallbackDistance = MeasureDroneDistanceToTarget(fallbackDrone)
		IsFallbackRelevant = not isDroneMissingAllRelevantTargetGenes(fallbackDrone, Princess)
		if IsFallbackRelevant then
			bestDistance = fallbackDistance
		end
		if Verbose then print('FallbackDrone has distance='..fallbackDistance..' and gene='..Component.BeeToGeneString(fallbackDrone, TargetTraits)..' and is relevant='..tostring(IsFallbackRelevant)) end	
		for i = 0, #BeeChest do
			if BeeChest[i] and BeeChest[i].name == "Forestry:beeDroneGE" then
				local bee = BeeChest[i]
				if bee.individual and bee.individual.active and bee.individual.inactive then
					local distanceToTarget = MeasureDroneDistanceToTarget(bee)
					local isDroneRelevant = not isDroneMissingAllRelevantTargetGenes(bee, Princess) or (distanceToTarget == 0)
					if DecisionLogging  then Logfile:write('drone='..Component.BeeToGeneString(bee, TargetTraits)..'='..tostring(isDroneRelevant)..'='..tostring(distanceToTarget)..'\n')end
					--if Verbose and isDroneRelevant then print('Drone '..tostring(i+1)..' has distance='..distanceToTarget..' and amount='..tostring(bee.size)..' and gene='..Component.BeeToGeneString(bee, TargetTraits)) end--..' with '..Component.table_to_string(bee)..'\n')
					if isDroneRelevant and (distanceToTarget < bestDistance) then
						bestDistance = distanceToTarget
						bestDroneIndex = i
					end
				end
			end
		end
		if bestDistance == 0 then
			PrincessDistance = MeasureDroneDistanceToTarget(Princess)
			if PrincessDistance == 0 then
				return bestDroneIndex, true
			end
		end
        return bestDroneIndex, false
    end
	return -1, false
end
return Decider
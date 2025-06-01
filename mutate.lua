c = require("component")
Component = require("component")
Config = require("config")
Utils = require("utils")
Mutation = {}

Mutation.target = nil
Mutation.Storage = {}
Mutation.alveary = c.items
Mutation.tree = nil
StorageChest = { value = 1 }

function getFirstFreeSlot(Chest)
	StorageChest.value = StorageChest.value + 1
	return StorageChest.value
end

function Mutation.syncStorage()
	Mutation.Storage = {}
	local libary = c.transposer.getAllStacks(Config.Output)
	for i = 1, libary.count() do
		local slot = libary()
		print("Slot", next(slot), "index", i)
		if next(slot) ~= nil then
			if slot.name == "Forestry:beeDroneGE" then
				if not Mutation.Storage[slot.individual.active.species.uid] then
					Mutation.Storage[slot.individual.active.species.uid] = {}
				end
				Mutation.Storage[slot.individual.active.species.uid].drone = i
			end
		elseif slot.name == "Forestry:beePrincessGE" then
			if not Mutation.Storage[slot.individual.active.species.uid] then
				Mutation.Storage[slot.individual.active.species.uid] = {}
			end
			Mutation.Storage[slot.individual.active.species.uid].princess = i
		end
	end
end

function FindPrincess(BeeChest)
	Princess = nil
	BeeChest.reset()
	for i = 1, BeeChest.count() do
		local bee = BeeChest()
		if bee.individual and not Princess and bee.name == "Forestry:beePrincessGE" then
			Climate.setHumidity(bee)
			Climate.setTemperature(bee)
			Climate.setLight(bee)
			Princess = { princess = bee, slot = i }
		end
	end
	BeeChest.reset()
	return Princess
end

function FindDrone(BeeChest, princess, target, parent1, parent2)
	Drone = nil
	-- if princess has target then
	-- if princess 0,0 breed 1,1 or 2,2 or 1,2
	-- if princess 1,0 ,1,t or 1,1 breed 2,2
	-- if princess 2,0 ,2,t or 2,2 breed 1,1
	-- if princess 1,2 breed 1,2 or
	--
	--if princess has 1 breed 2,2
	-- else breed 1,1

	for i = 1, storage.count() do
		local bee = storage()
		if bee.name == "Forestry:beeDroneGE" then
			local activeSpecies = bee.individual.active.species.uid
			local inactiveSpecies = bee.individual.inactive.species.uid
			local princessSpecies = {
				active = princess.princess.individual.active.species.uid,
				inactive = princess.princess.individual.individual.species.uid,
			}
			-- Trash Drones that contain irellevant species
			if
				not (
					activeSpecies == parent1
					or activeSpecies == parent2
					or activeSpecies == target
					or inactiveSpecies == parent1
					or inactiveSpecies == parent2
					or inactiveSpecies == target
				)
			then
				print("Trash")
			else
				-- If Drone has Both Target Traits
				if activeSpecies == target and inactiveSpecies == target then
					Drone = { drone = bee, slot = i }
				end
				if
					not Drone
					or not (
						Drone.drone.individual.active.species.uid == target
						and Drone.drone.individual.active.species.uid == target
					)
				then
					if activeSpecies == target or inactiveSpecies == target then
						Drone = { drone = bee, slot = i }
					end
					if
						(princessSpecies.active == parent1 and princessSpecies.inactive ~= parent2)
						or (princessSpecies.active ~= parent2 and princessSpecies.inactive == parent1) and not Drone
					then
						if activeSpecies == parent2 and inactiveSpecies == parent2 then
							Drone = { drone = bee, slot = i }
							-- Match
						end
					end
					if
						(princessSpecies.active == parent2 and princessSpecies.inactive ~= parent1)
						or (princessSpecies.active ~= parent1 and princessSpecies.inactive == parent2) and not Drone
					then
						if activeSpecies == parent1 and inactiveSpecies == parent1 then
							Drone = { drone = bee, slot = i }
							-- Match
						end
					end
				end
			end
		end
	end
end

function Mutation.crossbreed(bee1, bee2, target)
	Mutation.syncStorage()
	print("Breed", bee1, "With", bee2, "For", target)
	local parent1 = c.transposer.getStackInSlot(Config.Output, Mutation.Storage[bee1].drone)
	-- TODO if not enough drones are available, breed them first
	local parent2 = c.transposer.getStackInSlot(Config.Output, Mutation.Storage[bee2].drone)
	-- TODO if not enough drones are available, breed them first
	local parent1Slot =
		Utils.TransferItemToFirstFreeSlot(Config.Output, Config.Storage, 32, Mutation.Storage[bee1].drone)
	local parent2Slot =
		Utils.TransferItemToFirstFreeSlot(Config.Output, Config.Storage, 32, Mutation.Storage[bee2].drone)
	local storage = c.transposer.getAllStacks(Config.Output)
	local breedingDrone = nil
	local princessSlot = nil
	Princess = FindPrincess(storage)
	storage.reset()
	local princess = c.transposer.getStackInSlot(Config.Storage, princessSlot)
	if princess.individual.active.species.uid == bee1 and princess.individual.inactive.species.uid == bee1 then
		-- move bee2
		Utils.TransferItemToFirstFreeSlot(Config.Storage, Config.Output, 1, parent2Slot)
	elseif princess.individual.active.species.uid == bee2 and princess.individual.inactive.species.uid == bee2 then
		-- move bee1
		Utils.TransferItemToFirstFreeSlot(Config.Storage, Config.Output, 1, parent1Slot)
	else
	end
	print("Breeding Drone", breedingDrone)

	print("Moved Drones For Breeding")
	print("Target", target, "Parents:", bee1, bee2)
end

function Mutation.mutate(target)
	local tree = {}
	if Mutation.Storage[target] then
		return
	end
	local parents = Mutation.alveary.getBeeParents(target)
	if #parents == 0 then
		print("Cheating")
		Mutation.Storage[target] = getFirstFreeSlot(StorageChest)
		return
	end
	for k, parent in pairs(parents) do
		if Mutation.Storage[parent.allele1.uid] and Mutation.Storage[parent.allele2.uid] then
			Mutation.crossbreed(parent.allele1.uid, parent.allele2.uid, target)
			return
		end
	end
	local recipie = nil
	if #parents == 1 then
		recipie = 1
	else
		print("Please Select a  recipie by Number")
		for i = 1, #parents do
			print("(", i, ")", "Recipie", parents[i].allele1.name, parents[i].allele2.name)
		end
		recipie = io.read("n")
		print("Breeding with recipie", recipie)
	end
	local parent = parents[recipie]
	print("Allele 1", parent.allele1.name)
	Mutation.mutate(parent.allele1.uid)
	print("parents", parent)
	print("Allele 2", parent.allele2.name)
	Mutation.mutate(parent.allele2.uid)
	Mutation.crossbreed(parent.allele1.uid, parent.allele2.uid, target)
end

function Mutation.printTree(tree)
	if type(tree) == "table" then
		for k, v in pairs(tree) do
			print(k)
			Mutation.printTree(v)
		end
	else
		print(tree)
	end
end

function Mutation.defaultMutation()
	Mutation.crossbreed("gregtech.bee.speciesChrome", "gregtech.bee.speciesSteel", "gregtech.bee.speciesStainlesssteel")
end

return Mutation

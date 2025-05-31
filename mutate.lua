c = require("component")
Mutation = {}

Mutation.target = nil
Mutation.Storage = {}
Mutation.alveary = c.for_alveary_0
Mutation.tree = nil
StorageChest = { value = 1 }

function getFirstFreeSlot(Chest)
	StorageChest.value = StorageChest.value + 1
	return StorageChest.value
end

function Mutation.crossbreed(bee1, bee2, target)
	print("Breed", bee1, "With", bee2, "For", target)
	local slot = getFirstFreeSlot(StorageChest)
	print("Storing Result in ", slot)
	Mutation.Storage[target] = slot
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

return Mutation

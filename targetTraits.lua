IO = require("io")
TargetTraits = {}
local verbose = false
function TargetTraits.QueryTargetStats(InputDrawer)
	--local autoAnswer = {[0]='b','a','a','a','a','a','a','a','a','a','a','a'}
	local autoAnswer = {[0]='b','b','b','b','a','a','a','a','a','a','a','a'}
	--local autoAnswer = {[0]='b','a','a'}
	
	
	local answerCount = 0
	TargetTraits.A = {}
	TargetTraits.B = {}
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
	if verbose then print("Answer A, B or [blank] to choose genes") end
	for k, TypeOneTrait in pairs(TypeOneDrones.individual.active) do
		TypeTwoTrait = TypeTwoDrones.individual.active[k]
		TypeOneTraitDescription = tostring(TypeOneTrait)
		TypeTwoTraitDescription = tostring(TypeTwoTrait)

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
			if verbose then print(formatted)end
			--Input = io.read()
			Input = autoAnswer[answerCount]
			answerCount = answerCount + 1
			if Input == "A" or Input == "a" then
				Input = "A=" .. TypeOneTraitDescription
				TargetTraits.A[k] = TypeOneTrait
			elseif Input == "B" or Input == "b" then
				Input = "B=" .. TypeTwoTraitDescription
				TargetTraits.B[k] = TypeTwoTrait
			else
				Input = "Ignored"
			end
			if verbose then print("Choosing " .. Input)end
		end
	end
	--check if more type B than A traits have been chose
	TargetTraits.ASlot = 3
	TargetTraits.BSlot = 4
	local btraits = 0
	local atraits = 0
	if verbose then print("Traits A")
		print("-------------------------") end
	for k, v in pairs(TargetTraits.A) do
		if verbose then print(k, v)end
		atraits = atraits + 1
	end
	if verbose then print("Traits B")
		print("-------------------------")end
	for k, v in pairs(TargetTraits.B) do
		if verbose then print(k, v)end
		btraits = btraits + 1
	end
	if verbose then print("Btraits", btraits, "Ataits", atraits)end
	if btraits > atraits then
		--print(
		--	"Debugger entered if statement. For more information please buy the pro version of lua debugger for only 9.99 per month"
		--)
		local swap = TargetTraits.A
		TargetTraits.A = TargetTraits.B
		TargetTraits.B = swap
		TargetTraits.BSlot = 3
		TargetTraits.ASlot = 4
	end
	assert(btraits > 0, 'No Traits from one bee specified!')
end
--didnt work for unknown reasons (maybe pointers to real bee objects are needed?)
--[[function TargetTraits.useDefaultTarget()
	TargetTraits.A={["speed"]="0.30000001192093",["humidityTolerance"]="UP_2",["temperatureTolerance"]="NONE",["flowerProvider"]="flowersVanilla",["flowering"]="10",["nocturnal"]=true,["territory"]={"15","13","15"},["effect"]="forestry.allele.effect.poison"}
	TargetTraits.B={["species"]={["uid"]="gregtech.bee.speciesSalty",["humidity"]="Arid",["name"]="Salt",["temperature"]="Warm"},["tolerantFlyer"]=false,["lifespan"]="20",["caveDwelling"]=false}
	TargetTraits.ASlot = 3
	TargetTraits.BSlot = 4
end--]]
return TargetTraits

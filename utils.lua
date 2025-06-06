Component = require("component")
Utils = {}
function Utils.TransferItemToFirstFreeSlot(sourceSide, sinkSide, count, sourceSlot)
	local sinkData = Component.transposer.getAllStacks(sinkSide)
	for i = 0, sinkData.count() do
		local slot = sinkData()
		if next(slot) == nil then
			print("Move from side", sourceSide, "to Side", sinkSide)
			Component.transposer.transferItem(sourceSide, sinkSide, count, sourceSlot, i + 1)
			os.sleep(0.5)
			return i
		end
	end
end
return Utils

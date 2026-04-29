-- Globally used
local G = getfenv(0)
local oGlow = oGlow

-- Containers
local GetContainerItemLink = GetContainerItemLink

-- Update a single container bag frame
-- Button indices run opposite to container slot indices (button 1 = slot N, button N = slot 1)
local function updateBag(bagFrame)
	local bagID = bagFrame:GetID()
	local size = GetContainerNumSlots(bagID)
	if not size or size == 0 then return end
	local name = bagFrame:GetName()
	for i = 1, size do
		local bid = size - i + 1
		local slot = getglobal(name .. "Item" .. bid)
		local link = GetContainerItemLink(bagID, i)
		if slot then
			if link then
				oGlow(slot, getQuality(link))
			elseif slot.bc then
				slot.bc:Hide()
			end
		end
	end
end

-- Hook into each ContainerFrame using OnShow/OnEvent
for i = 1, NUM_CONTAINER_FRAMES do
	local bagFrame = getglobal("ContainerFrame" .. i)
	if bagFrame then
		local hook = CreateFrame("Frame")
		hook:SetParent(bagFrame)

		hook:SetScript("OnShow", function()
			updateBag(bagFrame)
		end)

		hook:SetScript("OnEvent", function()
			if event == "BAG_UPDATE" and bagFrame:IsShown() then
				updateBag(bagFrame)
			end
		end)

		hook:RegisterEvent("BAG_UPDATE")
	end
end

oGlow.updateBags = updateBag

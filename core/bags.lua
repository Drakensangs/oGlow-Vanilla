-- Globally used
local G = getfenv(0)
local oGlow = oGlow

-- Containers
local GetContainerItemLink = GetContainerItemLink

local MAX_CONTAINER_ITEMS = 36

local function updateBag(bagFrame)
	if oGlow.preventBags then return end

	local size = bagFrame.size
	if not size or size == 0 then return end

	local bagID = bagFrame:GetID()
	local name  = bagFrame:GetName()

	for i = 1, MAX_CONTAINER_ITEMS do
		local btn = getglobal(name .. "Item" .. i)
		if btn and btn.bc then btn.bc:Hide() end
	end

	for i = 1, size do
		local btn = getglobal(name .. "Item" .. i)
		if btn then
			local link = GetContainerItemLink(bagID, size - i + 1)
			if link then
				oGlow(btn, getQuality(link))
			end
		end
	end
end

for i = 1, NUM_CONTAINER_FRAMES do
	local bagFrame = getglobal("ContainerFrame" .. i)
	if bagFrame then
		local hook = CreateFrame("Frame")
		hook:SetParent(bagFrame)

		hook:SetScript("OnShow", function()
			if bagFrame:GetID() == -2 then return end
			if not oGlow.preventBags then updateBag(bagFrame) end
		end)

		hook:SetScript("OnEvent", function()
			if event == "BAG_UPDATE" and bagFrame:IsShown() then
				if bagFrame:GetID() == -2 then return end
				if not oGlow.preventBags then updateBag(bagFrame) end
			end
		end)

		hook:RegisterEvent("BAG_UPDATE")
	end
end

local function clearBags()
	for i = 1, NUM_CONTAINER_FRAMES do
		local bagFrame = getglobal("ContainerFrame" .. i)
		if bagFrame and bagFrame:GetID() ~= -2 then
			local name = bagFrame:GetName()
			for j = 1, MAX_CONTAINER_ITEMS do
				local btn = getglobal(name .. "Item" .. j)
				if btn and btn.bc then btn.bc:Hide() end
			end
		end
	end
end

local function updateBags()
	for i = 1, NUM_CONTAINER_FRAMES do
		local bagFrame = getglobal("ContainerFrame" .. i)
		if bagFrame and bagFrame:IsShown() and bagFrame:GetID() ~= -2 then
			updateBag(bagFrame)
		end
	end
end

oGlow.updateBag  = updateBag
oGlow.updateBags = updateBags
oGlow.clearBags  = clearBags

oGlow:RegisterRefresh(function()
	if oGlow.preventBags then return end
	for i = 1, NUM_CONTAINER_FRAMES do
		local bagFrame = getglobal("ContainerFrame" .. i)
		if bagFrame and bagFrame:IsShown() and bagFrame:GetID() ~= -2 then
			updateBag(bagFrame)
		end
	end
end)
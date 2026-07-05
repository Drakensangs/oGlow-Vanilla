local oGlow = oGlow

-- KEYRING_CONTAINER = -2 (defined in FrameXML/Constants.lua)
local KEYRING_BAG_ID   = -2
local MAX_CONTAINER_ITEMS = 36

local function updateKeyring()
	for i = 1, NUM_CONTAINER_FRAMES do
		local bagFrame = getglobal("ContainerFrame" .. i)
		if bagFrame and bagFrame:IsShown() and bagFrame:GetID() == KEYRING_BAG_ID then
			if not oGlow.preventKeyring then
				local saved = oGlow.preventBags
				oGlow.preventBags = nil
				oGlow.updateBag(bagFrame)
				oGlow.preventBags = saved
			else
				local name = bagFrame:GetName()
				for j = 1, MAX_CONTAINER_ITEMS do
					local btn = getglobal(name .. "Item" .. j)
					if btn and btn.bc then btn.bc:Hide() end
				end
			end
			return
		end
	end
end

local function clearKeyring()
	for i = 1, NUM_CONTAINER_FRAMES do
		local bagFrame = getglobal("ContainerFrame" .. i)
		if bagFrame and bagFrame:GetID() == KEYRING_BAG_ID then
			local name = bagFrame:GetName()
			for j = 1, MAX_CONTAINER_ITEMS do
				local btn = getglobal(name .. "Item" .. j)
				if btn and btn.bc then btn.bc:Hide() end
			end
			return
		end
	end
end

-- Attach a dedicated hook to each ContainerFrame for keyring-specific events.
for i = 1, NUM_CONTAINER_FRAMES do
	local bagFrame = getglobal("ContainerFrame" .. i)
	if bagFrame then
		local hook = CreateFrame("Frame")
		hook:SetParent(bagFrame)

		hook:SetScript("OnShow", function()
			if bagFrame:GetID() == KEYRING_BAG_ID then
				updateKeyring()
			end
		end)

		hook:SetScript("OnEvent", function()
			if event == "BAG_UPDATE" and bagFrame:IsShown()
			   and bagFrame:GetID() == KEYRING_BAG_ID then
				updateKeyring()
			end
		end)

		hook:RegisterEvent("BAG_UPDATE")
	end
end

oGlow.updateKeyring = updateKeyring
oGlow.clearKeyring  = clearKeyring

oGlow:RegisterRefresh(function()
	if oGlow.preventKeyring then return end
	for i = 1, NUM_CONTAINER_FRAMES do
		local bagFrame = getglobal("ContainerFrame" .. i)
		if bagFrame and bagFrame:IsShown() and bagFrame:GetID() == KEYRING_BAG_ID then
			updateKeyring()
			return
		end
	end
end)
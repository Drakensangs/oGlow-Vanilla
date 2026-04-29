-- Globally used
local G = getfenv(0)
local oGlow = oGlow

-- Each LootButton has a .slot field set by LootFrame_Update that holds the
-- actual loot slot index.  LOOTFRAME_NUMBUTTONS is the number of visible rows.

local function update()
	if not LootFrame:IsShown() then return end

	for i = 1, LOOTFRAME_NUMBUTTONS do
		local button = G["LootButton" .. i]
		if button and button.bc then
			button.bc:Hide()
		end
	end

	for i = 1, LOOTFRAME_NUMBUTTONS do
		local button = G["LootButton" .. i]
		if button and button:IsShown() and button.slot then
			local slot = button.slot
			if LootSlotIsItem(slot) then
				local link = GetLootSlotLink(slot)
				if link then
					oGlow(button, getQuality(link))
				end
			end
		end
	end
end

local origLootFrame_Update = LootFrame_Update
LootFrame_Update = function()
	origLootFrame_Update()
	update()
end

local hook = CreateFrame("Frame")
hook:SetParent(LootFrame)
hook:SetScript("OnHide", function()
	for i = 1, LOOTFRAME_NUMBUTTONS do
		local button = G["LootButton" .. i]
		if button and button.bc then
			button.bc:Hide()
		end
	end
end)

oGlow.updateLoot = update

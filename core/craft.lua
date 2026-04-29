-- Globally used
local G = getfenv(0)
local oGlow = oGlow

local GetCraftNumReagents = GetCraftNumReagents
local GetCraftReagentItemLink = GetCraftReagentItemLink
local GetCraftItemLink = GetCraftItemLink

local function update()
	local id = GetCraftSelectionIndex()
	if not id or id == 0 then return end

	local icon = G["CraftIcon"]
	local link = GetCraftItemLink(id)

	if icon then
		if link then
			oGlow(icon, getQuality(link))
		elseif icon.bc then
			icon.bc:Hide()
		end
	end

	for i = 1, GetCraftNumReagents(id) do
		local frame = G["CraftReagent" .. i]
		local rLink = GetCraftReagentItemLink(id, i)
		if frame then
			if rLink then
				local point = G["CraftReagent" .. i .. "IconTexture"]
				oGlow(frame, getQuality(rLink), point)
			elseif frame.bc then
				frame.bc:Hide()
			end
		end
	end
end

local lastSelection = nil

local function onUpdate()
	local id = GetCraftSelectionIndex()
	if id and id ~= 0 and id ~= lastSelection then
		lastSelection = id
		update()
	end
end

local hook = CreateFrame("Frame")
hook:SetScript("OnEvent", function()
	if event == "ADDON_LOADED" and arg1 == "Blizzard_CraftUI" then
		hook:SetParent("CraftFrame")
		hook:UnregisterEvent("ADDON_LOADED")
	elseif event == "CRAFT_SHOW" then
		lastSelection = nil
		update()
		hook:SetScript("OnUpdate", onUpdate)
	elseif event == "CRAFT_UPDATE" then
		lastSelection = nil
		update()
	elseif event == "CRAFT_CLOSE" then
		lastSelection = nil
		hook:SetScript("OnUpdate", nil)
	end
end)
hook:RegisterEvent("ADDON_LOADED")
hook:RegisterEvent("CRAFT_SHOW")
hook:RegisterEvent("CRAFT_UPDATE")
hook:RegisterEvent("CRAFT_CLOSE")

oGlow.updateCraft = update

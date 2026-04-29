-- Globally used
local G = getfenv(0)
local oGlow = oGlow

-- Tradeskill
local GetTradeSkillNumReagents = GetTradeSkillNumReagents
local GetTradeSkillReagentItemLink = GetTradeSkillReagentItemLink
local GetTradeSkillItemLink = GetTradeSkillItemLink

local function update()
	local id = GetTradeSkillSelectionIndex()
	if not id or id == 0 then return end

	local icon = G["TradeSkillSkillIcon"]
	local link = GetTradeSkillItemLink(id)

	if icon then
		if link then
			oGlow(icon, getQuality(link))
		elseif icon.bc then
			icon.bc:Hide()
		end
	end

	for i = 1, GetTradeSkillNumReagents(id) do
		local frame = G["TradeSkillReagent" .. i]
		local rLink = GetTradeSkillReagentItemLink(id, i)
		if frame then
			if rLink then
				local point = G["TradeSkillReagent" .. i .. "IconTexture"]
				oGlow(frame, getQuality(rLink), point)
			elseif frame.bc then
				frame.bc:Hide()
			end
		end
	end
end

local lastSelection = nil

local function onUpdate()
	local id = GetTradeSkillSelectionIndex()
	if id and id ~= 0 and id ~= lastSelection then
		lastSelection = id
		update()
	end
end

local hook = CreateFrame("Frame")
hook:SetScript("OnEvent", function()
	if event == "ADDON_LOADED" and arg1 == "Blizzard_TradeSkillUI" then
		hook:SetParent("TradeSkillFrame")
		hook:UnregisterEvent("ADDON_LOADED")
	elseif event == "TRADE_SKILL_SHOW" then
		lastSelection = nil
		update()
		hook:SetScript("OnUpdate", onUpdate)
	elseif event == "TRADE_SKILL_UPDATE" then
		lastSelection = nil
		update()
	elseif event == "TRADE_SKILL_CLOSE" then
		lastSelection = nil
		hook:SetScript("OnUpdate", nil)
	end
end)
hook:RegisterEvent("ADDON_LOADED")
hook:RegisterEvent("TRADE_SKILL_SHOW")
hook:RegisterEvent("TRADE_SKILL_UPDATE")
hook:RegisterEvent("TRADE_SKILL_CLOSE")

oGlow.updateTradeskill = update

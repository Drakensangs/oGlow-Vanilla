-- Globally used
local G = getfenv(0)
local oGlow = oGlow

-- Trade
local GetTradePlayerItemLink = GetTradePlayerItemLink
local GetTradeTargetItemLink = GetTradeTargetItemLink

local function setQuality(slot, link)
	if link then
		oGlow(slot, getQuality(link))
	elseif slot and slot.bc then
		slot.bc:Hide()
	end
end

local function updatePlayerItems()
	for i = 1, 7 do
		local slot = getglobal("TradePlayerItem" .. i .. "ItemButton")
		if slot then
			setQuality(slot, GetTradePlayerItemLink(i))
		end
	end
end

local function updateTargetItems()
	for i = 1, 7 do
		local slot = getglobal("TradeRecipientItem" .. i .. "ItemButton")
		if slot then
			setQuality(slot, GetTradeTargetItemLink(i))
		end
	end
end

local function update()
	updatePlayerItems()
	updateTargetItems()
end

local hook = CreateFrame("Frame")
hook:SetScript("OnEvent", function()
	if event == "TRADE_SHOW" or event == "TRADE_UPDATE" then
		if not oGlow.preventTrade then update() end
	elseif event == "TRADE_PLAYER_ITEM_CHANGED" then
		if not oGlow.preventTrade then
			local slot = getglobal("TradePlayerItem" .. arg1 .. "ItemButton")
			if slot then setQuality(slot, GetTradePlayerItemLink(arg1)) end
		end
	elseif event == "TRADE_TARGET_ITEM_CHANGED" then
		if not oGlow.preventTrade then
			local slot = getglobal("TradeRecipientItem" .. arg1 .. "ItemButton")
			if slot then setQuality(slot, GetTradeTargetItemLink(arg1)) end
		end
	end
end)
hook:RegisterEvent("TRADE_SHOW")
hook:RegisterEvent("TRADE_UPDATE")
hook:RegisterEvent("TRADE_PLAYER_ITEM_CHANGED")
hook:RegisterEvent("TRADE_TARGET_ITEM_CHANGED")

local function clearTrade()
	for i = 1, 7 do
		local s = getglobal("TradePlayerItem" .. i .. "ItemButton")
		if s and s.bc then s.bc:Hide() end
		local r = getglobal("TradeRecipientItem" .. i .. "ItemButton")
		if r and r.bc then r.bc:Hide() end
	end
end

oGlow.updateTrade = update
oGlow.clearTrade  = clearTrade
oGlow:RegisterRefresh(function()
	if oGlow.preventTrade then return end
	if TradeFrame and TradeFrame:IsShown() then update() end
end)

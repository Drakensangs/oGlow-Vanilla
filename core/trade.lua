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
		update()
	elseif event == "TRADE_PLAYER_ITEM_CHANGED" then
		local slot = getglobal("TradePlayerItem" .. arg1 .. "ItemButton")
		if slot then
			setQuality(slot, GetTradePlayerItemLink(arg1))
		end
	elseif event == "TRADE_TARGET_ITEM_CHANGED" then
		local slot = getglobal("TradeRecipientItem" .. arg1 .. "ItemButton")
		if slot then
			setQuality(slot, GetTradeTargetItemLink(arg1))
		end
	end
end)
hook:RegisterEvent("TRADE_SHOW")
hook:RegisterEvent("TRADE_UPDATE")
hook:RegisterEvent("TRADE_PLAYER_ITEM_CHANGED")
hook:RegisterEvent("TRADE_TARGET_ITEM_CHANGED")

oGlow.updateTrade = update

-- Globally used
local G = getfenv(0)
local oGlow = oGlow

-- Merchant
local GetMerchantItemLink = GetMerchantItemLink

local numPage = MERCHANT_ITEMS_PER_PAGE
local BUYBACK_ITEMS_PER_PAGE = 12

local scanner = CreateFrame("GameTooltip", "oGlowMerchantScanner", UIParent, "GameTooltipTemplate")
scanner:Hide()

-- Resolve tooltip text-line references once at load time to avoid getglobal
-- calls on every scan.
local scannerLines = {}
for i = 1, 30 do
	local line = getglobal("oGlowMerchantScannerTextLeft" .. i)
	if line then
		scannerLines[i] = line
	else
		break
	end
end

local colorToQuality = {
	["157157157"] = 0,  
	["255255255"] = 1,  
	["030255000"] = 2,  
	["000112221"] = 3,  
	["163053238"] = 4,  
	["255128000"] = 5,  
	["230204128"] = 6,  
}

local function getBuybackQuality(index)
	scanner:SetOwner(UIParent, "ANCHOR_NONE")
	scanner:ClearLines()
	scanner:SetBuybackItem(index)
	local q
	local fs = scannerLines[1]
	if fs then
		local r, g, b = fs:GetTextColor()
		if r and g and b then
			local key = string.format("%03d%03d%03d",
				math.floor(r * 255 + 0.5),
				math.floor(g * 255 + 0.5),
				math.floor(b * 255 + 0.5))
			q = colorToQuality[key]
		end
	end
	scanner:Hide()
	return q
end

local function clearAll()
	for i = 1, BUYBACK_ITEMS_PER_PAGE do
		local button = getglobal("MerchantItem" .. i .. "ItemButton")
		if button and button.bc then
			button.bc:Hide()
		end
	end
	local bbButton = getglobal("MerchantBuyBackItemItemButton")
	if bbButton and bbButton.bc then
		bbButton.bc:Hide()
	end
end

local function update()
	-- Always reset first to prevent bleed when switching between tabs.
	-- Without this, borders set for merchant items on tab 1 remain visible
	-- on the same buttons when tab 2 (buyback) is shown, and vice versa.
	clearAll()

	if MerchantFrame.selectedTab == 1 then
		-- Main merchant tab: color the merchant item grid.
		for i = 1, numPage do
			local index = ((MerchantFrame.page - 1) * numPage) + i
			local link = GetMerchantItemLink(index)
			local button = getglobal("MerchantItem" .. i .. "ItemButton")
			if button and link then
				oGlow(button, getQuality(link))
			end
		end

		local bbButton = getglobal("MerchantBuyBackItemItemButton")
		if bbButton then
			local bbIndex = GetNumBuybackItems()
			if bbIndex > 0 then
				local bbName = GetBuybackItemInfo(bbIndex)
				if bbName then
					local q = getBuybackQuality(bbIndex)
					if q then
						oGlow(bbButton, q)
					end
				end
			end
		end
	else
		local numBuyback = GetNumBuybackItems()
		for i = 1, BUYBACK_ITEMS_PER_PAGE do
			local button = getglobal("MerchantItem" .. i .. "ItemButton")
			if button then
				if i <= numBuyback then
					local q = getBuybackQuality(i)
					if q then
						oGlow(button, q)
					end
				end
			end
		end
	end
end

local origMerchantFrame_Update = MerchantFrame_Update
MerchantFrame_Update = function()
	origMerchantFrame_Update()
	update()
end

local hook = CreateFrame("Frame")
hook:SetParent(MerchantFrame)
hook:SetScript("OnHide", clearAll)
hook:SetScript("OnEvent", function()
	if event == "MERCHANT_SHOW" then
		update()
	end
end)
hook:RegisterEvent("MERCHANT_SHOW")

oGlow.updateMerchant = update

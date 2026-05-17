-- Globally used
local G = getfenv(0)
local oGlow = oGlow

-- Bank
local GetContainerItemLink = GetContainerItemLink

local function update()
	for i = 1, NUM_BANKGENERIC_SLOTS do
		local slot = getglobal("BankFrameItem" .. i)
		if slot then
			local link = GetContainerItemLink(-1, i)
			if link then
				oGlow(slot, getQuality(link))
			elseif slot.bc then
				slot.bc:Hide()
			end
		end
	end
end

local hook = CreateFrame("Frame")
hook:SetParent("BankFrame")
hook:SetScript("OnShow", function() if not oGlow.preventBank then update() end end)
hook:SetScript("OnEvent", function()
	if event == "PLAYERBANKSLOTS_CHANGED" and not oGlow.preventBank then
		update()
	end
end)
hook:RegisterEvent("PLAYERBANKSLOTS_CHANGED")

local function clearBank()
	for i = 1, NUM_BANKGENERIC_SLOTS do
		local slot = getglobal("BankFrameItem" .. i)
		if slot and slot.bc then slot.bc:Hide() end
	end
end

oGlow.updateBank = update
oGlow.clearBank  = clearBank
oGlow:RegisterRefresh(function()
	if oGlow.preventBank then return end
	local bf = getglobal("BankFrame")
	if bf and bf:IsShown() then update() end
end)

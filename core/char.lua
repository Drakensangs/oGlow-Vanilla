-- Globally used
local G = getfenv(0)
local pairs = pairs
local oGlow = oGlow

-- Addon
local GetInventoryItemQuality = GetInventoryItemQuality
local CharacterFrame = CharacterFrame

local items = {
	[0] = "Ammo",
	"Head 1",
	"Neck",
	"Shoulder 2",
	"Shirt",
	"Chest 3",
	"Waist 4",
	"Legs 5",
	"Feet 6",
	"Wrist 7",
	"Hands 8",
	"Finger0",
	"Finger1",
	"Trinket0",
	"Trinket1",
	"Back",
	"MainHand 9",
	"SecondaryHand 10",
	"Ranged 11",
	"Tabard",
}

local q, key, self
local update = function()
	if(not CharacterFrame:IsShown()) then return end
	for i, value in pairs(items) do
		--key, index = string.split(" ", value)

		index = "";
		_, _, key, index = string.find(value, "(.*) (.*)")
		if (not key) then
			key = value;
		end

		--DEFAULT_CHAT_FRAME:AddMessage(key);
		q = GetInventoryItemQuality("player", i)
		--DEFAULT_CHAT_FRAME:AddMessage(q);
		self = getglobal("Character"..key.."Slot")
		if(GetInventoryItemBroken("player", i)) then
			q = 100
		elseif(index and GetInventoryAlertStatus(index) == 3) then
			q = 99
		end

		oGlow(self, q)
	end
end

local hook = CreateFrame"Frame"
hook:SetParent"CharacterFrame"
hook:SetScript("OnShow", function() if not oGlow.preventCharacter then update() end end)
hook:SetScript("OnEvent", function() if(event == "UNIT_INVENTORY_CHANGED") and not oGlow.preventCharacter then update() end end)
hook:RegisterEvent"UNIT_INVENTORY_CHANGED"

local function clearCharacter()
	local slots = {
		"AmmoSlot","HeadSlot","NeckSlot","ShoulderSlot","ShirtSlot","ChestSlot",
		"WaistSlot","LegsSlot","FeetSlot","WristSlot","HandsSlot",
		"Finger0Slot","Finger1Slot","Trinket0Slot","Trinket1Slot","BackSlot",
		"MainHandSlot","SecondaryHandSlot","RangedSlot","TabardSlot",
	}
	for _, name in pairs(slots) do
		local s = getglobal("Character" .. name)
		if s and s.bc then s.bc:Hide() end
	end
end

oGlow.updateCharacter = update
oGlow.clearCharacter  = clearCharacter
oGlow:RegisterRefresh(function()
	if oGlow.preventCharacter then return end
	if CharacterFrame:IsShown() then update() end
end)

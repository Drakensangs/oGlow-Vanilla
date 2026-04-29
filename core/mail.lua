local _G = getfenv(0)
local oGlow = oGlow

local colorToQuality = {
	["157157157"] = 0,  -- Poor:      9d9d9d
	["255255255"] = 1,  -- Common:    ffffff
	["030255000"] = 2,  -- Uncommon:  1eff00
	["000112221"] = 3,  -- Rare:      0070dd
	["163053238"] = 4,  -- Epic:      a335ee
	["255128000"] = 5,  -- Legendary: ff8000
	["230204128"] = 6,  -- Artifact:  e6cc80
}

local scanner = CreateFrame("GameTooltip", "oGlowMailScanner", UIParent, "GameTooltipTemplate")
scanner:Hide()

-- Resolve tooltip text-line references once at load time, mirroring the
-- technique used by RecipeColor, so we never call getglobal in the hot path.
local scannerLines = {}
for i = 1, 30 do
	local line = getglobal("oGlowMailScannerTextLeft" .. i)
	if line then
		scannerLines[i] = line
	else
		break
	end
end

-- Returns the item quality (0-5) for the given inbox mail index, or nil if
-- the mail has no item or the quality cannot be determined.
local function getInboxItemQuality(mailIndex)
	scanner:SetOwner(UIParent, "ANCHOR_NONE")
	scanner:ClearLines()
	scanner:SetInboxItem(mailIndex, 1)

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
	for i = 1, 7 do
		local button = _G["MailItem"..i.."Button"]
		if button and button.bc then button.bc:Hide() end
	end
	local ob = _G["OpenMailPackageButton"]
	if ob and ob.bc then ob.bc:Hide() end
end

-- Updates the rarity border for all visible inbox slots on the current page,
-- plus the open-mail attachment button if a mail is open.
local function updateMail()
	if GetInboxNumItems() == 0 then
		clearAll()
		return
	end

	local pageStart = ((InboxFrame.pageNum - 1) * 7) + 1

	for i = 1, 7 do
		local mailItem = _G["MailItem" .. i]
		if mailItem then
			mailItem:Hide()
			mailItem:Show()
		end
	end

	for i = 1, 7 do
		local mailIndex = pageStart + i - 1
		local button = _G["MailItem"..i.."Button"]
		-- Always hide the border first; prevents bleed when a slot that had
		-- a coloured border on a previous page is reused for a plain mail.
		if button and button.bc then button.bc:Hide() end
		local q = getInboxItemQuality(mailIndex)
		if q and button then
			oGlow(button, q)
		end
	end

	if InboxFrame.openMailID then
		local button = _G["OpenMailPackageButton"]
		local q = getInboxItemQuality(InboxFrame.openMailID)
		if q then
			oGlow(button, q)
		elseif button and button.bc then
			button.bc:Hide()
		end
	end
end

-- Hook InboxFrame_Update so updateMail runs *after* Blizzard has finished
-- laying out the inbox slots.  Events like MAIL_INBOX_UPDATE fire before
-- InboxFrame_Update completes, so registering events alone is not sufficient
-- (and misses page turns entirely, which do not fire any event in 1.12.1).
local origInboxFrame_Update = InboxFrame_Update
InboxFrame_Update = function()
	origInboxFrame_Update()
	updateMail()
end

-- Handle MAIL_CLOSED to clear borders when the mailbox is dismissed.
local addon = CreateFrame("Frame")
addon:RegisterEvent("MAIL_CLOSED")
addon:SetScript("OnEvent", function()
	if event == "MAIL_CLOSED" then
		clearAll()
	end
end)

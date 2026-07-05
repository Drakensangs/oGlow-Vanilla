-- oGlow options
-- /oglow – toggle the options window
-- SavedVariables: oGlowDB

local PIPES = {
	{ key = "Character",  label = "Character frame"  },
	{ key = "Inspect",    label = "Inspect frame"    },
	{ key = "Bags",       label = "Bag frames"       },
	{ key = "Bank",       label = "Bank frame"       },
	{ key = "Keyring",    label = "Keyring frame"    },
	{ key = "Merchant",   label = "Merchant frame"   },
	{ key = "Trade",      label = "Trade frame"      },
	{ key = "Tradeskill", label = "Tradeskill frame" },
	{ key = "Craft",      label = "Craft frame"      },
	{ key = "Loot",       label = "Loot frame"       },
	{ key = "Mail",       label = "Mail frame"       },
}

-- Quality IDs and labels for the color section and dropdown.
-- Threshold dropdown entries: selecting quality X means show X and above,
local QUALITY_IDS = {0, 1, 2, 3, 4, 5, 6}
local QUALITY_LABELS = {
	[0] = "Poor",
	[1] = "Common",
	[2] = "Uncommon",
	[3] = "Rare",
	[4] = "Epic",
	[5] = "Legendary",
	[6] = "Artifact",
}

-- SavedVariables
local function defaultDB()
	return { version = 1, DisabledPipes = {}, Colors = {}, threshold = 1 }
end

local function applySavedColors()
	for k, v in pairs(oGlowDB.Colors) do
		local id = tonumber(k)
		if id and v[1] and v[2] and v[3] then
			oGlow:RegisterColor(id, v[1], v[2], v[3])
		end
	end
end

local function applySavedPipes()
	for _, p in ipairs(PIPES) do
		if oGlowDB.DisabledPipes[p.key] then
			oGlow["prevent" .. p.key] = true
		end
	end
end

local function applySavedThreshold()
	if type(oGlowDB.threshold) == "number" then
		oGlow:SetThreshold(oGlowDB.threshold)
	end
end

-- Layout
local MENU_W  = 340
local ROW_H   = 24
local PAD     = 16

-- Menu frame
local menuFrame = CreateFrame("Frame", "oGlowOptionsFrame", UIParent)
menuFrame:SetFrameStrata("DIALOG")
menuFrame:SetWidth(MENU_W)
menuFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 60)
menuFrame:SetMovable(true)
menuFrame:EnableMouse(true)
menuFrame:RegisterForDrag("LeftButton")
menuFrame:SetScript("OnDragStart", function() this:StartMoving() end)
menuFrame:SetScript("OnDragStop",  function() this:StopMovingOrSizing() end)
menuFrame:Hide()

menuFrame:SetBackdrop({
	bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true, tileSize = 16, edgeSize = 16,
	insets = {left = 4, right = 4, top = 4, bottom = 4},
})
menuFrame:SetBackdropColor(0.06, 0.06, 0.06, 0.94)
menuFrame:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)

tinsert(UISpecialFrames, "oGlowOptionsFrame")

-- Title bar
local titleText = menuFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
titleText:SetPoint("TOP", menuFrame, "TOP", 0, -PAD)
titleText:SetText("|cff33ff99oGlow|r Options")

local closeBtn = CreateFrame("Button", nil, menuFrame, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", menuFrame, "TOPRIGHT", -2, -2)
closeBtn:SetScript("OnClick", function() menuFrame:Hide() end)

-- Helpers
local curY = -(PAD + 26)

local function makeHeader(text)
	local fs = menuFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	fs:SetPoint("TOP", menuFrame, "TOP", 0, curY)
	fs:SetText("|cffffcc00" .. text .. "|r")
	curY = curY - 18
	return fs
end

-- Frame toggles
makeHeader("Frame Borders")

local checkboxes = {}

for i = 1, table.getn(PIPES) do
	local pKey   = PIPES[i].key
	local pLabel = PIPES[i].label
	local col    = math.mod(i - 1, 2)
	local row    = math.floor((i - 1) / 2)
	local yOff = curY - row * ROW_H

	local cb = CreateFrame("CheckButton", "oGlowOpt_CB_" .. pKey, menuFrame)
	cb:SetWidth(16)
	cb:SetHeight(16)
	if col == 0 then
		cb:SetPoint("TOPLEFT", menuFrame, "TOPLEFT", PAD + 30, yOff)
	else
		cb:SetPoint("TOPRIGHT", menuFrame, "TOPRIGHT", -(MENU_W / 3) - 20, yOff)
	end
	cb:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
	cb:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
	cb:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight")
	cb:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")

	cb:SetScript("OnClick", function()
		local enabled = this:GetChecked()
		if enabled then
			oGlow["prevent" .. pKey] = nil
			oGlowDB.DisabledPipes[pKey] = nil
			local fn = oGlow["update" .. pKey]
			if fn then fn() end
		else
			oGlow["prevent" .. pKey] = true
			oGlowDB.DisabledPipes[pKey] = true
			local fn = oGlow["clear" .. pKey]
			if fn then fn() end
		end
	end)

	local lbl = menuFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	lbl:SetPoint("LEFT", cb, "RIGHT", 4, 0)
	lbl:SetText(pLabel)

	checkboxes[pKey] = cb
end

local numToggleRows = math.ceil(table.getn(PIPES) / 2)
curY = curY - numToggleRows * ROW_H - 8

-- Quality threshold
curY = curY - 8
makeHeader("Show borders from quality:")

local threshDropdown = CreateFrame("Button", "oGlowThreshDropdown", menuFrame,
                                   "UIDropDownMenuTemplate")
threshDropdown:SetPoint("TOPLEFT", menuFrame, "TOPLEFT", 87, curY + 4)

local function threshDropdown_OnClick()
	local newThreshold = this.value - 1
	oGlow:SetThreshold(newThreshold)
	oGlowDB.threshold = newThreshold
	UIDropDownMenu_SetSelectedID(threshDropdown, this:GetID())
end

local function threshDropdown_Init()
	for i = 1, table.getn(QUALITY_IDS) do
		local qid   = QUALITY_IDS[i]
		local qlbl  = QUALITY_LABELS[qid]
		local r, g, b = oGlow.getColor(qid)
		r, g, b = r or 1, g or 1, b or 1
		local hex = string.format("%02x%02x%02x",
			math.floor(r * 255), math.floor(g * 255), math.floor(b * 255))
		local info    = {}
		info.text  = "|cff" .. hex .. qlbl .. "|r"
		info.value = qid
		info.func  = threshDropdown_OnClick
		UIDropDownMenu_AddButton(info)
	end
end

local function refreshThresholdDropdown()
	UIDropDownMenu_Initialize(threshDropdown, threshDropdown_Init)
	UIDropDownMenu_SetSelectedID(threshDropdown, oGlow:GetThreshold() + 2)
end

curY = curY - 32

-- Quality color overrides
curY = curY - 8
makeHeader("Quality Colors")

local colorRows = {}
local openColorPicker

for i = 1, table.getn(QUALITY_IDS) do
	local qid  = QUALITY_IDS[i]
	local col  = math.mod(i - 1, 2)
	local row  = math.floor((i - 1) / 2)
	local yOff = curY - row * ROW_H

	local swatch = CreateFrame("Button", nil, menuFrame)
	swatch:SetWidth(16)
	swatch:SetHeight(16)
	if col == 0 then
		swatch:SetPoint("TOPLEFT", menuFrame, "TOPLEFT", PAD + 34, yOff)
	else
		swatch:SetPoint("TOPRIGHT", menuFrame, "TOPRIGHT", -(MENU_W / 3) - 20, yOff)
	end

	local swatchBg = swatch:CreateTexture(nil, "BACKGROUND")
	swatchBg:SetAllPoints(swatch)
	swatchBg:SetTexture(0.15, 0.15, 0.15)

	local swatchTex = swatch:CreateTexture(nil, "ARTWORK")
	swatchTex:SetWidth(14)
	swatchTex:SetHeight(14)
	swatchTex:SetPoint("CENTER", swatch, "CENTER", 0, 0)
	swatchTex:SetTexture("Interface\\ChatFrame\\ChatFrameColorSwatch")
	swatch:SetNormalTexture(swatchTex)

	local lbl = menuFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	lbl:SetPoint("LEFT", swatch, "RIGHT", 4, 0)

	local resetBtn = CreateFrame("Button", nil, menuFrame)
	resetBtn:SetWidth(14)
	resetBtn:SetHeight(14)
	resetBtn:SetPoint("LEFT", lbl, "RIGHT", 4, 0)
	resetBtn:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
	resetBtn:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
	resetBtn:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")

	local swatchRef = swatch
	local lblRef    = lbl

	swatch:SetScript("OnClick", function() openColorPicker(qid, swatchRef, lblRef) end)

	resetBtn:SetScript("OnClick", function()
		oGlowDB.Colors[tostring(qid)] = nil
		oGlow:ResetColor(qid)
		oGlow:RefreshAll()
		local r, g, b = oGlow.getColor(qid)
		if r then
			swatchRef:GetNormalTexture():SetVertexColor(r, g, b)
			lblRef:SetTextColor(r, g, b)
		end
	end)
	resetBtn:SetScript("OnEnter", function()
		GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
		GameTooltip:SetText("Reset to default")
		GameTooltip:Show()
	end)
	resetBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

	colorRows[qid] = { swatch = swatchRef, label = lblRef }
end

local numColorRows = math.ceil(table.getn(QUALITY_IDS) / 2)
curY = curY - numColorRows * ROW_H - PAD

menuFrame:SetHeight(math.abs(curY) + PAD)

-- Colour picker
local colorPickerContext = {}

local function refreshSwatchDisplay(qid, swatchBtn, lblFs)
	local r, g, b = oGlow.getColor(qid)
	if r then
		swatchBtn:GetNormalTexture():SetVertexColor(r, g, b)
		lblFs:SetTextColor(r, g, b)
	end
end

local function onColorPickerOk()
	local r, g, b = ColorPickerFrame:GetColorRGB()
	local qid = colorPickerContext.quality
	oGlow:RegisterColor(qid, r, g, b)
	oGlowDB.Colors[tostring(qid)] = {r, g, b}
	oGlow:RefreshAll()
	refreshSwatchDisplay(qid, colorPickerContext.swatch, colorPickerContext.label)
	ColorPickerFrame:SetFrameStrata("FULLSCREEN_DIALOG")
end

local function onColorPickerCancel()
	local qid  = colorPickerContext.quality
	local prev = colorPickerContext.previousColor
	if prev then
		oGlow:RegisterColor(qid, prev[1], prev[2], prev[3])
		oGlowDB.Colors[tostring(qid)] = {prev[1], prev[2], prev[3]}
	else
		oGlowDB.Colors[tostring(qid)] = nil
		oGlow:ResetColor(qid)
	end
	oGlow:RefreshAll()
	refreshSwatchDisplay(qid, colorPickerContext.swatch, colorPickerContext.label)
	ColorPickerFrame:SetFrameStrata("FULLSCREEN_DIALOG")
end

openColorPicker = function(qid, swatchBtn, lblFs)
	local r, g, b = oGlow.getColor(qid)
	r, g, b = r or 1, g or 1, b or 1

	colorPickerContext.quality       = qid
	colorPickerContext.swatch        = swatchBtn
	colorPickerContext.label         = lblFs
	colorPickerContext.previousColor = {r, g, b}

	ColorPickerFrame.func        = onColorPickerOk
	ColorPickerFrame.cancelFunc  = onColorPickerCancel
	ColorPickerFrame.opacityFunc = nil

	ColorPickerFrame:SetFrameStrata("TOOLTIP")
	ColorPickerFrame:SetColorRGB(r, g, b)
	ShowUIPanel(ColorPickerFrame)
end

local function refreshCheckboxes()
	for pKey, cb in pairs(checkboxes) do
		cb:SetChecked(not oGlow["prevent" .. pKey])
	end
end

local function refreshColorSwatches()
	for qid, row in pairs(colorRows) do
		local r, g, b = oGlow.getColor(qid)
		r, g, b = r or 1, g or 1, b or 1
		row.swatch:GetNormalTexture():SetVertexColor(r, g, b)
		row.label:SetText(QUALITY_LABELS[qid] or tostring(qid))
		row.label:SetTextColor(r, g, b)
	end
end

menuFrame:SetScript("OnShow", function()
	refreshCheckboxes()
	refreshColorSwatches()
	refreshThresholdDropdown()
end)

SLASH_OGLOW1 = "/oglow"
SlashCmdList["OGLOW"] = function()
	if menuFrame:IsShown() then
		menuFrame:Hide()
	else
		menuFrame:Show()
	end
end

local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("VARIABLES_LOADED")
initFrame:SetScript("OnEvent", function()
	if event == "VARIABLES_LOADED" then
		if type(oGlowDB) ~= "table" then
			oGlowDB = defaultDB()
		else
			if not oGlowDB.DisabledPipes then oGlowDB.DisabledPipes = {} end
			if not oGlowDB.Colors        then oGlowDB.Colors        = {} end
			if oGlowDB.threshold == nil  then oGlowDB.threshold = 1   end
		end
		applySavedColors()
		applySavedThreshold()
		applySavedPipes()
	end
end)
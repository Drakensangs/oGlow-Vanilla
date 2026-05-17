local type = type

local colorTable = {}

local colorDefaults = {
	[100] = {0.9, 0,   0  },
	[99]  = {1,   1,   0  },
	[6]   = {0.9, 0.8, 0.502},
}

local function getColor(val)
	local c = colorTable[val]
	if c then
		return c[1], c[2], c[3]
	end
	local d = colorDefaults[val]
	if d then
		return d[1], d[2], d[3]
	end
	if type(val) == "number" then
		return GetItemQualityColor(val)
	end
end

-- Minimum quality threshold: borders are only shown for quality > threshold.
-- Default 1 means Common (1) is suppressed, Uncommon (2) and above are shown.
local qualityThreshold = 1

local function createBorder(self, point)
	local bc = self:CreateTexture(nil, "OVERLAY")
	bc:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
	bc:SetBlendMode("ADD")
	bc:SetAlpha(0.8)
	bc:SetWidth(70)
	bc:SetHeight(70)
	bc:SetPoint("CENTER", point or self)
	self.bc = bc
end

local refreshCallbacks = {}

local border, r, g, b
oGlow = setmetatable({
	RegisterColor = function(self, key, r, g, b)
		colorTable[key] = {r, g, b}
	end,

	ResetColor = function(self, key)
		colorTable[key] = nil
		return getColor(key)
	end,

	RegisterRefresh = function(self, fn)
		refreshCallbacks[table.getn(refreshCallbacks) + 1] = fn
	end,

	RefreshAll = function(self)
		for i = 1, table.getn(refreshCallbacks) do
			refreshCallbacks[i]()
		end
	end,

	SetThreshold = function(self, val)
		qualityThreshold = val
		self:RefreshAll()
	end,

	GetThreshold = function(self)
		return qualityThreshold
	end,
}, {
	__call = function(self, frame, quality, point)
		if not frame then return end
		local show = false
		if type(quality) == "number" then
			if quality >= 99 or quality > qualityThreshold then
				show = true
			end
		elseif type(quality) == "string" then
			show = true
		end

		if show then
			if not frame.bc then createBorder(frame, point) end
			border = frame.bc
			if border then
				r, g, b = getColor(quality)
				if r then
					border:SetVertexColor(r, g, b)
					border:Show()
				end
			end
		elseif frame.bc then
			frame.bc:Hide()
		end
	end,
})

function getQuality(link)
	if not link then return end
	local _, _, qColor = string.find(link, "|cff(%x*)|")
	if     qColor == "9d9d9d" then return 0
	elseif qColor == "ffffff" then return 1
	elseif qColor == "1eff00" then return 2
	elseif qColor == "0070dd" then return 3
	elseif qColor == "a335ee" then return 4
	elseif qColor == "ff8000" then return 5
	elseif qColor == "e6cc80" then return 6
	end
end

function oGlowPrint(text)
	if not text then return end
	DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99oGlow:|r " .. tostring(text))
end

-- Expose internals for options.lua.
oGlow.colorTable    = colorTable
oGlow.colorDefaults = colorDefaults
oGlow.getColor      = getColor

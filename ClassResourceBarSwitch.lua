local addOnName = ...

local data = {
	{ 2,  Enum.PowerType.HolyPower,     PaladinPowerBarFrame,    ClassNameplateBarPaladinFrame },
	{ 4,  Enum.PowerType.ComboPoints,   RogueComboPointBarFrame, ClassNameplateBarRogueFrame },
	{ 6,  Enum.PowerType.Runes,         RuneFrame,               DeathKnightResourceOverlayFrame },
	{ 8,  Enum.PowerType.ArcaneCharges, MageArcaneChargesFrame,  ClassNameplateBarMageFrame },
	{ 9,  Enum.PowerType.SoulShards,    WarlockPowerFrame,       ClassNameplateBarWarlockFrame },
	{ 10, Enum.PowerType.Chi,           MonkHarmonyBarFrame,     ClassNameplateBarWindwalkerMonkFrame },
	{ 11, Enum.PowerType.ComboPoints,   DruidComboPointBarFrame, ClassNameplateBarFeralDruidFrame },
	{ 13, Enum.PowerType.Essence,       EssencePlayerFrame,      ClassNameplateBarDracthyrFrame },
}

local function makeDBKey(d)
	local class, powerType = unpack(d)
	return class .. "-" .. powerType
end

local showOptions = {
	unitFrameBar = 1,
	nameplateBar = 2,
	both         = 3,
	none         = 4,
}

local db

local function prepare()
	for _, f in ipairs { RuneFrame, DeathKnightResourceOverlayFrame } do
		f.SetTooltip = ClassPowerBar.SetTooltip
		f.tooltip1 = f.tooltipTitle
		f.tooltip2 = f.tooltip
	end
end

local function setup()
	if not db then return end

	for _, d in ipairs(data) do
		local _, _, unitFrameBar, nameplateBar = unpack(d)
		local show = db[makeDBKey(d)].show

		if show == showOptions.unitFrameBar or show == showOptions.both then
			unitFrameBar.showTooltip = true
			unitFrameBar:SetTooltip(unitFrameBar.tooltip1, unitFrameBar.tooltip2)
			unitFrameBar:SetAlpha(1)
		else
			unitFrameBar.showTooltip = false
			unitFrameBar:SetTooltip(nil, nil)
			unitFrameBar:SetAlpha(0)
		end

		if show == showOptions.nameplateBar or show == showOptions.both then
			nameplateBar:SetAlpha(1)
		else
			nameplateBar:SetAlpha(0)
		end
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(_, event, ...)
	if event == "ADDON_LOADED" and addOnName == ... then
		f:UnregisterEvent("ADDON_LOADED")

		ClassResourceBarSwitchDB = ClassResourceBarSwitchDB or {}
		db = ClassResourceBarSwitchDB

		prepare()

		local category = Settings.RegisterVerticalLayoutCategory(addOnName)

		for _, d in ipairs(data) do
			local k = makeDBKey(d)

			db[k] = db[k] or {}

			local class, _, unitFrameBar = unpack(d)

			local variable = addOnName .. "_" .. k
			local setting = Settings.RegisterAddOnSetting(
				category, variable, "show", db[k], Settings.VarType.Number,
				GetClassInfo(class) .. " - " .. unitFrameBar.tooltip1,
				showOptions.both)
			setting:SetValueChangedCallback(setup)

			local function getOptions()
				local options = Settings.CreateControlTextContainer()
				options:Add(showOptions.unitFrameBar, "Unit Frame Bar")
				options:Add(showOptions.nameplateBar, "Nameplate Bar")
				options:Add(showOptions.both, "Both")
				options:Add(showOptions.none, "None")
				return options:GetData()
			end

			Settings.CreateDropdown(category, setting, getOptions, unitFrameBar.tooltip2)
		end

		Settings.RegisterAddOnCategory(category)

		setup()
	end
end)

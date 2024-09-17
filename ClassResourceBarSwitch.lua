local addOnName = ...

local data = {
	{ 2,  Enum.PowerType.HolyPower,     PaladinPowerBarFrame,    ClassNameplateBarPaladinFrame },
	{ 4,  Enum.PowerType.ComboPoints,   RogueComboPointBarFrame, ClassNameplateBarRogueFrame },
	{ 8,  Enum.PowerType.ArcaneCharges, MageArcaneChargesFrame,  ClassNameplateBarMageFrame },
	{ 9,  Enum.PowerType.SoulShards,    WarlockPowerFrame,       ClassNameplateBarWarlockFrame },
	{ 10, Enum.PowerType.Chi,           MonkHarmonyBarFrame,     ClassNameplateBarWindwalkerMonkFrame },
	{ 11, Enum.PowerType.ComboPoints,   DruidComboPointBarFrame, ClassNameplateBarFeralDruidFrame },
	{ 13, Enum.PowerType.Essence,       EssencePlayerFrame,      ClassNameplateBarDracthyrFrame },
}

for _, d in ipairs(data) do
	local _, _, unitFrameBar, nameplateBar = unpack(d)
	table.insert(d, unitFrameBar.shouldShowBarFunc)
	table.insert(d, nameplateBar.shouldShowBarFunc)
end

local showOptions = {
	unitFrameBar = 1,
	nameplateBar = 2,
	both = 3,
	none = 4,
}

local db

local function makeDBKey(d)
	return d[1] .. "-" .. d[2]
end

local function alwaysFalse()
	return false
end

local function setup()
	if not db then return end

	for _, d in ipairs(data) do
		local _, _, unitFrameBar, namePlateBar, unitFrameBarFunc, namePlateBarFunc = unpack(d)
		local show = db[makeDBKey(d)].show

		if show == showOptions.unitFrameBar or show == showOptions.both then
			unitFrameBar.shouldShowBarFunc = unitFrameBarFunc
		else
			unitFrameBar.shouldShowBarFunc = alwaysFalse
		end

		if show == showOptions.nameplateBar or show == showOptions.both then
			namePlateBar.shouldShowBarFunc = namePlateBarFunc
		else
			namePlateBar.shouldShowBarFunc = alwaysFalse
		end

		unitFrameBar:Setup()
		namePlateBar:Setup()
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function(_, event, ...)
	if event == "ADDON_LOADED" and addOnName == ... then
		f:UnregisterEvent("ADDON_LOADED")

		ClassResourceBarSwitchDB = ClassResourceBarSwitchDB or {}
		db = ClassResourceBarSwitchDB

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
	end

	if event == "PLAYER_ENTERING_WORLD" then
		f:UnregisterEvent("PLAYER_ENTERING_WORLD")
		setup()
	end
end)

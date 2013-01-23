-------------------------------------------------------------------------------
-- Prototype
--

local AL = LibStub("AceLocale-3.0")
local L = AL:GetLocale("Big Wigs: Common")
local UnitExists = UnitExists
local UnitAffectingCombat = UnitAffectingCombat
local GetSpellInfo = GetSpellInfo
local format = string.format
local type = type
local core = BigWigs
local C = core.C
local pName = UnitName("player")
local bossUtilityFrame = CreateFrame("Frame")
local enabledModules = {}
local allowedEvents = {}
local difficulty = 3
local UpdateDispelStatus = nil

-------------------------------------------------------------------------------
-- Debug
--

local debug = false -- Set to true to get (very spammy) debug messages.
local dbg = function(self, msg) print(format("[DBG:%s] %s", self.displayName, msg)) end

-------------------------------------------------------------------------------
-- Metatables
--

local metaMap = {__index = function(self, key) self[key] = {} return self[key] end}
local eventMap = setmetatable({}, metaMap)
local unitEventMap = setmetatable({}, metaMap)
local icons = setmetatable({}, {__index =
	function(self, key)
		local _, value
		if type(key) == "number" then
			_, _, value = GetSpellInfo(key)
			if not value then
				print(format("Big Wigs: An invalid spell id (%d) is being used in a bar/message.", key))
			end
		else
			value = "Interface\\Icons\\" .. key
		end
		self[key] = value
		return self[key]
	end
})
local spells = setmetatable({}, {__index =
	function(self, key)
		local value = GetSpellInfo(key)
		self[key] = value
		return self[key]
	end
})

-------------------------------------------------------------------------------
-- Core module functionality
--

local boss = {}
core.bossCore:SetDefaultModulePrototype(boss)
function boss:IsBossModule() return true end
function boss:OnInitialize() core:RegisterBossModule(self) end
function boss:OnEnable()
	if debug then dbg(self, "OnEnable()") end
	if self.SetupOptions then self:SetupOptions() end
	if type(self.OnBossEnable) == "function" then self:OnBossEnable() end

	-- Update Difficulty
	local _, _, diff = GetInstanceInfo()
	difficulty = diff

	-- Update Dispel Status
	UpdateDispelStatus()

	-- Update enabled modules list
	for i = #enabledModules, 1, -1 do
		local module = enabledModules[i]
		if module == self then return end
	end
	enabledModules[#enabledModules+1] = self

	self:SendMessage("BigWigs_OnBossEnable", self)
end
function boss:OnDisable()
	if debug then dbg(self, "OnDisable()") end
	if type(self.OnBossDisable) == "function" then self:OnBossDisable() end

	-- Update enabled modules list
	for i = #enabledModules, 1, -1 do
		if self == enabledModules[i] then
			tremove(enabledModules, i)
		end
	end

	-- No enabled modules? Unregister the combat log!
	if #enabledModules == 0 then
		bossUtilityFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	end

	-- Unregister the Unit Events for this module
	for a, b in pairs(unitEventMap[self]) do
		for k in pairs(b) do
			self:UnregisterUnitEvent(a, k)
		end
	end

	-- Empty the event maps for this module
	eventMap[self] = nil
	unitEventMap[self] = nil
	wipe(allowedEvents)

	-- Re-add allowed events if more than one module is enabled
	for a, b in pairs(eventMap) do
		for k in pairs(b) do
			allowedEvents[k] = true
		end
	end

	self.isEngaged = nil
	self:SendMessage("BigWigs_OnBossDisable", self)
end
function boss:GetOption(spellId)
	return self.db.profile[spells[spellId]]
end
function boss:Reboot()
	if debug then dbg(self, ":Reboot()") end
	self:SendMessage("BigWigs_OnBossReboot", self)
	self:Disable()
	self:Enable()
end

function boss:NewLocale(locale, default) return AL:NewLocale(self.name, locale, default, "raw") end
function boss:GetLocale(state) return AL:GetLocale(self.name, state) end

-------------------------------------------------------------------------------
-- Enable triggers
--

function boss:RegisterEnableMob(...) core:RegisterEnableMob(self, ...) end
function boss:RegisterEnableYell(...) core:RegisterEnableYell(self, ...) end

-------------------------------------------------------------------------------
-- Combat log related code
--

do
	local modMissingFunction = "Module %q got the event %q (%d), but it doesn't know how to handle it."
	local missingArgument = "Missing required argument when adding a listener to %q."
	local missingFunction = "%q tried to register a listener to method %q, but it doesn't exist in the module."
	local invalidId = "Module %q tried to register an invalid spell id (%d) to event %q."

	function boss:CHAT_MSG_RAID_BOSS_EMOTE(event, msg, ...)
		if eventMap[self][event][msg] then
			self[eventMap[self][event][msg]](self, msg, ...)
		else
			for emote, func in pairs(eventMap[self][event]) do
				if msg:find(emote, nil, true) or msg:find(emote) then -- Preserve backwards compat by leaving in the 2nd check
					self[func](self, msg, ...)
				end
			end
		end
	end
	function boss:Emote(func, ...)
		if not func then error(format(missingArgument, self.moduleName)) end
		if not self[func] then error(format(missingFunction, self.moduleName, func)) end
		if not eventMap[self].CHAT_MSG_RAID_BOSS_EMOTE then eventMap[self].CHAT_MSG_RAID_BOSS_EMOTE = {} end
		for i = 1, select("#", ...) do
			eventMap[self]["CHAT_MSG_RAID_BOSS_EMOTE"][(select(i, ...))] = func
		end
		self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
	end

	function boss:CHAT_MSG_MONSTER_YELL(event, msg, ...)
		if eventMap[self][event][msg] then
			self[eventMap[self][event][msg]](self, msg, ...)
		else
			for yell, func in pairs(eventMap[self][event]) do
				if msg:find(yell, nil, true) or msg:find(yell) then -- Preserve backwards compat by leaving in the 2nd check
					self[func](self, msg, ...)
				end
			end
		end
	end
	function boss:Yell(func, ...)
		if not func then error(format(missingArgument, self.moduleName)) end
		if not self[func] then error(format(missingFunction, self.moduleName, func)) end
		if not eventMap[self].CHAT_MSG_MONSTER_YELL then eventMap[self].CHAT_MSG_MONSTER_YELL = {} end
		for i = 1, select("#", ...) do
			eventMap[self]["CHAT_MSG_MONSTER_YELL"][(select(i, ...))] = func
		end
		self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	end

	bossUtilityFrame:SetScript("OnEvent", function(_, _, _, event, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName, spellSchool, extraSpellID, amount)
		if allowedEvents[event] then
			if event == "UNIT_DIED" then
				local numericId = tonumber(destGUID:sub(6, 10), 16)
				for i = #enabledModules, 1, -1 do
					local self = enabledModules[i]
					local m = eventMap[self][event]
					if m and m[numericId] then
						local func = m[numericId]
						if type(func) == "function" then
							func(numericId, destGUID, destName, destFlags)
						else
							self[func](self, numericId, destGUID, destName, destFlags)
						end
					end
				end
			else
				for i = #enabledModules, 1, -1 do
					local self = enabledModules[i]
					local m = eventMap[self][event]
					if m and (m[spellId] or m["*"]) then
						local func = m[spellId] or m["*"]
						if type(func) == "function" then
							func(destName, spellId, sourceName, extraSpellID, spellName, amount, event, sourceFlags, destFlags, destGUID, sourceGUID)
						else
							self[func](self, destName, spellId, sourceName, extraSpellID, spellName, amount, event, sourceFlags, destFlags, destGUID, sourceGUID)
							if debug then dbg(self, "Firing func: "..func) end
						end
					end
				end
			end
		end
	end)
	function boss:Log(event, func, ...)
		if not event or not func then error(format(missingArgument, self.moduleName)) end
		if type(func) ~= "function" and not self[func] then error(format(missingFunction, self.moduleName, func)) end
		if not eventMap[self][event] then eventMap[self][event] = {} end
		for i = 1, select("#", ...) do
			local id = (select(i, ...))
			eventMap[self][event][id] = func
			if type(id) == "number" and not GetSpellInfo(id) then
				print(format(invalidId, self.moduleName, id, event))
			end
		end
		allowedEvents[event] = true
		bossUtilityFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	end
	function boss:Death(func, ...)
		if not func then error(format(missingArgument, self.moduleName)) end
		if type(func) ~= "function" and not self[func] then error(format(missingFunction, self.moduleName, func)) end
		if not eventMap[self].UNIT_DIED then eventMap[self].UNIT_DIED = {} end
		for i = 1, select("#", ...) do
			eventMap[self]["UNIT_DIED"][(select(i, ...))] = func
		end
		allowedEvents.UNIT_DIED = true
		bossUtilityFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	end
end

-------------------------------------------------------------------------------
-- Unit-specific event update management
--

do
	local noEvent = "Module %q tried to register/unregister a unit event without specifying which event."
	local noUnit = "Module %q tried to register/unregister a unit event without specifying any units."
	local noFunc = "Module %q tried to register a unit event with the function '%s' which doesn't exist in the module."

	local frameTbl = {}
	local eventFunc = function(_, event, unit, ...)
		for i = #enabledModules, 1, -1 do
			local self = enabledModules[i]
			local m = unitEventMap[self] and unitEventMap[self][event]
			if m and m[unit] then
				self[m[unit]](self, unit, ...)
			end
		end
	end

	function boss:RegisterUnitEvent(event, func, ...)
		if type(event) ~= "string" then error(format(noEvent, self.moduleName)) end
		if not ... then error(format(noUnit, self.moduleName)) end
		if (not func and not self[event]) or (func and not self[func]) then error(format(noFunc, self.moduleName, func or event)) end
		if not unitEventMap[self][event] then unitEventMap[self][event] = {} end
		for i = 1, select("#", ...) do
			local unit = select(i, ...)
			if not frameTbl[unit] then
				frameTbl[unit] = CreateFrame("Frame")
				frameTbl[unit]:SetScript("OnEvent", eventFunc)
			end
			unitEventMap[self][event][unit] = func or event
			frameTbl[unit]:RegisterUnitEvent(event, unit)
			if debug then dbg(self, "Adding: "..event..", "..unit) end
		end
	end
	function boss:UnregisterUnitEvent(event, ...)
		if type(event) ~= "string" then error(format(noEvent, self.moduleName)) end
		if not ... then error(format(noUnit, self.moduleName)) end
		if not unitEventMap[self][event] then return end
		for i = 1, select("#", ...) do
			local unit = select(i, ...)
			unitEventMap[self][event][unit] = nil
			local keepRegistered
			for i = #enabledModules, 1, -1 do
				local m = unitEventMap[enabledModules[i]][event]
				if m and m[unit] then
					keepRegistered = true
				end
			end
			if not keepRegistered then
				if debug then dbg(self, "Removing: "..event..", "..unit) end
				frameTbl[unit]:UnregisterEvent(event)
			end
		end
	end
end

-------------------------------------------------------------------------------
-- Engage / wipe checking + unit scanning
--

do
	local function wipeCheck(module)
		if not IsEncounterInProgress() then
			if debug then dbg(module, "Wipe!") end
			module:Reboot()
		end
	end
	function boss:CheckBossStatus()
		local hasBoss = UnitHealth("boss1") > 100 or UnitHealth("boss2") > 100 or UnitHealth("boss3") > 100 or UnitHealth("boss4") > 100 or UnitHealth("boss5") > 100
		if not hasBoss and self.isEngaged then
			if debug then dbg(self, ":CheckBossStatus wipeCheck scheduled.") end
			self:ScheduleTimer(wipeCheck, 2, self)
		elseif not self.isEngaged and hasBoss then
			if debug then dbg(self, ":CheckBossStatus Engage called.") end
			local guid = UnitGUID("boss1") or UnitGUID("boss2") or UnitGUID("boss3") or UnitGUID("boss4") or UnitGUID("boss5")
			local module = core:GetEnableMobs()[tonumber(guid:sub(6, 10), 16)]
			local modType = type(module)
			if modType == "string" then
				if module == self.moduleName then
					self:Engage()
				else
					self:Disable()
				end
			elseif modType == "table" then
				for i = 1, #module do
					if module[i] == self.moduleName then
						self:Engage()
						break
					end
				end
				if not self.isEngaged then self:Disable() end
			end
		end
		if debug then dbg(self, ":CheckBossStatus called with no result. Engaged = "..tostring(self.isEngaged).." hasBoss = "..tostring(hasBoss)) end
	end
end

do
	local t = nil
	local function buildTable()
		t = {
			"boss1", "boss2", "boss3", "boss4", "boss5",
			"target", "targettarget",
			"focus", "focustarget",
			"party1target", "party2target", "party3target", "party4target",
			"mouseover", "mouseovertarget"
		}
		for i = 1, 25 do t[#t+1] = format("raid%dtarget", i) end
		buildTable = nil
	end
	local function findTargetByGUID(id)
		if not t then buildTable() end
		for i, unit in next, t do
			local guid = UnitGUID(unit)
			if guid and not UnitIsPlayer(unit) then
				if type(id) == "number" then guid = tonumber(guid:sub(6, 10), 16) end
				if guid == id then return unit end
			end
		end
	end
	function boss:GetUnitIdByGUID(id) return findTargetByGUID(id) end

	local function scan(self)
		for mobId, entry in pairs(core:GetEnableMobs()) do
			if type(entry) == "table" then
				for i, module in next, entry do
					if module == self.moduleName then
						local unit = findTargetByGUID(mobId)
						if unit and UnitAffectingCombat(unit) then return unit end
						break
					end
				end
			elseif entry == self.moduleName then
				local unit = findTargetByGUID(mobId)
				if unit and UnitAffectingCombat(unit) then return unit end
			end
		end
	end

	function boss:CheckForEngage()
		if debug then dbg(self, ":CheckForEngage initiated.") end
		local go = scan(self)
		if go then
			if debug then dbg(self, "Engage scan found active boss entities, transmitting engage sync.") end
			self:Sync("BossEngaged", self.moduleName)
		else
			if debug then dbg(self, "Engage scan did NOT find any active boss entities. Re-scheduling another engage check in 0.5 seconds.") end
			self:ScheduleTimer("CheckForEngage", .5)
		end
	end

	-- XXX What if we die and then get battleressed?
	-- XXX First of all, the CheckForWipe every 2 seconds would continue scanning.
	-- XXX Secondly, if the boss module registers for PLAYER_REGEN_DISABLED, it would
	-- XXX trigger again, and CheckForEngage (possibly) invoked, which results in
	-- XXX a new BossEngaged sync -> :Engage -> :OnEngage on the module.
	-- XXX Possibly a concern?
	function boss:CheckForWipe()
		if debug then dbg(self, ":CheckForWipe initiated.") end
		local go = scan(self)
		if not go then
			if debug then dbg(self, "Wipe scan found no active boss entities, rebooting module.") end
			self:Reboot()
			if self.OnWipe then self:OnWipe() end
		else
			if debug then dbg(self, "Wipe scan found active boss entities (" .. tostring(go) .. "). Re-scheduling another wipe check in 2 seconds.") end
			self:ScheduleTimer("CheckForWipe", 2)
		end
	end

	function boss:Engage()
		if debug then dbg(self, ":Engage") end

		-- Update Difficulty
		local _, _, diff = GetInstanceInfo()
		difficulty = diff

		-- Prevent rare combat log bug
		CombatLogClearEntries()

		-- Engage
		self.isEngaged = true
		if self.OnEngage then
			self:OnEngage(diff)
		end

		-- Update Dispel Status
		UpdateDispelStatus()

		self:SendMessage("BigWigs_OnBossEngage", self)
	end

	function boss:Win()
		if debug then dbg(self, ":Win") end
		self:Sync("Death", self.moduleName)
		wipe(icons) -- Wipe icon cache
		wipe(spells)
		self:SendMessage("BigWigs_OnBossWin", self)
	end
end

-------------------------------------------------------------------------------
-- Misc utility functions
--

function boss:Difficulty()
	return difficulty
end
boss.GetInstanceDifficulty = boss.Difficulty

function boss:LFR()
	return difficulty == 7
end

function boss:Heroic()
	return difficulty == 5 or difficulty == 6
end

function boss:GetCID(guid)
	if not guid then return -1 end
	local creatureId = tonumber(guid:sub(6, 10), 16)
	return creatureId
end

function boss:SpellName(spellId)
	return spells[spellId]
end

-------------------------------------------------------------------------------
-- Role checking
--

function boss:Tank()
	if core.db.profile.ignorerole then return true end
	local tree = GetSpecialization()
	local role = GetSpecializationRole(tree)
	return role == "TANK"
end

function boss:Healer()
	if core.db.profile.ignorerole then return true end
	local tree = GetSpecialization()
	local role = GetSpecializationRole(tree)
	return role == "HEALER"
end

--[[
function boss:Damager()
	if core.db.profile.ignorerole then return true end
	local tree = GetSpecialization()
	local role
	local _, class = UnitClass("player")
	if
		class == "MAGE" or class == "WARLOCK" or class == "HUNTER" or (class == "DRUID" and tree == 1) or
		(class == "PRIEST" and tree == 3) or (class == "SHAMAN" and tree == 1)
	then
		role = "RANGED"
	elseif
		class == "ROGUE" or (class == "WARRIOR" and tree ~= 3) or (class == "DEATHKNIGHT" and tree ~= 1) or
		(class == "PALADIN" and tree == 3) or (class == "DRUID" and tree == 2) or (class == "SHAMAN" and tree == 2)
	then
		role = "MELEE"
	end
	return role
end
]]

do
	local offDispel, defDispel = "", ""
	function UpdateDispelStatus()
		offDispel, defDispel = "", ""
		if IsSpellKnown(19801) or IsSpellKnown(2908) or IsSpellKnown(5938) then
			-- Tranq (Hunter), Soothe (Druid), Shiv (Rogue)
			offDispel = offDispel .. "enrage,"
		end
		if IsSpellKnown(19801) or IsSpellKnown(32375) or IsSpellKnown(528) or IsSpellKnown(370) or IsSpellKnown(30449) or IsSpellKnown(110707) or IsSpellKnown(110802) then
			-- Tranq (Hunter), Mass Dispel (Priest), Dispel Magic (Priest), Purge (Shaman), Spellsteal (Mage), Mass Dispel (Symbiosis), Purge (Symbiosis)
			offDispel = offDispel .. "magic,"
		end
		if IsSpellKnown(527) or IsSpellKnown(77130) or (IsSpellKnown(115450) and IsSpellKnown(115451)) or (IsSpellKnown(4987) and IsSpellKnown(53551)) or IsSpellKnown(88423) then
			-- Purify (Priest), Purify Spirit (Shaman), Detox (Monk-Modifier), Cleanse (Paladin-Modifier), Nature's Cure (Resto Druid)
			defDispel = defDispel .. "magic,"
		end
		if IsSpellKnown(527) or IsSpellKnown(115450) or IsSpellKnown(4987) then
			-- Purify (Priest), Detox (Monk), Cleanse (Paladin)
			defDispel = defDispel .. "disease,"
		end
		if IsSpellKnown(88423) or IsSpellKnown(115450) or IsSpellKnown(4987) or IsSpellKnown(2782) then
			-- Nature's Cure (Resto Druid), Detox (Monk), Cleanse (Paladin), Remove Corruption (Druid)
			defDispel = defDispel .. "poison,"
		end
		if IsSpellKnown(88423) or IsSpellKnown(2782) or IsSpellKnown(77130) or IsSpellKnown(475) then
			-- Nature's Cure (Resto Druid), Remove Corruption (Druid), Purify Spirit (Shaman), Remove Curse (Mage)
			defDispel = defDispel .. "curse,"
		end
	end
	function boss:Dispeller(dispelType, isOffensive)
		if isOffensive then
			if offDispel:find(dispelType, nil, true) then
				return true
			end
		else
			if defDispel:find(dispelType, nil, true) then
				return true
			end
		end
	end
end

-------------------------------------------------------------------------------
-- Delayed message handling
--

do
	local scheduledMessages = {}

	function boss:CancelDelayedMessage(text)
		if scheduledMessages[text] then
			self:CancelTimer(scheduledMessages[text])
			scheduledMessages[text] = nil
		end
	end

	-- ... = color, icon, sound, noraidsay, broadcastonly
	function boss:DelayedMessage(key, delay, text, ...)
		if type(delay) ~= "number" then error(format("Module '%s' tried to schedule a delayed message with delay as type %q, but it must be a number.", self.moduleName, type(delay))) end
		self:CancelDelayedMessage(text)

		scheduledMessages[text] = self:ScheduleTimer("Message", delay, key, text, ...)
	end
end

-------------------------------------------------------------------------------
-- Boss module APIs for messages, bars, icons, etc.
--

do
	local icons = {
		"6:21:7:27",		-- [0] tank
		"39:55:7:27",		-- [1] damage
		"70:86:7:27",		-- [2] healer
		"102:118:7:27",		-- [3] heroic only
		"133:153:7:27",		-- [4] deadly
		"168:182:7:27",		-- [5] important
		"198:214:7:27",		-- [6] interruptable
		"229:247:7:27",		-- [7] magic
		"6:21:40:58",		-- [8] curse
		"39:55:40:58",		-- [9] poison
		"70:86:40:58",		-- [10] disease
		"102:118:40:58",	-- [11] enrage
	}
	-- XXX this can potentially be extended to get a whole description from EJ ID with description and flag icons
	function boss:GetFlagIcon(flag)
		flag = flag + 1
		return "|TInterface\\EncounterJournal\\UI-EJ-Icons.blp:16:16:0:0:255:66:".. icons[flag] .."|t"
	end
end

local silencedOptions = {}
do
	bossUtilityFrame:Hide()
	BigWigsLoader:RegisterMessage("BigWigs_SilenceOption", function(event, key, time)
		if key ~= nil then -- custom bars have a nil key
			silencedOptions[key] = time
			bossUtilityFrame:Show()
		end
	end)
	local total = 0
	bossUtilityFrame:SetScript("OnUpdate", function(self, elapsed)
		total = total + elapsed
		if total >= 0.5 then
			for k, t in pairs(silencedOptions) do
				local newT = t - total
				if newT < 0 then
					silencedOptions[k] = nil
				else
					silencedOptions[k] = newT
				end
			end
			if not next(silencedOptions) then
				self:Hide()
			end
			total = 0
		end
	end)
end

local checkFlag = nil
do
	local noDefaultError   = "Module %s uses %q as a toggle option, but it does not exist in the modules default values."
	local notNumberError   = "Module %s tried to access %q, but in the database it's a %s."
	local nilKeyError      = "Module %s tried to check the bitflags for a nil option key."
	local invalidFlagError = "Module %s tried to check for an invalid flag type %q (%q). Flags must be bits."
	local noDBError        = "Module %s does not have a .db property, which is weird."
	checkFlag = function(self, key, flag)
		if type(key) == "nil" then error(format(nilKeyError, self.name)) end
		if type(flag) ~= "number" then error(format(invalidFlagError, self.name, type(flag), tostring(flag))) end
		if silencedOptions[key] then return end
		if type(key) == "number" then key = spells[key] end
		if type(self.db) ~= "table" then error(format(noDBError, self.name)) end
		if type(self.db.profile[key]) ~= "number" then
			if not self.toggleDefaults[key] then
				error(format(noDefaultError, self.name, key))
			end
			if debug then
				error(format(notNumberError, self.name, key, type(self.db.profile[key])))
			end
			self.db.profile[key] = self.toggleDefaults[key]
		end
		return bit.band(self.db.profile[key], flag) == flag
	end
end

-- XXX the monitor should probably also get a button to turn off the proximity bitflag
-- XXX for the given key.
function boss:OpenProximity(range, key, player, isReverse)
	if not checkFlag(self, key or "proximity", C.PROXIMITY) then return end
	self:SendMessage("BigWigs_ShowProximity", self, range, key or "proximity", player, isReverse)
end
function boss:CloseProximity(key)
	if not checkFlag(self, key or "proximity", C.PROXIMITY) then return end
	self:SendMessage("BigWigs_HideProximity", self, key or "proximity")
end

function boss:Message(key, text, color, icon, sound, noraidsay, broadcastonly)
	if not checkFlag(self, key, C.MESSAGE) then return end
	self:SendMessage("BigWigs_Message", self, key, type(text) == "number" and spells[text] or text, color, noraidsay, sound, broadcastonly, icon and icons[icon])
end

do
	local hexColors = {}
	for k, v in pairs(CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS) do
		hexColors[k] = "|cff" .. format("%02x%02x%02x", v.r * 255, v.g * 255, v.b * 255)
	end
	local coloredNames = setmetatable({}, {__index =
		function(self, key)
			if type(key) == "nil" then return nil end
			local _, class = UnitClass(key)
			if class then
				self[key] = hexColors[class] .. key:gsub("%-.+", "*") .. "|r" -- Replace server names with *
			else
				return key
			end
			return self[key]
		end
	})

	local mt = {
		__newindex = function(self, key, value)
			rawset(self, key, coloredNames[value])
		end
	}
	function boss:NewTargetList()
		return setmetatable({}, mt)
	end

	-- Outputs a local message only, no raid warning.
	function boss:LocalMessage(key, text, color, icon, sound, player, ...)
		if not checkFlag(self, key, C.MESSAGE) then return end
		if player then
			if ... then
				text = format(text, coloredNames[player], ...)
			else
				text = format(L["other"], text, coloredNames[player])
			end
		elseif type(text) == "number" then
			text = spells[text]
		end
		self:SendMessage("BigWigs_Message", self, key, text, color, true, sound, nil, icon and icons[icon])
	end

	function boss:TargetMessage(key, spellName, player, color, icon, sound, ...)
		if not checkFlag(self, key, C.MESSAGE) then return end
		if type(spellName) == "number" then spellName = spells[spellName] end
		if type(player) == "table" then
			local list = table.concat(player, ", ")
			wipe(player)
			if not list:find(pName) then sound = nil end
			local text = format(L["other"], spellName, list)
			self:SendMessage("BigWigs_Message", self, key, text, color, nil, sound, nil, icon and icons[icon])
		else
			if UnitIsUnit(player, "player") then
				if ... then
					local text = format(spellName, coloredNames[player], ...)
					self:SendMessage("BigWigs_Message", self, key, text, color, true, sound, nil, icon and icons[icon])
					self:SendMessage("BigWigs_Message", self, key, text, nil, nil, nil, true)
				else
					self:SendMessage("BigWigs_Message", self, key, format(L["you"], spellName), "Personal", true, sound, nil, icon and icons[icon])
					self:SendMessage("BigWigs_Message", self, key, format(L["other"], spellName, player), nil, nil, nil, true)
				end
			else
				-- Change color and remove sound when warning about effects on other players
				if color == "Personal" then color = "Important" end
				local text = nil
				if ... then
					text = format(spellName, coloredNames[player], ...)
				else
					text = format(L["other"], spellName, coloredNames[player])
				end
				self:SendMessage("BigWigs_Message", self, key, text, color, nil, nil, nil, icon and icons[icon])
			end
		end
	end
end

function boss:FlashShake(key, r, g, b)
	if not checkFlag(self, key, C.FLASHSHAKE) then return end
	self:SendMessage("BigWigs_Flash", self, key)
end

function boss:Say(key, msg)
	if not checkFlag(self, key, C.SAY) then return end
	SendChatMessage(msg, "SAY")
end

function boss:SaySelf(key, msg)
	if not checkFlag(self, key, C.SAY) then return end
	SendChatMessage(L["on"]:format(msg and (type(msg) == "number" and spells[msg] or msg) or spells[key], pName), "SAY")
end

function boss:PlaySound(key, sound)
	if not checkFlag(self, key, C.MESSAGE) then return end
	self:SendMessage("BigWigs_Sound", sound)
end


function boss:Bar(key, text, length, icon)
	if checkFlag(self, key, C.BAR) then
		self:SendMessage("BigWigs_StartBar", self, key, type(text) == "number" and spells[text] or text, length, icon and icons[icon])
	end
end

function boss:TargetBar(key, text, player, length, icon)
	if checkFlag(self, key, C.BAR) then
		if UnitIsUnit(player, "player") then
			self:SendMessage("BigWigs_StartBar", self, key, format(L["you"], type(text) == "number" and spells[text] or text), length, icon and icons[icon])
		else
			self:SendMessage("BigWigs_StartBar", self, key, format(L["other"], type(text) == "number" and spells[text] or text, player:gsub("%-.+", "*")), length, icon and icons[icon])
		end
	end
end

function boss:StopBar(text, player)
	if player then
		if UnitIsUnit(player, "player") then
			self:SendMessage("BigWigs_StopBar", self, format(L["you"], type(text) == "number" and spells[text] or text))
		else
			self:SendMessage("BigWigs_StopBar", self, format(L["other"], type(text) == "number" and spells[text] or text, player:gsub("%-.+", "*")))
		end
	else
		self:SendMessage("BigWigs_StopBar", self, type(text) == "number" and spells[text] or text)
	end
end

-- Examples of API use in a module:
-- self:Sync("abilityPrefix", playerName)
-- self:Sync("ability")
function boss:Sync(...) core:Transmit(...) end

do
	local sentWhispers = {}
	local function filter(self, event, msg) if sentWhispers[msg] or msg:find("^<BW>") or msg:find("^<DBM>") then return true end end
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", filter)

	function boss:Whisper(key, player, spellName, noName)
		self:SendMessage("BigWigs_Whisper", self, key, player, spellName, noName)
		if not checkFlag(self, key, C.WHISPER) then return end
		local msg = noName and spellName or format(L["you"], spellName)
		sentWhispers[msg] = true
		if UnitIsUnit(player, "player") or not UnitIsPlayer(player) or not core.db.profile.whisper then return end
		if UnitInRaid("player") and not UnitIsGroupLeader("player") and not UnitIsGroupAssistant("player") then return end
		SendChatMessage("<BW> " .. msg, "WHISPER", nil, player)
	end
end

function boss:PrimaryIcon(key, player)
	if key and not checkFlag(self, key, C.ICON) then return end
	if not player then
		self:SendMessage("BigWigs_RemoveRaidIcon", 1)
	else
		self:SendMessage("BigWigs_SetRaidIcon", player, 1)
	end
end

function boss:SecondaryIcon(key, player)
	if key and not checkFlag(self, key, C.ICON) then return end
	if not player then
		self:SendMessage("BigWigs_RemoveRaidIcon", 2)
	else
		self:SendMessage("BigWigs_SetRaidIcon", player, 2)
	end
end

function boss:AddSyncListener(sync)
	core:AddSyncListener(self, sync)
end

function boss:Berserk(seconds, noEngageMessage, customBoss, customBerserk)
	local boss = customBoss or self.displayName
	local key = "berserk"

	-- There are many Berserks, but we use 26662 because Brutallus uses this one.
	-- Brutallus is da bomb.
	local berserk, icon = (GetSpellInfo(26662)), 26662
	-- XXX "Interface\\EncounterJournal\\UI-EJ-Icons" ?
	-- http://static.wowhead.com/images/icons/ej-enrage.png
	if type(customBerserk) == "number" then
		key = customBerserk
		berserk, icon = (GetSpellInfo(customBerserk)), customBerserk
	elseif type(customBerserk) == "string" then
		berserk = customBerserk
	end

	if not noEngageMessage then
		-- Engage warning with minutes to enrage
		self:Message(key, format(L["custom_start"], boss, berserk, seconds / 60), "Attention")
	end

	-- Half-way to enrage warning.
	local half = seconds / 2
	local m = half % 60
	local halfMin = (half - m) / 60
	self:DelayedMessage(key, half + m, format(L["custom_min"], berserk, halfMin), "Positive")

	self:DelayedMessage(key, seconds - 60, format(L["custom_min"], berserk, 1), "Positive")
	self:DelayedMessage(key, seconds - 30, format(L["custom_sec"], berserk, 30), "Urgent")
	self:DelayedMessage(key, seconds - 10, format(L["custom_sec"], berserk, 10), "Urgent")
	self:DelayedMessage(key, seconds - 5, format(L["custom_sec"], berserk, 5), "Important")
	self:DelayedMessage(key, seconds, format(L["custom_end"], boss, berserk), "Important", icon, "Alarm")

	self:Bar(key, berserk, seconds, icon)
end


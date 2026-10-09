--[[
	main.lua
		The bagnon driver thingy
--]]

Bagnon = LibStub('AceAddon-3.0'):NewAddon('Bagnon', 'AceEvent-3.0', 'AceConsole-3.0')
local L = LibStub('AceLocale-3.0'):GetLocale('Bagnon')


--[[
	Binding Setup
--]]

BINDING_HEADER_BAGNON = 'Bagnon'
BINDING_NAME_BAGNON_TOGGLE = L.ToggleBags
BINDING_NAME_BANKNON_TOGGLE = L.ToggleBank
BINDING_NAME_BAGNON_KEYS_TOGGLE = L.ToggleKeys


--[[
	Startup
--]]

function Bagnon:OnInitialize()
	self.frames = {}

	self:HookBagClickEvents()
	self:WatchBlockedActions()
	self:RegisterAutoDisplayEvents()
	self:AddSlashCommands()
	self:CreateOptionsLoader()
	self:CreateLDBLauncher()
	self:CreateGuildBankLoader()
end

--create a loader for the options menu
function Bagnon:CreateOptionsLoader()
	local f = CreateFrame('Frame', nil, InterfaceOptionsFrame)
	f:SetScript('OnShow', function(self)
		self:SetScript('OnShow', nil)
		LoadAddOn('Bagnon_Config')
	end)
end

function Bagnon:CreateGuildBankLoader()
	local name, title, notes, enabled, loadable = GetAddOnInfo('Bagnon_GuildBank')
	if enabled and loadable then
		GuildBankFrame_LoadUI = function()
			LoadAddOn('Bagnon_GuildBank') 
		end
	end
end

function Bagnon:CreateLDBLauncher()
	local LDB = LibStub:GetLibrary('LibDataBroker-1.1', true)
	if not LDB then return end

	LDB:NewDataObject('BagnonLauncher', {
		type = 'launcher',

		icon = [[Interface\Icons\INV_Misc_Bag_07]],

		OnClick = function(_, button)
			if button == 'LeftButton' then
				if IsShiftKeyDown() then
					Bagnon:ToggleFrame('bank')
				elseif IsAltKeyDown() then
					Bagnon:ToggleFrame('keys')
				else
					Bagnon:ToggleFrame('inventory')
				end
			elseif button == 'RightButton' then
				Bagnon:ShowOptions()
			end
		end,

		OnTooltipShow = function(tooltip)
			if not tooltip or not tooltip.AddLine then return end

			tooltip:AddLine('Bagnon')
			tooltip:AddLine(L.TipShowInventory, 1, 1, 1)
			tooltip:AddLine(L.TipShowBank, 1, 1, 1)
			tooltip:AddLine(L.TipShowKeyring, 1, 1, 1)
			tooltip:AddLine(L.TipShowOptions, 1, 1, 1)
		end,
	})
end


--[[
	Frame Display
--]]

function Bagnon:GetFrame(frameID)
	for i, frame in pairs(self.frames) do
		if frame:GetFrameID() == frameID then
			return frame
		end
	end
end

function Bagnon:CreateFrame(frameID)
	table.insert(self.frames, self.Frame:New(frameID))
end

function Bagnon:ShowFrame(frameID)
	if self:IsFrameEnabled(frameID) then
		if not self:GetFrame(frameID) then
			self:CreateFrame(frameID)
		end

		self.FrameSettings:Get(frameID):Show()
		return true
	end
	return false
end

function Bagnon:HideFrame(frameID)
	if self:IsFrameEnabled(frameID) then
		self.FrameSettings:Get(frameID):Hide()
		return true
	end
	return false
end

function Bagnon:ToggleFrame(frameID)
	if self:IsFrameEnabled(frameID) then
		if not self:GetFrame(frameID) then
			self:CreateFrame(frameID)
		end

		self.FrameSettings:Get(frameID):Toggle()
		return true
	end
	return false
end

function Bagnon:IsFrameEnabled(frameID)
	return self.Settings:IsFrameEnabled(frameID)
end

function Bagnon:FrameControlsBag(frameID, bagSlot)
	return self.FrameSettings:Get(frameID):IsBagSlotShown(bagSlot) or (not self:IsBlizzardBagPassThroughEnabled())
end

function Bagnon:IsBlizzardBagPassThroughEnabled()
	return self.Settings:IsBlizzardBagPassThroughEnabled()
end


--[[
	Bag Click Events
--]]

function Bagnon:HookBagClickEvents()
	--backpack
	hooksecurefunc('CloseBackpack', function()
		self:HideFrame('inventory')
	end)

	local oOpenBackpack = OpenBackpack
	OpenBackpack = function()
		local shown = self:FrameControlsBag('inventory', BACKPACK_CONTAINER) and self:RequestFrame('inventory', 'ShowFrame')

		if not shown then
			oOpenBackpack()
		end
	end

	local oToggleBackpack = ToggleBackpack
	ToggleBackpack = function()
		local toggled = self:FrameControlsBag('inventory', BACKPACK_CONTAINER) and self:RequestFrame('inventory', 'ToggleFrame')

		if not toggled then
			oToggleBackpack()
		end
	end

	--single bag
	local oToggleBag = ToggleBag
	ToggleBag = function(bagSlot)
		local frameID = self.BagSlotInfo:IsBankBag(bagSlot) and 'bank' or 'inventory'
		local toggled = self:FrameControlsBag(frameID, bagSlot) and self:RequestFrame(frameID, 'ToggleFrame')

		if not toggled then
			oToggleBag(bagSlot)
		end
	end

	--keyring
	local oToggleKeyRing = ToggleKeyRing
	ToggleKeyRing = function()
		local toggled = self:FrameControlsBag('keys', KEYRING_CONTAINER) and self:RequestFrame('keys', 'ToggleFrame')

		if not toggled then
			toggled = self:FrameControlsBag('inventory', KEYRING_CONTAINER) and self:RequestFrame('inventory', 'ToggleFrame')
		end

		if not toggled then
			oToggleKeyRing()
		end
	end

	--all bags
	--closing the game menu triggers this function, and can be done in combat
	hooksecurefunc('CloseAllBags', function()
		self:HideFrame('inventory')
	end)

	local oOpenAllBags = OpenAllBags
	OpenAllBags = function(force)
		local opened = false
		if force then
			opened = self:FrameControlsBag('inventory', BACKPACK_CONTAINER) and self:RequestFrame('inventory', 'ShowFrame')
		else
			opened = self:FrameControlsBag('inventory', BACKPACK_CONTAINER) and self:RequestFrame('inventory', 'ToggleFrame')
		end

		if not opened then
			oOpenAllBags(force)
		end
	end
end


--[[
	Combat Safety
--]]

--is the frame really on screen? (the settings object only counts requests)
function Bagnon:IsFrameOnScreen(frameID)
	local frame = self:GetFrame(frameID)
	return frame and frame:IsShown() and true or false
end

--runs ShowFrame / ToggleFrame. In combat the game refuses to show or hide
--protected frames, so if the window did not react, resync the settings and
--report failure so the caller can hand the request to the default bags.
function Bagnon:RequestFrame(frameID, method)
	local wasShown = self:IsFrameOnScreen(frameID)
	local handled = self[method](self, frameID)

	if handled and InCombatLockdown() then
		local isShown = self:IsFrameOnScreen(frameID)
		local wanted = (method == 'ShowFrame') or (not wasShown)

		if isShown ~= wanted then
			self.FrameSettings:Get(frameID).shown = isShown and 1 or 0
			self.combatFallbacks = (self.combatFallbacks or 0) + 1
			return false
		end
	end
	return handled
end

--remember (and tell the player about) actions the game blocked for Bagnon
function Bagnon:WatchBlockedActions()
	self:RegisterEvent('ADDON_ACTION_BLOCKED', 'OnActionBlocked')
	self:RegisterEvent('ADDON_ACTION_FORBIDDEN', 'OnActionBlocked')
	self:RegisterEvent('PLAYER_REGEN_ENABLED', 'OnLeaveCombat')
end

function Bagnon:OnActionBlocked(event, addon, func)
	if type(addon) ~= 'string' or not addon:find('^Bagnon') then return end

	self.blockedCount = (self.blockedCount or 0) + 1
	self.lastBlocked = addon .. ': ' .. tostring(func)

	if not self.reportedBlock then
		self.reportedBlock = true
		self:Print('The game blocked an action in combat (' .. tostring(func) .. '). Type /bagnon debug and report the result.')
	end
end

function Bagnon:OnLeaveCombat()
	self.reportedBlock = nil
end

function Bagnon:PrintDebug()
	self:Print('debug (' .. (InCombatLockdown() and 'in combat' or 'out of combat') .. ')')
	for _, frameID in ipairs({'inventory', 'bank', 'keys'}) do
		local frame = self:GetFrame(frameID)
		if frame then
			local protected, explicit = frame:IsProtected()
			print(string.format(' - %s: shown=%s, protected=%s, explicit=%s', frameID, tostring(frame:IsShown()), tostring(protected), tostring(explicit)))
		else
			print(string.format(' - %s: not created yet', frameID))
		end
	end
	print(string.format(' - blocked actions: %d (last: %s)', self.blockedCount or 0, self.lastBlocked or 'none'))
	print(string.format(' - combat fallbacks to default bags: %d', self.combatFallbacks or 0))
end

--[[
	Automatic Display
--]]

function Bagnon:RegisterAutoDisplayEvents()
	self.BagEvents:Listen(self, 'BANK_OPENED')
	self.BagEvents:Listen(self, 'BANK_CLOSED')
	self:RegisterEvent('MAIL_CLOSED')
	self:RegisterEvent('AUCTION_HOUSE_SHOW')
	self:RegisterEvent('AUCTION_HOUSE_CLOSED')
	self:RegisterEvent('MERCHANT_SHOW')
	self:RegisterEvent('MERCHANT_CLOSED')
	self:RegisterEvent('TRADE_SHOW')
	self:RegisterEvent('TRADE_CLOSED')
	self:RegisterEvent('TRADE_SKILL_SHOW')
	self:RegisterEvent('TRADE_SKILL_CLOSE')
	self:RegisterEvent('GUILDBANKFRAME_OPENED')
	self:RegisterEvent('GUILDBANKFRAME_CLOSED')

	--override normal bank display
	BankFrame:UnregisterEvent('BANKFRAME_OPENED')
	BankFrame:UnregisterEvent('BANKFRAME_CLOSED')
	
	local f = CreateFrame('Frame', nil, CharacterFrame)
	f:SetScript('OnShow', function() Bagnon:PLAYER_FRAME_SHOW() end)
	f:SetScript('OnHide', function() Bagnon:PLAYER_FRAME_HIDE() end)
end

function Bagnon:ShowFrameAtEvent(frameID, event)
	if self:AutoDisplayingFrameOnEvent(frameID, event) then
		self:ShowFrame(frameID)
	end
end

function Bagnon:HideFrameAtEvent(frameID, event)
	if self:AutoDisplayingFrameOnEvent(frameID, event) then
		self:HideFrame(frameID)
	end
end

function Bagnon:AutoDisplayingFrameOnEvent(frameID, event)
	return self.Settings:IsFrameShownAtEvent(frameID, event)
end

function Bagnon:ShowBlizzardBankFrame()
	BankFrame_OnEvent(_G['BankFrame'], 'BANKFRAME_OPENED')
end

function Bagnon:HideBlizzardBankFrame()
	BankFrame_OnEvent(_G['BankFrame'], 'BANKFRAME_CLOSED')
end


--[[ Display Events ]]--

--visiting the bank
function Bagnon:BANK_OPENED()
	if not self:ShowFrame('bank') then
		self:ShowBlizzardBankFrame()
	end
	self:ShowFrameAtEvent('inventory', 'bank')
end

function Bagnon:BANK_CLOSED()
	if not self:HideFrame('bank') then
		self:HideBlizzardBankFrame()
	end
	self:HideFrameAtEvent('inventory', 'bank')
end

--visiting the mailbox
--mail frame is a special case, since its automatically handled by the stock interface
function Bagnon:MAIL_CLOSED()
	self:HideFrame('inventory')
end

--visiting the auction house
function Bagnon:AUCTION_HOUSE_SHOW()
	self:ShowFrameAtEvent('inventory', 'ah')
end

function Bagnon:AUCTION_HOUSE_CLOSED()
	self:HideFrameAtEvent('inventory', 'ah')
end

--visitng a vendor
function Bagnon:MERCHANT_SHOW()
	self:ShowFrameAtEvent('inventory', 'vendor')
end

function Bagnon:MERCHANT_CLOSED()
	self:HideFrameAtEvent('inventory', 'vendor')
end

--trading
function Bagnon:TRADE_SHOW()
	self:ShowFrameAtEvent('inventory', 'trade')
end

function Bagnon:TRADE_CLOSED()
	self:HideFrameAtEvent('inventory', 'trade')
end

--visiting the guild bank
function Bagnon:GUILDBANKFRAME_OPENED()
	self:ShowFrameAtEvent('inventory', 'guildbank')
end

function Bagnon:GUILDBANKFRAME_CLOSED()
	self:HideFrameAtEvent('inventory', 'guildbank')
end

--crafting
function Bagnon:TRADE_SKILL_SHOW()
	self:ShowFrameAtEvent('inventory', 'craft')
end

function Bagnon:TRADE_SKILL_CLOSE()
	self:HideFrameAtEvent('inventory', 'craft')
end

--player frame
function Bagnon:PLAYER_FRAME_SHOW()
	self:ShowFrameAtEvent('inventory', 'player')
end

function Bagnon:PLAYER_FRAME_HIDE()
	self:HideFrameAtEvent('inventory', 'player')
end


--[[
	Slash Commands
--]]

function Bagnon:AddSlashCommands()
	self:RegisterChatCommand('bagnon', 'HandleSlashCommand')
	self:RegisterChatCommand('bgn', 'HandleSlashCommand')
end

function Bagnon:HandleSlashCommand(cmd)
	cmd = cmd and cmd:lower() or ''
	if cmd == 'bank' then
		self:ToggleFrame('bank')
	elseif cmd == 'bags' then
		self:ToggleFrame('inventory')
	elseif cmd == 'keys' then
		self:ToggleFrame('keys')
	elseif cmd == 'level' then
		self:ToggleLevelGroup()
	elseif cmd == 'badge' or cmd == 'levelbadge' then
		self:ToggleLevelBadge()
	elseif cmd == 'debug' then
		self:PrintDebug()
	elseif cmd == 'version' then
		self:PrintVersion()
	elseif cmd == 'config' then
		self:ShowOptions()
	elseif cmd == '?' or cmd == 'help' then
		self:PrintHelp()
	else
		if not self:ShowOptions() then
			self:PrintHelp()
		end
	end
end

function Bagnon:PrintVersion()
	self:Print(self.SavedSettings:GetDBVersion())
end

--toggles grouping items by required-to-use level band, for both the
--inventory and bank frames at once (testing toggle; will move into the
--options window once the layout itself is confirmed working).
function Bagnon:ToggleLevelGroup()
	local enable = not self.FrameSettings:Get('inventory'):IsLevelGroupEnabled()
	for _, frameID in ipairs({'inventory', 'bank'}) do
		self.FrameSettings:Get(frameID):SetLevelGroup(enable)
	end
	self:Print('Level grouping: ' .. (enable and 'on' or 'off'))
end

--shows/hides the required-level number drawn on each item icon
function Bagnon:ToggleLevelBadge()
	local enable = not self.Settings:ShowingLevelBadge()
	self.Settings:SetShowLevelBadge(enable)
	self:Print('Level badge on item icons: ' .. (enable and 'on' or 'off'))
end

function Bagnon:PrintHelp()
	local function PrintCmd(cmd, desc)
		print(string.format(' - |cFF33FF99%s|r: %s', cmd, desc))
	end

	self:Print(L.Commands)
	PrintCmd('bags', L.CmdShowInventory)
	PrintCmd('bank', L.CmdShowBank)
	PrintCmd('keys', L.CmdShowKeyring)
	PrintCmd('level', 'Toggle grouping by required level')
	PrintCmd('badge', 'Show/hide the required level number on item icons')
	PrintCmd('debug', 'Print diagnostic info (use this when reporting a problem)')
	PrintCmd('version', L.CmdShowVersion)
end

function Bagnon:ShowOptions()
	if LoadAddOn('Bagnon_Config') then
		InterfaceOptionsFrame_OpenToCategory(self.GeneralOptions)
		return true
	end
	return false
end
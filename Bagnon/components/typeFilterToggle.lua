--[[
	typeFilterToggle.lua
		A button that opens a menu to filter the level-group layout down to
		one equipment type (Cloth/Leather/Mail/Plate/Weapon 1H/Weapon 2H).
--]]

local Bagnon = LibStub('AceAddon-3.0'):GetAddon('Bagnon')
local TypeFilterToggle = Bagnon.Classy:New('CheckButton')
Bagnon.TypeFilterToggle = TypeFilterToggle


local SIZE = 20
local NORMAL_TEXTURE_SIZE = 64 * (SIZE/36)
local menuFrame


--[[ Constructor ]]--

function TypeFilterToggle:New(frameID, parent)
	local b = self:Bind(CreateFrame('CheckButton', nil, parent))
	b:SetWidth(SIZE)
	b:SetHeight(SIZE)
	b:RegisterForClicks('anyUp')

	local nt = b:CreateTexture()
	nt:SetTexture([[Interface\Buttons\UI-Quickslot2]])
	nt:SetWidth(NORMAL_TEXTURE_SIZE)
	nt:SetHeight(NORMAL_TEXTURE_SIZE)
	nt:SetPoint('CENTER', 0, -1)
	b:SetNormalTexture(nt)

	local pt = b:CreateTexture()
	pt:SetTexture([[Interface\Buttons\UI-Quickslot-Depress]])
	pt:SetAllPoints(b)
	b:SetPushedTexture(pt)

	local ht = b:CreateTexture()
	ht:SetTexture([[Interface\Buttons\ButtonHilight-Square]])
	ht:SetAllPoints(b)
	b:SetHighlightTexture(ht)

	local ct = b:CreateTexture()
	ct:SetTexture([[Interface\Buttons\CheckButtonHilight]])
	ct:SetAllPoints(b)
	ct:SetBlendMode('ADD')
	b:SetCheckedTexture(ct)

	local icon = b:CreateTexture()
	icon:SetAllPoints(b)
	icon:SetTexture([[Interface\Icons\Spell_Nature_EnchantArmor]])

	b:SetScript('OnClick', b.OnClick)
	b:SetScript('OnEnter', b.OnEnter)
	b:SetScript('OnLeave', b.OnLeave)
	b:SetScript('OnShow', b.OnShow)

	b:SetFrameID(frameID)
	b:UpdateChecked()

	return b
end


--[[ Frame Events ]]--

function TypeFilterToggle:OnClick()
	local frameID = self:GetFrameID()
	local settings = Bagnon.FrameSettings:Get(frameID)
	local current = settings:GetTypeFilter()
	local self_ = self

	local menu = {
		{text = 'All types', checked = (not current or current == ''), func = function()
			settings:SetTypeFilter(nil)
			self_:UpdateChecked()
		end},
	}

	for _, entry in ipairs(Bagnon.Sorting.TYPE_FILTERS) do
		menu[#menu + 1] = {text = entry.label, checked = (current == entry.key), func = function()
			settings:SetTypeFilter(entry.key)
			self_:UpdateChecked()
		end}
	end

	if not menuFrame then
		menuFrame = CreateFrame('Frame', 'BagnonTypeFilterMenu', UIParent, 'UIDropDownMenuTemplate')
	end
	EasyMenu(menu, menuFrame, self, 0, 0, 'MENU')
end

function TypeFilterToggle:OnShow()
	self:UpdateChecked()
end

function TypeFilterToggle:OnEnter()
	if self:GetRight() > (GetScreenWidth() / 2) then
		GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
	else
		GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
	end
	GameTooltip:SetText('Filter by equipment type')
	GameTooltip:AddLine('Only used by the level-group layout, for now.', 1, 1, 1, true)
	GameTooltip:Show()
end

function TypeFilterToggle:OnLeave()
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
end


--[[ Update Methods ]]--

function TypeFilterToggle:UpdateChecked()
	local current = Bagnon.FrameSettings:Get(self:GetFrameID()):GetTypeFilter()
	self:SetChecked(current and current ~= '')
end


--[[ Properties ]]--

function TypeFilterToggle:SetFrameID(frameID)
	if self:GetFrameID() ~= frameID then
		self.frameID = frameID
	end
end

function TypeFilterToggle:GetFrameID()
	return self.frameID
end

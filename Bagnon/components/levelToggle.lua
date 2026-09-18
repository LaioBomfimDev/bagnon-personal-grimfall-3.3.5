--[[
	levelToggle.lua
		A button that toggles grouping items by required-to-use level band.
--]]

local Bagnon = LibStub('AceAddon-3.0'):GetAddon('Bagnon')
local LevelToggle = Bagnon.Classy:New('CheckButton')
Bagnon.LevelToggle = LevelToggle


local SIZE = 20
local NORMAL_TEXTURE_SIZE = 64 * (SIZE/36)


--[[ Constructor ]]--

function LevelToggle:New(frameID, parent)
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
	icon:SetTexture([[Interface\Icons\item_icecrownnecklaceb]])

	b:SetScript('OnClick', b.OnClick)
	b:SetScript('OnEnter', b.OnEnter)
	b:SetScript('OnLeave', b.OnLeave)
	b:SetScript('OnShow', b.OnShow)

	b:SetFrameID(frameID)
	b:UpdateChecked()

	return b
end


--[[ Frame Events ]]--

function LevelToggle:OnClick()
	Bagnon:ToggleLevelGroup()
	self:UpdateChecked()
end

function LevelToggle:OnShow()
	self:UpdateChecked()
end

function LevelToggle:OnEnter()
	if self:GetRight() > (GetScreenWidth() / 2) then
		GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
	else
		GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
	end
	GameTooltip:SetText('Group by required level')
	GameTooltip:Show()
end

function LevelToggle:OnLeave()
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
end


--[[ Update Methods ]]--

function LevelToggle:UpdateChecked()
	self:SetChecked(Bagnon.FrameSettings:Get(self:GetFrameID()):IsLevelGroupEnabled())
end


--[[ Properties ]]--

function LevelToggle:SetFrameID(frameID)
	if self:GetFrameID() ~= frameID then
		self.frameID = frameID
	end
end

function LevelToggle:GetFrameID()
	return self.frameID
end

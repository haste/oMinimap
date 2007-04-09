--[[-------------------------------------------------------------------------
  Copyright (c) 2006, Trond A Ekseth
  All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

      * Redistributions of source code must retain the above copyright
        notice, this list of conditions and the following disclaimer.
      * Redistributions in binary form must reproduce the above
        copyright notice, this list of conditions and the following
        disclaimer in the documentation and/or other materials provided
        with the distribution.
      * Neither the name of oMinimap nor the names of its contributors
        may be used to endorse or promote products derived from this
        software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
---------------------------------------------------------------------------]]

-- Global fluff
function GetMinimapShape() return "SQUARE" end

-- Local fluff
local name = "oMinimap"
local G = getfenv(0)

-- Add-On fluff
local addon = DongleStub('Dongle-1.0-RC3'):New(name)
local defaults = {
	profile = {
		zone = "BOTTOM",
		inline = true,
	},
}

-- DB fluff
local db = addon:InitializeDB("oMinimapDB", defaults, "profile")
local profile = db.profile
local frames = {
	["MinimapZoomIn"] = true,
	["MinimapZoomOut"] = true,
	["MinimapToggleButton"] = true,
	["MinimapZoneTextButton"] = true,
	["MinimapBorderTop"] = true,
	["MiniMapWorldMapButton"] = true,
	["MinimapBorder"] = true,
	["GameTimeFrame"] = true,
	["MiniMapTrackingFrame"] = true,
}

-- Slash fluff
local slash = addon:InitializeSlashCommand("oMinimap Slash Commands", "oMinimap", "omm", "ominimap")
slash:RegisterSlashHandler("|cff33ff99zone|r: Toggle the position of the zone text.", "zone", "zoneToggle")
slash:RegisterSlashHandler("|cff33ff99inline|r: Toggle if the zone text should be inline or not.", "inline", "inlineToggle")

-- Frame fluff
local r, g, b = NORMAL_FONT_COLOR
local setStyle = function(self)
	local zone = self.zone
	local inline = profile.inline
	local zPoint, zMod, fPoint, fMod, fHeight = profile.zone

	zMod = (zPoint == "TOP" and -1) or 1
	fHeight = (inline and 149) or 169
	fPoint = (zPoint == "TOP" and not inline and "BOTTOMLEFT") or "TOPLEFT"
	fMod = (zPoint == "TOP" and not inline and -1) or 1

	self:ClearAllPoints()
	self:SetPoint(fPoint, Minimap, -5, 4 * fMod)

	self:SetWidth(148)
	self:SetHeight(fHeight)

	self:SetFrameLevel(0)
	self:SetFrameStrata"BACKGROUND"

	self:SetBackdropBorderColor(0, 0, 0)
	self:SetBackdropColor(0, 0, 0)
	
	zone:ClearAllPoints()
	zone:SetPoint("LEFT", self, 5, 0)
	zone:SetPoint("RIGHT", self, -5, 0)
	zone:SetPoint(zPoint, self, 0, 9 * zMod)
end

function addon:Initialize()
	local frame = CreateFrame("Frame", "oMinimapFrame", Minimap)
	local zone = Minimap:CreateFontString(nil, "OVERLAY")

	frame.zone = zone
	frame.setStyle = setStyle

	frame:SetBackdrop({
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 16,
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
		insets = {left = 4, right = 4, top = 4, bottom = 4},
	})
	frame:setStyle()

	zone:SetJustifyV"TOP"
	zone:SetJustifyH"CENTER"
	zone:SetFont(STANDARD_TEXT_FONT, 12,"OUTLINE")

	self.Zone = zone

	MinimapCluster:SetMovable(true)
	Minimap:SetScript("OnMouseDown", function()
		if(IsAltKeyDown()) then
		MinimapCluster:ClearAllPoints()
			MinimapCluster:StartMoving()
		else
			Minimap_OnClick()
		end
	end)
	Minimap:SetScript("OnMouseUp", function()
		MinimapCluster:StopMovingOrSizing()
	end)
end

function addon:Enable()
	self:zoneChanged()
	for frame in pairs(frames) do
		G[frame]:Hide()
	end
	frames = nil

	self:RegisterEvent("ZONE_CHANGED", "zoneChanged")
	self:RegisterEvent("ZONE_CHANGED_INDOORS", "zoneChanged")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "zoneChanged")

	MiniMapTrackingFrame:UnregisterEvent"PLAYER_AURAS_CHANGED"
	MiniMapMailFrame:UnregisterEvent"UPDATE_PENDING_MAIL"
	Minimap:SetMaskTexture"Interface\\AddOns\\oMinimap\\texture\\Mask"
end

function addon:Disable()
	for frame in pairs(frames) do
		G[frame]:Show()
	end

	MiniMapTrackingFrame:RegisterEvent"PLAYER_AURAS_CHANGED"
	MiniMapMailFrame:RegisterEvent"UPDATE_PENDING_MAIL"
end

function addon:zoneChanged()
	local zone = self.Zone

	zone:SetText(GetMinimapZoneText())

	local type = GetZonePVPInfo()
	if (type == "sanctuary") then
		zone:SetTextColor(.41, .8, .94)
	elseif (type == "arena") then
		zone:SetTextColor(1, .1, .1)
	elseif (type == "friendly") then
		zone:SetTextColor(.1, 1, .1)
	elseif (type == "hostile") then
		zone:SetTextColor(1, .1, .1)
	elseif (type == "contested") then
		zone:SetTextColor(1, .7, 0)
	else
		zone:SetTextColor(r, g, b)
	end
end

function addon:zoneToggle()
	if(profile.zone == "TOP") then profile.zone = "BOTTOM"
	else profile.zone = "TOP" end

	oMinimapFrame:setStyle()
end

function addon:inlineToggle()
	profile.inline = not profile.inline

	oMinimapFrame:setStyle()
end

G[name] = addon

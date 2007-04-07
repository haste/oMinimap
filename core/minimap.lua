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

local name = "oMinimap"
local G = getfenv(0)
local addon = DongleStub('Dongle-1.0-RC3'):New(name)
local frames = {
	["MinimapZoomIn"] = true,
	["MinimapZoomOut"] = true,
	["MinimapToggleButton"] = true,
	["MinimapZoneTextButton"] = true,
	["MinimapBorderTop"] = true,
	["MiniMapWorldMapButton"] = true,
	["MinimapBorder"] = true,
	["GameTimeFrame"] = true,
}

function addon:Initialize()
	local text = Minimap:CreateFontString(nil, "OVERLAY")
	text:SetWidth(200)
	text:SetHeight(12)
	text:SetPoint("TOP", Minimap, "BOTTOM", 0, -5)
	text:SetJustifyH("CENTER")
	text:SetJustifyV("TOP")
	text:SetFont("Fonts\\FRIZQT__.TTF",12,"OUTLINE")
	self.Zone = text

	self:RegisterEvent("ZONE_CHANGED", "zoneChanged")
	self:RegisterEvent("ZONE_CHANGED_INDOORS", "zoneChanged")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "zoneChanged")
end

function addon:Enable()
	self:zoneChanged()
	for frame in pairs(frames) do
		G[frame]:Hide()
	end

	local frame = CreateFrame("Frame", "oMinimapFrame", Minimap)
	frame:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -5, 4)

	frame:SetBackdrop({
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 16,
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
		insets = {left = 4, right = 4, top = 4, bottom = 4},
	})
	
	frame:SetWidth(150)
	frame:SetHeight(170)
	frame:SetFrameLevel(0)
	frame:SetFrameStrata("BACKGROUND")
	frame:SetBackdropBorderColor(0, 0, 0)
	frame:SetBackdropColor(0, 0, 0)
	MiniMapMailFrame:UnregisterEvent("UPDATE_PENDING_MAIL")
	Minimap:SetMaskTexture("Interface\\AddOns\\oMinimap\\texture\\Mask")
	
	Minimap:ClearAllPoints()
	Minimap:SetPoint("TOPRIGHT", UIParent, -10, -10)
end

function addon:Disable()
	for frame in pairs(frames) do
		G[frame]:Show()
	end

	MiniMapMailFrame:RegisterEvent("UPDATE_PENDING_MAIL")
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
		zone:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
	end
end

G[name] = addon

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
-- Add-On fluff
local addon = CreateFrame("Frame", "oMinimap", Minimap)
local frames = {
	MinimapZoomIn,
	MinimapZoomOut,
	MinimapToggleButton,
	MinimapBorderTop,
	MiniMapWorldMapButton,
	MinimapBorder,
	GameTimeFrame,
}

-- We have to do this here
MinimapCluster:SetMovable(true)
MinimapCluster:SetUserPlaced(true)

-- Frame fluff
local event = function(self)
	MinimapZoneText:SetFont(STANDARD_TEXT_FONT, 12,"OUTLINE")
	MinimapZoneText:SetDrawLayer"OVERLAY"

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
	Minimap:EnableMouseWheel(true)
	Minimap:SetScript("OnMouseWheel", function(self, z)
		local c = Minimap:GetZoom()
		if(z > 0 and c < 5) then
			Minimap:SetZoom(c + 1)
		elseif(z < 0 and c > 0) then
			Minimap:SetZoom(c - 1)
		end
	end)

	MiniMapTrackingIcon:SetTexCoord(.07, .93, .07, .93)
	MiniMapTracking:SetScale(.85)
	MiniMapTrackingButtonBorder:Hide()
	MiniMapTrackingBackground:Hide()
	MiniMapTracking:SetParent(Minimap)
	MiniMapTracking:ClearAllPoints()
	MiniMapTracking:SetPoint"TOPLEFT"

	MiniMapBattlefieldBorder:Hide()
	MiniMapBattlefieldFrame:SetParent(Minimap)
	MiniMapBattlefieldFrame:ClearAllPoints()
	MiniMapBattlefieldFrame:SetPoint("TOPRIGHT", 0, -3)

	MiniMapMailBorder:Hide()
	MiniMapMailFrame:SetParent(Minimap)
	MiniMapMailFrame:ClearAllPoints()
	MiniMapMailFrame:SetPoint"TOP"
	MiniMapMailIcon:SetTexture"Interface\\AddOns\\oMinimap\\texture\\mail"

	MinimapNorthTag:Hide()
	Minimap:SetMaskTexture"Interface\\AddOns\\oMinimap\\texture\\Mask"

	self:ClearAllPoints()
	self:SetPoint("TOPLEFT", Minimap, -5, 4)

	self:SetWidth(149)
	self:SetHeight(149)

	self:SetFrameLevel(0)
	self:SetFrameStrata"BACKGROUND"

	self:SetBackdropColor(0, 0, 0, .4)

	MinimapZoneTextButton:ClearAllPoints()
	MinimapZoneTextButton:SetPoint("LEFT", self, 5, 0)
	MinimapZoneTextButton:SetPoint("RIGHT", self, -5, 0)
	MinimapZoneTextButton:SetPoint("BOTTOM", self, 0, 9)

	local font, size, outline = MinimapZoneText:GetFont()
	MinimapZoneText:SetFont(font, 11, outline)

	for _, frame in pairs(frames) do
		frame:Hide()
	end
	frames = nil
end

addon:SetScript("OnEvent", event)
addon:RegisterEvent"PLAYER_LOGIN"

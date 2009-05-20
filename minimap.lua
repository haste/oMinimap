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

local dummy = function() end

-- We have to do this here
MinimapCluster:SetMovable(true)
MinimapCluster:SetUserPlaced(true)

-- Frame fluff
local event = function(self)
	MinimapZoneText:SetFont(STANDARD_TEXT_FONT, 12,"OUTLINE")
	MinimapZoneText:SetDrawLayer"OVERLAY"

	Minimap:SetScript("OnMouseDown", function(self)
		if(IsAltKeyDown()) then
			MinimapCluster:ClearAllPoints()
			MinimapCluster:StartMoving()
		else
			Minimap_OnClick(self)
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
	MiniMapMailIcon:SetTexture[[Interface\AddOns\oMinimap\textures\mail]]

	MinimapNorthTag:Hide()
	MinimapNorthTag.Show = dummy

	Minimap:SetBlipTexture[[Interface\AddOns\oMinimap\textures\chiiblip]]
	Minimap:SetMaskTexture[[Interface\ChatFrame\ChatFrameBackground]]

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

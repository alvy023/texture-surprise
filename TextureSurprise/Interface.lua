-- Texture Surprise Addon
-- Author: alvy023
-- File: Interface.lua
-- Description: UI framework inspired by Plumber addon with custom styling
-- License: License.txt
-- For more information, visit the project repository.

-- Interface Global Variable
Interface = {}

-- Constants
local BUTTON_MIN_SIZE = 20
local ASSET_PATH = "Interface\\AddOns\\TextureSurprise\\assets\\"

-- Utility Functions
local function DisableSharpening(texture)
    texture:SetTexelSnappingBias(0)
    texture:SetSnapToPixelGrid(false)
end

-- Interface Mixins and Functions
--- Close Button Mixin
Interface.CloseButtonMixin = {}

--- Description: Handles the OnClick event for the close button
--- @param None
--- @return: None
function Interface.CloseButtonMixin:OnClick()
    -- Get the window frame (parent of the header)
    local header = self:GetParent()
    local window = header:GetParent()
    
    if window and window.CloseUI then
        window:CloseUI()
    elseif window then
        window:Hide()
    end
end

--- Description: Shows the normal texture state
--- @param None
--- @return: None
function Interface.CloseButtonMixin:ShowNormalTexture()
    self.Texture:SetTexCoord(0, 0.5, 0, 0.5)
    self.Highlight:SetTexCoord(0, 0.5, 0.5, 1)
end

--- Description: Shows the pushed texture state
--- @param None
--- @return: None
function Interface.CloseButtonMixin:ShowPushedTexture()
    self.Texture:SetTexCoord(0.5, 1, 0, 0.5)
    self.Highlight:SetTexCoord(0.5, 1, 0.5, 1)
end

--- Description: Initializes the close button
--- @param None
--- @return: None
function Interface.CloseButtonMixin:Initialize()
    self:SetSize(BUTTON_MIN_SIZE, BUTTON_MIN_SIZE)

    self.Texture = self:CreateTexture(nil, "ARTWORK")
    self.Texture:SetTexture(ASSET_PATH .. "PlumberCloseButton.tga")
    self.Texture:SetPoint("CENTER", self, "CENTER", 0, 0)
    self.Texture:SetSize(32, 32)
    DisableSharpening(self.Texture)

    self.Highlight = self:CreateTexture(nil, "HIGHLIGHT")
    self.Highlight:SetTexture(ASSET_PATH .. "PlumberCloseButton.tga")
    self.Highlight:SetPoint("CENTER", self, "CENTER", 0, 0)
    self.Highlight:SetSize(32, 32)
    self.Highlight:SetAlpha(0.7)
    DisableSharpening(self.Highlight)

    self:ShowNormalTexture()

    self:SetScript("OnClick", self.OnClick)
    self:SetScript("OnMouseUp", self.ShowNormalTexture)
    self:SetScript("OnMouseDown", self.ShowPushedTexture)
    self:SetScript("OnShow", self.ShowNormalTexture)
end

--- Description: Creates a close button
--- @param parent (Frame to attach the button to)
--- @return: Button frame
function Interface:CreateCloseButton(parent)
    local button = CreateFrame("Button", nil, parent)
    Mixin(button, Interface.CloseButtonMixin)
    button:Initialize()
    return button
end

--- Category Divider Implementation
Interface.CategoryDividerMixin = {}

--- Description: Hides the divider line
--- @param None
--- @return: None
function Interface.CategoryDividerMixin:HideDivider()
    self.Divider:Hide()
end

--- Description: Creates a category divider with text and line
--- @param parent (Frame to attach the divider to)
--- @param alignCenter (Boolean to center align text)
--- @return: FontString with divider
function Interface:CreateCategoryDivider(parent, alignCenter)
    local fontString = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    if alignCenter then
        fontString:SetJustifyH("CENTER")
    else
        fontString:SetJustifyH("LEFT")
    end

    fontString:SetJustifyV("TOP")
    fontString:SetTextColor(1, 1, 1)

    local divider = parent:CreateTexture(nil, "OVERLAY")
    divider:SetHeight(4)
    divider:SetPoint("TOPLEFT", fontString, "BOTTOMLEFT", 0, -4)
    divider:SetPoint("RIGHT", parent, "RIGHT", -8, 0)
    divider:SetTexture(ASSET_PATH .. "PlumberDividerHorizontal.tga")
    divider:SetVertexColor(0.5, 0.5, 0.5)
    DisableSharpening(divider)

    fontString.Divider = divider
    Mixin(fontString, Interface.CategoryDividerMixin)

    return fontString
end

--- Header Frame Implementation
Interface.HeaderFrameMixin = {}

--- Description: Sets the corner size (not implemented)
--- @param a (Size value)
--- @return: None
function Interface.HeaderFrameMixin:SetCornerSize(a)
    -- Placeholder for corner size adjustment
end

--- Description: Shows or hides the close button
--- @param state (Boolean to show or hide)
--- @return: None
function Interface.HeaderFrameMixin:ShowCloseButton(state)
    if self.CloseButton then
        self.CloseButton:SetShown(state)
    end
end

--- Description: Sets the title text of the header
--- @param title (String title text)
--- @return: None
function Interface.HeaderFrameMixin:SetTitle(title)
    self.Title:SetText(title)
end

--- Description: Gets the header height
--- @param None
--- @return: Height value
function Interface.HeaderFrameMixin:GetHeaderHeight()
    return 18
end

--- Description: Creates a header frame with title and optional close button
--- @param parent (Frame to attach the header to)
--- @param showCloseButton (Boolean to show or hide the close button)
--- @return: Header frame
function Interface:CreateHeaderFrame(parent, showCloseButton)
    local f = CreateFrame("Frame", nil, parent)
    f:ClearAllPoints()

    f.Title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.Title:SetJustifyH("CENTER")
    f.Title:SetJustifyV("MIDDLE")
    f.Title:SetTextColor(1, 0.82, 0)
    f.Title:SetPoint("CENTER", f, "TOP", 0, -9)

    if showCloseButton then
        f.CloseButton = Interface:CreateCloseButton(f)
        f.CloseButton:SetPoint("CENTER", f, "TOPRIGHT", -8, -8)
    end

    -- Create 9-piece frame using PlumberFrame texture
    local tex = ASSET_PATH .. "PlumberFrameOpaque.tga"
    local p = {}
    f.pieces = p

    for i = 1, 9 do
        p[i] = f:CreateTexture(nil, "BORDER")
        p[i]:SetTexture(tex)
        DisableSharpening(p[i])
        p[i]:ClearAllPoints()
    end

    -- Position corner pieces
    p[1]:SetPoint("CENTER", f, "TOPLEFT", 0, 0) -- 0,-8
    p[3]:SetPoint("CENTER", f, "TOPRIGHT", 0, 0) -- 0,-8
    p[7]:SetPoint("CENTER", f, "BOTTOMLEFT", 0, 0)
    p[9]:SetPoint("CENTER", f, "BOTTOMRIGHT", 0, 0)

    -- Position edge pieces
    p[2]:SetPoint("TOPLEFT", p[1], "TOPRIGHT", 0, 0)
    p[2]:SetPoint("TOPRIGHT", p[3], "TOPLEFT", 0, 0)
    p[4]:SetPoint("TOPLEFT", p[1], "BOTTOMLEFT", 0, 0)
    p[4]:SetPoint("BOTTOMLEFT", p[7], "TOPLEFT", 0, 0)
    p[5]:SetPoint("TOPLEFT", p[2], "BOTTOMLEFT", 0, 0)
    p[5]:SetPoint("BOTTOMRIGHT", p[6], "TOPLEFT", 0, 0)
    p[6]:SetPoint("TOPRIGHT", p[3], "BOTTOMRIGHT", 0, 0)
    p[6]:SetPoint("BOTTOMRIGHT", p[9], "TOPRIGHT", 0, 0)
    p[8]:SetPoint("BOTTOMLEFT", p[7], "BOTTOMRIGHT", 0, 0)
    p[8]:SetPoint("BOTTOMRIGHT", p[9], "BOTTOMLEFT", 0, 0)

    -- Set texture coordinates for 9-piece
    local size = 16
    p[1]:SetSize(size, size)
    p[1]:SetTexCoord(0, 0.25, 0, 0.25)
    
    p[2]:SetHeight(size)
    p[2]:SetTexCoord(0.25, 0.75, 0, 0.25)
    
    p[3]:SetSize(size, size)
    p[3]:SetTexCoord(0.75, 1, 0, 0.25)
    
    p[4]:SetWidth(size)
    p[4]:SetTexCoord(0, 0.25, 0.25, 0.75)
    
    p[5]:SetTexCoord(0.25, 0.75, 0.25, 0.75)
    
    p[6]:SetWidth(size)
    p[6]:SetTexCoord(0.75, 1, 0.25, 0.75)
    
    p[7]:SetSize(size, size)
    p[7]:SetTexCoord(0, 0.25, 0.75, 1)
    
    p[8]:SetHeight(size)
    p[8]:SetTexCoord(0.25, 0.75, 0.75, 1)
    
    p[9]:SetSize(size, size)
    p[9]:SetTexCoord(0.75, 1, 0.75, 1)

    Mixin(f, Interface.HeaderFrameMixin)
    f:ShowCloseButton(showCloseButton or false)
    f:EnableMouse(true)

    return f
end

--- Styled Window Implementation
--- Description: Creates a styled window with header and content area
--- @param title (String title text)
--- @param width (Width of the window)
--- @param height (Height of the window)
--- @param showCloseButton (Boolean to show or hide the close button)
--- @return: Styled window frame
function Interface:CreateStyledWindow(title, width, height, showCloseButton)
    local frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    frame:SetSize(width or 400, height or 300)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    frame:SetBackdropColor(0, 0, 0, 1)
    
    -- local backTexture = ASSET_PATH .. "PlumberFrameOpaque.tga"
    -- Create header
    local header = Interface:CreateHeaderFrame(frame, showCloseButton)
    header:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    header:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
    header:SetHeight(16)
    header:SetTitle(title or "Texture Surprise")
    
    -- Make header draggable
    header:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            frame:StartMoving()
        end
    end)
    
    header:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" then
            frame:StopMovingOrSizing()
        end
    end)

    -- Create content area with background
    local content = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    content:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, 0)
    content:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)

    frame.header = header
    frame.content = content
    
    -- Add show/hide methods
    frame.CloseUI = function(self)
        self:Hide()
    end

    return frame
end

return Interface
-- Texture Surprise Addon
-- Author: alvy023
-- File: EditMode.lua
-- Description: Edit mode functionality for texture frames
-- License: License.txt
-- For more information, visit the project repository.

-- Load Libraries
local AceGUI = LibStub("AceGUI-3.0")

-- EditMode Global Variable
EditModeTS = {}

-- Constants
local SYSTEM_ID_TEXTURESURPRISE = 37001 -- Unique system ID for Edit Mode
local ASSET_PATH = "Interface\\AddOns\\TextureSurprise\\assets\\"

-- Utility Functions
local function DisableSharpening(texture)
    texture:SetTexelSnappingBias(0)
    texture:SetSnapToPixelGrid(false)
end

-- Edit Mode Mixins and Methods
--- Base EditModeMixin - Provides core edit mode functionality (highlighting, selection, basic behavior)
EditModeTS.EditModeMixin = {}

--- Description: Shows the highlight overlay when in edit mode
--- @param state: Boolean - true to show highlight, false to hide
--- @return: None
function EditModeTS.EditModeMixin:SetHighlighted(state)
    if not self.EditModeHighlightParts then return end
    
    if state then
        -- Set texture and show all border parts
        for _, part in pairs(self.EditModeHighlightParts) do
            part:SetTexture(ASSET_PATH .. "PlumberEditMode")
            part:Show()
        end
        self.isSelected = false
    else
        -- Hide all border parts
        for _, part in pairs(self.EditModeHighlightParts) do
            part:Hide()
        end
    end
end

--- Description: Shows the selection overlay when selected in edit mode
--- @param state: Boolean - true to show selection, false to hide
--- @return: None
function EditModeTS.EditModeMixin:SetSelected(state)
    if not self.EditModeHighlightParts then return end
    
    if state then
        -- Set texture and show all border parts
        for _, part in pairs(self.EditModeHighlightParts) do
            part:SetTexture(ASSET_PATH .. "PlumberEditModeSelect")
            part:Show()
        end
        self.isSelected = true
    else
        -- Hide all border parts
        for _, part in pairs(self.EditModeHighlightParts) do
            part:Hide()
        end
        self.isSelected = false
    end
end

--- Description: Enters edit mode, enabling basic edit mode functionality
--- @param None
--- @return: None
function EditModeTS.EditModeMixin:OnEditModeEnter()
    self.editModeActive = true
    self:EnableMouse(true)
    self:SetHighlighted(true)
end

--- Description: Exits edit mode, disabling edit mode functionality
--- @param None
--- @return: None
function EditModeTS.EditModeMixin:OnEditModeExit()
    self.editModeActive = false
    self:EnableMouse(false)
    self:SetHighlighted(false)
    self:SetSelected(false)
end

--- Description: Initializes the edit mode overlay for the frame using 9-slice border technique
--- @param None
--- @return: None
function EditModeTS.EditModeMixin:InitializeEditMode()
    -- Create 9-slice border system instead of single stretched texture
    self.EditModeHighlightParts = {}
    
    -- Create border pieces: corners, edges, and center
    local borderParts = {
        "TopLeft", "Top", "TopRight",
        "Left", "Center", "Right", 
        "BottomLeft", "Bottom", "BottomRight"
    }
    
    for _, part in ipairs(borderParts) do
        local texture = self:CreateTexture(nil, "OVERLAY")
        DisableSharpening(texture)
        self.EditModeHighlightParts[part] = texture
        texture:Hide()
    end
    
    -- Start with initial positioning
    self:UpdateHighlightPosition()
    
    -- Initialize edit mode state
    self.isSelected = false
    self.editModeActive = false
end

--- Description: Updates the highlight overlay positions
--- @param None
--- @return: None
function EditModeTS.EditModeMixin:UpdateHighlightPosition()
    if not self.EditModeHighlightParts then return end
    
    -- Get current frame dimensions
    local frameWidth = self:GetWidth()
    local frameHeight = self:GetHeight()
    
    -- Border size (assuming the texture has 8-pixel borders)
    local borderSize = 8
    local totalWidth = frameWidth + borderSize 
    local totalHeight = frameHeight + borderSize
    
    -- Calculate edge dimensions (center sections that can stretch)
    local centerWidth = math.max(1, frameWidth)
    local centerHeight = math.max(1, frameHeight)
    
    local parts = self.EditModeHighlightParts
    
    -- Position corners (fixed size, no stretching)
    -- Top-left corner
    parts.TopLeft:SetSize(borderSize, borderSize)
    parts.TopLeft:SetPoint("TOPLEFT", self, "TOPLEFT", -borderSize, borderSize)
    parts.TopLeft:SetTexCoord(0, 0.25, 0, 0.25) -- Top-left quarter
    
    -- Top-right corner  
    parts.TopRight:SetSize(borderSize, borderSize)
    parts.TopRight:SetPoint("TOPRIGHT", self, "TOPRIGHT", borderSize, borderSize)
    parts.TopRight:SetTexCoord(0.75, 1, 0, 0.25) -- Top-right quarter
    
    -- Bottom-left corner
    parts.BottomLeft:SetSize(borderSize, borderSize)
    parts.BottomLeft:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", -borderSize, -borderSize)
    parts.BottomLeft:SetTexCoord(0, 0.25, 0.75, 1) -- Bottom-left quarter
    
    -- Bottom-right corner
    parts.BottomRight:SetSize(borderSize, borderSize)
    parts.BottomRight:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", borderSize, -borderSize)
    parts.BottomRight:SetTexCoord(0.75, 1, 0.75, 1) -- Bottom-right quarter
    
    -- Position edges (stretch in one direction)
    -- Top edge
    parts.Top:SetSize(centerWidth, borderSize)
    parts.Top:SetPoint("TOP", self, "TOP", 0, borderSize)
    parts.Top:SetTexCoord(0.25, 0.75, 0, 0.25) -- Top edge, horizontally tileable
    
    -- Bottom edge
    parts.Bottom:SetSize(centerWidth, borderSize)
    parts.Bottom:SetPoint("BOTTOM", self, "BOTTOM", 0, -borderSize)
    parts.Bottom:SetTexCoord(0.25, 0.75, 0.75, 1) -- Bottom edge, horizontally tileable
    
    -- Left edge
    parts.Left:SetSize(borderSize, centerHeight)
    parts.Left:SetPoint("LEFT", self, "LEFT", -borderSize, 0)
    parts.Left:SetTexCoord(0, 0.25, 0.25, 0.75) -- Left edge, vertically tileable
    
    -- Right edge
    parts.Right:SetSize(borderSize, centerHeight)
    parts.Right:SetPoint("RIGHT", self, "RIGHT", borderSize, 0)
    parts.Right:SetTexCoord(0.75, 1, 0.25, 0.75) -- Right edge, vertically tileable
    
    -- Center (can stretch in both directions)
    parts.Center:SetSize(centerWidth, centerHeight)
    parts.Center:SetPoint("CENTER", self, "CENTER", 0, 0)
    parts.Center:SetTexCoord(0.25, 0.75, 0.25, 0.75) -- Center, tileable in both directions
end

--- Description: Creates an edit menu for the frame
--- @param textureName: Name of the texture being edited
--- @param textureData: Data object for the texture
--- @return: The created menu frame or nil if Interface not available
function EditModeTS.EditModeMixin:CreateEditMenu(textureName, textureData)
    if not Interface or not Interface.CreateStyledWindow then
        return nil
    end
    
    local menu = Interface:CreateStyledWindow("Edit: " .. textureName, 225, 400, true)
    local frame = self
    
    -- Setup menu properties and cleanup
    menu.textureName = textureName
    menu.textureData = textureData
    menu.sourceFrame = frame
    menu:SetFrameStrata("TOOLTIP")

    -- Initialize editMenuPosition if it doesn't exist
    if frame.parentAddon and frame.parentAddon.db and frame.parentAddon.db.profile then
        if not frame.parentAddon.db.profile.editMenuPosition then
            frame.parentAddon.db.profile.editMenuPosition = { x = 0, y = 0 }
        end
        
        -- Restore saved menu position
        local pos = frame.parentAddon.db.profile.editMenuPosition
        menu:ClearAllPoints()
        menu:SetPoint("CENTER", UIParent, "CENTER", pos.x, pos.y)
    end
    
    -- Hook the header's OnMouseUp to save position when dragging stops
    if menu.header then
        local originalOnMouseUp = menu.header:GetScript("OnMouseUp")
        menu.header:SetScript("OnMouseUp", function(self, button)
            -- Call the original handler first
            if originalOnMouseUp then
                originalOnMouseUp(self, button)
            end
            
            -- Save the menu position after dragging
            if button == "LeftButton" and frame.parentAddon and frame.parentAddon.db and frame.parentAddon.db.profile then
                if not frame.parentAddon.db.profile.editMenuPosition then
                    frame.parentAddon.db.profile.editMenuPosition = { x = 0, y = 0 }
                end
                local x, y = menu:GetCenter()
                local screenWidth, screenHeight = UIParent:GetSize()
                local centerX, centerY = screenWidth / 2, screenHeight / 2
                frame.parentAddon.db.profile.editMenuPosition.x = x - centerX
                frame.parentAddon.db.profile.editMenuPosition.y = y - centerY
            end
        end)
    end
    
    menu:SetScript("OnHide", function()
        if frame then
            frame.menu = nil
        end
    end)
    
    -- Create content area for controls
    local menuContent = CreateFrame("Frame", nil, menu.content)
    menuContent:SetPoint("TOPLEFT", menu.content, "TOPLEFT", 0, -5)
    menuContent:SetPoint("BOTTOMRIGHT", menu.content, "BOTTOMRIGHT", 0, 2)
    
    -- Helper function to create increment/decrement buttons
    local function CreateIncrementButtons(parent, anchorFrame, onIncrement, onDecrement, step)
        step = step or 1
        
        local upBtn = CreateFrame("Button", nil, parent)
        upBtn:SetSize(25, 25)
        upBtn:SetPoint("LEFT", anchorFrame, "RIGHT", 0, 7)
        upBtn:SetNormalTexture("Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Up")
        upBtn:SetPushedTexture("Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Down")
        upBtn:SetHighlightTexture("Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Highlight")
        upBtn:SetScript("OnClick", function()
            onIncrement(step)
        end)
        
        local downBtn = CreateFrame("Button", nil, parent)
        downBtn:SetSize(25, 25)
        downBtn:SetPoint("TOP", upBtn, "BOTTOM", 0, 10)
        downBtn:SetNormalTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Up")
        downBtn:SetPushedTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Down")
        downBtn:SetHighlightTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Highlight")
        downBtn:SetScript("OnClick", function()
            onDecrement(step)
        end)
        
        return upBtn, downBtn
    end
    
    -- Position Category
    local positionSizeHeader = Interface:CreateCategoryDivider(menuContent, true)
    positionSizeHeader:SetText("Position & Size")
    positionSizeHeader:SetPoint("TOPLEFT", menuContent, "TOPLEFT", 15, -10)
    
    -- X Position control
    local xPosBox = CreateFrame("EditBox", nil, menuContent, "InputBoxTemplate")
    xPosBox:SetSize(60, 20)
    xPosBox:SetPoint("TOPLEFT", positionSizeHeader, "BOTTOMLEFT", 10, -30)
    xPosBox:SetText(tostring(math.floor(textureData.x or 0)))
    xPosBox:SetAutoFocus(false)
    xPosBox:SetScript("OnEnterPressed", function(self)
        local value = tonumber(self:GetText())
        if value then
            textureData.x = value
            local centerX = UIParent:GetWidth() / 2
            local centerY = UIParent:GetHeight() / 2
            frame:ClearAllPoints()
            frame:SetPoint("CENTER", UIParent, "CENTER", value, textureData.y or 0)
        end
        self:ClearFocus()
    end)
    menu.content.xPosBox = xPosBox
    
    local xPosLabel = menuContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    xPosLabel:SetText("X:")
    xPosLabel:SetPoint("BOTTOMLEFT", xPosBox, "TOPLEFT", -4, 2)
    
    CreateIncrementButtons(menuContent, xPosBox, 
        function(step)
            local current = tonumber(xPosBox:GetText()) or 0
            current = current + step
            xPosBox:SetText(tostring(math.floor(current)))
            textureData.x = current
            frame:ClearAllPoints()
            frame:SetPoint("CENTER", UIParent, "CENTER", current, textureData.y or 0)
        end,
        function(step)
            local current = tonumber(xPosBox:GetText()) or 0
            current = current - step
            xPosBox:SetText(tostring(math.floor(current)))
            textureData.x = current
            frame:ClearAllPoints()
            frame:SetPoint("CENTER", UIParent, "CENTER", current, textureData.y or 0)
        end,
        1
    )
    
    -- Y Position control
    local yPosBox = CreateFrame("EditBox", nil, menuContent, "InputBoxTemplate")
    yPosBox:SetSize(60, 20)
    yPosBox:SetPoint("LEFT", xPosBox, "RIGHT", 30, 0)
    yPosBox:SetText(tostring(math.floor(textureData.y or 0)))
    yPosBox:SetAutoFocus(false)
    yPosBox:SetScript("OnEnterPressed", function(self)
        local value = tonumber(self:GetText())
        if value then
            textureData.y = value
            frame:ClearAllPoints()
            frame:SetPoint("CENTER", UIParent, "CENTER", textureData.x or 0, value)
        end
        self:ClearFocus()
    end)
    menu.content.yPosBox = yPosBox
    
    local yPosLabel = menuContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    yPosLabel:SetText("Y:")
    yPosLabel:SetPoint("BOTTOMLEFT", yPosBox, "TOPLEFT", -4, 2)
    
    CreateIncrementButtons(menuContent, yPosBox, 
        function(step)
            local current = tonumber(yPosBox:GetText()) or 0
            current = current + step
            yPosBox:SetText(tostring(math.floor(current)))
            textureData.y = current
            frame:ClearAllPoints()
            frame:SetPoint("CENTER", UIParent, "CENTER", textureData.x or 0, current)
        end,
        function(step)
            local current = tonumber(yPosBox:GetText()) or 0
            current = current - step
            yPosBox:SetText(tostring(math.floor(current)))
            textureData.y = current
            frame:ClearAllPoints()
            frame:SetPoint("CENTER", UIParent, "CENTER", textureData.x or 0, current)
        end,
        1
    )
    
    -- Width control
    local widthBox = CreateFrame("EditBox", nil, menuContent, "InputBoxTemplate")
    widthBox:SetSize(60, 20)
    widthBox:SetPoint("TOPLEFT", xPosBox, "BOTTOMLEFT", 0, -30)
    widthBox:SetText(tostring(textureData.width))
    widthBox:SetAutoFocus(false)
    widthBox:SetScript("OnEnterPressed", function(self)
        local value = tonumber(self:GetText())
        if value and value > 0 then
            textureData.width = value
            frame:UpdateSize(value, nil)
        end
        self:ClearFocus()
    end)

    local widthLabel = menuContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    widthLabel:SetText("Width:")
    widthLabel:SetPoint("BOTTOMLEFT", widthBox, "TOPLEFT", -4, 2)
    
    CreateIncrementButtons(menuContent, widthBox, 
        function(step)
            local current = tonumber(widthBox:GetText()) or 100
            current = math.max(1, current + step)
            widthBox:SetText(tostring(current))
            textureData.width = current
            frame:UpdateSize(current, nil)
        end,
        function(step)
            local current = tonumber(widthBox:GetText()) or 100
            current = math.max(1, current - step)
            widthBox:SetText(tostring(current))
            textureData.width = current
            frame:UpdateSize(current, nil)
        end,
        1
    )
    
    -- Height control
    local heightBox = CreateFrame("EditBox", nil, menuContent, "InputBoxTemplate")
    heightBox:SetSize(60, 20)
    heightBox:SetPoint("LEFT", widthBox, "RIGHT", 30, 0)
    heightBox:SetText(tostring(textureData.height))
    heightBox:SetAutoFocus(false)
    heightBox:SetScript("OnEnterPressed", function(self)
        local value = tonumber(self:GetText())
        if value and value > 0 then
            textureData.height = value
            frame:UpdateSize(nil, value)
        end
        self:ClearFocus()
    end)

    local heightLabel = menuContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    heightLabel:SetText("Height:")
    heightLabel:SetPoint("BOTTOMLEFT", heightBox, "TOPLEFT", -4, 2)
    
    CreateIncrementButtons(menuContent, heightBox, 
        function(step)
            local current = tonumber(heightBox:GetText()) or 100
            current = math.max(1, current + step)
            heightBox:SetText(tostring(current))
            textureData.height = current
            frame:UpdateSize(nil, current)
        end,
        function(step)
            local current = tonumber(heightBox:GetText()) or 100
            current = math.max(1, current - step)
            heightBox:SetText(tostring(current))
            textureData.height = current
            frame:UpdateSize(nil, current)
        end,
        1
    )

    -- Rotation slider
    local rotationSlider = CreateFrame("Slider", nil, menuContent, "OptionsSliderTemplate")
    rotationSlider:SetSize(185, 20)
    rotationSlider:SetPoint("TOPLEFT", widthBox, "BOTTOMLEFT", -4, -30)
    rotationSlider:SetMinMaxValues(-180, 180)
    rotationSlider:SetValue(textureData.rotation or 0)
    rotationSlider:SetValueStep(15)
    rotationSlider:SetObeyStepOnDrag(true)
    rotationSlider.Low:SetText("-180°")
    rotationSlider.High:SetText("180°")
    rotationSlider:EnableKeyboard(true)

    local rotationLabel = menuContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    rotationLabel:SetText("Rotation: " .. string.format("%.0f°", textureData.rotation or 0))
    rotationLabel:SetPoint("BOTTOMLEFT", rotationSlider, "TOPLEFT", 0, 2)

    rotationSlider:SetScript("OnValueChanged", function(self, value)
        rotationLabel:SetText("Rotation: " .. string.format("%.0f°", value))
        value = -1 * math.floor(value + 0.5)
        textureData.rotation = value
        frame:UpdateRotation(value)
    end)
    
    
    -- Appearance Category
    local appearanceHeader = Interface:CreateCategoryDivider(menuContent, true)
    appearanceHeader:SetText("Appearance")
    appearanceHeader:SetPoint("TOPLEFT", rotationSlider, "BOTTOMLEFT", -6, -24)
    
    -- Alpha slider
    local alphaSlider = CreateFrame("Slider", nil, menuContent, "OptionsSliderTemplate")
    alphaSlider:SetSize(185, 20)
    alphaSlider:SetPoint("TOPLEFT", appearanceHeader, "BOTTOMLEFT", 5, -40)
    alphaSlider:SetMinMaxValues(0, 1)
    alphaSlider:SetValue(textureData.alpha or 1)
    alphaSlider:SetValueStep(0.01)

    local alphaLabel = menuContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    alphaLabel:SetText("Alpha: " .. string.format("%.2f", textureData.alpha or 1))
    alphaLabel:SetPoint("BOTTOMLEFT", alphaSlider, "TOPLEFT", 0, 2)
    
    alphaSlider:SetScript("OnValueChanged", function(self, value)
        textureData.alpha = value
        frame:SetAlpha(value)
        alphaLabel:SetText("Alpha: " .. string.format("%.2f", value))
    end)

    -- Strata control (dropdown, level)
    local strataDropdown = AceGUI:Create("Dropdown")
    strataDropdown:SetWidth(120)
    strataDropdown.frame:SetParent(menuContent)
    strataDropdown.frame:SetPoint("TOPLEFT", alphaSlider, "BOTTOMLEFT", -3, -30)
    strataDropdown:SetLabel("") 
    local strataList = {
        ["BACKGROUND"] = "BACKGROUND",
        ["LOW"] = "LOW",
        ["MEDIUM"] = "MEDIUM",
        ["HIGH"] = "HIGH",
        ["DIALOG"] = "DIALOG",
        ["TOOLTIP"] = "TOOLTIP"
    }
    local strataOrder = {"BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG", "TOOLTIP"}
    strataDropdown:SetList(strataList, strataOrder)
    strataDropdown:SetValue(textureData.strata or "MEDIUM")
    strataDropdown:SetCallback("OnValueChanged", function(_, _, value)
        textureData.strata = value
        frame:SetFrameStrata(value)
    end)
    
    -- Create custom label for strata dropdown
    local strataDropdownLabel = menuContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    strataDropdownLabel:SetText("Frame Strata:")
    strataDropdownLabel:SetPoint("BOTTOMLEFT", strataDropdown.frame, "TOPLEFT", 2, 2)
    
    local strataBox = CreateFrame("EditBox", nil, menuContent, "InputBoxTemplate")
    strataBox:SetSize(48, 20)
    strataBox:SetPoint("LEFT", strataDropdown.frame, "RIGHT", 20, 0)
    strataBox:SetText(tostring(textureData.level))
    strataBox:SetAutoFocus(false)
    strataBox:SetScript("OnEnterPressed", function(self)
        local value = tonumber(self:GetText())
        if value and value >= 0 then
            textureData.level = value
            frame:SetFrameLevel(value)
        end
        self:ClearFocus()
    end)

    local strataLevelLabel = menuContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    strataLevelLabel:SetText("Level:")
    strataLevelLabel:SetPoint("BOTTOMLEFT", strataBox, "TOPLEFT", -4, 5)
    
    -- Action buttons at bottom
    local removeBtn = CreateFrame("Button", nil, menuContent, "UIPanelButtonTemplate")
    removeBtn:SetSize(100, 25)
    removeBtn:SetPoint("BOTTOMLEFT", menuContent, "BOTTOMLEFT", 10, 10)
    removeBtn:SetText("Remove")
    removeBtn:SetScript("OnClick", function()
        TextureManager:RemoveTexture(textureName, frame.parentAddon)
        menu:Hide()
    end)

    local lockBtn = CreateFrame("Button", nil, menuContent, "UIPanelButtonTemplate")
    lockBtn:SetSize(100, 25)
    lockBtn:SetPoint("LEFT", removeBtn, "RIGHT", 5, 0)
    lockBtn:SetText(textureData.locked and "Unlock" or "Lock")
    lockBtn:SetScript("OnClick", function()
        textureData.locked = not textureData.locked
        frame.locked = textureData.locked
        frame:SetMovable(not textureData.locked and frame.editModeActive)
        lockBtn:SetText(textureData.locked and "Unlock" or "Lock")
    end)
    
    return menu
end

--- EditModeTextureMixin - Extends EditModeMixin for texture frames specifically
EditModeTS.EditModeTextureMixin = {}
for k, v in pairs(EditModeTS.EditModeMixin) do
    EditModeTS.EditModeTextureMixin[k] = v
end

--- Description: Handles the start of dragging the texture frame
--- @param None
--- @return: None
function EditModeTS.EditModeTextureMixin:OnDragStart()
    if not self.locked and self.editModeActive then
        self:StartMoving()
    end
end

--- Description: Handles the stop of dragging the texture frame
--- @param None
--- @return: None
function EditModeTS.EditModeTextureMixin:OnDragStop()
    if not self.locked and self.editModeActive then
        self:StopMovingOrSizing()
        self:UpdatePosition()
    end
end

--- Description: Shows the highlight overlay when hovering (texture-specific override)
--- @param None
--- @return: None
function EditModeTS.EditModeTextureMixin:ShowHighlighted()
    if not self:IsShown() then return end
    self:SetHighlighted(true)
end

--- Description: Shows the selection overlay and opens the edit menu (texture-specific override)
--- @param None
--- @return: None
function EditModeTS.EditModeTextureMixin:ShowSelected()
    if not self:IsShown() then return end
    self:SetSelected(true)
    self:ShowEditMenu()
end

--- Description: Hides the selection overlay and closes the edit menu
--- @param None
--- @return: None
function EditModeTS.EditModeTextureMixin:HideSelection()
    self:SetSelected(false)
    if EditModeManagerFrame and EditModeManagerFrame:IsShown() then
        self:SetHighlighted(true)
    else
        self:SetHighlighted(false)
    end
    if self.menu then
        self.menu:Hide()
    end
end

--- Description: Enters edit mode for texture frames (extends base functionality)
--- @param None
--- @return: None
function EditModeTS.EditModeTextureMixin:OnEditModeEnter()
    -- Call parent method
    EditModeTS.EditModeMixin.OnEditModeEnter(self)

    -- Add texture-specific functionality
    self:SetMovable(not self.locked)
    self:RegisterForDrag("LeftButton")
end

--- Description: Exits edit mode for texture frames (extends base functionality)
--- @param None
--- @return: None
function EditModeTS.EditModeTextureMixin:OnEditModeExit()
    -- Add texture-specific cleanup first
    self:SetMovable(false)
    self:RegisterForDrag()
    if self.menu then
        self.menu:Hide()
    end
    
    -- Call parent method
    EditModeTS.EditModeMixin.OnEditModeExit(self)
end

--- Description: Updates the texture's position in the database after dragging
--- @param None
--- @return: None
function EditModeTS.EditModeTextureMixin:UpdatePosition()
    local frameX, frameY = self:GetCenter()
    local screenWidth, screenHeight = UIParent:GetSize()
    local centerX, centerY = screenWidth / 2, screenHeight / 2
    local relativeX = frameX - centerX
    local relativeY = frameY - centerY
    
    -- Update database
    if self.parentAddon.db.profile.textures[self.textureName] then
        self.parentAddon.db.profile.textures[self.textureName].x = relativeX
        self.parentAddon.db.profile.textures[self.textureName].y = relativeY
    end

    -- Update the edit menu fields if open
    if self.menu then
        if self.menu.content.xPosBox then
            self.menu.content.xPosBox:SetText(tostring(math.floor(relativeX)))
        end
        if self.menu.content.yPosBox then
            self.menu.content.yPosBox:SetText(tostring(math.floor(relativeY)))
        end
    end
end

--- Description: Updates the frame size and refreshes highlight overlay
--- @param width: New width value
--- @param height: New height value (optional)
--- @return: None
function EditModeTS.EditModeTextureMixin:UpdateSize(width, height)
    if width then
        self:SetWidth(width)
    end
    if height then
        self:SetHeight(height)
    end
    
    -- Update the highlight overlay to maintain 20 pixel margin
    self:UpdateHighlightPosition()
end

--- Description: Updates the texture rotation
--- @param rotation: New rotation value in degrees
--- @return: None
function EditModeTS.EditModeTextureMixin:UpdateRotation(rotation)
    if rotation and self.texture then
        self.texture:SetRotation(math.rad(rotation))
    end
end

--- Description: Displays the edit menu for the texture
--- @param None
--- @return: None
function EditModeTS.EditModeTextureMixin:ShowEditMenu()
    if self.menu then
        self.menu:Show()
        return
    end
    
    local textureData = self.parentAddon.db.profile.textures[self.textureName]
    if not textureData then return end
    
    -- Use the CreateEditMenu method from EditModeMixin
    self.menu = self:CreateEditMenu(self.textureName, textureData)
    if self.menu then
        self.menu:Show()
    end
end

--- Description: Sets up edit mode functionality for a texture frame
--- @param frame: The texture frame to set up
--- @param parentAddon: Reference to the main addon object
--- @param textureName: Name of the texture
--- @return: None
function EditModeTS:EnableTextureFrameEditMode(frame, parentAddon, textureName)
    -- Apply the EditModeTextureMixin (which inherits from EditModeMixin)
    Mixin(frame, self.EditModeTextureMixin)
    
    -- Set frame properties
    frame.parentAddon = parentAddon
    frame.textureName = textureName
    frame.systemName = "TextureSurprise_" .. textureName
    
    local textureData = parentAddon.db.profile.textures[textureName]
    frame.locked = textureData and textureData.locked or false
    
    -- Initialize the edit mode functionality
    frame:InitializeEditMode()

    -- Set up event handlers
    frame:SetScript("OnDragStart", frame.OnDragStart)
    frame:SetScript("OnDragStop", frame.OnDragStop)
    frame:SetScript("OnMouseDown", function(self, button)
        if self.editModeActive and button == "LeftButton" then
            self:ShowSelected()
        end
    end)
    frame:RegisterEvent("GLOBAL_MOUSE_DOWN")
    frame:SetScript("OnEvent", function(self, event)
        if event == "GLOBAL_MOUSE_DOWN" and self.editModeActive and self.isSelected then
            -- Check if the mouse is over the edit menu before deselecting
            if self.menu and self.menu:IsShown() then
                local mouseX, mouseY = GetCursorPosition()
                local scale = self.menu:GetEffectiveScale()
                mouseX = mouseX / scale
                mouseY = mouseY / scale
                
                -- Get menu bounds
                local left = self.menu:GetLeft()
                local right = self.menu:GetRight()
                local top = self.menu:GetTop()
                local bottom = self.menu:GetBottom()
                
                -- If mouse is inside the menu bounds, don't deselect
                if mouseX >= left and mouseX <= right and mouseY >= bottom and mouseY <= top then
                    return -- Don't deselect, click is inside menu
                end
            end
            
            -- Mouse is outside menu (or menu not shown), deselect
            self:HideSelection()
        end
    end)

    EventRegistry:RegisterCallback("EditMode.Enter", frame.OnEditModeEnter, frame)
    EventRegistry:RegisterCallback("EditMode.Exit", frame.OnEditModeExit, frame)
end

--- EditModeGroupMixin - Extends EditModeMixin for group frames
EditModeTS.EditModeGroupMixin = {}
for k, v in pairs(EditModeTS.EditModeMixin) do
    EditModeTS.EditModeGroupMixin[k] = v
end

--- Description: Handles the start of dragging the group frame
--- @param None
--- @return: None
function EditModeTS.EditModeGroupMixin:OnDragStart()
    if not self.locked and self.editModeActive then
        self:StartMoving()
    end
end

--- Description: Handles the stop of dragging the group frame
--- @param None
--- @return: None
function EditModeTS.EditModeGroupMixin:OnDragStop()
    if not self.locked and self.editModeActive then
        self:StopMovingOrSizing()
        self:UpdateGroupPosition()
    end
end

--- Description: Shows the highlight overlay when hovering (group-specific override)
--- @param None
--- @return: None
function EditModeTS.EditModeGroupMixin:ShowHighlighted()
    if not self:IsShown() then return end
    self:SetHighlighted(true)
end

--- Description: Shows the selection overlay and opens the edit menu (group-specific override)
--- @param None
--- @return: None
function EditModeTS.EditModeGroupMixin:ShowSelected()
    if not self:IsShown() then return end
    self:SetSelected(true)
    self:ShowGroupEditMenu()
end

--- Description: Hides the selection overlay and closes the edit menu
--- @param None
--- @return: None
function EditModeTS.EditModeGroupMixin:HideSelection()
    self:SetSelected(false)
    if EditModeManagerFrame and EditModeManagerFrame:IsShown() then
        self:SetHighlighted(true)
    else
        self:SetHighlighted(false)
    end
    if self.menu then
        self.menu:Hide()
    end
end

--- Description: Enters edit mode for group frames (extends base functionality)
--- @param None
--- @return: None
function EditModeTS.EditModeGroupMixin:OnEditModeEnter()
    -- Call parent method
    EditModeTS.EditModeMixin.OnEditModeEnter(self)

    -- Add group-specific functionality
    self:SetMovable(not self.locked)
    self:RegisterForDrag("LeftButton")
    
    -- Make child textures non-interactive in edit mode
    self:SetChildTexturesInteractable(false)
end

--- Description: Exits edit mode for group frames (extends base functionality)
--- @param None
--- @return: None
function EditModeTS.EditModeGroupMixin:OnEditModeExit()
    -- Add group-specific cleanup first
    self:SetMovable(false)
    self:RegisterForDrag()
    if self.menu then
        self.menu:Hide()
    end
    
    -- Restore child texture interactability
    self:SetChildTexturesInteractable(true)
    
    -- Call parent method
    EditModeTS.EditModeMixin.OnEditModeExit(self)
end

--- Description: Sets whether child textures can be interacted with
--- @param interactable: Boolean indicating if textures should be interactable
--- @return: None
function EditModeTS.EditModeGroupMixin:SetChildTexturesInteractable(interactable)
    if not self.groupName or not self.parentAddon then return end
    
    local group = self.parentAddon.db.profile.groups[self.groupName]
    if not group then return end
    
    for _, textureName in ipairs(group.textures) do
        local textureFrame = TextureManager.frames[textureName]
        if textureFrame then
            textureFrame:EnableMouse(interactable)
        end
    end
end

--- Description: Updates the group's position in the database after dragging
--- @param None
--- @return: None
function EditModeTS.EditModeGroupMixin:UpdateGroupPosition()
    local frameX, frameY = self:GetCenter()
    local screenWidth, screenHeight = UIParent:GetSize()
    local centerX, centerY = screenWidth / 2, screenHeight / 2
    local relativeX = frameX - centerX
    local relativeY = frameY - centerY
    
    -- Update database through GroupManager
    GroupManager:UpdateGroupPosition(self.groupName, relativeX, relativeY, self.parentAddon)
end

--- Description: Creates the edit menu for a group
--- @param None
--- @return: The created menu frame or nil
function EditModeTS.EditModeGroupMixin:ShowGroupEditMenu()
    if self.menu then
        self.menu:Show()
        return
    end
    
    local groupData = self.parentAddon.db.profile.groups[self.groupName]
    if not groupData then return end
    
    -- Create the menu using styled interface
    self.menu = Interface:CreateStyledWindow("Edit Group: " .. self.groupName, 225, 350, true)
    local menu = self.menu
    local frame = self
    
    -- Setup menu properties
    menu.groupName = self.groupName
    menu.groupData = groupData
    menu.sourceFrame = frame
    menu:SetFrameStrata("TOOLTIP")
    
    -- Initialize editMenuPosition if it doesn't exist
    if frame.parentAddon and frame.parentAddon.db and frame.parentAddon.db.profile then
        if not frame.parentAddon.db.profile.editMenuPosition then
            frame.parentAddon.db.profile.editMenuPosition = {x = 0, y = 0}
        end
        
        local centerX, centerY = UIParent:GetWidth() / 2, UIParent:GetHeight() / 2
        menu:SetPoint("CENTER", UIParent, "CENTER", 
            frame.parentAddon.db.profile.editMenuPosition.x, 
            frame.parentAddon.db.profile.editMenuPosition.y)
        
        menu:SetScript("OnDragStop", function()
            menu:StopMovingOrSizing()
            if frame and frame.parentAddon and frame.parentAddon.db and frame.parentAddon.db.profile then
                local x, y = menu:GetCenter()
                local screenWidth, screenHeight = UIParent:GetSize()
                local centerX, centerY = screenWidth / 2, screenHeight / 2
                frame.parentAddon.db.profile.editMenuPosition.x = x - centerX
                frame.parentAddon.db.profile.editMenuPosition.y = y - centerY
            end
        end)
    end
    
    menu:SetScript("OnHide", function()
        if frame then
            frame.menu = nil
        end
    end)
    
    -- Create content area for controls
    local menuContent = CreateFrame("Frame", nil, menu.content)
    menuContent:SetPoint("TOPLEFT", menu.content, "TOPLEFT", 0, -5)
    menuContent:SetPoint("BOTTOMRIGHT", menu.content, "BOTTOMRIGHT", 0, 2)
    
    -- Position & Size Category
    local positionSizeHeader = Interface:CreateCategoryDivider(menuContent, true)
    positionSizeHeader:SetText("Position")
    positionSizeHeader:SetPoint("TOPLEFT", menuContent, "TOPLEFT", 15, -10)
    
    -- X Position control
    local xPosBox = CreateFrame("EditBox", nil, menuContent, "InputBoxTemplate")
    xPosBox:SetSize(60, 20)
    xPosBox:SetPoint("TOPLEFT", positionSizeHeader, "BOTTOMLEFT", 10, -30)
    xPosBox:SetText(tostring(math.floor(groupData.x or 0)))
    xPosBox:SetAutoFocus(false)
    xPosBox:SetScript("OnEnterPressed", function(self)
        local value = tonumber(self:GetText())
        if value then
            groupData.x = value
            frame:ClearAllPoints()
            frame:SetPoint("CENTER", UIParent, "CENTER", value, groupData.y or 0)
            GroupManager:UpdateGroupPosition(frame.groupName, value, groupData.y or 0, frame.parentAddon)
        end
        self:ClearFocus()
    end)
    
    local xPosLabel = menuContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    xPosLabel:SetText("X:")
    xPosLabel:SetPoint("BOTTOMLEFT", xPosBox, "TOPLEFT", -4, 2)
    
    -- Y Position control
    local yPosBox = CreateFrame("EditBox", nil, menuContent, "InputBoxTemplate")
    yPosBox:SetSize(60, 20)
    yPosBox:SetPoint("LEFT", xPosBox, "RIGHT", 30, 0)
    yPosBox:SetText(tostring(math.floor(groupData.y or 0)))
    yPosBox:SetAutoFocus(false)
    yPosBox:SetScript("OnEnterPressed", function(self)
        local value = tonumber(self:GetText())
        if value then
            groupData.y = value
            frame:ClearAllPoints()
            frame:SetPoint("CENTER", UIParent, "CENTER", groupData.x or 0, value)
            GroupManager:UpdateGroupPosition(frame.groupName, groupData.x or 0, value, frame.parentAddon)
        end
        self:ClearFocus()
    end)
    
    local yPosLabel = menuContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    yPosLabel:SetText("Y:")
    yPosLabel:SetPoint("BOTTOMLEFT", yPosBox, "TOPLEFT", -4, 2)
    
    -- Group Members Category
    local membersHeader = Interface:CreateCategoryDivider(menuContent, true)
    membersHeader:SetText("Members")
    membersHeader:SetPoint("TOPLEFT", xPosBox, "BOTTOMLEFT", -10, -24)
    
    local membersLabel = menuContent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    membersLabel:SetPoint("TOPLEFT", membersHeader, "BOTTOMLEFT", 10, -10)
    membersLabel:SetText(string.format("%d texture(s)", #groupData.textures))
    
    -- List member names
    local membersList = menuContent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    membersList:SetPoint("TOPLEFT", membersLabel, "BOTTOMLEFT", 0, -5)
    membersList:SetPoint("RIGHT", menuContent, "RIGHT", -15, 0)
    membersList:SetJustifyH("LEFT")
    membersList:SetJustifyV("TOP")
    
    local memberText = ""
    for i, textureName in ipairs(groupData.textures) do
        memberText = memberText .. "• " .. textureName
        if i < #groupData.textures then
            memberText = memberText .. "\n"
        end
    end
    membersList:SetText(memberText)
    
    -- Appearance Category
    local appearanceHeader = Interface:CreateCategoryDivider(menuContent, true)
    appearanceHeader:SetText("Appearance")
    appearanceHeader:SetPoint("TOPLEFT", membersList, "BOTTOMLEFT", -10, -20)
    
    -- Visibility checkbox
    local visibilityCheck = CreateFrame("CheckButton", nil, menuContent, "UICheckButtonTemplate")
    visibilityCheck:SetSize(24, 24)
    visibilityCheck:SetPoint("TOPLEFT", appearanceHeader, "BOTTOMLEFT", 10, -10)
    visibilityCheck:SetChecked(groupData.visible ~= false)
    visibilityCheck:SetScript("OnClick", function(self)
        groupData.visible = self:GetChecked()
        frame:SetShown(groupData.visible)
    end)
    
    local visibilityLabel = menuContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    visibilityLabel:SetText("Visible")
    visibilityLabel:SetPoint("LEFT", visibilityCheck, "RIGHT", 5, 0)
    
    -- Action buttons at bottom
    local lockBtn = CreateFrame("Button", nil, menuContent, "UIPanelButtonTemplate")
    lockBtn:SetSize(100, 25)
    lockBtn:SetPoint("BOTTOMLEFT", menuContent, "BOTTOMLEFT", 10, 10)
    lockBtn:SetText(groupData.locked and "Unlock" or "Lock")
    lockBtn:SetScript("OnClick", function()
        groupData.locked = not groupData.locked
        frame.locked = groupData.locked
        frame:SetMovable(not groupData.locked and frame.editModeActive)
        lockBtn:SetText(groupData.locked and "Unlock" or "Lock")
    end)
    
    local ungroupBtn = CreateFrame("Button", nil, menuContent, "UIPanelButtonTemplate")
    ungroupBtn:SetSize(100, 25)
    ungroupBtn:SetPoint("LEFT", lockBtn, "RIGHT", 5, 0)
    ungroupBtn:SetText("Ungroup")
    ungroupBtn:SetScript("OnClick", function()
        -- Confirm ungroup
        StaticPopupDialogs["TEXTURESURPRISE_UNGROUP_CONFIRM"] = {
            text = "Ungroup all textures in '" .. frame.groupName .. "'?",
            button1 = "Yes",
            button2 = "No",
            OnAccept = function()
                GroupManager:DeleteGroup(frame.groupName, frame.parentAddon)
                menu:Hide()
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
        }
        StaticPopup_Show("TEXTURESURPRISE_UNGROUP_CONFIRM")
    end)
    
    menu:Show()
    return menu
end

--- Description: Sets up edit mode functionality for a group frame
--- @param frame: The group frame to set up
--- @param parentAddon: Reference to the main addon object
--- @param groupName: Name of the group
--- @return: None
function EditModeTS:EnableGroupFrameEditMode(frame, parentAddon, groupName)
    -- Apply the EditModeGroupMixin (which inherits from EditModeMixin)
    Mixin(frame, self.EditModeGroupMixin)
    
    -- Set frame properties
    frame.parentAddon = parentAddon
    frame.groupName = groupName
    frame.systemName = "TextureSurprise_Group_" .. groupName
    
    local groupData = parentAddon.db.profile.groups[groupName]
    frame.locked = groupData and groupData.locked or false
    
    -- Initialize the edit mode functionality
    frame:InitializeEditMode()

    -- Set up event handlers
    frame:SetScript("OnDragStart", frame.OnDragStart)
    frame:SetScript("OnDragStop", frame.OnDragStop)
    frame:SetScript("OnMouseDown", function(self, button)
        if self.editModeActive and button == "LeftButton" then
            self:ShowSelected()
        end
    end)
    frame:RegisterEvent("GLOBAL_MOUSE_DOWN")
    
    frame:SetScript("OnEvent", function(self, event)
        if event == "GLOBAL_MOUSE_DOWN" and self.editModeActive and self.isSelected then
            -- Check if the mouse is over the edit menu before deselecting
            if self.menu and self.menu:IsShown() then
                local mouseX, mouseY = GetCursorPosition()
                local scale = self.menu:GetEffectiveScale()
                mouseX = mouseX / scale
                mouseY = mouseY / scale
                
                -- Get menu bounds
                local left = self.menu:GetLeft()
                local right = self.menu:GetRight()
                local top = self.menu:GetTop()
                local bottom = self.menu:GetBottom()
                
                -- If mouse is inside the menu bounds, don't deselect
                if mouseX >= left and mouseX <= right and mouseY >= bottom and mouseY <= top then
                    return -- Don't deselect, click is inside menu
                end
            end
            
            -- Mouse is outside menu (or menu not shown), deselect
            self:HideSelection()
        end
    end)

    EventRegistry:RegisterCallback("EditMode.Enter", frame.OnEditModeEnter, frame)
    EventRegistry:RegisterCallback("EditMode.Exit", frame.OnEditModeExit, frame)
end

-- Return the EditMode table
return EditModeTS
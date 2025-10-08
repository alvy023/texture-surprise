-- Texture Surprise Addon
-- Author: alvy023
-- File: EditMode.lua
-- Description: Edit mode functionality for texture frames
-- License: License.txt
-- For more information, visit the project repository.

-- Load Libraries
local AceGUI = LibStub("AceGUI-3.0")

-- EditMode Global Variable
EditMode = {}

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
EditMode.EditModeMixin = {}

--- Description: Shows the highlight overlay when in edit mode
--- @param state: Boolean - true to show highlight, false to hide
--- @return: None
function EditMode.EditModeMixin:SetHighlighted(state)
    if not self.EditModeHighlight then return end
    
    if state then
        self.EditModeHighlight:SetTexture(ASSET_PATH .. "PlumberEditMode")
        self.EditModeHighlight:SetVertexColor(0, 0.56, 1, 0.3) -- Blue highlight
        self.EditModeHighlight:Show()
        self.isSelected = false
    else
        self.EditModeHighlight:Hide()
    end
end

--- Description: Shows the selection overlay when selected in edit mode
--- @param state: Boolean - true to show selection, false to hide
--- @return: None
function EditMode.EditModeMixin:SetSelected(state)
    if not self.EditModeHighlight then return end
    
    if state then
        self.EditModeHighlight:SetTexture(ASSET_PATH .. "PlumberEditModeSelect")
        self.EditModeHighlight:SetVertexColor(1, 0.82, 0, 0.5) -- Yellow selection
        self.EditModeHighlight:Show()
        self.isSelected = true
    else
        self.EditModeHighlight:Hide()
        self.isSelected = false
    end
end

--- Description: Enters edit mode, enabling basic edit mode functionality
--- @param None
--- @return: None
function EditMode.EditModeMixin:OnEditModeEnter()
    self.editModeActive = true
    self:EnableMouse(true)
    self:SetHighlighted(true)
end

--- Description: Exits edit mode, disabling edit mode functionality
--- @param None
--- @return: None
function EditMode.EditModeMixin:OnEditModeExit()
    self.editModeActive = false
    self:EnableMouse(false)
    self:SetHighlighted(false)
    self:SetSelected(false)
end

--- Description: Initializes the edit mode overlay for the frame
--- @param None
--- @return: None
function EditMode.EditModeMixin:InitializeEditMode()
    -- Add edit mode overlay
    self.EditModeHighlight = self:CreateTexture(nil, "OVERLAY")
    -- Start with initial positioning
    self:UpdateHighlightPosition()
    self.EditModeHighlight:Hide()
    DisableSharpening(self.EditModeHighlight)
    
    -- Initialize edit mode state
    self.isSelected = false
    self.editModeActive = false
end

--- Description: Updates the highlight overlay position to be 10% larger than the frame
--- @param None
--- @return: None
function EditMode.EditModeMixin:UpdateHighlightPosition()
    if not self.EditModeHighlight then return end
    
    -- Get current frame dimensions
    local frameWidth = self:GetWidth()
    local frameHeight = self:GetHeight()
    
    -- Calculate 10% increase (5% on each side)
    local widthIncrease = frameWidth * 0.2
    local heightIncrease = frameHeight * 0.2
    
    self.EditModeHighlight:ClearAllPoints()
    self.EditModeHighlight:SetPoint("TOPLEFT", self, "TOPLEFT", -widthIncrease, heightIncrease)
    self.EditModeHighlight:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", widthIncrease, -heightIncrease)
end

--- Description: Creates an edit menu for the frame
--- @param textureName: Name of the texture being edited
--- @param textureData: Data object for the texture
--- @return: The created menu frame or nil if Interface not available
function EditMode.EditModeMixin:CreateEditMenu(textureName, textureData)
    if not Interface or not Interface.CreateStyledWindow then
        return nil -- Interface not available
    end
    
    local menu = Interface:CreateStyledWindow("Edit: " .. textureName, 250, 300, true)
    local frame = self -- Reference to the source frame
    
    -- Set up menu properties and cleanup
    menu.textureName = textureName
    menu.textureData = textureData
    menu.sourceFrame = frame
    
    menu:SetScript("OnHide", function()
        if frame then
            frame.menu = nil
        end
    end)
    
    -- Create scroll area for controls
    local menuContent = CreateFrame("Frame", nil, menu.content)
    menuContent:SetPoint("TOPLEFT", menu.content, "TOPLEFT", 10, -10)
    menuContent:SetPoint("BOTTOMRIGHT", menu.content, "BOTTOMRIGHT", -30, 10)
    
    -- Position Category
    local positionHeader = Interface:CreateCategoryDivider(menuContent, true)
    positionHeader:SetText("Position & Size")
    positionHeader:SetPoint("TOPLEFT", menuContent, "TOPLEFT", 15, -20)
    
    -- Width control
    local widthBox = CreateFrame("EditBox", nil, menuContent, "InputBoxTemplate")
    widthBox:SetSize(80, 20)
    widthBox:SetPoint("TOPLEFT", positionHeader, "BOTTOMLEFT", 10, -40)
    widthBox:SetText(tostring(textureData.width))
    widthBox:SetAutoFocus(false)

    local widthLabel = menuContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    widthLabel:SetText("Width:")
    widthLabel:SetPoint("BOTTOMLEFT", widthBox, "TOPLEFT", 0, 2)
    
    -- Height control
    local heightBox = CreateFrame("EditBox", nil, menuContent, "InputBoxTemplate")
    heightBox:SetSize(80, 20)
    heightBox:SetPoint("LEFT", widthBox, "RIGHT", 20, 0)
    heightBox:SetText(tostring(textureData.height))
    heightBox:SetAutoFocus(false)

    local heightLabel = menuContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    heightLabel:SetText("Height:")
    heightLabel:SetPoint("BOTTOMLEFT", heightBox, "TOPLEFT", 0, 2)
    
    -- Appearance Category
    local appearanceHeader = Interface:CreateCategoryDivider(menuContent, true)
    appearanceHeader:SetText("Appearance")
    appearanceHeader:SetPoint("TOPLEFT", widthBox, "BOTTOMLEFT", -10, -20)
    
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
    
    -- Action buttons at bottom
    local removeBtn = CreateFrame("Button", nil, menuContent, "UIPanelButtonTemplate")
    removeBtn:SetSize(100, 25)
    removeBtn:SetPoint("BOTTOMLEFT", menuContent, "BOTTOMLEFT", 10, 20)
    removeBtn:SetText("Remove")
    removeBtn:SetScript("OnClick", function()
        TextureManager:RemoveTexture(textureName, frame.parentAddon)
        menu:Hide()
    end)

    local lockBtn = CreateFrame("Button", nil, menuContent, "UIPanelButtonTemplate")
    lockBtn:SetSize(100, 25)
    lockBtn:SetPoint("LEFT", removeBtn, "RIGHT", 10, 0)
    lockBtn:SetText(textureData.locked and "Unlock" or "Lock")
    lockBtn:SetScript("OnClick", function()
        textureData.locked = not textureData.locked
        frame.locked = textureData.locked
        frame:SetMovable(not textureData.locked and frame.editModeActive)
        lockBtn:SetText(textureData.locked and "Unlock" or "Lock")
    end)
    
    -- Event handlers for input boxes
    widthBox:SetScript("OnEnterPressed", function(self)
        local value = tonumber(self:GetText())
        if value and value > 0 then
            textureData.width = value
            frame:UpdateSize(value, nil)
        end
        self:ClearFocus()
    end)
    
    heightBox:SetScript("OnEnterPressed", function(self)
        local value = tonumber(self:GetText())
        if value and value > 0 then
            textureData.height = value
            frame:UpdateSize(nil, value)
        end
        self:ClearFocus()
    end)
    
    return menu
end

--- EditModeTextureMixin - Extends EditModeMixin for texture frames specifically
EditMode.EditModeTextureMixin = {}
for k, v in pairs(EditMode.EditModeMixin) do
    EditMode.EditModeTextureMixin[k] = v
end

--- Description: Handles the start of dragging the texture frame
--- @param None
--- @return: None
function EditMode.EditModeTextureMixin:OnDragStart()
    if not self.locked and self.editModeActive then
        self:StartMoving()
    end
end

--- Description: Handles the stop of dragging the texture frame
--- @param None
--- @return: None
function EditMode.EditModeTextureMixin:OnDragStop()
    if not self.locked and self.editModeActive then
        self:StopMovingOrSizing()
        self:UpdatePosition()
    end
end

--- Description: Shows the highlight overlay when hovering (texture-specific override)
--- @param None
--- @return: None
function EditMode.EditModeTextureMixin:ShowHighlighted()
    if not self:IsShown() then return end
    self:SetHighlighted(true)
end

--- Description: Shows the selection overlay and opens the edit menu (texture-specific override)
--- @param None
--- @return: None
function EditMode.EditModeTextureMixin:ShowSelected()
    if not self:IsShown() then return end
    self:SetSelected(true)
    self:ShowEditMenu()
end

--- Description: Hides the selection overlay and closes the edit menu
--- @param None
--- @return: None
function EditMode.EditModeTextureMixin:HideSelection()
    self:SetSelected(false)
    self:SetHighlighted(false)
    if self.menu then
        self.menu:Hide()
    end
end

--- Description: Enters edit mode for texture frames (extends base functionality)
--- @param None
--- @return: None
function EditMode.EditModeTextureMixin:OnEditModeEnter()
    -- Call parent method
    EditMode.EditModeMixin.OnEditModeEnter(self)
    
    -- Add texture-specific functionality
    self:SetMovable(not self.locked)
    self:RegisterForDrag("LeftButton")
end

--- Description: Exits edit mode for texture frames (extends base functionality)
--- @param None
--- @return: None
function EditMode.EditModeTextureMixin:OnEditModeExit()
    -- Add texture-specific cleanup first
    self:SetMovable(false)
    self:RegisterForDrag()
    if self.menu then
        self.menu:Hide()
    end
    
    -- Call parent method
    EditMode.EditModeMixin.OnEditModeExit(self)
end

--- Description: Updates the texture's position in the database after dragging
--- @param None
--- @return: None
function EditMode.EditModeTextureMixin:UpdatePosition()
    local frameX, frameY = self:GetCenter()
    local screenWidth, screenHeight = UIParent:GetSize()
    local centerX, centerY = screenWidth / 2, screenHeight / 2
    local relativeX = frameX - centerX
    local relativeY = frameY - centerY
    
    -- Update database
    local textureData = self.parentAddon.db.profile.textures[self.textureName]
    if textureData then
        textureData.x = relativeX
        textureData.y = relativeY
    end
end

--- Description: Updates the frame size and refreshes highlight overlay
--- @param width: New width value
--- @param height: New height value (optional)
--- @return: None
function EditMode.EditModeTextureMixin:UpdateSize(width, height)
    if width then
        self:SetWidth(width)
    end
    if height then
        self:SetHeight(height)
    end
    
    -- Update the highlight overlay to maintain 20 pixel margin
    self:UpdateHighlightPosition()
end

--- Description: Displays the edit menu for the texture
--- @param None
--- @return: None
function EditMode.EditModeTextureMixin:ShowEditMenu()
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

-- Edit Mode Functions

--- Description: Sets up edit mode functionality for a texture frame
--- @param frame: The texture frame to set up
--- @param parentAddon: Reference to the main addon object
--- @param textureName: Name of the texture
--- @return: None
function EditMode:EnableTextureFrameEditMode(frame, parentAddon, textureName)
    -- Apply the EditModeTextureMixin (which inherits from EditModeMixin)
    Mixin(frame, self.EditModeTextureMixin)
    
    -- Set frame properties
    frame.parentAddon = parentAddon
    frame.textureName = textureName
    
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
            -- Clear other selections
            for frameName, otherFrame in pairs(TextureManager.frames) do
                if frameName ~= textureName and otherFrame.isSelected then
                    otherFrame:ShowHighlighted()
                end
            end
        end
    end)
    
    -- Hook into Edit Mode events
    frame:HookScript("OnShow", function(self)
        if EditModeManagerFrame and EditModeManagerFrame.editModeActive then
            self:OnEditModeEnter()
        end
    end)
    
    -- Register with Edit Mode if available
    if EditModeManagerFrame and EditModeManagerFrame.RegisterSystemFrame then
        EditModeManagerFrame:RegisterSystemFrame(frame, SYSTEM_ID_TEXTURESURPRISE)
    end
    
    -- Hook Edit Mode events
    local function OnEditModeChange()
        if EditModeManagerFrame and EditModeManagerFrame.editModeActive then
            frame:OnEditModeEnter()
        else
            frame:OnEditModeExit()
        end
    end
    
    -- Listen for edit mode changes
    if EditModeManagerFrame then
        EditModeManagerFrame:HookScript("OnShow", OnEditModeChange)
        EditModeManagerFrame:HookScript("OnHide", OnEditModeChange)
    end
end

-- Return the EditMode table
return EditMode
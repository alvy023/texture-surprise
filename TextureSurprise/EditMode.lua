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

-- Edit Mode Mixin
EditMode.EditModeTextureMixin = {}

-- Mixin Methods
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

--- Description: Shows the highlight overlay when hovering
--- @param None
--- @return: None
function EditMode.EditModeTextureMixin:ShowHighlighted()
    if not self:IsShown() then return end
    self.isSelected = false
    self.EditModeHighlight:SetColorTexture(0, 0.56, 1, 0.3) -- blue
    self.EditModeHighlight:Show()
end

--- Description: Shows the selection overlay and opens the edit menu
--- @param None
--- @return: None
function EditMode.EditModeTextureMixin:ShowSelected()
    if not self:IsShown() then return end
    self.isSelected = true
    self.EditModeHighlight:SetColorTexture(1, 0.82, 0, 0.5) -- yellow
    self.EditModeHighlight:Show()
    self:ShowEditMenu()
end

--- Description: Hides the selection overlay and closes the edit menu
--- @param None
--- @return: None
function EditMode.EditModeTextureMixin:HideSelection()
    self.isSelected = false
    self.EditModeHighlight:Hide()
    if self.menu then
        self.menu:Hide()
    end
end

--- Description: Enters edit mode, enabling dragging and showing highlights
--- @param None
--- @return: None
function EditMode.EditModeTextureMixin:OnEditModeEnter()
    self.editModeActive = true
    self:EnableMouse(true)
    self:SetMovable(not self.locked)
    self:RegisterForDrag("LeftButton")
    self:ShowHighlighted()
end

--- Description: Exits edit mode, disabling dragging and hiding highlights
--- @param None
--- @return: None
function EditMode.EditModeTextureMixin:OnEditModeExit()
    self.editModeActive = false
    self:EnableMouse(false)
    self:SetMovable(false)
    self:RegisterForDrag()
    self:HideSelection()
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
    
    local menu = AceGUI:Create("Window-TS")
    menu:SetTitle("Edit Texture: " .. self.textureName)
    menu:SetWidth(280)
    menu:SetHeight(350)
    menu:SetLayout("Flow")
    
    -- Width control
    local widthBox = AceGUI:Create("EditBox")
    widthBox:SetLabel("Width")
    widthBox:SetText(tostring(textureData.width))
    widthBox:SetWidth(120)
    widthBox:SetCallback("OnEnterPressed", function(_, _, val)
        local num = tonumber(val)
        if num and num > 0 then
            textureData.width = num
            self:SetWidth(num)
        end
    end)
    menu:AddChild(widthBox)
    
    -- Height control
    local heightBox = AceGUI:Create("EditBox")
    heightBox:SetLabel("Height")
    heightBox:SetText(tostring(textureData.height))
    heightBox:SetWidth(120)
    heightBox:SetCallback("OnEnterPressed", function(_, _, val)
        local num = tonumber(val)
        if num and num > 0 then
            textureData.height = num
            self:SetHeight(num)
        end
    end)
    menu:AddChild(heightBox)
    
    -- Alpha slider
    local alphaSlider = AceGUI:Create("Slider")
    alphaSlider:SetLabel("Alpha")
    alphaSlider:SetSliderValues(0, 1, 0.01)
    alphaSlider:SetValue(textureData.alpha or 1)
    alphaSlider:SetWidth(200)
    alphaSlider:SetCallback("OnValueChanged", function(_, _, val)
        textureData.alpha = val
        self:SetAlpha(val)
    end)
    menu:AddChild(alphaSlider)
    
    -- Frame Strata dropdown
    local strataBox = AceGUI:Create("Dropdown")
    strataBox:SetLabel("Frame Strata")
    strataBox:SetList({
        BACKGROUND="BACKGROUND",
        LOW="LOW",
        MEDIUM="MEDIUM",
        HIGH="HIGH",
        DIALOG="DIALOG",
        TOOLTIP="TOOLTIP"
    })
    strataBox:SetValue(textureData.strata or "MEDIUM")
    strataBox:SetWidth(150)
    strataBox:SetCallback("OnValueChanged", function(_, _, val)
        textureData.strata = val
        self:SetFrameStrata(val)
    end)
    menu:AddChild(strataBox)
    
    -- Frame Level control
    local levelBox = AceGUI:Create("EditBox")
    levelBox:SetLabel("Frame Level")
    levelBox:SetWidth(100)
    levelBox:SetText(tostring(textureData.level or self:GetFrameLevel()))
    levelBox:SetCallback("OnEnterPressed", function(_, _, val)
        local num = tonumber(val)
        if num then
            textureData.level = num
            self:SetFrameLevel(num)
        end
    end)
    menu:AddChild(levelBox)
    
    -- Lock/Unlock button
    local lockBtn = AceGUI:Create("Button")
    lockBtn:SetText(textureData.locked and "Unlock" or "Lock")
    lockBtn:SetWidth(100)
    lockBtn:SetCallback("OnClick", function()
        textureData.locked = not textureData.locked
        self.locked = textureData.locked
        self:SetMovable(not textureData.locked and self.editModeActive)
        lockBtn:SetText(textureData.locked and "Unlock" or "Lock")
    end)
    menu:AddChild(lockBtn)
    
    -- Remove button
    local removeBtn = AceGUI:Create("Button")
    removeBtn:SetText("Remove")
    removeBtn:SetWidth(100)
    removeBtn:SetCallback("OnClick", function()
        TextureManager:RemoveTexture(self.textureName, self.parentAddon)
        menu:Hide()
        menu:Release()
    end)
    menu:AddChild(removeBtn)
    
    menu:SetCallback("OnClose", function()
        self.menu = nil
    end)
    
    self.menu = menu
    menu:Show()
end

-- Edit Mode Functions
--- Description: Sets up edit mode functionality for a texture frame
--- @param frame: The texture frame to set up
--- @param parentAddon: Reference to the main addon object
--- @param textureName: Name of the texture
--- @return: None
function EditMode:SetupEditModeForFrame(frame, parentAddon, textureName)
    -- Apply the mixin
    Mixin(frame, self.EditModeTextureMixin)
    
    -- Set frame properties
    frame.parentAddon = parentAddon
    frame.textureName = textureName
    frame.isSelected = false
    frame.editModeActive = false
    
    local textureData = parentAddon.db.profile.textures[textureName]
    frame.locked = textureData and textureData.locked or false
    
    -- Add edit mode overlay
    frame.EditModeHighlight = frame:CreateTexture(nil, "OVERLAY")
    frame.EditModeHighlight:SetAllPoints(frame)
    frame.EditModeHighlight:Hide()

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
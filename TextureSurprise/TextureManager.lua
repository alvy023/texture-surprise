-- Texture Surprise Addon
-- Author: alvy023
-- File: TextureManager.lua
-- Description: Texture management functionality for the TS addon.
-- License: License.txt
-- For more information, visit the project repository.

-- Load Libraries
local AceGUI = LibStub("AceGUI-3.0")

-- TextureManager Global Variable
TextureManager = {}
local SYSTEM_ID_TEXTURESURPRISE = 37001 -- Unique system ID for Edit Mode

TextureManager.frames = TextureManager.frames or {}

-- Functions
--- Description: Creates the texture manager window
--- @param parentAddon: Reference to the main addon object
--- @return: The created window object
function TextureManager:Create(parentAddon)
    local window = AceGUI:Create("Window-TS")
    window:SetTitle("Texture Manager")
    window:SetTitleFont("Fonts\\FRIZQT__.TTF", 14, "")
    window.titleLabel:SetTextColor(1, 1, 1) -- RGB

    -- Create edit area
    local editBar = AceGUI:Create("SimpleGroup")
    editBar:SetLayout("Flow")
    editBar:SetFullWidth(true)

    local spacer = AceGUI:Create("Label")
    spacer:SetWidth(50)
    spacer:SetHeight(80)

    local editBox = AceGUI:Create("EditBox")
    editBox:SetLabel(" Texture File Name (.tga):")
    editBox:SetWidth(278)
    editBox.label:SetTextColor(1, 1, 1) -- RGB white
    -- editBox.editbox:SetScript("OnTextChanged", EditBox_OnTextChanged)

    editBar:AddChild(spacer)
    editBar:AddChild(editBox)
    window:AddChild(editBar)

    -- Create Button Bar
    local buttonBar = AceGUI:Create("SimpleGroup")
    buttonBar:SetLayout("Flow")
    buttonBar:SetFullWidth(true)

    local spacer1 = AceGUI:Create("Label")
    spacer1:SetWidth(50)
    local spacer2 = AceGUI:Create("Label")
    spacer2:SetWidth(10)
    local spacer3 = AceGUI:Create("Label")
    spacer3:SetWidth(10)

    local addButton = AceGUI:Create("Button")
    addButton:SetText("Add")
    addButton:SetWidth(80)
    addButton:SetCallback("OnClick", function()
        local text = editBox:GetText()
        if type(text) == "string" and text:lower():sub(-4) == ".tga" then
            -- Test if texture file exists
            local texturePath = "Interface\\AddOns\\TextureSurprise\\textures\\" .. text
            parentAddon:Print("Testing texture path: " .. texturePath)
            local testTexture = window.frame:CreateTexture(nil, "ARTWORK")
            testTexture:SetTexture(texturePath)
            if not testTexture:GetTexture() then
                editBox:SetLabel(" Texture File Path: Couldn't find file")
                editBox.label:SetTextColor(1, 0, 0) -- RGB bright red
            else
                -- Store and show the texture
                TextureManager:StoreTexture(text, texturePath, 0, 0, 64, 64, parentAddon)
                TextureManager:ShowTexture(text, parentAddon)
                parentAddon:Print("Added texture: " .. texturePath)
                editBox:SetLabel(" Texture File Name (.tga):")
                editBox.label:SetTextColor(1, 1, 1) -- RGB white
            end
            -- Clean up test texture
            testTexture:Hide()
        else
            editBox:SetLabel(" Texture File Name (.tga): Texture file is invalid!")
            editBox.label:SetTextColor(1, 0, 0) -- RGB bright red
        end
    end)
    addButton.text:SetTextColor(1, 1, 1) -- RGB white

    local removeButton = AceGUI:Create("Button")
    removeButton:SetText("Remove")
    removeButton:SetWidth(80)
    removeButton:SetCallback("OnClick", function()
        local text = editBox:GetText()
        if type(text) == "string" and text ~= "" then
            local removed = TextureManager:RemoveTexture(text, parentAddon)
            if removed then
                parentAddon:Print("Removed texture: " .. text)
                editBox:SetLabel(" Texture File Name (.tga): Successfully removed " .. text)
                editBox.label:SetTextColor(0, 1, 0) -- RGB bright green
            else
                parentAddon:Print("Texture not found: " .. text)
                editBox:SetLabel(" Texture File Path: Couldn't find texture!")
                editBox.label:SetTextColor(1, 0, 0) -- RGB bright red
            end
        else
            parentAddon:Print("Please enter a valid texture name to remove.")
            editBox:SetLabel(" Texture File Path: Texture file required")
            editBox.label:SetTextColor(1, 0, 0) -- RGB bright red
        end
    end)
    removeButton.text:SetTextColor(1, 1, 1) -- RGB white

    local editModeButton = AceGUI:Create("Button")
    editModeButton:SetText("Edit Mode")
    editModeButton:SetWidth(100)
    editModeButton:SetCallback("OnClick", function()
        window.frame:Hide()
        if EditModeManagerFrame and EditModeManagerFrame.Show then
            EditModeManagerFrame:Show()
        else
            parentAddon:Print("[Error] Edit Mode Manager not available!")
        end
    end)
    editModeButton.text:SetTextColor(1, 1, 1) -- RGB white

    buttonBar:AddChild(spacer1)
    buttonBar:AddChild(addButton)
    buttonBar:AddChild(spacer2)
    buttonBar:AddChild(removeButton)
    buttonBar:AddChild(spacer3)
    buttonBar:AddChild(editModeButton)
    window:AddChild(buttonBar)

    return window
end

--- Description: Stores texture information in the database
--- @param name: Name of the texture
--- @param path: File path of the texture
--- @param x: X coordinate for texture placement
--- @param y: Y coordinate for texture placement
--- @param width: Width of the texture
--- @param height: Height of the texture
--- @param parentAddon: Reference to the main addon object
--- @return: None
function TextureManager:StoreTexture(name, path, x, y, width, height, parentAddon)
    if not parentAddon.db.profile.textures then
        parentAddon.db.profile.textures = {}
    end
    parentAddon.db.profile.textures[name] = {
        path = path,
        x = x,
        y = y,
        width = width,
        height = height,
        locked = false,
        visible = false,
        alpha = 1.0,
        strata = "MEDIUM",
        level = 1,
    }
end

--- Description: Displays the texture on the screen
--- @param name: Name of the texture to display
--- @param parentAddon: Reference to the main addon object
--- @return: None
function TextureManager:ShowTexture(name, parentAddon)
    if not parentAddon.db.profile.textures or not parentAddon.db.profile.textures[name] then
        if parentAddon and parentAddon.Print then
            parentAddon:Print("[Error] Texture not found: " .. (name or "nil"))
        end
        return
    end
    local textureData = parentAddon.db.profile.textures[name]
    
    if TextureManager.frames[name] then
        TextureManager.frames[name]:Show()
        return
    end
    
    -- Create the frame for the texture
    local frame = CreateFrame("Frame", "TextureSurpriseFrame_"..name, UIParent, "EditModeSystemTemplate")
        frame.parentAddon = parentAddon
        frame.isSelected = false
        frame.locked = textureData.locked
        frame:SetSize(textureData.width, textureData.height)
        local offsetX = textureData.x or 0
        local offsetY = textureData.y or 0
        frame:SetPoint("CENTER", UIParent, "CENTER", offsetX, offsetY)
        frame:SetAlpha(textureData.alpha)
        frame:SetFrameStrata(textureData.strata)
        frame:SetFrameLevel(textureData.level)
        -- Add edit mode overlay
        frame.EditModeHighlight = frame:CreateTexture(nil, "OVERLAY")
        frame.EditModeHighlight:SetAllPoints(frame)
        frame.EditModeHighlight:Hide()

        -- Add the texture
        local texture = frame:CreateTexture(nil, "ARTWORK")
        texture:SetAllPoints(frame)
        texture:SetTexture(textureData.path)

        -- Register with Edit Mode
        if EditModeManagerFrame and EditModeManagerFrame.RegisterSystemFrame then
            EditModeManagerFrame:RegisterSystemFrame(frame, SYSTEM_ID_TEXTURESURPRISE)
        end

        -- Check frame selection for Edit Mode highlight
        frame:SetScript("OnMouseDown", function(self, button)
            if EditModeManagerFrame and EditModeManagerFrame.editModeActive then
                if button then
                    self.isSelected = true
                    self.EditModeHighlight:SetColorTexture(1, 0.82, 0, 0.5) -- yellow
                    -- Show AceGUI menu for editing width, height, alpha
                    if not self.menu then
                        local menu = AceGUI:Create("Window-TS")
                        menu:SetTitle("Edit Texture")
                        menu:SetWidth(250)
                        menu:SetHeight(280)
                        menu:SetLayout("Flow")

                        local widthBox = AceGUI:Create("EditBox")
                        widthBox:SetLabel("Width")
                        widthBox:SetText(tostring(textureData.width))
                        widthBox:SetWidth(80)
                        widthBox:SetCallback("OnEnterPressed", function(_, _, val)
                            local num = tonumber(val)
                            if num and num > 0 then
                                textureData.width = num
                                self:SetWidth(num)
                            end
                        end)
                        menu:AddChild(widthBox)

                        local heightBox = AceGUI:Create("EditBox")
                        heightBox:SetLabel("Height")
                        heightBox:SetText(tostring(textureData.height))
                        heightBox:SetWidth(80)
                        heightBox:SetCallback("OnEnterPressed", function(_, _, val)
                            local num = tonumber(val)
                            if num and num > 0 then
                                textureData.height = num
                                self:SetHeight(num)
                            end
                        end)
                        menu:AddChild(heightBox)

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

                        local strataBox = AceGUI:Create("Dropdown")
                        strataBox:SetLabel("Frame Strata")
                        strataBox:SetList({BACKGROUND="BACKGROUND",LOW="LOW",MEDIUM="MEDIUM",HIGH="HIGH",DIALOG="DIALOG",TOOLTIP="TOOLTIP"})
                        strataBox:SetValue(textureData.strata or "MEDIUM")
                        strataBox:SetWidth(120)
                        strataBox:SetCallback("OnValueChanged", function(_, _, val)
                            textureData.strata = val
                            self:SetFrameStrata(val)
                        end)
                        menu:AddChild(strataBox)

                        local levelBox = AceGUI:Create("EditBox")
                        levelBox:SetLabel("Frame Level")
                        levelBox:SetWidth(80)
                        levelBox:SetText(tostring(textureData.level or self:GetFrameLevel()))
                        levelBox:SetCallback("OnEnterPressed", function(_, _, val)
                            local num = tonumber(val)
                            if num then
                                textureData.level = num
                                self:SetFrameLevel(num)
                            end
                        end)
                        menu:AddChild(levelBox)

                        local lockBtn = AceGUI:Create("Button")
                        lockBtn:SetText(textureData.locked and "Unlock" or "Lock")
                        lockBtn:SetWidth(80)
                        lockBtn:SetCallback("OnClick", function()
                            textureData.locked = not textureData.locked
                            frame.locked = textureData.locked
                            if textureData.locked then
                                self:SetMovable(false)
                                lockBtn:SetText("Unlock")
                            else
                                self:SetMovable(true)
                                lockBtn:SetText("Lock")
                            end
                        end)
                        menu:AddChild(lockBtn)

                        local removeBtn = AceGUI:Create("Button")
                        removeBtn:SetText("Remove")
                        removeBtn:SetWidth(80)
                        removeBtn:SetCallback("OnClick", function()
                            TextureManager:RemoveTexture(name, self.parentAddon)
                            self:Hide()
                            menu:Hide()
                            menu:Release()
                            self.menu = nil
                        end)
                        menu:AddChild(removeBtn)

                        menu:SetCallback("OnClose", function()
                            self.menu = nil
                        end)

                        self.menu = menu
                    end
                    self.menu:Show()
                end
            end
        end)
        WorldFrame:HookScript("OnMouseDown", function(_, button)
            if EditModeManagerFrame and EditModeManagerFrame.editModeActive and button == "LeftButton" then
                if frame.isSelected then
                    frame.isSelected = false
                    frame.EditModeHighlight:SetColorTexture(0, 0.56, 1, 0.3) -- blue
                end
            end
        end)

        -- Implement required Edit Mode methods
        frame.GetSystemSettingDisplayData = function(self)
            return {
                position = {
                    point = "CENTER",
                    relativeTo = UIParent,
                    relativePoint = "CENTER",
                    offsetX = textureData.x or 0,
                    offsetY = textureData.y or 0,
                }
            }
        end
        frame.UpdateSystemSetting = function(self, systemID, settingName, newValue)
            if settingName == "position" then
                local position = newValue
                local offsetX = position.offsetX or 0
                local offsetY = position.offsetY or 0
                
                -- Save to database
                self.parentAddon.db.profile.textures[name].x = offsetX
                self.parentAddon.db.profile.textures[name].y = offsetY
            end
        end
        frame.OnSystemSettingChange = function(self, systemID, settingName, newValue)
            if settingName == "position" then
                self:UpdateSystemSetting(systemID, settingName, newValue)
            end
        end
        frame.OnEditModeEnter = function(self)
            self:EnableMouse(true)
            self:SetMovable(true)
            self:RegisterForDrag("LeftButton")
            self:SetScript("OnDragStart", function(self)
                if not frame.locked then
                    self:StartMoving()
                end
            end)
            self:SetScript("OnDragStop", function(self)
                self:StopMovingOrSizing()
                local frameX, frameY = self:GetCenter()
                local screenWidth, screenHeight = UIParent:GetSize()
                local centerX, centerY = screenWidth / 2, screenHeight / 2
                local relativeX = frameX - centerX
                local relativeY = frameY - centerY
                
                -- Use Edit Mode system to update position
                local newPosition = {
                    point = "CENTER",
                    relativeTo = UIParent,
                    relativePoint = "CENTER",
                    offsetX = relativeX,
                    offsetY = relativeY,
                }
                
                -- Update through Edit Mode system
                if self.UpdateSystemSetting then
                    self:UpdateSystemSetting(SYSTEM_ID_TEXTURESURPRISE, "position", newPosition)
                end
            end)
            self.EditModeHighlight:Show()
            self.EditModeHighlight:SetColorTexture(0, 0.56, 1, 0.3) -- blue
        end
        frame.OnEditModeExit = function(self)
            -- Store current position before Edit Mode does anything
            local currentX, currentY = self:GetCenter()
            local screenWidth, screenHeight = UIParent:GetSize()
            local centerX, centerY = screenWidth / 2, screenHeight / 2
            local savedOffsetX = currentX - centerX
            local savedOffsetY = currentY - centerY
            
            -- Disable edit mode functionality
            self:EnableMouse(false)
            self:SetMovable(false)
            self:RegisterForDrag()
            self:SetScript("OnDragStart", nil)
            self:SetScript("OnDragStop", nil)
            self.EditModeHighlight:Hide()
            if self.menu then
                self.menu:Hide()
            end
            
            -- Immediately restore position after this function completes
            self:SetScript("OnUpdate", function(frame)
                -- Check if Edit Mode is no longer active
                if not (EditModeManagerFrame and EditModeManagerFrame.editModeActive) then
                    -- Restore the position
                    frame:ClearAllPoints()
                    frame:SetPoint("CENTER", UIParent, "CENTER", savedOffsetX, savedOffsetY)
                    -- Remove the OnUpdate script
                    frame:SetScript("OnUpdate", nil)
                end
            end)
        end

        frame:Show()
    TextureManager.frames[name] = frame
end

--- Description: Removes a texture from the database
--- @param name: Name of the texture to remove
--- @param parentAddon: Reference to the main addon object
--- @return: true if removed, false if not found
function TextureManager:RemoveTexture(name, parentAddon)
    if not parentAddon.db.profile.textures or not parentAddon.db.profile.textures[name] then
        return false
    end
    parentAddon.db.profile.textures[name] = nil
    local frame = TextureManager.frames[name]
    if frame then
        frame:Hide()
        TextureManager.frames[name] = nil
    end
    return true
end

return TextureManager
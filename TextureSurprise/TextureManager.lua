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
    
    -- Create the frame for the texture with Edit Mode template
    local frame = CreateFrame("Frame", "TextureSurpriseFrame_"..name, UIParent, "EditModeSystemTemplate")
    
    -- Set frame properties
    frame:SetSize(textureData.width, textureData.height)
    local offsetX = textureData.x or 0
    local offsetY = textureData.y or 0
    frame:SetPoint("CENTER", UIParent, "CENTER", offsetX, offsetY)
    frame:SetAlpha(textureData.alpha)
    frame:SetFrameStrata(textureData.strata)
    frame:SetFrameLevel(textureData.level)

    -- Add the texture
    local texture = frame:CreateTexture(nil, "ARTWORK")
    texture:SetAllPoints(frame)
    texture:SetTexture(textureData.path)

    -- Setup edit mode functionality using the EditMode module
    EditMode:SetupEditModeForFrame(frame, parentAddon, name)

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
        if frame.menu then
            frame.menu:Hide()
            frame.menu:Release()
        end
        frame:Hide()
        TextureManager.frames[name] = nil
    end
    return true
end

return TextureManager
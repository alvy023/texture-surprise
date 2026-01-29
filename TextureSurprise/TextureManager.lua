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
--- Description: Creates the texture manager window using styled interface
--- @param parentAddon: Reference to the main addon object
--- @return: The created window object
function TextureManager:Create(parentAddon)
    -- Use styled interface if available
    local window = Interface:CreateStyledWindow("Texture Manager", 408, 370, true)

    -- Create the profile area
    local profileFrame = CreateFrame("Frame", nil, window.content)
    profileFrame:SetPoint("TOPLEFT", window.content, "TOPLEFT", 0, -8)
    profileFrame:SetPoint("TOPRIGHT", window.content, "TOPRIGHT", 0, -8)
    profileFrame:SetHeight(150)

    ProfileManager:Create(profileFrame, parentAddon)

    -- Add divider
    local profileHeader = Interface:CreateCategoryDivider(profileFrame, true)
    profileHeader:SetText("Manage  Textures in Profile")
    profileHeader:SetPoint("TOPLEFT", profileFrame, "BOTTOMLEFT", 15, -28)
    
    -- Create input area
    local textureFrame = CreateFrame("Frame", nil, window.content)
    textureFrame:SetPoint("TOPLEFT", profileFrame, "BOTTOMLEFT", 0, -53)
    textureFrame:SetPoint("TOPRIGHT", profileFrame, "BOTTOMRIGHT", 0, -53)
    textureFrame:SetHeight(70)

    -- Create texture directory input box
    local directoryLabel = textureFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    directoryLabel:SetText("Texture Directory: Interface\\AddOns\\")
    directoryLabel:SetPoint("TOPLEFT", textureFrame, "TOPLEFT", 10, -18)

    local directoryEditBox = CreateFrame("EditBox", nil, textureFrame, "InputBoxTemplate")
    directoryEditBox:SetSize(140, 25)
    directoryEditBox:SetPoint("LEFT", directoryLabel, "RIGHT", 5, 0)
    directoryEditBox:SetAutoFocus(false)
    directoryEditBox:SetText("MyCustomTextures")
    
    -- Create texture file input box
    local textureLabel = textureFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    textureLabel:SetText("Texture File Name:")
    textureLabel:SetPoint("TOPLEFT", directoryLabel, "BOTTOMLEFT", 0, -20)

    local textureEditBox = CreateFrame("EditBox", nil, textureFrame, "InputBoxTemplate")
    textureEditBox:SetSize(140, 25)
    textureEditBox:SetPoint("LEFT", textureLabel, "RIGHT", 15, 0)
    textureEditBox:SetAutoFocus(false)
    textureEditBox:SetText("example_texture_1.tga")
    
    -- Add/Remove buttons
    local addButton = CreateFrame("Button", nil, textureFrame, "UIPanelButtonTemplate")
    addButton:SetSize(60, 25)
    addButton:SetPoint("LEFT", textureEditBox, "RIGHT", 3, 0)
    addButton:SetText("Add")
    
    local deleteButton = CreateFrame("Button", nil, textureFrame, "UIPanelButtonTemplate")
    deleteButton:SetSize(60, 25)
    deleteButton:SetPoint("LEFT", addButton, "RIGHT", 3, 0)
    deleteButton:SetText("Delete")

    -- Result label
    local resultLabel = textureFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    resultLabel:SetText("")
    resultLabel:SetPoint("BOTTOM", textureFrame, "BOTTOM", 0, -20)

    -- Edit Mode button
    local editModeButton = CreateFrame("Button", nil, textureFrame, "UIPanelButtonTemplate")
    editModeButton:SetSize(100, 25)
    editModeButton:SetPoint("BOTTOM", textureFrame, "BOTTOM", 0, -60)
    editModeButton:SetText("Edit Mode")
    
    -- Button functionality
    textureEditBox:SetScript("OnEnterPressed", function(self)
        addButton:Click()
        self:ClearFocus()
    end)

    addButton:SetScript("OnClick", function()
        local textureDir = directoryEditBox:GetText()
        local texture = textureEditBox:GetText()
        if type(texture) == "string" and (texture:lower():sub(-4) == ".tga" or texture:lower():sub(-4) == ".blp") then
            local customPath = "Interface\\AddOns\\" .. textureDir .. "\\" .. texture
            local builtInPath = "Interface\\AddOns\\TextureSurprise\\textures\\" .. texture
            local texturePath = nil
            
            -- Test custom texture path first then built-in
            local testTexture = window:CreateTexture(nil, "ARTWORK")
            testTexture:SetTexture(customPath)
            if testTexture:GetTexture() then
                texturePath = customPath
            else
                testTexture:SetTexture(builtInPath)
                if testTexture:GetTexture() then
                    texturePath = builtInPath
                end
            end
            testTexture:Hide()
            
            if not texturePath then
                resultLabel:SetText("Error: Couldn't find file in either directory!")
                resultLabel:SetTextColor(1, 0, 0)
            elseif parentAddon.db.profile.textures[texture] == nil then
                TextureManager:StoreTexture(texture, texturePath, 0, 0, 64, 64, parentAddon)
                TextureManager:AddTexture(texture, parentAddon)
                local source = (texturePath == customPath) and "(custom)" or "(built-in)"
                resultLabel:SetText("Added: " .. texture .. " " .. source)
                resultLabel:SetTextColor(0, 1, 0)
            else
                resultLabel:SetText("Error: Texture already exists!")
                resultLabel:SetTextColor(1, 0, 0)
            end
        else
            resultLabel:SetText("Error: Invalid texture file!")
            resultLabel:SetTextColor(1, 0, 0)
        end
    end)
    
    deleteButton:SetScript("OnClick", function()
        local texture = textureEditBox:GetText()
        if type(texture) == "string" and texture ~= "" then
            local removed = TextureManager:RemoveTexture(texture, parentAddon)
            if removed then
                resultLabel:SetText("Successfully removed texture")
                resultLabel:SetTextColor(0, 1, 0)
                textureEditBox:SetText("")
            else
                resultLabel:SetText("Error: Texture not found!")
                resultLabel:SetTextColor(1, 0, 0)
            end
        else
            resultLabel:SetText("Error: Texture name required!")
            resultLabel:SetTextColor(1, 0, 0)
        end
    end)
    
    editModeButton:SetScript("OnClick", function()
        window:Hide()
        if EditModeManagerFrame and EditModeManagerFrame.Show then
            EditModeManagerFrame:Show()
        else
            parentAddon:Print("[Error] Edit Mode Manager not available!")
        end
    end)
    
    -- Reset input label on close
    window:SetScript("OnHide", function()
        textureEditBox:SetText("example_texture_1.tga")
        resultLabel:SetText("")
    end)
    
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
        rotation = 0,
    }
end

--- Description: Displays the texture on the screen
--- @param name: Name of the texture to display
--- @param parentAddon: Reference to the main addon object
--- @return: None
function TextureManager:AddTexture(name, parentAddon)
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
    texture:SetRotation(math.rad(textureData.rotation))
    frame.texture = texture

    -- Setup edit mode functionality using the EditMode module
    EditModeTS:EnableTextureFrameEditMode(frame, parentAddon, name)

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
        end
        frame:Hide()
        TextureManager.frames[name] = nil
    end
    return true
end

return TextureManager
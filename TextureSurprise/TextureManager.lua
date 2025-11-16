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
    local window = Interface:CreateStyledWindow("Texture Manager", 300, 175, true)
    
    -- Create input area
    local inputFrame = CreateFrame("Frame", nil, window.content)
    inputFrame:SetPoint("TOPLEFT", window.content, "TOPLEFT", 0, -32)
    inputFrame:SetPoint("TOPRIGHT", window.content, "TOPRIGHT", 0, -32)
    inputFrame:SetHeight(70)
    
    -- Create instructions
    local instructions = inputFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    instructions:SetPoint("TOP", inputFrame, "TOP", -8, 22)
    instructions:SetText("Add .tga or .blp texture file to:\nInterface\\AddOns\\MyCustomTextures\\")
    instructions:SetTextColor(1, 1, 1)
    instructions:SetJustifyH("LEFT")
    
    -- Create input box
    local editBox = CreateFrame("EditBox", nil, inputFrame, "InputBoxTemplate")
    editBox:SetSize(240, 25)
    editBox:SetPoint("TOP", inputFrame, "TOP", 2, -30)
    editBox:SetAutoFocus(false)
    editBox:SetText("example_texture_1.tga")
    
    local inputLabel = inputFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    inputLabel:SetText("Texture File Name:")
    inputLabel:SetTextColor(1, 1, 1)
    inputLabel:SetPoint("BOTTOMLEFT", editBox, "TOPLEFT", -2, 2)

    -- Add divider
    local inputHeader = Interface:CreateCategoryDivider(inputFrame, true)
    inputHeader:SetText("")
    inputHeader:SetPoint("TOPLEFT", inputFrame, "BOTTOMLEFT", 7, 5)
    
    -- Create button area
    local buttonFrame = CreateFrame("Frame", nil, window.content)
    buttonFrame:SetPoint("TOPLEFT", inputFrame, "BOTTOMLEFT", 0, -10)
    buttonFrame:SetPoint("TOPRIGHT", inputFrame, "BOTTOMRIGHT", 0, -10)
    buttonFrame:SetHeight(40)
    
    -- Add buttons
    local addButton = CreateFrame("Button", nil, buttonFrame, "UIPanelButtonTemplate")
    addButton:SetSize(80, 25)
    addButton:SetPoint("LEFT", buttonFrame, "LEFT", 10, 0)
    addButton:SetText("Add")
    
    local removeButton = CreateFrame("Button", nil, buttonFrame, "UIPanelButtonTemplate")
    removeButton:SetSize(80, 25)
    removeButton:SetPoint("LEFT", addButton, "RIGHT", 10, 0)
    removeButton:SetText("Remove")
    
    local editModeButton = CreateFrame("Button", nil, buttonFrame, "UIPanelButtonTemplate")
    editModeButton:SetSize(100, 25)
    editModeButton:SetPoint("LEFT", removeButton, "RIGHT", 10, 0)
    editModeButton:SetText("Edit Mode")
    
    -- Button functionality
    editBox:SetScript("OnEnterPressed", function(self)
        addButton:Click()
        self:ClearFocus()
    end)

    addButton:SetScript("OnClick", function()
        local text = editBox:GetText()
        if type(text) == "string" and (text:lower():sub(-4) == ".tga" or text:lower():sub(-4) == ".blp") then
            local customPath = "Interface\\AddOns\\MyCustomTextures\\" .. text
            local builtInPath = "Interface\\AddOns\\TextureSurprise\\textures\\" .. text
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
                inputLabel:SetText("Error: Couldn't find file in either directory!")
                inputLabel:SetTextColor(1, 0, 0)
            elseif parentAddon.db.profile.textures[text] == nil then
                TextureManager:StoreTexture(text, texturePath, 0, 0, 64, 64, parentAddon)
                TextureManager:ShowTexture(text, parentAddon)
                local source = (texturePath == customPath) and "(custom)" or "(built-in)"
                inputLabel:SetText("Added: " .. text .. " " .. source)
                inputLabel:SetTextColor(0, 1, 0)
            else
                inputLabel:SetText("Error: Texture already exists!")
                inputLabel:SetTextColor(1, 0, 0)
            end
        else
            inputLabel:SetText("Error: Invalid texture file!")
            inputLabel:SetTextColor(1, 0, 0)
        end
    end)
    
    removeButton:SetScript("OnClick", function()
        local text = editBox:GetText()
        if type(text) == "string" and text ~= "" then
            local removed = TextureManager:RemoveTexture(text, parentAddon)
            if removed then
                inputLabel:SetText("Successfully removed texture")
                inputLabel:SetTextColor(0, 1, 0)
                editBox:SetText("")
            else
                inputLabel:SetText("Error: Texture not found!")
                inputLabel:SetTextColor(1, 0, 0)
            end
        else
            inputLabel:SetText("Error: Texture name required!")
            inputLabel:SetTextColor(1, 0, 0)
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
        inputLabel:SetText("Texture File Name:")
        inputLabel:SetTextColor(1, 1, 1)
        editBox:SetText("example_texture_1.tga")
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
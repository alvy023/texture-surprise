-- Texture Surprise Addon
-- Author: alvy023
-- File: TextureManager.lua
-- Description: Manage the textures for the addon.
-- License: License.txt
-- For more information, visit the project repository.

-- Initialize variables
local AceGUI = LibStub("AceGUI-3.0")
local TextureManager = {
    managerFrame = nil,
    editModeFrame = nil,
}
local texturesPath = "Interface\\AddOns\\TextureSurprise\\textures\\"

-- Frame Setup Functions
--- Description: Create the local texture manager frame
--- @param: None
--- @return: None
local function CreateManagerFrame()
    if TextureManager.managerFrame then return end
    -- Create the main manager frame
    local managerFrame = AceGUI:Create("Frame")
    managerFrame:SetTitle("Texture Manager")
    managerFrame:SetStatusText("Select a texture to add, edit, or remove.")
    managerFrame:SetCallback("OnClose", function() managerFrame:Hide() end)
    managerFrame:SetLayout("Flow")
    managerFrame:SetWidth(400)
    managerFrame:SetHeight(300)
    -- Add the texture name input box
    local textureNameInput = AceGUI:Create("EditBox")
    textureNameInput:SetLabel("Texture Name")
    textureNameInput:SetWidth(200)
    managerFrame:AddChild(textureNameInput)
    -- Add buttons for adding, editing, and removing textures
    local addButton = AceGUI:Create("Button")
    addButton:SetText("Add")
    addButton:SetWidth(50)
    -- addButton:SetCallback("OnClick", function() TextureManager:AddTexture() end)
    managerFrame:AddChild(addButton)
    local editButton = AceGUI:Create("Button")
    editButton:SetText("Edit")
    editButton:SetWidth(50)
    -- editButton:SetCallback("OnClick", function() TextureManager:EditTexture() end)
    managerFrame:AddChild(editButton)
    local removeButton = AceGUI:Create("Button")
    removeButton:SetText("Remove")
    removeButton:SetWidth(50)
    -- removeButton:SetCallback("OnClick", function() TextureManager:RemoveTexture() end)
    managerFrame:AddChild(removeButton)
    managerFrame:Hide()
    -- Add to TextureManager global
    TextureManager.managerFrame = managerFrame
end

--- Description: Create the edit mode frame for texture placement
--- @param: None
--- @return: None
local function CreateEditModeFrame()
    if TextureManager.editModeFrame then return end
    local editModeFrame = AceGUI:Create("Frame", "TSEditModeFrame", UIParent)
    -- Register for edit events
    editModeFrame:SetScript("OnEvent", function(self, event, ...)
        if event == "ADDON_LOADED" then
            local addonName = ...
            if addonName == "TextureSurprise" then
                -- TextureManager:RegisterEditMode()
            end
        elseif event == "EDIT_MODE_LAYOUTS_UPDATED" then
            -- TextureManager:OnEditModeLayoutUpdated()
        end
    end)
    editModeFrame:RegisterEvent("ADDON_LOADED")
    editModeFrame:RegisterEvent("EDIT_MODE_LAYOUTS_UPDATED")
    editModeFrame:Hide()
    -- Add to TextureManager global
    TextureManager.editModeFrame = editModeFrame
end

--- Description: Initialize the texture manager
--- @param: None
--- @return: TextureManager
function TextureManager:Initialize()
    CreateManagerFrame()
    CreateEditModeFrame()
    return TextureManager
end


-- Texture Surprise Addon
-- Author: alvy023
-- File: TextureSurprise.lua
-- Description: Core functionality for the TS addon.
-- License: License.txt
-- For more information, visit the project repository.

-- Load Libraries
local AceAddon = LibStub("AceAddon-3.0")
local AceDB = LibStub("AceDB-3.0")
local AceGUI = LibStub("AceGUI-3.0")
local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")

-- Initialize TS as AceAddon module
TextureSurprise = AceAddon:NewAddon("TextureSurprise", "AceConsole-3.0", "AceEvent-3.0")

-- Initialize minimap button
local dataBroker = LDB:NewDataObject("TextureSurprise", {
    type = "data source",
    text = "TS",
    icon = "Interface\\AddOns\\TextureSurprise\\assets\\ts-icon.tga",
    OnClick = function(_, button)
        if button == "LeftButton" then
            TextureSurprise:ShowTextureManager()
        elseif button == "RightButton" then
            TextureSurprise:ShowOptionsMenu()
        end
    end,
    OnTooltipShow = function(tooltip)
        tooltip:AddLine("Texture Surprise")
        tooltip:AddLine("Left-click to open texture manager")
        tooltip:AddLine("Right-click for options")
    end,
})

-- Initialize the options menu
local menuFrame = CreateFrame("Frame", "TSOptionsMenu", UIParent, "UIDropDownMenuTemplate")
local UIDropDownMenu_Initialize = UIDropDownMenu_Initialize
local UIDropDownMenu_CreateInfo = UIDropDownMenu_CreateInfo
local UIDropDownMenu_AddButton = UIDropDownMenu_AddButton
local ToggleDropDownMenu = ToggleDropDownMenu

-- Event Handlers
--- Description: OnInitialize event handler
--- @param: None
--- @return: None
function TextureSurprise:OnInitialize()
    -- Initialize database
    self.db = AceDB:New("TextureSurpriseDB", {
        profile = {
            minimap = { hide = false },
            addonCompartment = { hide = false },
            textures = {},
        }
    }, true)
    -- Register minimap button
    LDBIcon:Register("Texture Surprise", dataBroker, self.db.profile.minimap)
    -- Enable addon compartment entry
    if not self.db.profile.addonCompartment.hide then
        self:EnableAddonCompartment()
    end
    -- Register addon for event notifications
    self:RegisterEvent("PLAYER_LOGIN")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

--- Description: PLAYER_LOGIN event handler
--- @param: None
--- @return: None
function TextureSurprise:PLAYER_LOGIN()
    -- TextureManager:LoadSavedTextures()
end

--- Description: Player reload event handler
--- @param: None
--- @return: None
function TextureSurprise:PLAYER_ENTERING_WORLD()
    -- TextureManager:LoadSavedTextures()
end

-- Functions
--- Description: Enables the addon compartment entry
--- @param: None
--- @return: None
function TextureSurprise:EnableAddonCompartment()
    if LDBIcon:IsButtonCompartmentAvailable() then
        LDBIcon:AddButtonToCompartment("Texture Surprise")
    end
end

--- Description: Disables the addon compartment entry
--- @param: None
--- @return: None
function TextureSurprise:DisableAddonCompartment()
    if LDBIcon:IsButtonCompartmentAvailable() then
        LDBIcon:RemoveButtonFromCompartment("Texture Surprise")
    end
end

--- Description: Show the texture manager UI
--- @param: None
--- @return: None
function TextureSurprise:ShowTextureManager()
    -- TODO: Show the Texture Manager
end

--- Description: Show the options menu
--- @param: anchorFrame (Frame to attach the options to)
--- @return: None
function TextureSurprise:ShowOptionsMenu(anchorFrame)
    if not menuFrame then
        menuFrame = CreateFrame("Frame", "TSOptionsMenu", UIParent, "UIDropDownMenuTemplate")
    end

    UIDropDownMenu_Initialize(menuFrame, function(frame, level, menuList)
        local info = UIDropDownMenu_CreateInfo()

        -- Minimap Checkbox
        info.text = "Show Minimap Button"
        info.checked = not self.db.profile.minimap.hide
        info.func = function()
            self.db.profile.minimap.hide = not self.db.profile.minimap.hide
            if LDBIcon then
                if self.db.profile.minimap.hide then
                    LDBIcon:Hide("Texture Surprise")
                else
                    LDBIcon:Show("Texture Surprise")
                end
            end
        end
        info.isNotRadio = true
        info.keepShownOnClick = true
        UIDropDownMenu_AddButton(info, level)

        -- Addon Compartment Checkbox
        info = UIDropDownMenu_CreateInfo()
        info.text = "Show Addon Compartment"
        info.checked = not self.db.profile.addonCompartment.hide
        info.func = function()
            self.db.profile.addonCompartment.hide = not self.db.profile.addonCompartment.hide
            if self.db.profile.addonCompartment.hide then
                self:DisableAddonCompartment()
            else
                self:EnableAddonCompartment()
            end
        end
        info.isNotRadio = true
        info.keepShownOnClick = true
        UIDropDownMenu_AddButton(info, level)
    end)

    ToggleDropDownMenu(1, nil, menuFrame, "cursor", 0, 0)
end

--- Description: Toggle the minimap button
--- @param: None
--- @return: None
function TextureSurprise:ToggleMinimapButton()
    local hide = not self.db.profile.minimap.hide
    self.db.profile.minimap.hide = hide
    if hide then
        LDBIcon:Hide("TextureSurprise")
    else
        LDBIcon:Show("TextureSurprise")
    end
end

-- Slash Commands
TextureSurprise:RegisterChatCommand("ts", "ShowTextureManager")
TextureSurprise:RegisterChatCommand("ts-mini", "ToggleMinimapButton")
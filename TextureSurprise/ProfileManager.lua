-- Texture Surprise Addon
-- Author: alvy023
-- File: ProfileManager.lua
-- Description: Profile management functionality integrated into the texture manager
-- License: License.txt
-- For more information, visit the project repository.

-- ProfileManager Global Variable
ProfileManager = {}

--- Description: Creates a profile management section within the texture manager window
--- This function creates UI elements for managing addon profiles including:
--- - A dropdown to select/switch between existing profiles
--- - A button to create new profiles (opens dialog)
--- - A button to copy the current profile to a new name
--- - A button to delete the current profile (if not the last one)
--- - A button to reset the current profile to default settings
--- @param parentFrame: Parent frame to attach the profile section to
--- @param parentAddon: Reference to the main addon object
--- @return: The created profile section frame
function ProfileManager:Create(parentFrame, parentAddon)
    if not parentFrame then return nil end
    
    local db = parentAddon.db
    
    -- Create profile section frame
    local profileSection = CreateFrame("Frame", nil, parentFrame)
    profileSection:SetAllPoints(parentFrame)
    
    -- Constants for consistent sizing
    local LABEL_WIDTH = 165
    local DROPDOWN_WIDTH = 140
    local INPUT_WIDTH = 150
    local BUTTON_WIDTH = 60
    local ROW_HEIGHT = 30
    local LEFT_MARGIN = 10
    
    -- Profile section header
    local header = Interface:CreateCategoryDivider(profileSection, true)
    header:SetText("Manage Profiles")
    header:SetPoint("TOPLEFT", profileSection, "TOPLEFT", 15, -5)
    
    -- Row 1: Current Profile Selector
    local row1Y = -43
    
    local currentLabel = profileSection:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    currentLabel:SetPoint("TOPLEFT", profileSection, "TOPLEFT", LEFT_MARGIN, row1Y)
    currentLabel:SetWidth(LABEL_WIDTH)
    currentLabel:SetJustifyH("LEFT")
    currentLabel:SetText("Current Profile")
    
    local currentDropdown = CreateFrame("Frame", "TSProfileCurrentDropDown", profileSection, "UIDropDownMenuTemplate")
    currentDropdown:SetPoint("LEFT", currentLabel, "RIGHT", -15, -2)
    UIDropDownMenu_SetWidth(currentDropdown, DROPDOWN_WIDTH)
    
    local function UpdateCurrentDropdown()
        UIDropDownMenu_Initialize(currentDropdown, function()
            local profiles = db:GetProfiles()
            local currentProfile = db:GetCurrentProfile()
            
            for _, profileName in ipairs(profiles) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = profileName
                info.checked = (profileName == currentProfile)
                info.func = function()
                    db:SetProfile(profileName)
                    UIDropDownMenu_SetText(currentDropdown, profileName)
                    UpdateCurrentDropdown()
                    parentAddon:Print("Switched to profile: " .. profileName)
                    ProfileManager:RefreshTexturesForProfile(parentAddon)
                end
                UIDropDownMenu_AddButton(info)
            end
        end)
        UIDropDownMenu_SetText(currentDropdown, db:GetCurrentProfile())
    end
    
    UpdateCurrentDropdown()
    
    -- Row 2: Copy Profile to Current
    local row2Y = row1Y - ROW_HEIGHT
    
    local copyLabel = profileSection:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    copyLabel:SetPoint("TOPLEFT", profileSection, "TOPLEFT", LEFT_MARGIN, row2Y)
    copyLabel:SetWidth(LABEL_WIDTH)
    copyLabel:SetJustifyH("LEFT")
    copyLabel:SetText("Copy Profile to Current")
    
    local copyDropdown = CreateFrame("Frame", "TSProfileCopyDropDown", profileSection, "UIDropDownMenuTemplate")
    copyDropdown:SetPoint("LEFT", copyLabel, "RIGHT", -15, -2)
    UIDropDownMenu_SetWidth(copyDropdown, DROPDOWN_WIDTH)
    
    UIDropDownMenu_Initialize(copyDropdown, function()
        local profiles = db:GetProfiles()
        local currentProfile = db:GetCurrentProfile()
        
        for _, profileName in ipairs(profiles) do
            if profileName ~= currentProfile then
                local info = UIDropDownMenu_CreateInfo()
                info.text = profileName
                info.func = function()
                    UIDropDownMenu_SetText(copyDropdown, profileName)
                end
                UIDropDownMenu_AddButton(info)
            end
        end
    end)
    UIDropDownMenu_SetText(copyDropdown, "Select Profile")
    
    local copyBtn = CreateFrame("Button", nil, profileSection, "UIPanelButtonTemplate")
    copyBtn:SetSize(BUTTON_WIDTH, 22)
    copyBtn:SetPoint("LEFT", copyDropdown, "RIGHT", -10, 2)
    copyBtn:SetText("Copy")
    copyBtn:SetScript("OnClick", function()
        local selectedText = UIDropDownMenu_GetText(copyDropdown)
        if selectedText and selectedText ~= "Select Profile" then
            ProfileManager:ShowConfirmDialog(
                "Copy Profile",
                "Copy settings from '" .. selectedText .. "' to current profile?",
                function()
                    db:CopyProfile(selectedText)
                    parentAddon:Print("Copied from profile: " .. selectedText)
                    UpdateCurrentDropdown()
                    ProfileManager:RefreshTexturesForProfile(parentAddon)
                end
            )
        else
            parentAddon:Print("Please select a profile to copy from")
        end
    end)
    
    -- Row 3: Add New Profile
    local row3Y = row2Y - ROW_HEIGHT
    
    local newLabel = profileSection:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    newLabel:SetPoint("TOPLEFT", profileSection, "TOPLEFT", LEFT_MARGIN, row3Y)
    newLabel:SetWidth(LABEL_WIDTH)
    newLabel:SetJustifyH("LEFT")
    newLabel:SetText("Add New Profile")
    
    local newEditBox = CreateFrame("EditBox", nil, profileSection, "InputBoxTemplate")
    newEditBox:SetSize(INPUT_WIDTH, 20)
    newEditBox:SetPoint("LEFT", newLabel, "RIGHT", 8, 0)
    newEditBox:SetAutoFocus(false)
    newEditBox:SetMaxLetters(64)
    
    local addBtn = CreateFrame("Button", nil, profileSection, "UIPanelButtonTemplate")
    addBtn:SetSize(BUTTON_WIDTH, 22)
    addBtn:SetPoint("LEFT", newEditBox, "RIGHT", 7, 0)
    addBtn:SetText("Add")
    addBtn:SetScript("OnClick", function()
        local profileName = newEditBox:GetText()
        if profileName and profileName ~= "" then
            local profiles = db:GetProfiles()
            local exists = false
            for _, name in ipairs(profiles) do
                if name == profileName then
                    exists = true
                    break
                end
            end
            
            if exists then
                parentAddon:Print("Profile '" .. profileName .. "' already exists!")
            else
                db:SetProfile(profileName)
                UpdateCurrentDropdown()
                newEditBox:SetText("")
                parentAddon:Print("Created and switched to profile: " .. profileName)
                ProfileManager:RefreshTexturesForProfile(parentAddon)
            end
        else
            parentAddon:Print("Please enter a profile name")
        end
    end)
    
    newEditBox:SetScript("OnEnterPressed", function()
        addBtn:Click()
        newEditBox:ClearFocus()
    end)
    
    newEditBox:SetScript("OnEscapePressed", function()
        newEditBox:ClearFocus()
    end)
    
    -- Row 4: Delete Existing Profile
    local row4Y = row3Y - ROW_HEIGHT
    
    local deleteLabel = profileSection:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    deleteLabel:SetPoint("TOPLEFT", profileSection, "TOPLEFT", LEFT_MARGIN, row4Y)
    deleteLabel:SetWidth(LABEL_WIDTH)
    deleteLabel:SetJustifyH("LEFT")
    deleteLabel:SetText("Delete Existing Profile")
    
    local deleteDropdown = CreateFrame("Frame", "TSProfileDeleteDropDown", profileSection, "UIDropDownMenuTemplate")
    deleteDropdown:SetPoint("LEFT", deleteLabel, "RIGHT", -15, -2)
    UIDropDownMenu_SetWidth(deleteDropdown, DROPDOWN_WIDTH)
    
    local function UpdateDeleteDropdown()
        UIDropDownMenu_Initialize(deleteDropdown, function()
            local profiles = db:GetProfiles()
            local currentProfile = db:GetCurrentProfile()
            
            for _, profileName in ipairs(profiles) do
                if profileName ~= currentProfile then
                    local info = UIDropDownMenu_CreateInfo()
                    info.text = profileName
                    info.func = function()
                        UIDropDownMenu_SetText(deleteDropdown, profileName)
                    end
                    UIDropDownMenu_AddButton(info)
                end
            end
        end)
        UIDropDownMenu_SetText(deleteDropdown, "Select Profile")
    end
    
    UpdateDeleteDropdown()
    
    local deleteBtn = CreateFrame("Button", nil, profileSection, "UIPanelButtonTemplate")
    deleteBtn:SetSize(BUTTON_WIDTH, 22)
    deleteBtn:SetPoint("LEFT", deleteDropdown, "RIGHT", -10, 2)
    deleteBtn:SetText("Delete")
    deleteBtn:SetScript("OnClick", function()
        local selectedText = UIDropDownMenu_GetText(deleteDropdown)
        if selectedText and selectedText ~= "Select Profile" then
            local profiles = db:GetProfiles()
            if #profiles > 1 then
                ProfileManager:ShowConfirmDialog(
                    "Delete Profile",
                    "Are you sure you want to delete '" .. selectedText .. "'?",
                    function()
                        db:DeleteProfile(selectedText)
                        UpdateDeleteDropdown()
                        parentAddon:Print("Deleted profile: " .. selectedText)
                        ProfileManager:RefreshTexturesForProfile(parentAddon)
                    end
                )
            else
                parentAddon:Print("Cannot delete the last profile!")
            end
        else
            parentAddon:Print("Please select a profile to delete")
        end
    end)
    
    return profileSection
end

--- Description: Shows a confirmation dialog
--- @param title: Dialog title
--- @param message: Confirmation message
--- @param onConfirm: Function to call when confirmed
--- @return: None
function ProfileManager:ShowConfirmDialog(title, message, onConfirm)
    local dialog = Interface:CreateStyledWindow(title, 320, 150, true)
    
    -- Message
    local messageText = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    messageText:SetPoint("TOPLEFT", dialog, "TOPLEFT", 20, -50)
    messageText:SetPoint("TOPRIGHT", dialog, "TOPRIGHT", -20, -50)
    messageText:SetText(message)
    messageText:SetJustifyH("LEFT")
    messageText:SetWordWrap(true)
    
    -- Yes button
    local yesBtn = CreateFrame("Button", nil, dialog, "UIPanelButtonTemplate")
    yesBtn:SetWidth(60)
    yesBtn:SetHeight(25)
    yesBtn:SetPoint("BOTTOMRIGHT", dialog, "BOTTOMRIGHT", -10, 10)
    yesBtn:SetText("Yes")
    yesBtn:SetScript("OnClick", function()
        onConfirm()
        dialog:Hide()
    end)
    
    -- No button
    local noBtn = CreateFrame("Button", nil, dialog, "UIPanelButtonTemplate")
    noBtn:SetWidth(60)
    noBtn:SetHeight(25)
    noBtn:SetPoint("RIGHT", yesBtn, "LEFT", -5, 0)
    noBtn:SetText("No")
    noBtn:SetScript("OnClick", function()
        dialog:Hide()
    end)
    
    dialog:Show()
end

--- Description: Refreshes textures when switching profiles
--- @param parentAddon: Reference to the main addon object
--- @return: None
function ProfileManager:RefreshTexturesForProfile(parentAddon)
    local db = parentAddon.db
    
    -- Hide all currently displayed textures
    for name, frame in pairs(TextureManager.frames) do
        if frame.menu then
            frame.menu:Hide()
        end
        frame:Hide()
    end
    
    -- Clear the frames table
    wipe(TextureManager.frames)
    
    -- Show textures from the new profile
    if db.profile.textures then
        for name, _ in pairs(db.profile.textures) do
            TextureManager:AddTexture(name, parentAddon)
        end
    end
end

return ProfileManager

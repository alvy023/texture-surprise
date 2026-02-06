-- Texture Surprise Addon
-- Author: alvy023
-- File: GroupManager.lua
-- Description: Group management functionality for the TS addon.
-- License: License.txt
-- For more information, visit the project repository.

-- Load Libraries
local AceGUI = LibStub("AceGUI-3.0")

-- GroupManager Global Variable
GroupManager = {}

GroupManager.groupFrames = GroupManager.groupFrames or {}

-- Functions
--- Description: Creates the group manager window using styled interface
--- @param parentAddon: Reference to the main addon object
--- @return: The created window object
function GroupManager:Create(parentAddon)
    -- Use styled interface if available
    local window = Interface:CreateStyledWindow("Texture Group Manager", 408, 520, true)

    -- Create the manage groups area
    local manageGroupsFrame = CreateFrame("Frame", nil, window.content)
    manageGroupsFrame:SetPoint("TOPLEFT", window.content, "TOPLEFT", 0, -8)
    manageGroupsFrame:SetPoint("TOPRIGHT", window.content, "TOPRIGHT", 0, -8)
    manageGroupsFrame:SetHeight(100)

    local manageHeader = Interface:CreateCategoryDivider(manageGroupsFrame, true)
    manageHeader:SetText("Manage Groups")
    manageHeader:SetPoint("TOPLEFT", manageGroupsFrame, "TOPLEFT", 15, -15)

    -- Current Groups dropdown
    local groupsLabel = manageGroupsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    groupsLabel:SetText("Current Groups:")
    groupsLabel:SetPoint("TOPLEFT", manageGroupsFrame, "TOPLEFT", 10, -50)

    local groupsDropdown = CreateFrame("Frame", "TSGroupsDropdown", manageGroupsFrame, "UIDropDownMenuTemplate")
    groupsDropdown:SetPoint("LEFT", groupsLabel, "RIGHT", -15, -3)
    UIDropDownMenu_SetWidth(groupsDropdown, 180)

    -- Delete Group button
    local deleteGroupButton = CreateFrame("Button", nil, manageGroupsFrame, "UIPanelButtonTemplate")
    deleteGroupButton:SetSize(100, 25)
    deleteGroupButton:SetPoint("LEFT", groupsDropdown, "RIGHT", -15, 0)
    deleteGroupButton:SetText("Delete Group")

    -- Create New Group section
    local createGroupFrame = CreateFrame("Frame", nil, window.content)
    createGroupFrame:SetPoint("TOPLEFT", manageGroupsFrame, "BOTTOMLEFT", 0, -15)
    createGroupFrame:SetPoint("TOPRIGHT", manageGroupsFrame, "BOTTOMRIGHT", 0, -15)
    createGroupFrame:SetHeight(80)

    local createHeader = Interface:CreateCategoryDivider(createGroupFrame, true)
    createHeader:SetText("Create New Group")
    createHeader:SetPoint("TOPLEFT", createGroupFrame, "TOPLEFT", 15, -15)

    local nameLabel = createGroupFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameLabel:SetText("Name:")
    nameLabel:SetPoint("TOPLEFT", createGroupFrame, "TOPLEFT", 10, -50)

    local nameEditBox = CreateFrame("EditBox", nil, createGroupFrame, "InputBoxTemplate")
    nameEditBox:SetSize(180, 25)
    nameEditBox:SetPoint("LEFT", nameLabel, "RIGHT", 10, 0)
    nameEditBox:SetAutoFocus(false)

    local createButton = CreateFrame("Button", nil, createGroupFrame, "UIPanelButtonTemplate")
    createButton:SetSize(80, 25)
    createButton:SetPoint("LEFT", nameEditBox, "RIGHT", 5, 0)
    createButton:SetText("Create")

    -- Add Textures to Group section
    local addTextureFrame = CreateFrame("Frame", nil, window.content)
    addTextureFrame:SetPoint("TOPLEFT", createGroupFrame, "BOTTOMLEFT", 0, -15)
    addTextureFrame:SetPoint("TOPRIGHT", createGroupFrame, "BOTTOMRIGHT", 0, -15)
    addTextureFrame:SetHeight(120)

    local addHeader = Interface:CreateCategoryDivider(addTextureFrame, true)
    addHeader:SetText("Add Textures to Group")
    addHeader:SetPoint("TOPLEFT", addTextureFrame, "TOPLEFT", 15, -15)

    -- Group selector for adding textures
    local selectGroupLabel = addTextureFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    selectGroupLabel:SetText("Group:")
    selectGroupLabel:SetPoint("TOPLEFT", addTextureFrame, "TOPLEFT", 10, -50)

    local selectGroupDropdown = CreateFrame("Frame", "TSSelectGroupDropdown", addTextureFrame, "UIDropDownMenuTemplate")
    selectGroupDropdown:SetPoint("LEFT", selectGroupLabel, "RIGHT", -15, -3)
    UIDropDownMenu_SetWidth(selectGroupDropdown, 180)

    -- Texture selector
    local textureLabel = addTextureFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    textureLabel:SetText("Texture:")
    textureLabel:SetPoint("TOPLEFT", selectGroupLabel, "BOTTOMLEFT", 0, -32)

    local textureDropdown = CreateFrame("Frame", "TSTextureDropdown", addTextureFrame, "UIDropDownMenuTemplate")
    textureDropdown:SetPoint("LEFT", textureLabel, "RIGHT", -15, -3)
    UIDropDownMenu_SetWidth(textureDropdown, 180)

    -- Add to Group button
    local addToGroupButton = CreateFrame("Button", nil, addTextureFrame, "UIPanelButtonTemplate")
    addToGroupButton:SetSize(100, 25)
    addToGroupButton:SetPoint("LEFT", textureDropdown, "RIGHT", -15, 0)
    addToGroupButton:SetText("Add to Group")

    -- Current Group Members section
    local membersFrame = CreateFrame("Frame", nil, window.content)
    membersFrame:SetPoint("TOPLEFT", addTextureFrame, "BOTTOMLEFT", 0, -15)
    membersFrame:SetPoint("TOPRIGHT", addTextureFrame, "BOTTOMRIGHT", 0, -15)
    membersFrame:SetHeight(120)

    local membersHeader = Interface:CreateCategoryDivider(membersFrame, true)
    membersHeader:SetText("Current Group Members")
    membersHeader:SetPoint("TOPLEFT", membersFrame, "TOPLEFT", 15, -15)

    -- Scrollable members list
    local membersScrollFrame = CreateFrame("ScrollFrame", nil, membersFrame, "UIPanelScrollFrameTemplate")
    membersScrollFrame:SetPoint("TOPLEFT", membersFrame, "TOPLEFT", 10, -50)
    membersScrollFrame:SetPoint("BOTTOMRIGHT", membersFrame, "BOTTOMRIGHT", -30, 10)

    local membersContent = CreateFrame("Frame", nil, membersScrollFrame)
    membersContent:SetSize(340, 60)
    membersScrollFrame:SetScrollChild(membersContent)

    -- Edit Mode button
    local editModeButton = CreateFrame("Button", nil, window.content, "UIPanelButtonTemplate")
    editModeButton:SetSize(100, 25)
    editModeButton:SetPoint("BOTTOM", window.content, "BOTTOM", 0, 10)
    editModeButton:SetText("Edit Mode")

    -- Result label
    local resultLabel = window.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    resultLabel:SetText("")
    resultLabel:SetPoint("BOTTOM", editModeButton, "TOP", 0, 5)

    -- Store references for updates
    window.groupsDropdown = groupsDropdown
    window.selectGroupDropdown = selectGroupDropdown
    window.textureDropdown = textureDropdown
    window.membersContent = membersContent
    window.resultLabel = resultLabel
    window.nameEditBox = nameEditBox
    window.selectedGroup = nil

    -- Initialize dropdowns
    local function UpdateGroupsDropdown()
        UIDropDownMenu_Initialize(groupsDropdown, function(self, level)
            if not parentAddon.db.profile.groups then return end
            
            for groupName, _ in pairs(parentAddon.db.profile.groups) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = groupName
                info.func = function()
                    UIDropDownMenu_SetText(groupsDropdown, groupName)
                    window.selectedGroup = groupName
                    UpdateMembersList()
                end
                UIDropDownMenu_AddButton(info)
            end
        end)
    end

    local function UpdateSelectGroupDropdown()
        UIDropDownMenu_Initialize(selectGroupDropdown, function(self, level)
            if not parentAddon.db.profile.groups then return end
            
            for groupName, _ in pairs(parentAddon.db.profile.groups) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = groupName
                info.func = function()
                    UIDropDownMenu_SetText(selectGroupDropdown, groupName)
                end
                UIDropDownMenu_AddButton(info)
            end
        end)
    end

    local function UpdateTextureDropdown()
        UIDropDownMenu_Initialize(textureDropdown, function(self, level)
            local ungroupedTextures = GroupManager:GetUngroupedTextures(parentAddon)
            if not ungroupedTextures or #ungroupedTextures == 0 then return end
            
            for _, textureName in ipairs(ungroupedTextures) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = textureName
                info.func = function()
                    UIDropDownMenu_SetText(textureDropdown, textureName)
                end
                UIDropDownMenu_AddButton(info)
            end
        end)
    end

    local function UpdateMembersList()
        -- Clear existing members
        for _, child in ipairs({membersContent:GetChildren()}) do
            child:Hide()
            child:SetParent(nil)
        end

        if not window.selectedGroup or not parentAddon.db.profile.groups[window.selectedGroup] then
            return
        end

        local group = parentAddon.db.profile.groups[window.selectedGroup]
        local yOffset = -5
        
        for i, textureName in ipairs(group.textures) do
            local memberFrame = CreateFrame("Frame", nil, membersContent)
            memberFrame:SetSize(320, 25)
            memberFrame:SetPoint("TOPLEFT", membersContent, "TOPLEFT", 0, yOffset)

            local bullet = memberFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            bullet:SetText("• " .. textureName)
            bullet:SetPoint("LEFT", memberFrame, "LEFT", 5, 0)

            local removeButton = CreateFrame("Button", nil, memberFrame, "UIPanelButtonTemplate")
            removeButton:SetSize(60, 20)
            removeButton:SetPoint("RIGHT", memberFrame, "RIGHT", -5, 0)
            removeButton:SetText("Remove")
            removeButton:SetScript("OnClick", function()
                GroupManager:RemoveTextureFromGroup(textureName, window.selectedGroup, parentAddon)
                UpdateMembersList()
                UpdateTextureDropdown()
                resultLabel:SetText("Removed " .. textureName .. " from group")
                resultLabel:SetTextColor(0, 1, 0)
            end)

            yOffset = yOffset - 25
        end

        membersContent:SetHeight(math.max(60, math.abs(yOffset)))
    end

    -- Button functionality
    createButton:SetScript("OnClick", function()
        local groupName = nameEditBox:GetText()
        if groupName and groupName ~= "" then
            local success, message = GroupManager:CreateGroup(groupName, parentAddon)
            if success then
                nameEditBox:SetText("")
                UpdateGroupsDropdown()
                UpdateSelectGroupDropdown()
                resultLabel:SetText("Created group: " .. groupName)
                resultLabel:SetTextColor(0, 1, 0)
            else
                resultLabel:SetText("Error: " .. message)
                resultLabel:SetTextColor(1, 0, 0)
            end
        else
            resultLabel:SetText("Error: Group name required!")
            resultLabel:SetTextColor(1, 0, 0)
        end
    end)

    deleteGroupButton:SetScript("OnClick", function()
        if window.selectedGroup then
            GroupManager:DeleteGroup(window.selectedGroup, parentAddon)
            window.selectedGroup = nil
            UIDropDownMenu_SetText(groupsDropdown, "Select Group")
            UpdateGroupsDropdown()
            UpdateSelectGroupDropdown()
            UpdateTextureDropdown()
            UpdateMembersList()
            resultLabel:SetText("Group deleted")
            resultLabel:SetTextColor(0, 1, 0)
        else
            resultLabel:SetText("Error: No group selected!")
            resultLabel:SetTextColor(1, 0, 0)
        end
    end)

    addToGroupButton:SetScript("OnClick", function()
        local selectedGroup = UIDropDownMenu_GetText(selectGroupDropdown)
        local selectedTexture = UIDropDownMenu_GetText(textureDropdown)
        
        if selectedGroup and selectedTexture and selectedGroup ~= "Select Group" and selectedTexture ~= "Select Texture" then
            local success, message = GroupManager:AddTextureToGroup(selectedTexture, selectedGroup, parentAddon)
            if success then
                UpdateTextureDropdown()
                if window.selectedGroup == selectedGroup then
                    UpdateMembersList()
                end
                resultLabel:SetText("Added " .. selectedTexture .. " to " .. selectedGroup)
                resultLabel:SetTextColor(0, 1, 0)
            else
                resultLabel:SetText("Error: " .. message)
                resultLabel:SetTextColor(1, 0, 0)
            end
        else
            resultLabel:SetText("Error: Select both group and texture!")
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

    -- Initialize dropdown texts
    UIDropDownMenu_SetText(groupsDropdown, "Select Group")
    UIDropDownMenu_SetText(selectGroupDropdown, "Select Group")
    UIDropDownMenu_SetText(textureDropdown, "Select Texture")

    -- Update dropdowns when window is shown
    window:SetScript("OnShow", function()
        UpdateGroupsDropdown()
        UpdateSelectGroupDropdown()
        UpdateTextureDropdown()
        if window.selectedGroup then
            UpdateMembersList()
        end
        resultLabel:SetText("")
    end)

    return window
end

--- Description: Creates a new group
--- @param name: Name of the group
--- @param parentAddon: Reference to the main addon object
--- @return: success (boolean), message (string)
function GroupManager:CreateGroup(name, parentAddon)
    if not parentAddon.db.profile.groups then
        parentAddon.db.profile.groups = {}
    end

    if parentAddon.db.profile.groups[name] then
        return false, "Group already exists!"
    end

    parentAddon.db.profile.groups[name] = {
        textures = {},
        x = 0,
        y = 0,
        locked = false,
        visible = true,
        alpha = 1.0,
        strata = "MEDIUM",
        level = 1,
        rotation = 0,
        relativePositions = {}
    }

    return true, "Group created successfully"
end

--- Description: Deletes a group and ungroups all its textures
--- @param name: Name of the group
--- @param parentAddon: Reference to the main addon object
--- @return: None
function GroupManager:DeleteGroup(name, parentAddon)
    if not parentAddon.db.profile.groups or not parentAddon.db.profile.groups[name] then
        return
    end

    local group = parentAddon.db.profile.groups[name]
    
    -- Ungroup all textures first
    for _, textureName in ipairs(group.textures) do
        self:RemoveTextureFromGroup(textureName, name, parentAddon)
    end

    -- Delete the group
    parentAddon.db.profile.groups[name] = nil

    -- Delete the group frame if it exists
    if self.groupFrames[name] then
        self.groupFrames[name]:Hide()
        self.groupFrames[name] = nil
    end
end

--- Description: Adds a texture to a group
--- @param textureName: Name of the texture
--- @param groupName: Name of the group
--- @param parentAddon: Reference to the main addon object
--- @return: success (boolean), message (string)
function GroupManager:AddTextureToGroup(textureName, groupName, parentAddon)
    if not parentAddon.db.profile.groups or not parentAddon.db.profile.groups[groupName] then
        return false, "Group does not exist!"
    end

    if not parentAddon.db.profile.textures or not parentAddon.db.profile.textures[textureName] then
        return false, "Texture does not exist!"
    end

    -- Check if texture is already in this group
    local group = parentAddon.db.profile.groups[groupName]
    for _, name in ipairs(group.textures) do
        if name == textureName then
            return false, "Texture already in group!"
        end
    end

    -- Check if texture is in another group
    local currentGroup = self:GetTextureGroup(textureName, parentAddon)
    if currentGroup then
        return false, "Texture is already in group: " .. currentGroup
    end

    -- Add texture to group
    table.insert(group.textures, textureName)

    -- Calculate relative position from group center
    local textureFrame = TextureManager.frames[textureName]
    if textureFrame then
        local _, _, _, x, y = textureFrame:GetPoint()
        group.relativePositions[textureName] = {
            x = (x or 0) - group.x,
            y = (y or 0) - group.y
        }
    else
        group.relativePositions[textureName] = {x = 0, y = 0}
    end

    -- Create or update group frame
    self:CreateGroupFrame(groupName, parentAddon)

    return true, "Texture added to group"
end

--- Description: Removes a texture from a group
--- @param textureName: Name of the texture
--- @param groupName: Name of the group
--- @param parentAddon: Reference to the main addon object
--- @return: None
function GroupManager:RemoveTextureFromGroup(textureName, groupName, parentAddon)
    if not parentAddon.db.profile.groups or not parentAddon.db.profile.groups[groupName] then
        return
    end

    local group = parentAddon.db.profile.groups[groupName]
    
    -- Remove texture from group
    for i, name in ipairs(group.textures) do
        if name == textureName then
            table.remove(group.textures, i)
            break
        end
    end

    -- Remove relative position data
    group.relativePositions[textureName] = nil

    -- Convert relative position back to absolute and reparent texture
    local textureFrame = TextureManager.frames[textureName]
    if textureFrame then
        textureFrame:ClearAllPoints()
        textureFrame:SetParent(UIParent)
        local textureData = parentAddon.db.profile.textures[textureName]
        if textureData then
            textureFrame:SetPoint("CENTER", UIParent, "CENTER", textureData.x, textureData.y)
        end
    end

    -- Update group frame
    if #group.textures > 0 then
        self:CreateGroupFrame(groupName, parentAddon)
    else
        -- No textures left, hide group frame
        if self.groupFrames[groupName] then
            self.groupFrames[groupName]:Hide()
        end
    end
end

--- Description: Creates or updates a group frame
--- @param groupName: Name of the group
--- @param parentAddon: Reference to the main addon object
--- @return: The group frame
function GroupManager:CreateGroupFrame(groupName, parentAddon)
    if not parentAddon.db.profile.groups or not parentAddon.db.profile.groups[groupName] then
        return
    end

    local group = parentAddon.db.profile.groups[groupName]
    
    -- Hide existing frame if it exists
    if self.groupFrames[groupName] then
        self.groupFrames[groupName]:Hide()
        self.groupFrames[groupName] = nil
    end

    -- Don't create frame if no textures
    if #group.textures == 0 then
        return
    end

    -- Create the group frame (no longer using EditModeSystemTemplate as we handle it ourselves)
    local frame = CreateFrame("Frame", "TextureSurpriseGroupFrame_"..groupName, UIParent)
    
    -- Calculate bounding box for all textures in group
    local minX, maxX, minY, maxY = math.huge, -math.huge, math.huge, -math.huge
    
    for _, textureName in ipairs(group.textures) do
        local relPos = group.relativePositions[textureName]
        if relPos then
            local textureData = parentAddon.db.profile.textures[textureName]
            if textureData then
                local w, h = textureData.width / 2, textureData.height / 2
                minX = math.min(minX, relPos.x - w)
                maxX = math.max(maxX, relPos.x + w)
                minY = math.min(minY, relPos.y - h)
                maxY = math.max(maxY, relPos.y + h)
            end
        end
    end

    local width = maxX - minX
    local height = maxY - minY
    
    frame:SetSize(math.max(64, width), math.max(64, height))
    frame:SetPoint("CENTER", UIParent, "CENTER", group.x, group.y)

    -- Reparent textures to group frame
    for _, textureName in ipairs(group.textures) do
        local textureFrame = TextureManager.frames[textureName]
        if textureFrame then
            local relPos = group.relativePositions[textureName]
            textureFrame:SetParent(frame)
            textureFrame:ClearAllPoints()
            textureFrame:SetPoint("CENTER", frame, "CENTER", relPos.x, relPos.y)
        end
    end

    -- Setup edit mode functionality for group frame
    EditModeTS:EnableGroupFrameEditMode(frame, parentAddon, groupName)
    
    -- Set initial visibility
    frame:SetShown(group.visible ~= false)
    
    self.groupFrames[groupName] = frame

    return frame
end

--- Description: Gets list of textures not in any group
--- @param parentAddon: Reference to the main addon object
--- @return: Array of texture names
function GroupManager:GetUngroupedTextures(parentAddon)
    local ungrouped = {}
    
    if not parentAddon.db.profile.textures then
        return ungrouped
    end

    for textureName, _ in pairs(parentAddon.db.profile.textures) do
        if not self:IsTextureInGroup(textureName, parentAddon) then
            table.insert(ungrouped, textureName)
        end
    end

    return ungrouped
end

--- Description: Checks if a texture is in any group
--- @param textureName: Name of the texture
--- @param parentAddon: Reference to the main addon object
--- @return: Boolean
function GroupManager:IsTextureInGroup(textureName, parentAddon)
    return self:GetTextureGroup(textureName, parentAddon) ~= nil
end

--- Description: Gets the group name for a texture
--- @param textureName: Name of the texture
--- @param parentAddon: Reference to the main addon object
--- @return: Group name or nil
function GroupManager:GetTextureGroup(textureName, parentAddon)
    if not parentAddon.db.profile.groups then
        return nil
    end

    for groupName, group in pairs(parentAddon.db.profile.groups) do
        for _, name in ipairs(group.textures) do
            if name == textureName then
                return groupName
            end
        end
    end

    return nil
end

--- Description: Updates group frame position when moved in edit mode
--- @param groupName: Name of the group
--- @param x: New X position
--- @param y: New Y position
--- @param parentAddon: Reference to the main addon object
--- @return: None
function GroupManager:UpdateGroupPosition(groupName, x, y, parentAddon)
    if not parentAddon.db.profile.groups or not parentAddon.db.profile.groups[groupName] then
        return
    end

    local group = parentAddon.db.profile.groups[groupName]
    group.x = x
    group.y = y
end

--- Description: Initializes all group frames from saved data
--- @param parentAddon: Reference to the main addon object
--- @return: None
function GroupManager:InitializeGroups(parentAddon)
    if not parentAddon.db.profile.groups then
        return
    end

    for groupName, _ in pairs(parentAddon.db.profile.groups) do
        self:CreateGroupFrame(groupName, parentAddon)
    end
end

return GroupManager

-- Texture Surprise Addon
-- Author: alvy023
-- File: Interface.lua
-- Description: UI framework built on Blizzard's native frame templates
-- License: License.txt
-- For more information, visit the project repository.

-- Interface Global Variable
Interface = {}

-- Interface Mixins and Functions
--- Category Divider Implementation
Interface.CategoryDividerMixin = {}

--- Description: Hides the divider line
--- @param None
--- @return: None
function Interface.CategoryDividerMixin:HideDivider()
    self.Divider:Hide()
end

--- Description: Creates a category divider with text and line
--- @param parent (Frame to attach the divider to)
--- @param alignCenter (Boolean to center align text)
--- @return: FontString with divider
function Interface:CreateCategoryDivider(parent, alignCenter)
    local fontString = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    if alignCenter then
        fontString:SetJustifyH("CENTER")
    else
        fontString:SetJustifyH("LEFT")
    end

    fontString:SetJustifyV("TOP")
    fontString:SetTextColor(1, 1, 1)

    local divider = parent:CreateTexture(nil, "OVERLAY")
    divider:SetHeight(4)
    divider:SetPoint("TOPLEFT", fontString, "BOTTOMLEFT", -7, -8)
    divider:SetPoint("RIGHT", parent, "RIGHT", -8, 0)
    divider:SetColorTexture(0.5, 0.5, 0.5, 0.5)

    fontString.Divider = divider
    Mixin(fontString, Interface.CategoryDividerMixin)

    return fontString
end

--- Styled Window Implementation
--- Description: Creates a styled window with title bar and content area, built on Blizzard's native BasicFrameTemplateWithInset
--- @param title (String title text)
--- @param width (Width of the window)
--- @param height (Height of the window)
--- @param showCloseButton (Boolean to show or hide the close button)
--- @return: Styled window frame
function Interface:CreateStyledWindow(title, width, height, showCloseButton)
    local frame = CreateFrame("Frame", nil, UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(width or 400, height or 300)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetMovable(true)

    frame.TitleText:SetText(title or "Texture Surprise")
    frame.CloseButton:SetShown(showCloseButton or false)

    -- Draggable title bar strip (also used by EditMode.lua to hook position-save on drag stop)
    local header = CreateFrame("Frame", nil, frame)
    header:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    header:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
    header:SetHeight(24)
    header:EnableMouse(true)
    header:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            frame:StartMoving()
        end
    end)
    header:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" then
            frame:StopMovingOrSizing()
        end
    end)

    -- Create content area anchored inside the template's inset region
    local content = CreateFrame("Frame", nil, frame)
    content:SetPoint("TOPLEFT", frame, "TOPLEFT", 4, -24)
    content:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -6, 4)

    frame.header = header
    frame.content = content

    -- Add show/hide methods
    frame.CloseUI = function(self)
        self:Hide()
    end

    return frame
end

return Interface

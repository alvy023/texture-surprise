-- Patch Notes Delivered Addon
-- Author: alvy023
-- File: AceGUI-IconButton-PND.lua
-- Description: Custom AceGUI based Icon button
-- License: See License.txt
-- For more information, visit the project repository.

-- Load Libraries
local AceGUI = LibStub("AceGUI-3.0")

-- Constants
local Type, Version = "IconButton-TS", 1

-- Functions
--- Description: Handles the OnEnter event for the control.
--- @param: frame - The frame triggering the event.
--- @return:
local function Control_OnEnter(frame)
    frame.obj:Fire("OnEnter")
end

--- Description: Handles the OnLeave event for the control.
--- @param: frame - The frame triggering the event.
--- @return:
local function Control_OnLeave(frame)
    frame.obj:Fire("OnLeave")
end

--- Description: Handles the OnClick event for the button.
--- @param: frame - The frame triggering the event.
--- @param: button - The mouse button used to click.
--- @return:
local function Button_OnClick(frame, button)
    frame.obj:Fire("OnClick", button)
    AceGUI:ClearFocus()
end

-- Methods
local methods = {
    --- Description: Called when the widget is acquired.
    --- @param:
    --- @return:
    ["OnAcquire"] = function(self)
        self:SetHeight(24)
        self:SetWidth(24)
        self:SetImage(nil)
        self:SetTooltip(nil)
        self:SetDisabled(false)
    end,

    --- Description: Called when the widget is released.
    --- @param:
    --- @return:
    ["OnRelease"] = function(self)
        self.icon:Hide()
    end,

    --- Description: Sets the image for the button.
    --- @param: icon - The texture path for the icon.
    --- @return:
    ["SetImage"] = function(self, icon)
        self.icon:SetTexture(icon)
        self.icon:Show()
    end,

    --- Description: Sets the size of the image.
    --- @param: width - The width of the image.
    --- @param: height - The height of the image.
    --- @return:
    ["SetImageSize"] = function(self, width, height)
        self.icon:SetSize(width, height)
    end,

    --- Description: Sets the tooltip text for the button.
    --- @param: tooltipText - The text to display in the tooltip.
    --- @return:
    ["SetTooltip"] = function(self, tooltipText)
        self.tooltipText = tooltipText
    end,

    --- Description: Sets the size of the button.
    --- @param: width - The width of the button.
    --- @param: height - The height of the button.
    --- @return:
    ["SetSize"] = function(self, width, height)
        self.frame:SetSize(width, height)
    end,

    --- Description: Sets a callback for a specific event.
    --- @param: event - The event to set the callback for.
    --- @param: callback - The function to call when the event occurs.
    --- @return:
    ["SetCallback"] = function(self, event, callback)
        if event == "OnClick" then
            self.frame:SetScript("OnMouseUp", callback)
        else
            self.frame:SetScript(event, callback)
        end
    end,

    --- Description: Sets the disabled state of the button.
    --- @param: disabled - Whether the button should be disabled.
    --- @return:
    ["SetDisabled"] = function(self, disabled)
        self.disabled = disabled
        if disabled then
            self.frame:Disable()
            self.icon:SetVertexColor(0.5, 0.5, 0.5, 0.5)
        else
            self.frame:Enable()
            self.icon:SetVertexColor(1, 1, 1, 1)
        end
    end,

    --- Description: Hides the button.
    --- @param:
    --- @return:
    ["Hide"] = function(self)
        self.frame:Hide()
    end,

    --- Description: Shows the button.
    --- @param:
    --- @return:
    ["Show"] = function(self)
        self.frame:Show()
    end
}

-- Constructor
--- Description: Creates a new instance of the IconButton-MPA widget.
--- @param:
--- @return: The created widget.
local function Constructor()
    local frame = CreateFrame("Button", nil, UIParent)
    frame:Hide()

    frame:EnableMouse(true)
    frame:SetScript("OnEnter", Control_OnEnter)
    frame:SetScript("OnLeave", Control_OnLeave)
    frame:SetScript("OnMouseUp", Button_OnClick)

    local icon = frame:CreateTexture(nil, "BACKGROUND")
    icon:SetAllPoints(frame)

    local widget = {
        frame = frame,
        icon = icon,
        type = Type
    }
    for method, func in pairs(methods) do
        widget[method] = func
    end

    frame:SetScript("OnEnter", function()
        if widget.tooltipText then
            GameTooltip:SetOwner(widget.frame, "ANCHOR_TOPRIGHT")
            GameTooltip:SetText(widget.tooltipText, 1, 1, 1, 1, true)
            GameTooltip:Show()
        end
    end)

    frame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

-- PlayerControls Addon: Combines Speed Control and Teleportation Features

-- Prevent multiple frame instances
if _G.PlayerControlsAddonLoaded then return end
_G.PlayerControlsAddonLoaded = true

-- Keep track of previous teleport locations
local previousLocations = {}

-- Function to update the list of previous locations
function AddToPreviousLocations(location)
    table.insert(previousLocations, 1, location)
    if #previousLocations > 8 then
        table.remove(previousLocations, #previousLocations)
    end
end

function GetPreviousLocations()
    return previousLocations
end

-- Speed Control Feature
local speedCommands = { "s1", "s2", "s3", "s4", "s5" }
local currentSpeedIndex = 1

-- Function to increase speed
function IncreaseSpeed()
    currentSpeedIndex = math.min(currentSpeedIndex + 1, #speedCommands)
    local command = speedCommands[currentSpeedIndex]
    SendChatMessage(command, "SAY")
end

-- Function to decrease speed
function DecreaseSpeed()
    currentSpeedIndex = math.max(currentSpeedIndex - 1, 1)
    local command = speedCommands[currentSpeedIndex]
    SendChatMessage(command, "SAY")
end

function SpeedControl_Cycle()
    currentSpeedIndex = (currentSpeedIndex % #speedCommands) + 1
    local command = speedCommands[currentSpeedIndex]
    SendChatMessage(command, "SAY")
end

-- Load teleport locations from a separate file
local teleportLocations = {}
if TeleportLocations then
    teleportLocations = TeleportLocations
end

--------------------------------------------------------------------------------------------------------------------------------

-- Main frame
local mainFrame = CreateFrame("Frame", "PlayerControlsFrame", UIParent)
mainFrame:SetSize(200, 90)
mainFrame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -20, 20)
mainFrame:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
mainFrame:SetBackdropColor(0, 0, 0, 0.8)
mainFrame:EnableMouse(true)
mainFrame:SetMovable(true)
mainFrame:RegisterForDrag("LeftButton")
mainFrame:SetScript("OnDragStart", mainFrame.StartMoving)
mainFrame:SetScript("OnDragStop", mainFrame.StopMovingOrSizing)

-- Up Arrow Button (Increase Speed)
local upButton = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
upButton:SetSize(50, 30) -- Half the size of the speed button
upButton:SetText("UP") -- Up arrow symbol
upButton:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 20, -10)
upButton:SetScript("OnClick", IncreaseSpeed)

-- Down Arrow Button (Decrease Speed)
local downButton = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
downButton:SetSize(50, 30) -- Half the size of the speed button
downButton:SetText("DOWN") -- Down arrow symbol
downButton:SetPoint("LEFT", upButton, "RIGHT", 5, 0)
downButton:SetScript("OnClick", DecreaseSpeed)

-- Create a "Back" button in the same place you create your other main buttons
local backButton = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
backButton:SetSize(50, 30)
backButton:SetText("Back")
backButton:SetPoint("LEFT", downButton, "RIGHT", 5, 0)  -- Adjust position as you like
backButton:SetScript("OnClick", function()
    -- All we do is say "tb"
    SendChatMessage("tb", "SAY")
end)

-----------------------------------------------------------------------------------------------------------------------------------

-- Teleportation Feature
local largeFrame = CreateFrame("Frame", "TeleportFrame", UIParent)
largeFrame:SetSize(400, 600)
largeFrame:SetPoint("CENTER", UIParent, "CENTER")
largeFrame:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
largeFrame:SetBackdropColor(0, 0, 0, 0.8)
largeFrame:Hide()
largeFrame:EnableMouse(true)
largeFrame:SetMovable(true)
largeFrame:RegisterForDrag("LeftButton")
largeFrame:SetScript("OnDragStart", largeFrame.StartMoving)
largeFrame:SetScript("OnDragStop", largeFrame.StopMovingOrSizing)

-- Add title to the Teleport window
local teleportTitle = largeFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
teleportTitle:SetPoint("TOP", largeFrame, "TOP", 0, -10) -- Centered at the top of the frame
teleportTitle:SetText("Teleport Location Finder")

-- Close button for the Teleport (T) window
local largeCloseButton = CreateFrame("Button", nil, largeFrame, "UIPanelButtonTemplate")
largeCloseButton:SetSize(80, 30)
largeCloseButton:SetText("Close")
largeCloseButton:SetPoint("BOTTOM", largeFrame, "BOTTOM", 0, 10)
largeCloseButton:SetScript("OnClick", function()
    largeFrame:Hide()
end)

-- Teleport input box
local inputBox = CreateFrame("EditBox", "TeleportInputBox", largeFrame, "InputBoxTemplate")
inputBox:SetSize(250, 30)
inputBox:SetPoint("TOP", largeFrame, "TOP", 0, -30)
inputBox:SetAutoFocus(true)

-- Scroll frame for teleport locations
local scrollFrame = CreateFrame("ScrollFrame", "TeleportScrollFrame", largeFrame, "UIPanelScrollFrameTemplate")
scrollFrame:SetSize(300, 470)
scrollFrame:SetPoint("TOP", inputBox, "BOTTOM", 0, -10)

local scrollChild = CreateFrame("Frame", nil, scrollFrame)
scrollChild:SetSize(scrollFrame:GetWidth(), 1)
scrollFrame:SetScrollChild(scrollChild)

local locationButtons = {}

local function TeleportToLocation(location)
    SendChatMessage("t " .. location, "SAY")
    AddToPreviousLocations(location)
    largeFrame:Hide() -- Close T window after teleport
end

local function PopulateTeleportList(locations)
    for _, button in pairs(locationButtons) do
        button:Hide()
    end
    locationButtons = {}

    for i = 1, math.min(20, #locations) do
        local loc = locations[i]
        local button = CreateFrame("Button", nil, scrollChild, "UIPanelButtonTemplate")
        button:SetSize(scrollChild:GetWidth() - 20, 30)
        button:SetText(loc)
        button:SetPoint("TOP", 0, -40 * (i - 1))
        button:SetScript("OnClick", function()
            TeleportToLocation(loc)
        end)
        table.insert(locationButtons, button)
    end
end

local function UpdateTeleportList(filter)
    local prioritizedLocations = {}
    local secondaryLocations = {}

    for _, loc in ipairs(teleportLocations or {}) do
        if loc:lower():find("^" .. filter) then
            table.insert(prioritizedLocations, loc)
        elseif loc:lower():find(filter) then
            table.insert(secondaryLocations, loc)
        end
    end

    local combinedLocations = {}
    for _, loc in ipairs(prioritizedLocations) do
        table.insert(combinedLocations, loc)
    end
    for _, loc in ipairs(secondaryLocations) do
        table.insert(combinedLocations, loc)
    end

    PopulateTeleportList(combinedLocations)
end

inputBox:SetScript("OnTextChanged", function(self)
    local searchText = self:GetText():lower()
    UpdateTeleportList(searchText)
end)

-- Handle Enter key to teleport to the first location in the list
inputBox:SetScript("OnEnterPressed", function(self)
    if locationButtons[1] and locationButtons[1]:IsShown() then
        -- Execute the OnClick script of the first button
        locationButtons[1]:GetScript("OnClick")()
    end
end)

UpdateTeleportList("") -- Populate initially

--------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------
-- Teleport Friend Frame
-------------------------------------------------

-- Create the frame
local tfFrame = CreateFrame("Frame", "TeleportFriendFrame", UIParent)
tfFrame:SetSize(450, 600)
tfFrame:SetPoint("CENTER", UIParent, "CENTER")
tfFrame:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
tfFrame:SetBackdropColor(0, 0, 0, 0.8)
tfFrame:Hide()
tfFrame:EnableMouse(true)
tfFrame:SetMovable(true)
tfFrame:RegisterForDrag("LeftButton")
tfFrame:SetScript("OnDragStart", tfFrame.StartMoving)
tfFrame:SetScript("OnDragStop", tfFrame.StopMovingOrSizing)

-- Title
local tfTitle = tfFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
tfTitle:SetPoint("TOP", tfFrame, "TOP", 0, -10)
tfTitle:SetText("Teleport to Friend")

-- Close button
local tfCloseButton = CreateFrame("Button", nil, tfFrame, "UIPanelButtonTemplate")
tfCloseButton:SetSize(80, 30)
tfCloseButton:SetText("Close")
tfCloseButton:SetPoint("BOTTOM", tfFrame, "BOTTOM", 0, 10)
tfCloseButton:SetScript("OnClick", function()
    tfFrame:Hide()
end)

-------------------------------------------------
-- Party + Friend List Handling
-------------------------------------------------

-- This function will gather your party members first, then your friend list.
-- NOTE: In WoW 3.3.5, the relevant APIs are:
--   GetNumPartyMembers() (not in a raid) or GetNumRaidMembers()
--   GetNumFriends() + GetFriendInfo(index)
-- Adjust logic for raid if needed.
local function GetOnlinePartyAndFriends()
    local data = {}

    -- 1) Party members (online only)
    local partyCount = GetNumPartyMembers()
    for i = 1, partyCount do
        local unitID = "party" .. i
        if UnitExists(unitID) and UnitIsConnected(unitID) then
            local rawName = UnitName(unitID)
            local className = UnitClass(unitID)
            if rawName and className then
                table.insert(data, {
                    label   = rawName .. " - " .. className,
                    rawName = rawName
                })
            end
        end
    end

    -- 2) Friends (online only)
    local friendCount = GetNumFriends()
    for i = 1, friendCount do
        local friendName, level, class, area, connected, status, note = GetFriendInfo(i)
        if friendName and connected then
            table.insert(data, {
                label   = friendName .. " - " .. (class or "Unknown"),
                rawName = friendName
            })
        end
    end

    return data
end



-------------------------------------------------
-- Scroll Frame & Buttons
-------------------------------------------------

-- Create a scroll frame
local tfScrollFrame = CreateFrame("ScrollFrame", "TFFriendScrollFrame", tfFrame, "UIPanelScrollFrameTemplate")
tfScrollFrame:SetSize(300, 470)
tfScrollFrame:SetPoint("TOP", tfFrame, "TOP", 0, -80)

local tfScrollChild = CreateFrame("Frame", nil, tfScrollFrame)
tfScrollChild:SetSize(tfScrollFrame:GetWidth(), 1)
tfScrollFrame:SetScrollChild(tfScrollChild)

-- We'll keep a table of dynamically created buttons
local tfButtons = {}

-- Populate list
local function PopulateFriendListUI(filteredNames)
    -- Hide old buttons
    for _, btn in pairs(tfButtons) do
        btn:Hide()
    end
    tfButtons = {}

    -- Create new buttons
    for i, friendInfo in ipairs(filteredNames) do
        local btn = CreateFrame("Button", nil, tfScrollChild, "UIPanelButtonTemplate")
        btn:SetSize(tfScrollChild:GetWidth() - 20, 30)
        btn:SetPoint("TOP", 0, -35 * (i - 1))
        btn:SetText(friendInfo.label)  -- e.g. "Zayne - Warrior"
        btn:SetScript("OnClick", function()
            -- Use the rawName for the chat command
            SendChatMessage("app " .. friendInfo.rawName, "SAY")
            tfFrame:Hide()
        end)
        table.insert(tfButtons, btn)
    end
end

-------------------------------------------------
-- Filter Mechanism
-------------------------------------------------

-- 1) Full unfiltered list of party+friends
local fullFriendList = {}

function PopulateFriendList(filterText)
    fullFriendList = GetOnlinePartyAndFriends()

    local results = {}
    local f = filterText:lower()

    -- Compare `info.label`, since `info` is a table with { label, rawName }
    for _, info in ipairs(fullFriendList) do
        if info.label:lower():find(f) then
            table.insert(results, info)
        end
    end

    PopulateFriendListUI(results)
end

-------------------------------------------------
-- Edit Box (Input) - For searching or typing custom name
-------------------------------------------------
local tfInputBox = CreateFrame("EditBox", "TFFriendInputBox", tfFrame, "InputBoxTemplate")
tfInputBox:SetSize(250, 30)
tfInputBox:SetPoint("TOP", tfFrame, "TOP", 0, -40)
tfInputBox:SetAutoFocus(true)
tfInputBox:SetScript("OnTextChanged", function(self)
    local text = self:GetText() or ""
    PopulateFriendList(text)
end)

local tfTeleportButton = CreateFrame("Button", nil, tfFrame, "UIPanelButtonTemplate")
tfTeleportButton:SetSize(80, 30)
tfTeleportButton:SetText("Go")
tfTeleportButton:SetPoint("LEFT", tfInputBox, "RIGHT", 5, 0)
tfTeleportButton:SetScript("OnClick", function()
    local typedName = tfInputBox:GetText()
    if typedName and typedName ~= "" then
        SendChatMessage("app " .. typedName, "SAY")
        tfFrame:Hide()
    end
end)

-- Pressing ENTER also triggers the teleport
tfInputBox:SetScript("OnEnterPressed", function(self)
    local typedName = self:GetText()
    if typedName and typedName ~= "" then
        SendChatMessage("app " .. typedName, "SAY")
        tfFrame:Hide()
    end
end)

-- Hide on load
tfFrame:Hide()

-- The "tfButton" we created earlier will show this frame and call:
--    PopulateFriendList("")
-- whenever clicked.

----------------------------------------------------------------------------------------------------------------------------------------


-- Teleport Back Feature
local tbFrame = CreateFrame("Frame", "TeleportBackFrame", UIParent)
tbFrame:SetSize(400, 400)
tbFrame:SetPoint("CENTER", UIParent, "CENTER")
tbFrame:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
tbFrame:SetBackdropColor(0, 0, 0, 0.8)
tbFrame:Hide()
tbFrame:EnableMouse(true)
tbFrame:SetMovable(true)
tbFrame:RegisterForDrag("LeftButton")
tbFrame:SetScript("OnDragStart", tbFrame.StartMoving)
tbFrame:SetScript("OnDragStop", tbFrame.StopMovingOrSizing)

-- Add title to the Teleport window
local tbTitle = tbFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
tbTitle:SetPoint("TOP", tbFrame, "TOP", 0, -10) -- Centered at the top of the frame
tbTitle:SetText("Teleport Back Selection")

local tbCloseButton = CreateFrame("Button", nil, tbFrame, "UIPanelButtonTemplate")
tbCloseButton:SetSize(80, 30)
tbCloseButton:SetText("Close")
tbCloseButton:SetPoint("BOTTOM", tbFrame, "BOTTOM", 0, 10)
tbCloseButton:SetScript("OnClick", function()
    tbFrame:Hide()
end)

local tbScrollFrame = CreateFrame("ScrollFrame", "TBScrollFrame", tbFrame, "UIPanelScrollFrameTemplate")
tbScrollFrame:SetSize(300, 500)
tbScrollFrame:SetPoint("TOP", tbFrame, "TOP", 0, -40)

local tbScrollChild = CreateFrame("Frame", nil, tbScrollFrame)
tbScrollChild:SetSize(tbScrollFrame:GetWidth(), 1)
tbScrollFrame:SetScrollChild(tbScrollChild)

local tbLocationButtons = {}

local function PopulateTeleportBackList()
    local locations = GetPreviousLocations()
    for _, button in pairs(tbLocationButtons) do
        button:Hide()
    end
    tbLocationButtons = {}

    for i, loc in ipairs(locations) do
        local button = CreateFrame("Button", nil, tbScrollChild, "UIPanelButtonTemplate")
        button:SetSize(tbScrollChild:GetWidth() - 20, 30)
        button:SetText(loc)
        button:SetPoint("TOP", 0, -40 * (i - 1))
        button:SetScript("OnClick", function()
            SendChatMessage("t " .. loc, "SAY")
            AddToPreviousLocations(loc)
            tbFrame:Hide()
        end)
        table.insert(tbLocationButtons, button)
    end
end

-- Helper: Toggles one frame while hiding all others
local function ToggleExclusive(frameToToggle, ...)
    -- Pack the rest of the frames into a table
    local frames = { ... }
    
    for _, f in ipairs(frames) do
        if f == frameToToggle then
            -- Toggle the chosen frame
            if f:IsShown() then
                f:Hide()
            else
                f:Show()
            end
        else
            -- Always hide the other frames
            f:Hide()
        end
    end
end

local teleportButton = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
teleportButton:SetSize(50, 30)
teleportButton:SetText("T")
teleportButton:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", 20, 10)
teleportButton:SetScript("OnClick", function()
    ToggleExclusive(largeFrame, largeFrame, tfFrame, tbFrame)
end)

-------------------------------------------------
-- Teleport Friend Feature (Button)
-------------------------------------------------
-- (Your mainFrame, T button, TB button, etc. assumed to exist already)
local tfButton = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
tfButton:SetSize(50, 30)
tfButton:SetText("TF")
tfButton:SetPoint("LEFT", teleportButton, "RIGHT", 5, 0)
tfButton:SetScript("OnClick", function()
    -- Re-populate the friend list, then toggle
    PopulateFriendList("")
    ToggleExclusive(tfFrame, largeFrame, tfFrame, tbFrame)
end)

local tbButton = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
tbButton:SetSize(50, 30)
tbButton:SetText("TB")
tbButton:SetPoint("LEFT", tfButton, "RIGHT", 5, 0)
tbButton:SetScript("OnClick", function()
    PopulateTeleportBackList()
    ToggleExclusive(tbFrame, largeFrame, tfFrame, tbFrame)
end)

-- Keybinding Support
BINDING_HEADER_PLAYER_CONTROLS = "Player Controls"
BINDING_NAME_PLAYER_CONTROLS_SPEEDCYCLE = "Cycle Speed"

_G["BINDING_FUNCTION_PlayerControlsSpeedCycle"] = SpeedControl_Cycle

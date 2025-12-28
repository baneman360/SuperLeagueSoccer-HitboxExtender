-- Services
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Configuration
local CONFIG = {
    LARGE_SIZE = Vector3.new(50, 50, 50),
    DISABLED_SIZE = Vector3.new(0, 0, 0),
    UPDATE_INTERVAL = 0.3,
    
    UI = {
        POSITION = Vector2.new(20, 200),
        BUTTON_SIZE = Vector2.new(200, 40),
        TEXT_SIZE = 16,
        PADDING = 10,
        COLORS = {
            ENABLED = Color3.fromRGB(46, 204, 113),
            DISABLED = Color3.fromRGB(231, 76, 60),
            BACKGROUND = Color3.fromRGB(44, 62, 80),
            TEXT = Color3.fromRGB(255, 255, 255),
            OUTLINE = Color3.fromRGB(30, 30, 30)
        }
    }
}

-- State
local state = {
    enabled = true,
    lastUpdate = 0
}

-- UI Elements
local ui = {
    background = nil,
    toggleButton = nil,
    statusText = nil,
    titleText = nil
}

--[[
    FUNCTION: createUI
    DESCRIPTION: Initializes all UI drawing objects
    PARAMETERS: None
    RETURNS: None
]]
local function createUI()
    -- Background panel
    ui.background = Drawing.new("Square")
    ui.background.Size = Vector2.new(
        CONFIG.UI.BUTTON_SIZE.X + CONFIG.UI.PADDING * 2,
        CONFIG.UI.BUTTON_SIZE.Y * 2 + CONFIG.UI.PADDING * 3
    )
    ui.background.Position = CONFIG.UI.POSITION
    ui.background.Color = CONFIG.UI.COLORS.BACKGROUND
    ui.background.Filled = true
    ui.background.Visible = true
    ui.background.ZIndex = 1
    
    -- Title text
    ui.titleText = Drawing.new("Text")
    ui.titleText.Text = "HITBOX TOGGLE"
    ui.titleText.Size = CONFIG.UI.TEXT_SIZE
    ui.titleText.Position = Vector2.new(
        CONFIG.UI.POSITION.X + CONFIG.UI.PADDING,
        CONFIG.UI.POSITION.Y + CONFIG.UI.PADDING
    )
    ui.titleText.Color = CONFIG.UI.COLORS.TEXT
    ui.titleText.Visible = true
    ui.titleText.ZIndex = 2
    ui.titleText.Outline = true
    ui.titleText.OutlineColor = CONFIG.UI.COLORS.OUTLINE
    
    -- Toggle button
    ui.toggleButton = Drawing.new("Square")
    ui.toggleButton.Size = CONFIG.UI.BUTTON_SIZE
    ui.toggleButton.Position = Vector2.new(
        CONFIG.UI.POSITION.X + CONFIG.UI.PADDING,
        CONFIG.UI.POSITION.Y + CONFIG.UI.PADDING * 2 + 20
    )
    ui.toggleButton.Filled = true
    ui.toggleButton.Visible = true
    ui.toggleButton.ZIndex = 2
    
    -- Status text
    ui.statusText = Drawing.new("Text")
    ui.statusText.Size = CONFIG.UI.TEXT_SIZE
    ui.statusText.Position = Vector2.new(
        CONFIG.UI.POSITION.X + CONFIG.UI.PADDING + CONFIG.UI.BUTTON_SIZE.X / 2 - 40,
        CONFIG.UI.POSITION.Y + CONFIG.UI.PADDING * 2 + 30
    )
    ui.statusText.Color = CONFIG.UI.COLORS.TEXT
    ui.statusText.Visible = true
    ui.statusText.ZIndex = 3
    ui.statusText.Outline = true
    ui.statusText.OutlineColor = CONFIG.UI.COLORS.OUTLINE
end

--[[
    FUNCTION: updateUI
    DESCRIPTION: Updates UI elements to reflect current state
    PARAMETERS: None
    RETURNS: None
]]
local function updateUI()
    if state.enabled then
        ui.toggleButton.Color = CONFIG.UI.COLORS.ENABLED
        ui.statusText.Text = "ENABLED (50,50,50)"
    else
        ui.toggleButton.Color = CONFIG.UI.COLORS.DISABLED
        ui.statusText.Text = "DISABLED (0,0,0)"
    end
end

--[[
    FUNCTION: applyHitboxSize
    DESCRIPTION: Applies the current hitbox size to player's character
    PARAMETERS: None
    RETURNS: boolean - success status
]]
local function applyHitboxSize()
    local success, error = pcall(function()
        local player = Players.LocalPlayer
        if not player or not player.Character then
            return
        end
        
        local size = state.enabled and CONFIG.LARGE_SIZE or CONFIG.DISABLED_SIZE
        
        local hitbox = player.Character:FindFirstChild("Hitbox")
        if hitbox then
            hitbox.Size = size
        end
        
        local tackleHitbox = player.Character:FindFirstChild("TackleHitbox")
        if tackleHitbox then
            tackleHitbox.Size = size
        end
    end)
    
    if not success then
        warn("[HITBOX TOGGLE] Error applying hitbox size:", error)
    end
    
    return success
end

--[[
    FUNCTION: handleClick
    DESCRIPTION: Handles mouse click events on the toggle button
    PARAMETERS:
        - mousePos: Vector2 - Current mouse position
    RETURNS: None
]]
local function handleClick(mousePos)
    local buttonPos = ui.toggleButton.Position
    local buttonSize = ui.toggleButton.Size
    
    if mousePos.X >= buttonPos.X and mousePos.X <= buttonPos.X + buttonSize.X and
       mousePos.Y >= buttonPos.Y and mousePos.Y <= buttonPos.Y + buttonSize.Y then
        state.enabled = not state.enabled
        updateUI()
        applyHitboxSize()
    end
end

--[[
    MAIN INITIALIZATION
]]
print("[HITBOX TOGGLE] Initializing...")

-- Create UI
createUI()
updateUI()

-- Hitbox application loop
task.spawn(function()
    while true do
        local currentTime = tick()
        if currentTime - state.lastUpdate >= CONFIG.UPDATE_INTERVAL then
            applyHitboxSize()
            state.lastUpdate = currentTime
        end
        task.wait(CONFIG.UPDATE_INTERVAL)
    end
end)

-- Input handling
task.spawn(function()
    while true do
        if mouse1click then
            local mousePos = getmouseposition()
            handleClick(mousePos)
        end
        task.wait(0.1)
    end
end)

print("[HITBOX TOGGLE] Script loaded successfully!")
print("[HITBOX TOGGLE] Current state: " .. (state.enabled and "ENABLED" or "DISABLED"))

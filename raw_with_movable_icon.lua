-- [[ MM2 ALL-IN-ONE SCRIPT ]] --
-- Paste this into your executor (e.g., Synapse, Wave, Solara)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- UI Creation
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ToggleBtn = Instance.new("TextButton")
local StatusLabel = Instance.new("TextLabel")

ScreenGui.Name = "MM2_Helper"
ScreenGui.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 130)
MainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- MOVABLE OPEN / CLOSE ICON
local ToggleIcon = Instance.new("ImageButton")
ToggleIcon.Name = "OpenCloseIcon"
ToggleIcon.Size = UDim2.fromOffset(50,50)
ToggleIcon.Position = UDim2.new(0,15,0.5,-25)
ToggleIcon.BackgroundTransparency = 1
ToggleIcon.Image = "rbxassetid://72243650390596"
ToggleIcon.ZIndex = 100
ToggleIcon.Parent = ScreenGui

local menuOpen = MainFrame.Visible
ToggleIcon.Activated:Connect(function()
    menuOpen = not menuOpen
    MainFrame.Visible = menuOpen
end)

local UIS = game:GetService("UserInputService")
local dragging, dragStart, startPos, moved = false, nil, nil, false
ToggleIcon.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging, moved, dragStart, startPos = true, false, input.Position, ToggleIcon.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - dragStart
        if math.abs(d.X) > 5 or math.abs(d.Y) > 5 then moved = true end
        ToggleIcon.Position = UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
    end
end)
ToggleIcon.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)

Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.Text = "MM2 Helper Ultimate"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.Parent = MainFrame

ToggleBtn.Size = UDim2.new(0, 180, 0, 35)
ToggleBtn.Position = UDim2.new(0, 20, 0, 45)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ToggleBtn.Text = "Status: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 18
ToggleBtn.Parent = MainFrame

StatusLabel.Size = UDim2.new(1, 0, 0, 25)
StatusLabel.Position = UDim2.new(0, 0, 0, 95)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Role: Detecting..."
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextSize = 14
StatusLabel.Parent = MainFrame

-- Variables
local ScriptEnabled = false
local SafeHidingSpot = Vector3.new(0, 500, 0) -- Teleports you high in the sky out of bounds
local OriginalPosition = nil

-- Helper functions to identify roles based on inventory items
local function GetRole()
    if LocalPlayer.Backpack:FindFirstChild("Knife") or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Knife")) then
        return "Murderer"
    elseif LocalPlayer.Backpack:FindFirstChild("Gun") or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Gun")) then
        return "Sheriff"
    else
        return "Innocent"
    end
end

local function FindMurderer()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and (p.Backpack:FindFirstChild("Knife") or (p.Character and p.Character:FindFirstChild("Knife"))) then
            return p
        end
    end
    return nil
end

-- Main Loop Logic
RunService.Heartbeat:Connect(function()
    if not ScriptEnabled then return end
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local role = GetRole()
    StatusLabel.Text = "Current Role: " .. role

    if role == "Murderer" then
        -- AUTO KILL: Teleports directly to targets and swings knife
        local knife = LocalPlayer.Backpack:FindFirstChild("Knife") or character:FindFirstChild("Knife")
        if knife then
            if knife.Parent == LocalPlayer.Backpack then
                knife.Parent = character -- Equip knife automatically
            end
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid").Health > 0 then
                    -- Teleport behind player to kill them
                    character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1)
                    knife:Activate() -- Slash
                    task.wait(0.1)
                end
            end
        end

    elseif role == "Innocent" then
        -- AUTO HIDE: Safely teleports you away from danger areas
        if character.HumanoidRootPart.Position.Y < 400 then
            OriginalPosition = character.HumanoidRootPart.CFrame
            character.HumanoidRootPart.CFrame = CFrame.new(SafeHidingSpot)
        end

    elseif role == "Sheriff" then
        -- AUTO SHOOT MURDERER: Finds murderer and aims/shoots instantly
        local gun = LocalPlayer.Backpack:FindFirstChild("Gun") or character:FindFirstChild("Gun")
        local murderer = FindMurderer()
        
        if gun and murderer and murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart") then
            if gun.Parent == LocalPlayer.Backpack then
                gun.Parent = character -- Equip gun automatically
            end
            -- Turn to face the murderer and activate gun
            character.HumanoidRootPart.CFrame = CFrame.lookAt(character.HumanoidRootPart.Position, murderer.Character.HumanoidRootPart.Position)
            gun:Activate()
        end
    end
end)

-- Toggle Functionality
ToggleBtn.MouseButton1Click:Connect(function()
    ScriptEnabled = not ScriptEnabled
    if ScriptEnabled then
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
        ToggleBtn.Text = "Status: ON"
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        ToggleBtn.Text = "Status: OFF"
        StatusLabel.Text = "Role: Paused"
        -- Bring innocent back down if script turned off
        if OriginalPosition and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = OriginalPosition
        end
    end
end)
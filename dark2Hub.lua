local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "Dark2 Hub",
   Icon = 0, -- Bisa pakai asset id atau string icon
   LoadingTitle = "better anime character!?",
   LoadingSubtitle = "by RYXu",
   ShowText = "Rayfield",
   Theme = "Default",
   ToggleUIKeybind = "K",
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,
   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil,
      FileName = "testingHub"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = true,
   KeySettings = {
      Title = "dark2 Hub | Key",
      Subtitle = "Key System",
      Note = "https://link-hub.net/1392772/AfVHcFNYkLMx", -- cuma teks, boleh pakai link shortener
      FileName = "Dark2HubKey",
      SaveKey = false,
      GrabKeyFromSite = true, -- ubah ke false karena pakai key manual
      Key = {"AyamGoreng!"} -- isi key langsung disini
   }
})

-- Create Tabs
local mainTab = Window:CreateTab("home", nil)
local miscTab = Window:CreateTab("misc", nil)

-- Create Sections
local mainSection = mainTab:CreateSection("main")

Rayfield:Notify({
   Title = "Key valid loading the script...",
   Content = "Loading...",
   Duration = 4.9,
   Image = nil,
})

-- Infinite Coins Toggle (Persistent)
local coinToggle = mainTab:CreateToggle({
   Name = "Infinite Coins (Auto)",
   CurrentValue = false,
   Flag = "InfiniteCoinsToggle",
   Callback = function(Value)
       _G.infiniteCoinsEnabled = Value
       
       if Value then
           local Players = game:GetService("Players")
           local ReplicatedStorage = game:GetService("ReplicatedStorage")
           local RunService = game:GetService("RunService")
           local player = Players.LocalPlayer
           
           local targetCoinAmount = 999999999
           local lastKnownValue = 0
           
           local function findCoinValue()
               local paths = {
                   player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Coins"),
                   player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Money"),
                   player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Cash"),
                   player:FindFirstChild("Data") and player.Data:FindFirstChild("Coins"),
                   player:FindFirstChild("Stats") and player.Stats:FindFirstChild("Coins")
               }
               
               for _, path in pairs(paths) do
                   if path then return path end
               end
               return nil
           end
           
           local function fireRemoteEvents()
               for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
                   if obj:IsA("RemoteEvent") then
                       local name = obj.Name:lower()
                       if name:find("coin") or name:find("money") or name:find("cash") or name:find("currency") or name:find("buy") or name:find("purchase") then
                           pcall(function()
                               obj:FireServer(targetCoinAmount)
                               obj:FireServer("Coins", targetCoinAmount)
                               obj:FireServer({Coins = targetCoinAmount})
                               obj:FireServer("AddCoins", targetCoinAmount)
                           end)
                       end
                   end
               end
           end
           
           local function collectWorkspaceCoins()
               local collected = 0
               local character = player.Character
               if character and character:FindFirstChild("HumanoidRootPart") then
                   local originalPos = character.HumanoidRootPart.CFrame
                   
                   for _, obj in pairs(workspace:GetDescendants()) do
                       if obj.Name:lower():find("coin") and obj:IsA("BasePart") and obj.CanCollide == false then
                           pcall(function()
                               character.HumanoidRootPart.CFrame = obj.CFrame
                               wait(0.1)
                               if obj:FindFirstChild("ClickDetector") then
                                   fireclickdetector(obj.ClickDetector)
                               elseif obj:FindFirstChild("ProximityPrompt") then
                                   fireproximityprompt(obj.ProximityPrompt)
                               end
                               collected = collected + 1
                           end)
                       end
                       if collected >= 50 then break end -- Limit untuk performa
                   end
                   
                   character.HumanoidRootPart.CFrame = originalPos
                   return collected
               end
               return 0
           end
           
           -- Main coin monitoring loop
           _G.coinMonitorConnection = RunService.Heartbeat:Connect(function()
               if not _G.infiniteCoinsEnabled then return end
               
               local coinValue = findCoinValue()
               if coinValue then
                   local currentValue = coinValue.Value
                   
                   -- Check if coins dropped significantly (reset/match join)
                   if currentValue < lastKnownValue * 0.1 and lastKnownValue > 1000 then
                       -- Coins were reset, restore them
                       coinValue.Value = targetCoinAmount
                       fireRemoteEvents()
                       
                   elseif currentValue < targetCoinAmount * 0.5 then
                       -- Coins too low, boost them
                       coinValue.Value = targetCoinAmount
                       fireRemoteEvents()
                   end
                   
                   lastKnownValue = math.max(currentValue, lastKnownValue)
               else
                   -- Try alternative methods if direct value not found
                   fireRemoteEvents()
               end
           end)
           
           -- Initial coin boost
           local coinValue = findCoinValue()
           if coinValue then
               coinValue.Value = targetCoinAmount
               lastKnownValue = targetCoinAmount
           end
           
           -- Try remote events
           fireRemoteEvents()
           
           -- Try workspace collection
           spawn(function()
               local collected = collectWorkspaceCoins()
               if collected > 0 then
                   wait(2)
                   local newCoinValue = findCoinValue()
                   if newCoinValue and newCoinValue.Value < targetCoinAmount then
                       newCoinValue.Value = targetCoinAmount
                   end
               end
           end)
           
           -- Handle character respawning
           if player.Character then
               player.Character.AncestryChanged:Connect(function()
                   if _G.infiniteCoinsEnabled then
                       wait(3) -- Wait for respawn to complete
                       local coinValue = findCoinValue()
                       if coinValue and coinValue.Value < targetCoinAmount * 0.5 then
                           coinValue.Value = targetCoinAmount
                           fireRemoteEvents()
                       end
                   end
               end)
           end
           
           player.CharacterAdded:Connect(function()
               if _G.infiniteCoinsEnabled then
                   wait(3) -- Wait for character to fully load
                   local coinValue = findCoinValue()
                   if coinValue then
                       coinValue.Value = targetCoinAmount
                       fireRemoteEvents()
                   end
               end
           end)
           
           Rayfield:Notify({
               Title = "Infinite Coins Enabled!",
               Content = "Auto-maintaining coins at 999M",
               Duration = 4,
           })
           
       else
           -- Disable infinite coins
           if _G.coinMonitorConnection then
               _G.coinMonitorConnection:Disconnect()
               _G.coinMonitorConnection = nil
           end
           
           Rayfield:Notify({
               Title = "Infinite Coins Disabled",
               Content = "Coin monitoring stopped",
               Duration = 3,
           })
       end
   end,
})

-- Walkspeed Slider
local Slider = mainTab:CreateSlider({
    Name = "Walkspeed Slider",
    Range = {10, 300},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Flag = "Slider1",
    Callback = function(Value)
        local character = game.Players.LocalPlayer.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.WalkSpeed = Value
        end
    end,
})

-- Infinite Jump Button
local Button2 = mainTab:CreateButton({
    Name = "Infinite Jump",
    Callback = function()
        -- Toggle the infinite jump between on or off on every script run
        _G.infinjump = not _G.infinjump
        
        if _G.infinjump then
            -- Ensures this only runs once to save resources
            if _G.infinJumpStarted == nil then
                _G.infinJumpStarted = true
                
                -- Notifies readiness using Rayfield notification
                Rayfield:Notify({
                    Title = "Dark2 Hub", 
                    Content = "Infinite Jump Activated!", 
                    Duration = 3,
                    Image = nil,
                })
                
                -- The actual infinite jump using UserInputService (more reliable)
                local UserInputService = game:GetService("UserInputService")
                local Players = game:GetService("Players")
                local player = Players.LocalPlayer
                
                _G.jumpConnection = UserInputService.JumpRequest:Connect(function()
                    if _G.infinjump then
                        local character = player.Character
                        if character and character:FindFirstChildOfClass("Humanoid") then
                            local humanoid = character:FindFirstChildOfClass("Humanoid")
                            humanoid:ChangeState("Jumping")
                            wait()
                            humanoid:ChangeState("Seated")
                        end
                    end
                end)
            end
        else
            -- Disconnect when turned off
            if _G.jumpConnection then
                _G.jumpConnection:Disconnect()
                _G.infinJumpStarted = nil
            end
            
            Rayfield:Notify({
                Title = "Dark2 Hub", 
                Content = "Infinite Jump Deactivated!", 
                Duration = 3,
                Image = nil,
            })
        end
    end,
})

-- Fly Toggle (FIXED)
local FlyToggle = mainTab:CreateToggle({
    Name = "Fly (BUG DON'T USE)",
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = function(Value)
        _G.flyEnabled = Value
        
        local Players = game:GetService("Players")
        local UserInputService = game:GetService("UserInputService")
        local RunService = game:GetService("RunService")
        local player = Players.LocalPlayer
        
        if _G.flyEnabled then
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local hrp = character.HumanoidRootPart
                local humanoid = character:FindFirstChild("Humanoid")
                
                -- Create BodyVelocity for movement
                local bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
                bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                bodyVelocity.Parent = hrp
                
                -- Create BodyAngularVelocity for rotation control
                local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
                bodyAngularVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
                bodyAngularVelocity.AngularVelocity = Vector3.new(0, 0, 0)
                bodyAngularVelocity.Parent = hrp
                
                -- Fly variables
                local flySpeed = _G.flySpeed or 3 -- Use global fly speed or default to 3
                local camera = workspace.CurrentCamera
                
                -- Key tracking
                local keys = {
                    W = false,
                    A = false,
                    S = false,
                    D = false,
                    Space = false,
                    LeftShift = false
                }
                
                -- Input handling
                local function onKeyDown(key)
                    if keys[key.KeyCode.Name] ~= nil then
                        keys[key.KeyCode.Name] = true
                    end
                end
                
                local function onKeyUp(key)
                    if keys[key.KeyCode.Name] ~= nil then
                        keys[key.KeyCode.Name] = false
                    end
                end
                
                -- Connect input events
                _G.keyDownConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
                        onKeyDown(input)
                    end
                end)
                
                _G.keyUpConnection = UserInputService.InputEnded:Connect(function(input, gameProcessed)
                    if not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
                        onKeyUp(input)
                    end
                end)
                
                -- Fly loop
                _G.flyConnection = RunService.Heartbeat:Connect(function()
                    if _G.flyEnabled and hrp and hrp.Parent then
                        local velocity = Vector3.new(0, 0, 0)
                        local currentFlySpeed = _G.flySpeed or 3
                        
                        -- Get camera direction
                        local cameraCFrame = camera.CFrame
                        local lookDirection = cameraCFrame.LookVector
                        local rightDirection = cameraCFrame.RightVector
                        local upDirection = Vector3.new(0, 1, 0)
                        
                        -- Calculate movement based on keys
                        if keys.W then -- Forward
                            velocity = velocity + (lookDirection * currentFlySpeed)
                        end
                        if keys.S then -- Backward
                            velocity = velocity - (lookDirection * currentFlySpeed)
                        end
                        if keys.A then -- Left
                            velocity = velocity - (rightDirection * currentFlySpeed)
                        end
                        if keys.D then -- Right
                            velocity = velocity + (rightDirection * currentFlySpeed)
                        end
                        if keys.Space then -- Up
                            velocity = velocity + (upDirection * currentFlySpeed)
                        end
                        if keys.LeftShift then -- Down
                            velocity = velocity - (upDirection * currentFlySpeed)
                        end
                        
                        -- Apply velocity
                        bodyVelocity.Velocity = velocity * 16 -- Multiply for better movement
                        
                        -- Disable default character physics
                        if humanoid then
                            humanoid.PlatformStand = true
                        end
                    end
                end)
                
                -- Store references for cleanup
                _G.flyBodyVelocity = bodyVelocity
                _G.flyBodyAngularVelocity = bodyAngularVelocity
                _G.flyHumanoid = humanoid
                
                Rayfield:Notify({
                    Title = "Fly Enabled!",
                    Content = "WASD to move, Space/Shift for up/down",
                    Duration = 4,
                    Image = nil,
                })
                
            else
                Rayfield:Notify({
                    Title = "Error!",
                    Content = "Character not found",
                    Duration = 3,
                    Image = nil,
                })
            end
            
        else
            -- Disable fly
            if _G.flyConnection then
                _G.flyConnection:Disconnect()
                _G.flyConnection = nil
            end
            
            if _G.keyDownConnection then
                _G.keyDownConnection:Disconnect()
                _G.keyDownConnection = nil
            end
            
            if _G.keyUpConnection then
                _G.keyUpConnection:Disconnect()
                _G.keyUpConnection = nil
            end
            
            -- Clean up body movers
            if _G.flyBodyVelocity then
                _G.flyBodyVelocity:Destroy()
                _G.flyBodyVelocity = nil
            end
            
            if _G.flyBodyAngularVelocity then
                _G.flyBodyAngularVelocity:Destroy()
                _G.flyBodyAngularVelocity = nil
            end
            
            -- Re-enable normal physics
            if _G.flyHumanoid then
                _G.flyHumanoid.PlatformStand = false
                _G.flyHumanoid = nil
            end
            
            Rayfield:Notify({
                Title = "Fly Disabled!",
                Content = "Back to normal movement",
                Duration = 3,
                Image = nil,
            })
        end
    end,
})

-- Fly Speed Slider
local FlySlider = mainTab:CreateSlider({
    Name = "Fly Speed",
    Range = {1, 10},
    Increment = 0.5,
    Suffix = " Speed",
    CurrentValue = 3,
    Flag = "FlySpeedSlider",
    Callback = function(Value)
        _G.flySpeed = Value
        if _G.flyEnabled then
            Rayfield:Notify({
                Title = "Fly Speed Updated!",
                Content = "New speed: " .. Value,
                Duration = 2,
                Image = nil,
            })
        end
    end,
})

-- ESP Toggle (FIXED)
local ESPToggle = miscTab:CreateToggle({
   Name = "ESP (BETA)",
   CurrentValue = false,
   Flag = "ESPToggle",
   Callback = function(Value)
       if Value then
           -- Enable ESP
           _G.espEnabled = true
           
           local player = game.Players.LocalPlayer
           local mouse = player:GetMouse()
           
           -- Function to add ESP to character
           local function addESP(char)
               if char and not char:FindFirstChild("ESP_Highlight") then
                   local highlight = Instance.new("Highlight")
                   highlight.Name = "ESP_Highlight"
                   highlight.Parent = char
                   highlight.Adornee = char
                   highlight.FillColor = Color3.fromRGB(0, 255, 0) -- hijau
                   highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                   highlight.FillTransparency = 0.5
               end
           end
           
           -- Add ESP for existing players
           for _, plr in pairs(game.Players:GetPlayers()) do
               if plr ~= player and plr.Character then
                   addESP(plr.Character)
               end
               
               -- Handle when player spawns
               plr.CharacterAdded:Connect(function(char)
                   if plr ~= player and _G.espEnabled then
                       wait(1) -- Wait for character to fully load
                       addESP(char)
                   end
               end)
           end
           
           -- Handle new players joining
           game.Players.PlayerAdded:Connect(function(plr)
               if plr ~= player then
                   plr.CharacterAdded:Connect(function(char)
                       if _G.espEnabled then
                           wait(1) -- Wait for character to fully load
                           addESP(char)
                       end
                   end)
               end
           end)
           
           -- Click to teleport functionality
           _G.mouseConnection = mouse.Button1Down:Connect(function()
               if _G.espEnabled and mouse.Target and mouse.Target.Parent then
                   local targetPlayer = game.Players:GetPlayerFromCharacter(mouse.Target.Parent)
                   if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                       local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                       if hrp then
                           hrp.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                           
                           Rayfield:Notify({
                               Title = "Teleported!",
                               Content = "Teleported to " .. targetPlayer.Name,
                               Duration = 2,
                               Image = nil,
                           })
                       end
                   end
               end
           end)
           
           Rayfield:Notify({
               Title = "ESP Enabled!",
               Content = "Click on players to teleport",
               Duration = 3,
               Image = nil,
           })
           
       else
           -- Disable ESP
           _G.espEnabled = false
           
           -- Remove all ESP highlights
           for _, plr in pairs(game.Players:GetPlayers()) do
               if plr.Character and plr.Character:FindFirstChild("ESP_Highlight") then
                   plr.Character.ESP_Highlight:Destroy()
               end
           end
           
           -- Disconnect mouse connection
           if _G.mouseConnection then
               _G.mouseConnection:Disconnect()
               _G.mouseConnection = nil
           end
           
           Rayfield:Notify({
               Title = "ESP Disabled!",
               Content = "ESP and teleport disabled",
               Duration = 3,
               Image = nil,
           })
       end
   end,
})

-- Player Stats ESP Toggle
local statsToggle = miscTab:CreateToggle({
   Name = "Player Stats",
   CurrentValue = false,
   Flag = "PlayerStatsToggle",
   Callback = function(Value)
       local Players = game:GetService("Players")
       local RunService = game:GetService("RunService")
       local player = Players.LocalPlayer
       
       if Value then
           _G.playerStatsEnabled = true
           _G.statsGuis = {}
           _G.statsConnections = {}
           
           -- Fungsi cari coin value (flexible)
           local function findCoinValue(plr)
               local paths = {
                   plr:FindFirstChild("leaderstats") and plr.leaderstats:FindFirstChild("Coins"),
                   plr:FindFirstChild("leaderstats") and plr.leaderstats:FindFirstChild("Money"),
                   plr:FindFirstChild("leaderstats") and plr.leaderstats:FindFirstChild("Cash"),
                   plr:FindFirstChild("Stats") and plr.Stats:FindFirstChild("Coins"),
                   plr:FindFirstChild("Data") and plr.Data:FindFirstChild("Coins")
               }
               for _, v in pairs(paths) do
                   if v then return v end
               end
               return nil
           end
           
           -- Fungsi buat GUI
           local function createStatsGUI(targetPlayer)
               if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
               local hrp = targetPlayer.Character.HumanoidRootPart
               
               local billboardGui = Instance.new("BillboardGui")
               billboardGui.Name = "PlayerStats_" .. targetPlayer.Name
               billboardGui.Parent = hrp
               billboardGui.Size = UDim2.new(0, 200, 0, 100)
               billboardGui.StudsOffset = Vector3.new(0, 3, 0)
               billboardGui.AlwaysOnTop = true
               
               local frame = Instance.new("Frame", billboardGui)
               frame.Size = UDim2.new(1, 0, 1, 0)
               frame.BackgroundColor3 = Color3.new(0, 0, 0)
               frame.BackgroundTransparency = 0.3
               frame.BorderSizePixel = 0
               
               local nameLabel = Instance.new("TextLabel", frame)
               nameLabel.Size = UDim2.new(1, 0, 0.25, 0)
               nameLabel.BackgroundTransparency = 1
               nameLabel.Text = targetPlayer.Name
               nameLabel.TextColor3 = Color3.new(1, 1, 1)
               nameLabel.TextScaled = true
               
               local distanceLabel = Instance.new("TextLabel", frame)
               distanceLabel.Size = UDim2.new(1, 0, 0.25, 0)
               distanceLabel.Position = UDim2.new(0, 0, 0.25, 0)
               distanceLabel.BackgroundTransparency = 1
               distanceLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
               distanceLabel.TextScaled = true
               
               local healthLabel = Instance.new("TextLabel", frame)
               healthLabel.Size = UDim2.new(1, 0, 0.25, 0)
               healthLabel.Position = UDim2.new(0, 0, 0.5, 0)
               healthLabel.BackgroundTransparency = 1
               healthLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
               healthLabel.TextScaled = true
               
               local coinsLabel = Instance.new("TextLabel", frame)
               coinsLabel.Size = UDim2.new(1, 0, 0.25, 0)
               coinsLabel.Position = UDim2.new(0, 0, 0.75, 0)
               coinsLabel.BackgroundTransparency = 1
               coinsLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
               coinsLabel.TextScaled = true
               
               _G.statsGuis[targetPlayer.Name] = {
                   gui = billboardGui,
                   distanceLabel = distanceLabel,
                   healthLabel = healthLabel,
                   coinsLabel = coinsLabel,
                   player = targetPlayer
               }
           end
           
           -- Buat GUI untuk semua player
           for _, plr in pairs(Players:GetPlayers()) do
               if plr ~= player then
                   createStatsGUI(plr)
                   local con = plr.CharacterAdded:Connect(function()
                       task.wait(1)
                       if _G.playerStatsEnabled then
                           createStatsGUI(plr)
                       end
                   end)
                   table.insert(_G.statsConnections, con)
               end
           end
           
           -- Loop update
           _G.statsUpdateConnection = RunService.Heartbeat:Connect(function()
               if not _G.playerStatsEnabled then return end
               local playerHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
               if not playerHRP then return end
               
               for _, guiData in pairs(_G.statsGuis) do
                   local targetPlayer = guiData.player
                   if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                       local hrp = targetPlayer.Character.HumanoidRootPart
                       local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
                       
                       guiData.distanceLabel.Text = "Distance: " .. math.floor((playerHRP.Position - hrp.Position).Magnitude) .. " studs"
                       
                       if humanoid then
                           guiData.healthLabel.Text = "Health: " .. math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
                       end
                       
                       local coinVal = findCoinValue(targetPlayer)
                       if coinVal then
                           guiData.coinsLabel.Text = "Coins: " .. tostring(coinVal.Value)
                       else
                           guiData.coinsLabel.Text = "Coins: N/A"
                       end
                   end
               end
           end)
           
       else
           -- Matikan Player Stats
           _G.playerStatsEnabled = false
           if _G.statsUpdateConnection then
               _G.statsUpdateConnection:Disconnect()
               _G.statsUpdateConnection = nil
           end
           -- disconnect semua CharacterAdded
           if _G.statsConnections then
               for _, con in pairs(_G.statsConnections) do
                   con:Disconnect()
               end
               _G.statsConnections = {}
           end
           -- hapus semua GUI
           for _, guiData in pairs(_G.statsGuis) do
               if guiData.gui then
                   guiData.gui:Destroy()
               end
           end
           _G.statsGuis = {}
       end
   end,
})

local noclipToggle = miscTab:CreateToggle({
   Name = "Noclip",
   CurrentValue = false,
   Flag = "NoclipToggle",
   Callback = function(Value)
       _G.noclip = Value
       local RunService = game:GetService("RunService")
       local player = game.Players.LocalPlayer
       
       if _G.noclip and not _G.noclipConn then
           _G.noclipConn = RunService.Stepped:Connect(function()
               if player.Character then
                   for _, part in pairs(player.Character:GetDescendants()) do
                       if part:IsA("BasePart") then
                           part.CanCollide = false
                       end
                   end
               end
           end)
       else
           if _G.noclipConn then
               _G.noclipConn:Disconnect()
               _G.noclipConn = nil
           end
       end
   end,
})

-- Pastikan tab teleport cuma dibuat sekali aja
local TeleportTab = Window:CreateTab("Teleport", nil)

local Players = game:GetService("Players")
local lp = Players.LocalPlayer

-- Daftar lokasi teleport (urutan kanan → tengah → kiri sesuai revisi)
local locations = {
    Lobby = CFrame.new(8.9982748, 8.0, -1.58185959),      -- kanan
    Red   = CFrame.new(58.5368004, 13.5, 34.3241539),     -- tengah
    Blue  = CFrame.new(54.0298042, 13.5, -45.0270157),    -- kiri
}

-- Fungsi aman buat teleport
local function safeTP(cf)
    local char = lp.Character or lp.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    if hrp then
        hrp.CFrame = cf + Vector3.new(0, 2, 0) -- biar gak nyangkut lantai
        Rayfield:Notify({
            Title = "Teleport Success",
            Content = "Berhasil teleport!",
            Duration = 2
        })
    else
        Rayfield:Notify({
            Title = "Teleport Failed",
            Content = "HumanoidRootPart tidak ditemukan",
            Duration = 2
        })
    end
end

-- Variabel simpan pilihan dropdown
local selectedLocation = "Lobby"

-- Dropdown Menu
TeleportTab:CreateDropdown({
   Name = "Pilih Lokasi",
   Options = {"Lobby", "Red", "Blue"},
   CurrentOption = {"Lobby"},
   MultipleOptions = false,
   Flag = "TeleportDropdown",
   Callback = function(Options)
       selectedLocation = Options[1]
   end,
})

-- Button Teleport
TeleportTab:CreateButton({
   Name = "Teleport!",
   Callback = function()
       if locations[selectedLocation] then
           safeTP(locations[selectedLocation])
       else
           Rayfield:Notify({
               Title = "Error",
               Content = "Lokasi tidak valid!",
               Duration = 2
           })
       end
   end,
})

-- TAMBAHKAN CODE INI KE SCRIPT KAMU (SERVICES DAN VARIABLES)
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local placeId = game.PlaceId
local jobId = game.JobId

-- BUTTON SERVER HOP (PAKAI TEMPLATE KAMU)
local Button = miscTab:CreateButton({
   Name = "Server Hop",
   Callback = function()
       Rayfield:Notify({
           Title = "Server Hop",
           Content = "Mencari server lain...",
           Duration = 3,
       })
       
       -- HAPUS Method 1 yang langsung teleport (ini yang bikin rejoin)
       -- Langsung ke API method untuk dapetin server list
       
       local servers = {}
       local attempts = 0
       local maxAttempts = 5
       
       while attempts < maxAttempts and #servers == 0 do
           attempts = attempts + 1
           
           local success, result = pcall(function()
               local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Desc&limit=100"
               return HttpService:JSONDecode(game:HttpGet(url))
           end)
           
           if success and result and result.data then
               for _, server in pairs(result.data) do
                   -- PASTIKAN server bukan server sekarang DAN ada player
                   if server.id ~= jobId and server.playing < server.maxPlayers and server.playing >= 1 then
                       table.insert(servers, {id = server.id, playing = server.playing})
                   end
               end
           end
           
           if #servers == 0 then
               Rayfield:Notify({
                   Title = "Server Hop",
                   Content = "Attempt " .. attempts .. "/" .. maxAttempts .. " - Mencari server...",
                   Duration = 1,
               })
               wait(2)
           end
       end
       
       -- Teleport ke server yang PASTI berbeda
       if #servers > 0 then
           -- Sort servers by player count untuk pilih yang paling aktif
           table.sort(servers, function(a, b) return a.playing > b.playing end)
           
           local targetServer = servers[math.random(1, math.min(#servers, 10))] -- Pilih dari 10 server teratas
           
           Rayfield:Notify({
               Title = "Server Hop",
               Content = "Teleporting to server with " .. targetServer.playing .. " players...",
               Duration = 2,
           })
           
           local success2 = pcall(function()
               TeleportService:TeleportToPlaceInstance(placeId, targetServer.id, Players.LocalPlayer)
           end)
           
           if not success2 then
               -- Coba server lain kalau gagal
               if #servers > 1 then
                   local backupServer = servers[2]
                   TeleportService:TeleportToPlaceInstance(placeId, backupServer.id, Players.LocalPlayer)
               else
                   Rayfield:Notify({
                       Title = "Error",
                       Content = "Gagal teleport ke server lain",
                       Duration = 3,
                   })
               end
           end
       else
           Rayfield:Notify({
               Title = "Server Hop Failed",
               Content = "Tidak ada server lain yang tersedia",
               Duration = 3,
           })
       end
   end,
})

-- BUTTON REJOIN SERVER
local Button2 = miscTab:CreateButton({
   Name = "Rejoin Server",
   Callback = function()
       Rayfield:Notify({
           Title = "Rejoining",
           Content = "Rejoining server...",
           Duration = 2,
       })
       
       TeleportService:Teleport(placeId, Players.LocalPlayer)
   end,
})

-- BUTTON LOW PLAYER SERVER
local Button3 = miscTab:CreateButton({
   Name = "Low Player Server",
   Callback = function()
       Rayfield:Notify({
           Title = "Server Hop",
           Content = "Mencari server dengan player sedikit...",
           Duration = 3,
       })
       
       local servers = {}
       local success, result = pcall(function()
           local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
           return HttpService:JSONDecode(game:HttpGet(url))
       end)
       
       if success and result and result.data then
           for _, server in pairs(result.data) do
               if server.id ~= jobId and server.playing < server.maxPlayers and server.playing <= 5 then
                   table.insert(servers, {id = server.id, playing = server.playing})
               end
           end
           
           table.sort(servers, function(a, b) return a.playing < b.playing end)
           
           if #servers > 0 then
               TeleportService:TeleportToPlaceInstance(placeId, servers[1].id, Players.LocalPlayer)
           else
               TeleportService:Teleport(placeId, Players.LocalPlayer)
           end
       else
           TeleportService:Teleport(placeId, Players.LocalPlayer)
       end
   end,
})

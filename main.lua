--------------------------------------------------
-- RIVEN Premium Hub by TucoT9
-- Erweiterte Funktionalität für ein verbessertes Spielerlebnis
--------------------------------------------------

-- UI-Bibliothek laden
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/T9Tuco/riven/refs/heads/main/lib"))()

-- Hauptfenster erstellen mit angepassten Farben
local Window = OrionLib:MakeWindow({
    Name = "RIVEN by TucoT9",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "RIVENCheats",
    IntroEnabled = false,
    IntroText = "RIVEN Hub",
    IntroIcon = "rbxassetid://10618644218",
    Icon = "rbxassetid://10618644218",
    CloseCallback = function() print("RIVEN Hub geschlossen") end,
    -- Dunkelgraue Hintergrundfarbe
    Background = Color3.fromRGB(40, 40, 40),
    -- Cyan Akzentfarbe
    BorderColor3 = Color3.fromRGB(0, 255, 255)
})

--------------------------------------------------
-- Tabs erstellen
--------------------------------------------------
local AimbotTab    = Window:MakeTab({ Name = "Aimbot", Icon = "rbxassetid://4483345998" })
local CarModTab    = Window:MakeTab({ Name = "Fahrzeug-Mods", Icon = "rbxassetid://13773422471" })
local ESP_Tab      = Window:MakeTab({ Name = "ESP", Icon = "rbxassetid://4483345998" })
local MiscTab      = Window:MakeTab({ Name = "Sonstiges", Icon = "rbxassetid://4483345998" })
local MainTab      = Window:MakeTab({ Name = "Spieler", Icon = "rbxassetid://17132515723" })
local InfoTab      = Window:MakeTab({ Name = "Info", Icon = "rbxassetid://14219650242" })
local TrollTab     = Window:MakeTab({ Name = "Troll", Icon = "rbxassetid://4483362458" })
local ServerTab    = Window:MakeTab({ Name = "Server-Info", Icon = "rbxassetid://17132521951" })

--------------------------------------------------
-- Gemeinsame Services & Variablen
--------------------------------------------------
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService  = game:GetService("TeleportService")
local LocalPlayer      = Players.LocalPlayer
local cam              = workspace.CurrentCamera

--------------------------------------------------
-- [AIMBOT] - Funktionen
--------------------------------------------------
local aimbotEnabled = false
local aimPart = "HumanoidRootPart"
local teamCheck = true
local smoothness = 0.20

AimbotTab:AddToggle({
    Name = "Aimbot aktivieren",
    Default = false,
    Callback = function(Value)
        aimbotEnabled = Value
    end    
})

AimbotTab:AddBind({
    Name = "Aimbot Tastenbelegung",
    Default = Enum.KeyCode.V,
    Hold = false,
    Callback = function()
        aimbotEnabled = not aimbotEnabled
    end    
})

AimbotTab:AddDropdown({
    Name = "Zielteil",
    Default = "HumanoidRootPart",
    Options = {"Kopf", "HumanoidRootPart"},
    Callback = function(Value)
        aimPart = Value
    end    
})

AimbotTab:AddToggle({
    Name = "Team-Check",
    Default = true,
    Callback = function(Value)
        teamCheck = Value
    end    
})

AimbotTab:AddSlider({
    Name = "Aimbot-Stärke",
    Min = 0.1,
    Max = 1,
    Default = 0.25,
    Increment = 0.01,
    ValueName = "Smoothness",
    Callback = function(Value)
        smoothness = Value
    end    
})

local function getClosestTarget()
    local cam = workspace.CurrentCamera
    local closestPlayer = nil
    local closestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(aimPart) then
            if teamCheck and player.Team == LocalPlayer.Team then
                continue
            end

            local targetPos, onScreen = cam:WorldToScreenPoint(player.Character[aimPart].Position)
            if onScreen then
                local distance = (Vector2.new(targetPos.X, targetPos.Y) - Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end

    return closestPlayer
end

RunService.RenderStepped:Connect(function()
    if aimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getClosestTarget()
        if target and target.Character and target.Character:FindFirstChild(aimPart) then
            local targetPos = target.Character[aimPart].Position
            local currentLookAt = cam.CFrame.LookVector
            local targetLookAt = (targetPos - cam.CFrame.Position).Unit
            local newLookAt = currentLookAt:Lerp(targetLookAt, smoothness)
            cam.CFrame = CFrame.new(cam.CFrame.Position, cam.CFrame.Position + newLookAt)
        end
    end
end)

--------------------------------------------------
-- [FAHRZEUG-MODS] - Funktionen
--------------------------------------------------
local SpeedKey = Enum.KeyCode.LeftControl
local SpeedKeyMultiplier = 13
local FlightSpeed = 100
local FlightAcceleration = 11
local UserCharacter = nil
local UserRootPart = nil
local FlightConnection = nil
local Flying = false

local function setCharacter(character)
    UserCharacter = character
    UserRootPart = character:WaitForChild("HumanoidRootPart")
end
LocalPlayer.CharacterAdded:Connect(setCharacter)
if LocalPlayer.Character then setCharacter(LocalPlayer.Character) end

local CurrentVelocity = Vector3.new(0,0,0)
local function Flight(delta)
    local BaseVelocity = Vector3.new(0,0,0)
    if not UserInputService:GetFocusedTextBox() then
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            BaseVelocity = BaseVelocity + cam.CFrame.LookVector * FlightSpeed
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            BaseVelocity = BaseVelocity - cam.CFrame.LookVector * FlightSpeed
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            BaseVelocity = BaseVelocity - cam.CFrame.RightVector * FlightSpeed
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            BaseVelocity = BaseVelocity + cam.CFrame.RightVector * FlightSpeed
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            BaseVelocity = BaseVelocity + Vector3.new(0, FlightSpeed, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            BaseVelocity = BaseVelocity - Vector3.new(0, FlightSpeed, 0)
        end
        if UserInputService:IsKeyDown(SpeedKey) then
            BaseVelocity = BaseVelocity * SpeedKeyMultiplier
        end
    end
    if UserRootPart then
        local root = UserRootPart:GetRootPart()
        if root and not root.Anchored then
            CurrentVelocity = CurrentVelocity:Lerp(BaseVelocity, math.clamp(delta * FlightAcceleration, 0, 1))
            root.Velocity = CurrentVelocity + Vector3.new(0,2,0)
            root.CFrame = CFrame.lookAt(root.Position, root.Position + cam.CFrame.LookVector)
        end
    end
end

function ToggleFlight(enable)
    if enable then
        Flying = true
        FlightConnection = RunService.RenderStepped:Connect(Flight)
    else
        Flying = false
        if FlightConnection then
            FlightConnection:Disconnect()
            FlightConnection = nil
        end
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.X then
         ToggleFlight(not Flying)
    end
end)

CarModTab:AddLabel("Fahrzeug-Flug Tastenbelegung: X")
CarModTab:AddSlider({
    Name = "Fluggeschwindigkeit",
    Min = 20,
    Max = 190,
    Default = FlightSpeed,
    Increment = 1,
    ValueName = "Geschwindigkeit",
    Callback = function(Value)
        FlightSpeed = Value
    end
})

local function enterVehicle()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.SeatPart then
        humanoid.Sit = false
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end
CarModTab:AddButton({
    Name = "Fahrzeug betreten",
    Callback = function()
        enterVehicle()
    end
})

function serverHop()
    local placeId = game.PlaceId
    local serversApi = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then
        warn("PlayerGui nicht gefunden!")
        return
    end
    local screenGui = Instance.new("ScreenGui", playerGui)
    screenGui.Name = "ServerSuchText"
    local textLabel = Instance.new("TextLabel", screenGui)
    textLabel.Size = UDim2.new(0.4, 0, 0.05, 0)
    textLabel.Position = UDim2.new(0.3, 0, 0.9, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "Suche nach einem neuen Server... Erstellt von TucoT9 :D"
    textLabel.TextColor3 = Color3.new(1, 0, 0)
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextScaled = true
    spawn(function()
        while screenGui.Parent do
            for i = 0, 1, 0.01 do
                textLabel.TextColor3 = Color3.fromHSV(i, 1, 1)
                task.wait(0.05)
            end
        end
    end)
    task.delay(10, function()
        textLabel.Text = "Es tut uns leid, aber der Server-Wechsel ist fehlgeschlagen"
        task.wait(1)
        screenGui:Destroy()
    end)
    while true do
        local success, response = pcall(function()
            return game:HttpGet(serversApi)
        end)
        if success and response then
            local data = HttpService:JSONDecode(response)
            if data and data.data then
                for _, server in ipairs(data.data) do
                    if server.playing < server.maxPlayers and server.id ~= game.JobId then
                        print("Freier Server gefunden: " .. server.id)
                        screenGui:Destroy()
                        TeleportService:TeleportToPlaceInstance(placeId, server.id)
                        return
                    end
                end
            end
        end
        print("Kein Server gefunden. Suche erneut...")
        task.wait(5)
    end
end
MiscTab:AddButton({
    Name = "Server wechseln",
    Callback = function()
        serverHop()
    end
})

local function moveToPosition(Vehicle, destination, speed)
    if Vehicle and Vehicle.PrimaryPart then
        local diff = destination - Vehicle.PrimaryPart.Position
        local direction = diff.Unit
        Vehicle:SetPrimaryPartCFrame(Vehicle.PrimaryPart.CFrame:Lerp(CFrame.new(destination), 0.05))
    end
end
local running = false
local function autoFarm()
    local Character = LocalPlayer.Character
    if not Character then
        warn("Spieler-Charakter nicht gefunden!")
        return
    end
    local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
    if not Humanoid or not Humanoid.SeatPart or not Humanoid.SeatPart:IsA("VehicleSeat") then
        warn("Spieler sitzt nicht in einem Fahrzeug!")
        return
    end
    local SeatPart = Humanoid.SeatPart
    local Vehicle = SeatPart.Parent
    if not Vehicle or not Vehicle:IsA("Model") then
        warn("Kein Fahrzeugmodell gefunden!")
        return
    end
    if not Vehicle.PrimaryPart then
        Vehicle.PrimaryPart = Vehicle:FindFirstChildWhichIsA("BasePart")
    end
    if not Vehicle.PrimaryPart then
        warn("Fahrzeug hat kein PrimaryPart!")
        return
    end
    while running do
        for _, destination in ipairs({
            Vector3.new(-1681.19, 10.18, -1262.23),
            Vector3.new(-1698.44, 232.60, -1249.67),
            Vector3.new(-974.89, 333.79, -1518.37),
            Vector3.new(-966.96, 10.19, -1520.92),
            Vector3.new(-1016.46, 373.71, -1523.31),
            Vector3.new(449.28, 343.82, -1525.49),
            Vector3.new(455.47, 10.18, -1516.97),
            Vector3.new(514.28, 469.11, -1507.60),
            Vector3.new(-988.95, 299.10, -1556.77),
            Vector3.new(-997.54, 10.18, -1563.18),
            Vector3.new(-985.69, 392.95, -1553.51),
            Vector3.new(-1116.60, 533.45, -260.89),
            Vector3.new(-1100.83, 10.20, -234.67),
            Vector3.new(-1109.38, 524.85, -265.78),
            Vector3.new(-1451.84, 698.98, 823.48),
            Vector3.new(-1456.86, 10.18, 789.07),
            Vector3.new(-1408.65, 493.05, 786.56),
            Vector3.new(-1778.05, 605.96, 2729.24),
            Vector3.new(-1543.54,

 493.05, 786.56),
            Vector3.new(-1778.05, 605.96, 2729.24),
            Vector3.new(-1543.54, 530.30, 2736.57),
            Vector3.new(-1522.59, 10.16, 2732.81),
            Vector3.new(-1652.04, 575.36, 2730.64),
            Vector3.new(-883.61, 525.79, 2732.55),
            Vector3.new(-852.89, 10.16, 2734.87),
            Vector3.new(-874.54, 693.48, 2747.84),
            Vector3.new(-294.54, 762.64, 3596.54),
            Vector3.new(-330.82, 10.18, 3622.39),
            Vector3.new(-278.73, 397.32, 3618.05),
            Vector3.new(-858.61, 514.71, 2698.35),
            Vector3.new(-886.25, 10.16, 2693.42),
            Vector3.new(-859.37, 512.87, 2696.70),
            Vector3.new(-1537.10, 228.78, 2685.75),
            Vector3.new(-1555.95, 10.20, 2693.96),
            Vector3.new(-1539.72, 724.35, 2689.17),
            Vector3.new(-1439.12, 718.88, 826.53),
            Vector3.new(-1416.24, 10.21, 831.46),
            Vector3.new(-1448.49, 725.31, 829.72),
            Vector3.new(-1079.40, 702.66, -245.85),
            Vector3.new(-1076.40, 974.83, -243.18),
            Vector3.new(-1089.55, 10.17, -267.41)
        }) do
            if not running then break end
            print("Bewege zu:", destination)
            moveToPosition(Vehicle, destination, 120)
            wait(1)
        end
    end
    print("AutoFarm beendet.")
end
MiscTab:AddToggle({
    Name = "AutoFarm",
    Default = false,
    Callback = function(state)
        running = state
        if running then
            task.spawn(autoFarm)
        end
    end
})

local isRunning = false
local function antiFallOut()
    while isRunning do
        wait(0.1)
        enterVehicle()
    end
end

local function spawnTrain()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local trainsFolder = ReplicatedStorage:FindFirstChild("Trains")
    if trainsFolder then
        local trainModel = trainsFolder:FindFirstChild("HB IC")
        if trainModel and trainModel:IsA("Model") then
            local clonedTrain = trainModel:Clone()
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local hrp = character.HumanoidRootPart
                local spawnPosition = hrp.Position + hrp.CFrame.LookVector * 5
                local modelCFrame = clonedTrain:GetModelCFrame()
                local offset = spawnPosition - modelCFrame.Position
                for _, descendant in ipairs(clonedTrain:GetDescendants()) do
                    if descendant:IsA("BasePart") then
                        descendant.Position = descendant.Position + offset
                    end
                end
                clonedTrain.Parent = workspace
                print("Das Modell wurde erfolgreich vor dem Spieler gespawnt!")
            else
                warn("Charakter oder HumanoidRootPart nicht gefunden!")
            end
        else
            warn("HB IC wurde im Ordner 'Trains' nicht gefunden oder ist kein Modell!")
        end
    else
        warn("Der Ordner 'Trains' wurde im ReplicatedStorage nicht gefunden!")
    end
end
TrollTab:AddButton({
    Name = "HB IC (Zug) spawnen",
    Callback = spawnTrain
})

local function spawnTrain2()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local trainsFolder = ReplicatedStorage:FindFirstChild("Trains")
    if trainsFolder then
        local trainModel = trainsFolder:FindFirstChild("HB Regio")
        if trainModel and trainModel:IsA("Model") then
            local clonedTrain = trainModel:Clone()
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local hrp = character.HumanoidRootPart
                local spawnPosition = hrp.Position + hrp.CFrame.LookVector * 5
                local modelCFrame = clonedTrain:GetModelCFrame()
                local offset = spawnPosition - modelCFrame.Position
                for _, descendant in ipairs(clonedTrain:GetDescendants()) do
                    if descendant:IsA("BasePart") then
                        descendant.Position = descendant.Position + offset
                    end
                end
                clonedTrain.Parent = workspace
                print("Das Modell wurde erfolgreich vor dem Spieler gespawnt!")
            else
                warn("Charakter oder HumanoidRootPart nicht gefunden!")
            end
        else
            warn("HB Regio wurde im Ordner 'Trains' nicht gefunden oder ist kein Modell!")
        end
    else
        warn("Der Ordner 'Trains' wurde im ReplicatedStorage nicht gefunden!")
    end
end
TrollTab:AddButton({
    Name = "HB Regio (Zug) spawnen",
    Callback = spawnTrain2
})

local function spawnAdminCar()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local VehiclesFolder = ReplicatedStorage:FindFirstChild("Vehicles")
    if VehiclesFolder then
        local vehicleModel = VehiclesFolder:FindFirstChild("BMW M5 Admin")
        if vehicleModel and vehicleModel:IsA("Model") then
            local clonedVehicle = vehicleModel:Clone()
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local hrp = character.HumanoidRootPart
                local spawnPosition = hrp.Position + hrp.CFrame.LookVector * 5
                local modelCFrame = clonedVehicle:GetModelCFrame()
                local offset = spawnPosition - modelCFrame.Position
                for _, descendant in ipairs(clonedVehicle:GetDescendants()) do
                    if descendant:IsA("BasePart") then
                        descendant.Position = descendant.Position + offset
                    end
                end
                clonedVehicle.Parent = workspace
            end
        end
    end
end
TrollTab:AddButton({
    Name = "Admin-Auto spawnen",
    Callback = spawnAdminCar
})

function tpPlayer(targetPosition)
    local player = LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        local seat = Instance.new("Seat")
        seat.Size = Vector3.new(2,1,2)
        seat.Anchored = true
        seat.CanCollide = false
        seat.Transparency = 1
        seat.CFrame = CFrame.new(targetPosition)
        seat.Parent = workspace
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Sit = true
        end
        humanoidRootPart.CFrame = CFrame.new(targetPosition)
        task.delay(1, function()
            if seat and seat.Parent then seat:Destroy() end
        end)
    else
        warn("HumanoidRootPart nicht gefunden!")
    end
end

local function applyRainbowEffect()
    local player = LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local running = true
    local rainbowColors = {
        Color3.fromRGB(255, 0, 0),
        Color3.fromRGB(255, 165, 0),
        Color3.fromRGB(255, 255, 0),
        Color3.fromRGB(0, 255, 0),
        Color3.fromRGB(0, 0, 255),
        Color3.fromRGB(128, 0, 128),
        Color3.fromRGB(255, 20, 147)
    }
    local function isCarPart(part)
        local partName = part.Name:lower()
        return partName:find("wheel") or partName:find("chassis") or partName:find("body")
    end
    local carParts = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and isCarPart(obj) then
            table.insert(carParts, obj)
        end
    end
    local colorIndex = 1
    local nextColorIndex = 2
    local transitionStep = 0
    while running do
        for _, obj in ipairs(carParts) do
            if obj and obj.Parent then
                local distance = (obj.Position - character.HumanoidRootPart.Position).Magnitude
                if distance < 10 then
                    local currentColor = rainbowColors[colorIndex]
                    local nextColor = rainbowColors[nextColorIndex]
                    local interpolatedColor = currentColor:Lerp(nextColor, transitionStep)
                    obj.Color = interpolatedColor
                end
            end
        end
        transitionStep = transitionStep + 0.05
        if transitionStep >= 1 then
            transitionStep = 0
            colorIndex = nextColorIndex
            nextColorIndex = (nextColorIndex % #rainbowColors) + 1
        end
        task.wait(0.05)
    end
end
CarModTab:AddToggle({
    Name = "Regenbogen-Auto",
    Default = false,
    Callback = function(state)
        running = state
        if running then
            task.spawn(applyRainbowEffect)
        end
    end
})

local toggleActive = false
local function updateHealth()
    local vehiclesFolder = workspace:FindFirstChild("Vehicles")
    if vehiclesFolder then
        for _, vehicle in ipairs(vehiclesFolder:GetChildren()) do
            if vehicle:IsA("Model") then
                if toggleActive then
                    vehicle:SetAttribute("CurrentHealth", 0.99)
                end
            end
        end
    end
end
CarModTab:AddToggle({
    Name = "Unzerstörbares Auto",
    Default = false,
    Callback = function(value)
        toggleActive = value
        updateHealth()
    end
})
CarModTab:AddButton({
    Name = "Immer funktionierend",
    Callback = function() updateIsOn() end
})
local function updateIsOn()
    local vehiclesFolder = workspace:FindFirstChild("Vehicles")
    if vehiclesFolder then
        for _, vehicle in ipairs(vehiclesFolder:GetChildren()) do
            if vehicle:IsA("Model") then
                vehicle:SetAttribute("IsOn", true)
            end
        end
    end
end

--------------------------------------------------
-- [ESP] - Basis & erweiterte Funktionen
--------------------------------------------------
local espEnabled = false
local espBoxEnabled = false
local espNameEnabled = false
local espTracerEnabled = false
local espHealthEnabled = false

ESP_Tab:AddToggle({
    Name = "ESP aktivieren (Basis)",
    Default = false,
    Callback = function(Value) espEnabled = Value end
})
ESP_Tab:AddToggle({
    Name = "Box ESP",
    Default = false,
    Callback = function(Value) espBoxEnabled = Value end
})
ESP_Tab:AddToggle({
    Name = "Name/Distanz/Rolle ESP",
    Default = false,
    Callback = function(Value) espNameEnabled = Value end
})
ESP_Tab:AddToggle({
    Name = "Tracer ESP",
    Default = false,
    Callback = function(Value) espTracerEnabled = Value end
})
ESP_Tab:AddToggle({
    Name = "Gesundheits-ESP",
    Default = false,
    Callback = function(Value) espHealthEnabled = Value end
})

local espObjects = {}
local function CreateESP(player)
    if espObjects[player] then return end
    local esp = {}
    esp.BoxOutline = Drawing.new("Square")
    esp.BoxOutline.Thickness = 4
    esp.BoxOutline.Filled = false
    esp.BoxOutline.Color = Color3.new(0,0,0)
    esp.BoxOutline.Transparency = 1
    esp.BoxOutline.Visible = false

    esp.Box = Drawing.new("Square")
    esp.Box.Thickness = 2
    esp.Box.Filled = false
    esp.Box.Color = Color3.fromRGB(255,0,255)
    esp.Box.Transparency = 1
    esp.Box.Visible = false

    esp.Name = Drawing.new("Text")
    esp.Name.Size = 13
    esp.Name.Color = Color3.new(1,1,1)
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.Visible = false

    esp.Tracer = Drawing.new("Line")
    esp.Tracer.Color = Color3.fromRGB(255,0,255)
    esp.Tracer.Thickness = 1
    esp.Tracer.Visible = false

    esp.HealthBack = Drawing.new("Square")
    esp.HealthBack.Color = Color3.new(0,0,0)
    esp.HealthBack.Thickness = 1
    esp.HealthBack.Filled = true
    esp.HealthBack.Transparency = 0.5
    esp.HealthBack.Visible = false

    esp.HealthFill = Drawing.new("Square")
    esp.HealthFill.Color = Color3.new(0,1,0)
    esp.HealthFill.Thickness = 1
    esp.HealthFill.Filled = true
    esp.HealthFill.Transparency = 0.5
    esp.HealthFill.Visible = false

    espObjects[player] = esp
end

local function RemoveESP(player)
    if espObjects[player] then
        for _, obj in pairs(espObjects[player]) do
            obj:Remove()
        end
        espObjects[player] = nil
    end
end

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        if player.Character then CreateESP(player) end
        player.CharacterAdded:Connect(function() CreateESP(player) end)
    end
end
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function() CreateESP(player) end)
    end
end)
Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

RunService.RenderStepped:Connect(function()
    if not espEnabled then
        for _, esp in pairs(espObjects) do
            for _, obj in pairs(esp) do
                obj.Visible = false
            end
        end
        return
    end
    for player, esp in pairs(espObjects) do
        local char = player.Character
        if char then
            local head = char:FindFirstChild("Head")
            local root = char:FindFirstChild("HumanoidRootPart")
            local humanoid = char:FindFirstChild("Humanoid")
            if head and root and humanoid and humanoid.Health > 0 then
                local headPos, headVis = cam:WorldToViewportPoint(head.Position)
                local rootPos, rootVis = cam:WorldToViewportPoint(root.Position)
                if headVis and rootVis then
                    local boxHeight = math.abs(rootPos.Y - headPos.Y)
                    local boxWidth = boxHeight * 0.65
                    local boxX = rootPos.X - boxWidth/2
                    local boxY = headPos.Y
                    if espBoxEnabled then
                        esp.BoxOutline.Visible = true
                        esp.BoxOutline.Position = Vector2.new(boxX, boxY)
                        esp.BoxOutline.Size = Vector2.new(boxWidth, boxHeight)
                        esp.Box.Visible = true
                        esp.Box.Position = Vector2.new(boxX, boxY)
                        esp.Box.Size = Vector2.new(boxWidth, boxHeight)
                    else
                        esp.BoxOutline.Visible = false
                        esp.Box.Visible = false
                    end
                    if espNameEnabled then
                        local distance = (root.Position - cam.CFrame.Position).Magnitude
                        esp.Name.Visible = true
                        esp.Name.Text = string.format("%s\n[%.0f]", player.Name, distance)
                        esp.Name.Position = Vector2.new(headPos.X, headPos.Y - 35)
                    else
                        esp.Name.Visible = false
                    end
                    if espTracerEnabled then
                        esp.Tracer.Visible = true
                        esp.Tracer.From = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y - 5)
                        esp.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                    else
                        esp.Tracer.Visible = false
                    end
                    if espHealthEnabled then
                        esp.HealthBack.Visible = true
                        esp.HealthFill.Visible = true
                        local healthPercent = humanoid.Health / humanoid.MaxHealth
                        local barHeight = boxHeight
                        local barWidth = 4
                        local barX = boxX - (barWidth + 2)
                        local barY = boxY
                        esp.HealthBack.Position = Vector2.new(barX, barY)
                        esp.HealthBack.Size = Vector2.new(barWidth, barHeight)
                        local fillHeight = math.clamp(barHeight * healthPercent, 0, barHeight)
                        esp.HealthFill.Position = Vector2.new(barX, barY + (boxHeight - fillHeight))
                        esp.HealthFill.Size = Vector2.new(barWidth, fillHeight)
                    else
                        esp.HealthBack.Visible = false
                        esp.HealthFill.Visible = false
                    end
                else
                    for _, obj in pairs(esp) do obj.Visible = false end
                end
            else
                for _, obj in pairs(esp) do obj.Visible = false end
            end
        else
            for _, obj in pairs(esp) do obj.Visible = false end
        end
    end
end)

--------------------------------------------------
-- [SONSTIGES] - Diverse Funktionen
--------------------------------------------------
local toggleSpeedHack = false
MiscTab:AddToggle({
    Name = "SpeedHack",
    Default = false,
    Callback = function(Value)
        toggleSpeedHack = Value
    end    
})
MiscTab:AddBind({
    Name = "SpeedBind",
    Default = Enum.KeyCode.T,
    Hold = false,
    Callback = function()
        toggleSpeedHack = not toggleSpeedHack
    end
})
local stepSize = 0.25
RunService.Heartbeat:Connect(function()
    if toggleSpeedHack and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            local direction = humanoid.MoveDirection
            if direction.Magnitude > 0 then
                LocalPlayer.Character:SetPrimaryPartCFrame(LocalPlayer.Character.PrimaryPart.CFrame + direction.Unit * stepSize)
            end
        end
    end
end)

local Noclipping
local Clip = true
MiscTab:AddToggle({
    Name = "Noclip",
    Default = false,
    Callback = function(Value)
        if Value then
            Clip = false
            Noclipping = RunService.Stepped:Connect(function()
                if LocalPlayer.Character then
                    for _, child in pairs(LocalPlayer.Character:GetDescendants()) do
                        if child:IsA("BasePart") and child.CanCollide then
                            child.CanCollide = false
                        end
                    end
                end
            end)
        else
            if Noclipping then Noclipping:Disconnect() end
            Clip = true
        end
    end
})

MiscTab:AddButton({
    Name = "Fling",
    Callback = function()
        local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
        ScreenGui.ResetOnSpawn = false
        local Frame = Instance.new("Frame", ScreenGui)
        Frame.BackgroundColor3 = Color3.new(0,0,0)
        Frame.BorderColor3 = Color3.new(1,1,1)
        Frame.Position = UDim2.new(0.4,0,0.4,0)
        Frame.Size = UDim2.new(0,107,0,69)
        local TextButton = Instance.new("TextButton", Frame)
        TextButton.BackgroundColor3 = Color3.new(0,0,0)
        TextButton.BorderColor3 = Color3.new(1,1,1)
        TextButton.Position = UDim2.new(0.11,0,0.45,0)
        TextButton.Size = UDim2.new(0,83,0,31)
        TextButton.Font = Enum.Font.SourceSans
        TextButton.Text = "AUS"
        TextButton.TextColor3 = Color3.new(1,1,1)
        TextButton.TextSize = 20
        local CloseButton = Instance.new("TextButton", Frame)
        CloseButton.BackgroundColor3 = Color3.fromRGB(255,0,0)
        CloseButton.BorderColor3 = Color3.new(1,1,1)
        CloseButton.Position = UDim2.new(0.86,0,0.02,0)
        CloseButton.Size = UDim2.new(0,16,0,16)
        CloseButton.Font = Enum.Font.SourceSansBold
        CloseButton.Text = "X"
        CloseButton.TextColor3 = Color3.new(0,0,0)
        CloseButton.TextSize = 12
        TextButton.MouseButton1Click:Connect(function()
            if TextButton.Text == "AUS" then TextButton.Text = "AN" else TextButton.Text = "AUS" end
        end)
        CloseButton.MouseButton1Click:Connect(function() Frame:Destroy() end)
    end
})

MiscTab:AddButton({
    Name = "Unendliche Ausdauer",
    Callback = function()
        if not getfenv().firsttime then
            getfenv().firsttime = true
            local func
            for i, v in pairs(getgc(true)) do
                if type(v) == "function" and debug.getinfo(v).name == "setStamina" then
                    func = v
                    break
                end
            end
            if func then
                hookfunction(func, function(...)
                    local args = {...}
                    return args[1], math.huge
                end)
            end
        end
    end
})

MiscTab:AddToggle({
    Name = "Anti-Fall",
    Default = false,
    Callback = function(state)
        if state then
            getfenv().ANTIFALL = true
            getfenv().nofall = RunService.RenderStepped:Connect(function()
                if LocalPlayer.Character then
                    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local ray = workspace:Raycast(hrp.Position, Vector3.new(0,-20,0))
                        if ray and hrp.Velocity.Y < -30 then
                            hrp.Velocity = Vector3.new(0,0,0)
                        end
                    end
                end
            end)
        else
            getfenv().ANTIFALL = false
            if getfenv().nofall then getfenv().nofall:Disconnect() end
        end
    end
})

local antiDownedConnection
MiscTab:AddToggle({
    Name = "Anti-Niederschlag",
    Default = false,
    Callback = function(state)
        if LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:WaitForChild("Humanoid")
            if state then
                antiDownedConnection = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                    humanoid.Health = 100
                end)
            else
                if antiDownedConnection then
                    antiDownedConnection:Disconnect()
                    antiDownedConnection = nil
                end
            end
        end
    end
})

MiscTab:AddButton({
    Name = "Fahrzeug verlassen",
    Callback = function()
        enterVehicle()
    end
})

local xrayEnabled = false
MiscTab:AddToggle({
    Name = "Röntgenblick",
    Default = false,
    Callback = function(Value)
        xrayEnabled = Value
        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") and not part.Parent:FindFirstChildWhichIsA("Humanoid") then
                part.LocalTransparencyModifier = xrayEnabled and 0.5 or 0
            end
        end
    end
})

local clickToDeleteEnabled = false
local clickToDeleteConnection
local function toggleClickToDelete(enable)
    local mouse = LocalPlayer:GetMouse()
    if enable then
        clickToDeleteConnection = mouse.Button1Down:Connect(function()
            if mouse.Target then mouse.Target:Destroy() end
        end)
    elseif clickToDeleteConnection then
        clickToDeleteConnection:Disconnect()
        clickToDeleteConnection = nil
    end
end
MiscTab:AddToggle({
    Name = "Klicken zum Löschen",
    Default = false,
    Callback = function(Value)
        clickToDeleteEnabled = Value
        toggleClickToDelete(clickToDeleteEnabled)
    end
})

local infinityJumpEnabled = false
local function toggleInfinityJump(enable)
    if enable then
        UserInputService.JumpRequest:Connect(function()
            if infinityJumpEnabled and LocalPlayer.Character then
                local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    end
end
MiscTab:AddToggle({
    Name = "Unendlicher Sprung",
    Default = false,
    Callback = function(Value)
        infinityJumpEnabled = Value
        toggleInfinityJump(infinityJumpEnabled)
    end
})

local rainbowColorsChar = {
    Color3.fromRGB(255, 0, 0),
    Color3.fromRGB(255, 127, 0),
    Color3.fromRGB(255, 255, 0),
    Color3.fromRGB(0, 255, 0),
    Color3.fromRGB(0, 0, 255),
    Color3.fromRGB(75, 0, 130),
    Color3.fromRGB(148, 0, 211),
    Color3.fromRGB(255, 255, 255)
}
local currentColorIndex = 1
local changingColors = false
local function changeColor()
    if LocalPlayer.Character then
        local newColor = rainbowColorsChar[currentColorIndex]
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("MeshPart") then
                part.Color = newColor
            end
        end
        currentColorIndex = (currentColorIndex % #rainbowColorsChar) + 1
    else
        warn("Charakter nicht gefunden!")
    end
end
local function toggleColorChange(state)
    changingColors = state
    if changingColors then
        spawn(function()
            while changingColors do
                changeColor()
                task.wait(0.6)
            end
        end)
    end
end
MiscTab:AddToggle({
    Name = "Regenbogen-Charakter",
    Default = false,
    Callback = function(Value)
        toggleColorChange(Value)
    end
})

local isForceField = false
local function toggleMaterial(state)
    isForceField = state
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("MeshPart") then
                part.Material = isForceField and Enum.Material.ForceField or Enum.Material.Plastic
            end
        end
    end
end
MiscTab:AddToggle({
    Name = "Geisterkörper",
    Default = false,
    Callback = function(Value)
        toggleMaterial(Value)
    end
})

local antiFallDamageEnabled = false
local function toggleAntiFallDamage(enable)
    if enable then
        RunService.RenderStepped:Connect(function()
            if antiFallDamageEnabled and LocalPlayer.Character then
                local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp and hrp.Velocity.Y < -50 then
                    hrp.Velocity = Vector3.new(hrp.Velocity.X, -5, hrp.Velocity.Z)
                    hrp.CFrame = hrp.CFrame * CFrame.new(0, -0.1, 0)
                end
            end
        end)
    end
end
MiscTab:AddToggle({
    Name = "Anti-Fallschaden",
    Default = false,
    Callback = function(Value)
        antiFallDamageEnabled = Value
        toggleAntiFallDamage(antiFallDamageEnabled)
    end
})

--------------------------------------------------
-- [INFO] Tab
--------------------------------------------------
InfoTab:AddButton({
    Name = "Discord: RIVEN",
    Callback = function()
        local link = "https://discord.gg/nexusng"
        setclipboard(link)
        OrionLib:MakeNotification({
            Name = "Link kopiert!",
            Content = "Discord-Link wurde in die Zwischenablage kopiert.",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
    end
})

InfoTab:AddSection({ Name = "Benutzer-Feedback" })
local function SendMessageEMBED(url, embed)
    local headers = { ["Content-Type"] = "application/json" }
    local data = {
        ["embeds"] = {
            {
                ["title"] = embed.title,
                ["description"] = embed.description,
                ["color"] = embed.color,
                ["fields"] = embed.fields,
                ["footer"] = { ["text"] = embed.footer.text },
                ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }
        }
    }
    local body = HttpService:JSONEncode(data)
    local response = request({
        Url = url,
        Method = "POST",
        Headers = headers,
        Body = body
    })
    print("Embed an Discord gesendet.")
end
local webhookUrl = "https://ptb.discord.com/api/webhooks/1340776848312897638/xoN-OM26FRrndUvt_25sQbYqqPZ0PsrBdb70mUvH1S8wS16IWQNYMsP0Zrs-acC_VR4a"
local userRating = 0
local userComment = ""
local startTime = tick()
InfoTab:AddDropdown({
    Name = "Bewerte das Skript (1-5)",
    Default = "Auswählen",
    Options = {"1", "2", "3", "4", "5"},
    Callback = function(value)
        userRating = tonumber(value)
        print("Benutzer hat Bewertung ausgewählt:", userRating)
    end
})
InfoTab:AddTextbox({
    Name = "Hinterlasse einen Kommentar (optional)",
    Default = "",
    TextDisappear = false,
    Callback = function(value)
        userComment = value
        print("Benutzerkommentar:", userComment)
    end
})
InfoTab:AddButton({
    Name = "Bewertung abschicken",
    Callback = function()
        if userRating > 0 then
            local playTime = math.floor(tick() - startTime)
            local player = LocalPlayer
            local stars = string.rep("⭐", userRating)
            local embed = {
                title = "Skript-Bewertung erhalten!",
                description = "Ein Benutzer hat dein Skript bewertet.",
                color = 16766720,
                fields = {
                    { name = "Benutzername", value = player.Name, inline = true },
                    { name = "Benutzer-ID", value = tostring(player.UserId), inline = true },
                    { name = "Server-ID", value = game.JobId, inline = false },
                    { name = "Bewertung", value = tostring(userRating) .. " / 5 " .. stars, inline = true },
                    { name = "Spielzeit", value = tostring(playTime) .. " Sekunden", inline = true },
                    { name = "Kommentar", value = userComment ~= "" and userComment or "Kein Kommentar abgegeben.", inline = false },
                    { name = "Place-ID", value = tostring(game.PlaceId), inline = false }
                },
                footer = { text = "Bewertungssystem" }
            }
            SendMessageEMBED(webhookUrl, embed)
            OrionLib:MakeNotification({
                Name = "Vielen Dank!",
                Content = "Dein Feedback wurde übermittelt. Wir schätzen es sehr!",
                Image = "rbxassetid://4483345998",
                Time = 5
            })
        else
            OrionLib:MakeNotification({
                Name = "Fehler",
                Content = "Bitte wähle eine Bewertung aus, bevor du sie abschickst.",
                Image = "rbxassetid://4483345998",
                Time = 5
            })
        end
    end
})

--------------------------------------------------
-- [MainTab] - Client & Spieler Optionen
--------------------------------------------------
local MainSection = MainTab:AddSection({ Name = "Client" })
MainTab:AddToggle({
    Name = "Klicken zum Löschen",
    Default = false,
    Callback = function(Value)
        clickToDeleteEnabled = Value
        toggleClickToDelete(clickToDeleteEnabled)
    end
})
MainTab:AddToggle({
    Name = "Regenbogen-Charakter",
    Default = false,
    Callback = function(Value)
        toggleColorChange(Value)
    end
})
MainTab:AddToggle({
    Name = "Geisterkörper",
    Default = false,
    Callback = function(Value)
        toggleMaterial(Value)
    end
})
local PlayerSection = MainTab:AddSection({ Name = "Spieler" })
MainTab:AddToggle({
    Name = "Anti-Fallschaden",
    Default = false,
    Callback = function(Value)
        antiFallDamageEnabled = Value
        toggleAntiFallDamage(antiFallDamageEnabled)
    end
})
MainTab:AddToggle({
    Name = "Unendlicher Sprung",
    Default = false,
    Callback = function(Value)
        infinityJumpEnabled = Value
        toggleInfinityJump(infinityJumpEnabled)
    end
})

--------------------------------------------------
-- [TrollTab] - Weitere Funktionen (Züge, Admin-Auto)
--------------------------------------------------
TrollTab:AddSection({ Name = "Fahrzeuge" })
TrollTab:AddButton({ Name = "Admin-Auto spawnen", Callback = spawnAdminCar })

--------------------------------------------------
-- [ServerTab] - Team-Statistiken
--------------------------------------------------
local teamLabels = {}
local function createTeamLabels()
    for _, label in pairs(teamLabels) do label:Remove() end
    teamLabels = {}
    for _, team in pairs(game:GetService("Teams"):GetChildren()) do
        local count = #team:GetPlayers()
        local label = ServerTab:AddLabel(team.Name .. " - Spieler: " .. count)
        teamLabels[team.Name] = label
    end
end
local function updateTeamLabels()
    for teamName, label in pairs(teamLabels) do
        local team = game:GetService("Teams"):FindFirstChild(teamName)
        if team then
            local playerCount = #team:GetPlayers()
            label:Set(teamName .. " - Spieler: " .. playerCount)
        end
    end
end
createTeamLabels()
task.spawn(function() while task.wait(1) do updateTeamLabels() end end)

--------------------------------------------------
-- UI initialisieren
--------------------------------------------------
OrionLib:Init()

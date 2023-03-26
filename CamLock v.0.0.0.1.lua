if getgenv().script_key == "ayvWJBsuKdJNsCntrPReSHIROUrsaUQgsAVdKBTMbrZLEY" then

    getgenv().ShirouSettings = { 
        Customize = {
            Enabled = ShirouSettings.Customize.Enabled,
            Show_Fov = ShirouSettings.Customize.Show_Fov,
            KeyBind = ShirouSettings.Customize.KeyBind,
            Auto_prediction = ShirouSettings.Customize.Auto_prediction,
            UseShake = ShirouSettings.Customize.UseShake,
            ShakePower = ShirouSettings.Customize.ShakePower,
            Smoothness = ShirouSettings.Customize.Smoothness,
            Prediction = ShirouSettings.Customize.Prediction,
            NearestHitPart = ShirouSettings.Customize.NearestHitPart,
            AimPart = ShirouSettings.Customize.AimPart,
            JumpAimPart = ShirouSettings.Customize.JumpAimPart,
            Fov_Size = ShirouSettings.Customize.Fov_Size,
            HoldKey = false,
            ToggleKey = true,
            UseKeyBoardKey = true,
            UseMouseKey = false,
            ThirdPerson = true,
            FirstPerson = true,
            UseCircleRadius = true,
            DisableOutSideCircle = false,
            CheckForWalls = true,
        },
        Horizontal = {
            PredictMovement = true
        },
        Part = {
            CheckIfJumped = true
        },
        Check = {
            CheckIfKo = true,
            DisableOnTargetDeath = true,
            DisableOnPlayerDeath = true
        },
        Smooth = {
            EnabledSmoothness = true,
            SmoothMethod = Enum.EasingStyle.Circular,
            SmoothMethodV2 = Enum.EasingDirection.InOut      
        },
        Resolver = {
            UnderGround = true,
            UseUnderGroundKeybind = false,
            UnderGroundKey = Enum.KeyCode.K,
            DetectDesync = true,
            Detection = 86,
 
            UseDetectDesyncKeybind = false,
            DetectDesyncKey = Enum.KeyCode.L,
            SendNotification = false    
        },
        Visual = {
            FovTransparency = 1,
            FovThickness = 1,
            FovColor = Color3.fromRGB(0, 0, 0)   
        }
    }
    
    --// locals
    local Players, Uis, RService, Inset, CurrentCamera = 
    game:GetService("Players"), 
    game:GetService("UserInputService"), 
    game:GetService("RunService"),
    game:GetService("GuiService"):GetGuiInset().Y,
    game:GetService("Workspace").CurrentCamera
     
    local Client = Players.LocalPlayer;
     
    local Mouse, Camera = Client:GetMouse(), workspace.CurrentCamera
     
    local Circle = Drawing.new("Circle")
     
    local CF, RNew, Vec3, Vec2 = CFrame.new, Ray.new, Vector3.new, Vector2.new
     
    local OldAimPart = getgenv().ShirouSettings.Customize.AimPart
     
    local AimlockTarget, MousePressed, CanNotify = nil, false, false
     
    getgenv().UpdateFOV = function()
    if (not Circle) then
    return (Circle)
    end
    Circle.Color = ShirouSettings.Visual.FovColor
    Circle.Visible = ShirouSettings.Customize.Show_Fov
    Circle.Radius = ShirouSettings.Customize.Fov_Size
    Circle.Thickness = ShirouSettings.Visual.FovThickness
    Circle.Position = Vec2(Mouse.X, Mouse.Y + Inset)
    return (Circle)
    end
     
    RService.Heartbeat:Connect(UpdateFOV)
     
    -- // Functions
    
    --// Check if aimlock is loaded
    if getgenv().LoadShirou == true then
    game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Shirou";
    Text = "Shirous lock is already loaded.";
    Icon = "";
    Duration = 5
    })
    wait(1)
    game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Updated";
    Text = "If you made changes to your settings they have been applied";
    Icon = "";
    Duration = 5
    })
    return 
    end
    
    getgenv().LoadShirou = true
    
    --// Notification function
    game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Shirous lock loaded";
    Text = "shirou#0001";
    Icon = "";
    Duration = 5
    })
     
    getgenv().WallCheck = function(destination, ignore)
    local Origin = Camera.CFrame.p
    local CheckRay = RNew(Origin, destination - Origin)
    local Hit = game.workspace:FindPartOnRayWithIgnoreList(CheckRay, ignore)
    return Hit == nil
    end
     
    getgenv().WTS = function(Object)
    local ObjectVector = Camera:WorldToScreenPoint(Object.Position)
    return Vec2(ObjectVector.X, ObjectVector.Y)
    end
     
    getgenv().IsOnScreen = function(Object)
    local IsOnScreen = Camera:WorldToScreenPoint(Object.Position)
    return IsOnScreen
    end
     
    getgenv().FilterObjs = function(Object)
    if string.find(Object.Name, "Gun") then
    return
    end
    if table.find({"Part", "MeshPart", "BasePart"}, Object.ClassName) then
    return true
    end
    end
     
    getgenv().GetClosestBodyPart = function(character)
    local ClosestDistance = 1 / 0
    local BodyPart = nil
    if (character and character:GetChildren()) then
    for _, x in next, character:GetChildren() do
    if FilterObjs(x) and IsOnScreen(x) then
    local Distance = (WTS(x) - Vec2(Mouse.X, Mouse.Y)).Magnitude
    if (Circle.Radius > Distance and Distance < ClosestDistance) then
    ClosestDistance = Distance
    BodyPart = x
    end
    end
    end
    end
    return BodyPart
    end
     
    getgenv().WorldToViewportPoint = function(P)
    return Camera:WorldToViewportPoint(P)
    end
     
    getgenv().WorldToScreenPoint = function(P)
    return Camera.WorldToScreenPoint(Camera, P)
    end
     
    getgenv().GetObscuringObjects = function(T)
    if T and T:FindFirstChild(getgenv().ShirouSettings.Customize.AimPart) and Client and Client.Character:FindFirstChild("Head") then
    local RayPos =
    workspace:FindPartOnRay(RNew(T[getgenv().ShirouSettings.Customize.AimPart].Position, Client.Character.Head.Position))
    if RayPos then
    return RayPos:IsDescendantOf(T)
    end
    end
    end
     
    getgenv().GetNearestTarget = function()
    local AimlockTarget, Closest = nil, 1 / 0
     
    for _, v in pairs(game:GetService("Players"):GetPlayers()) do
    if (v.Character and v ~= Client and v.Character:FindFirstChild("HumanoidRootPart")) then
    local Position, OnScreen = Camera:WorldToScreenPoint(v.Character.HumanoidRootPart.Position)
    local Distance = (Vec2(Position.X, Position.Y) - Vec2(Mouse.X, Mouse.Y)).Magnitude
    if ShirouSettings.Customize.CheckForWalls then
    if
    (Circle.Radius > Distance and Distance < Closest and OnScreen and
    getgenv().WallCheck(v.Character.HumanoidRootPart.Position, {Client, v.Character}))
    then
    Closest = Distance
    AimlockTarget = v
    end
    elseif ShirouSettings.Customize.UseCircleRadius then
    if
    (Circle.Radius > Distance and Distance < Closest and OnScreen and
    getgenv().WallCheck(v.Character.HumanoidRootPart.Position, {Client, v.Character}))
    then
    Closest = Distance
    AimlockTarget = v
    end
    else
    if (Circle.Radius > Distance and Distance < Closest and OnScreen) then
    Closest = Distance
    AimlockTarget = v
    end
    end
    end
    end
    return AimlockTarget
    end
     
    -- // Use KeyBind Function
     
    Uis.InputBegan:connect(
    function(input)
    if
    input.KeyCode == ShirouSettings.Customize.KeyBind and ShirouSettings.Customize.UseKeyBoardKey == true and
    getgenv().ShirouSettings.Customize.Enabled == true and
    AimlockTarget == nil and
    getgenv().ShirouSettings.Customize.HoldKey == true
    then
    pcall(
    function()
    MousePressed = true
    AimlockTarget = GetNearestTarget()
    end
    )
    end
    end
    )Uis.InputEnded:connect(
    function(input)
    if
    input.KeyCode == ShirouSettings.Customize.KeyBind and getgenv().ShirouSettings.Customize.HoldKey == true and
    ShirouSettings.Customize.UseKeyBoardKey == true and
    getgenv().ShirouSettings.Customize.Enabled == true and
    AimlockTarget ~= nil
    then
    AimlockTarget = nil
    MousePressed = false
    end
    end
    )
     
    Uis.InputBegan:Connect(
    function(keyinput, stupid)
    if
    keyinput.KeyCode == ShirouSettings.Resolver.UnderGroundKey and getgenv().ShirouSettings.Customize.Enabled == true and
    ShirouSettings.Resolver.UseUnderGroundKeybind == true
    then
    if ShirouSettings.Resolver.UnderGround == true then
        ShirouSettings.Resolver.UnderGround = false
    if getgenv().ShirouSettings.Resolver.SendNotification then
    game.StarterGui:SetCore(
    "SendNotification",
    {
    Title = "Shirou",
    Text = "Disabled UnderGround Resolver",
    Icon = "rbxassetid://12624498811",
    Duration = 1
    }
    )
    end
    else
    ShirouSettings.Resolver.UnderGround = true
    if getgenv().ShirouSettings.Resolver.SendNotification then
    game.StarterGui:SetCore(
    "SendNotification",
    {
    Title = "Shirou",
    Text = "Enabled UnderGround Resolver",
    Icon = "rbxassetid://12624498811",
    Duration = 1
    }
    )
    end
    end
    end
    end
    )
     
    Uis.InputBegan:Connect(
    function(keyinput, stupid)
    if
    keyinput.KeyCode == ShirouSettings.Resolver.DetectDesyncKey and getgenv().ShirouSettings.Customize.Enabled == true and
    ShirouSettings.Resolver.UseDetectDesyncKeybind == true
    then
    if ShirouSettings.Resolver.DetectDesync == true then
    ShirouSettings.Resolver.DetectDesync = false
    if getgenv().ShirouSettings.Resolver.SendNotification then
    game.StarterGui:SetCore(
    "SendNotification",
    {
    Title = "Shirou",
    Text = "Disabled Desync Resolver",
    Icon = "rbxassetid://12624498811",
    Duration = 1
    }
    )
    end
    else
    ShirouSettings.Resolver.DetectDesync = true
    if getgenv().ShirouSettings.Resolver.SendNotification then
    game.StarterGui:SetCore(
    "SendNotification",
    {
    Title = "Shirou",
    Text = "Enabled Desync Resolver",
    Icon = "rbxassetid://12624498811",
    Duration = 1
    }
    )
    end
    end
    end
    end
    )
     
    Uis.InputBegan:Connect(
    function(keyinput, stupid)
    if
    keyinput.KeyCode == ShirouSettings.Customize.KeyBind and ShirouSettings.Customize.UseKeyBoardKey == true and
    getgenv().ShirouSettings.Customize.Enabled == true and
    AimlockTarget == nil and
    getgenv().ShirouSettings.Customize.ToggleKey == true
    then
    pcall(
    function()
    MousePressed = true
    AimlockTarget = GetNearestTarget()
    end
    )
    elseif
    keyinput.KeyCode == ShirouSettings.Customize.KeyBind and ShirouSettings.Customize.UseKeyBoardKey == true and
    getgenv().ShirouSettings.Customize.Enabled == true and
    AimlockTarget ~= nil
    then
    AimlockTarget = nil
    MousePressed = false
    end
    end
    )
     
    -- // Use MouseKey Function
     
    Uis.InputBegan:connect(
    function(input)
    if
    input.UserInputType == ShirouSettings.Customize.MouseKey and ShirouSettings.Customize.UseMouseKey == true and
    getgenv().ShirouSettings.Customize.Enabled == true and
    AimlockTarget == nil and
    getgenv().ShirouSettings.Customize.HoldKey == true
    then
    pcall(
    function()
    MousePressed = true
    AimlockTarget = GetNearestTarget()
    end
    )
    end
    end
    )Uis.InputEnded:connect(
    function(input)
    if
    input.UserInputType == ShirouSettings.Customize.MouseKey and getgenv().ShirouSettings.Customize.HoldKey == true and
    ShirouSettings.Customize.UseMouseKey == true and
    getgenv().ShirouSettings.Customize.Enabled == true and
    AimlockTarget ~= nil
    then
    AimlockTarget = nil
    MousePressed = false
    end
    end
    )
     
    Uis.InputBegan:Connect(
    function(keyinput, stupid)
    if
    keyinput.UserInputType == ShirouSettings.Customize.MouseKey and ShirouSettings.Customize.UseMouseKey == true and
    getgenv().ShirouSettings.Customize.Enabled == true and
    AimlockTarget == nil and
    getgenv().ShirouSettings.Customize.ToggleKey == true
    then
    pcall(
    function()
    MousePressed = true
    AimlockTarget = GetNearestTarget()
    end
    )
    elseif
    keyinput.UserInputType == ShirouSettings.Customize.MouseKey and ShirouSettings.Customize.UseMouseKey == true and
    getgenv().ShirouSettings.Customize.Enabled == true and
    AimlockTarget ~= nil
    then
    AimlockTarget = nil
    MousePressed = false
    end
    end
    )
     
    -- // Main Functions. RunService HeartBeat.
     
    task.spawn(
    function()
    while task.wait() do
    if MousePressed == true and getgenv().ShirouSettings.Customize.Enabled == true then
    if AimlockTarget and AimlockTarget.Character then
    if getgenv().ShirouSettings.Customize.NearestHitPart == true then
    getgenv().ShirouSettings.Customize.AimPart = tostring(GetClosestBodyPart(AimlockTarget.Character))
    end
    end
    if getgenv().ShirouSettings.Customize.DisableOutSideCircle == true and AimlockTarget and AimlockTarget.Character then
    if
    Circle.Radius <
    (Vec2(
    Camera:WorldToScreenPoint(AimlockTarget.Character.HumanoidRootPart.Position).X,
    Camera:WorldToScreenPoint(AimlockTarget.Character.HumanoidRootPart.Position).Y
    ) - Vec2(Mouse.X, Mouse.Y)).Magnitude
    then
    AimlockTarget = nil
    end
    end
    end
    end
    end
    )
     
    RService.Heartbeat:Connect(
    function()
    if getgenv().ShirouSettings.Customize.Enabled == true and MousePressed == true then
    if getgenv().ShirouSettings.Customize.UseShake == true and AimlockTarget and AimlockTarget.Character then
    pcall(
    function()
    local TargetVelv1 = AimlockTarget.Character[getgenv().ShirouSettings.Customize.AimPart]
    TargetVelv1.Velocity =
    Vec3(TargetVelv1.Velocity.X, TargetVelv1.Velocity.Y, TargetVelv1.Velocity.Z) +
    Vec3(
    math.random(-getgenv().ShirouSettings.Customize.ShakePower, getgenv().ShirouSettings.Customize.ShakePower),
    math.random(-getgenv().ShirouSettings.Customize.ShakePower, getgenv().ShirouSettings.Customize.ShakePower),
    math.random(-getgenv().ShirouSettings.Customize.ShakePower, getgenv().ShirouSettings.Customize.ShakePower)
    ) *
    0.1
    TargetVelv1.AssemblyLinearVelocity =
    Vec3(TargetVelv1.Velocity.X, TargetVelv1.Velocity.Y, TargetVelv1.Velocity.Z) +
    Vec3(
    math.random(-getgenv().ShirouSettings.Customize.ShakePower, getgenv().ShirouSettings.Customize.ShakePower),
    math.random(-getgenv().ShirouSettings.Customize.ShakePower, getgenv().ShirouSettings.Customize.ShakePower),
    math.random(-getgenv().ShirouSettings.Customize.ShakePower, getgenv().ShirouSettings.Customize.ShakePower)
    ) *
    0.1
    end
    )
    end
    if getgenv().ShirouSettings.Resolver.UnderGround == true and AimlockTarget and AimlockTarget.Character then
    pcall(
    function()
    local TargetVelv2 = AimlockTarget.Character[getgenv().ShirouSettings.Customize.AimPart]
    TargetVelv2.Velocity = Vec3(TargetVelv2.Velocity.X, 0, TargetVelv2.Velocity.Z)
    TargetVelv2.AssemblyLinearVelocity = Vec3(TargetVelv2.Velocity.X, 0, TargetVelv2.Velocity.Z)
    end
    )
    end
    if
    getgenv().ShirouSettings.Resolver.DetectDesync == true and AimlockTarget and AimlockTarget.Character and
    AimlockTarget.Character:WaitForChild("HumanoidRootPart").Velocity.magnitude >
    getgenv().ShirouSettings.Resolver.Detection
    then
    pcall(
    function()
    local TargetVel = AimlockTarget.Character[getgenv().ShirouSettings.Customize.AimPart]
    TargetVel.Velocity = Vec3(0, 0, 0)
    TargetVel.AssemblyLinearVelocity = Vec3(0, 0, 0)
    end
    )
    end
    if getgenv().ShirouSettings.Customize.ThirdPerson == true and getgenv().ShirouSettings.Customize.FirstPerson == true then
    if
    (Camera.Focus.p - Camera.CoordinateFrame.p).Magnitude > 1 or
    (Camera.Focus.p - Camera.CoordinateFrame.p).Magnitude <= 1
    then
    CanNotify = true
    else
    CanNotify = false
    end
    elseif getgenv().ShirouSettings.Customize.ThirdPerson == true and getgenv().ShirouSettings.Customize.FirstPerson == false then
    if (Camera.Focus.p - Camera.CoordinateFrame.p).Magnitude > 1 then
    CanNotify = true
    else
    CanNotify = false
    end
    elseif getgenv().ShirouSettings.Customize.ThirdPerson == false and getgenv().ShirouSettings.Customize.FirstPerson == true then
    if (Camera.Focus.p - Camera.CoordinateFrame.p).Magnitude <= 1 then
    CanNotify = true
    else
    CanNotify = false
    end
    end
    if getgenv().ShirouSettings.Customize.Auto_prediction == true and getgenv().ShirouSettings.Customize.Prediction then
    local pingvalue = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
    local split = string.split(pingvalue, "(")
    local ping = tonumber(split[1])
    if ping > 190 then
    getgenv().ShirouSettings.Customize.Prediction = 0.206547
    elseif ping > 180 then
    getgenv().ShirouSettings.Customize.Prediction = 0.19284
    elseif ping > 170 then
    getgenv().ShirouSettings.Customize.Prediction = 0.1923111
    elseif ping > 160 then
    getgenv().ShirouSettings.Customize.Prediction = 0.1823111
    elseif ping > 150 then
    getgenv().ShirouSettings.Customize.Prediction = 0.171
    elseif ping > 140 then
    getgenv().ShirouSettings.Customize.Prediction = 0.165773
    elseif ping > 130 then
    getgenv().ShirouSettings.Customize.Prediction = 0.1223333
    elseif ping > 120 then
    getgenv().ShirouSettings.Customize.Prediction = 0.143765
    elseif ping > 110 then
    getgenv().ShirouSettings.Customize.Prediction = 0.1455
    elseif ping > 100 then
    getgenv().ShirouSettings.Customize.Prediction = 0.130340
    elseif ping > 90 then
    getgenv().ShirouSettings.Customize.Prediction = 0.136
    elseif ping > 80 then
    getgenv().ShirouSettings.Customize.Prediction = 0.1347
    elseif ping > 70 then
    getgenv().ShirouSettings.Customize.Prediction = 0.119
    elseif ping > 60 then
    getgenv().ShirouSettings.Customize.Prediction = 0.12731
    elseif ping > 50 then
    getgenv().ShirouSettings.Customize.Prediction = 0.127668
    elseif ping > 40 then
    getgenv().ShirouSettings.Customize.Prediction = 0.125
    elseif ping > 30 then
    getgenv().ShirouSettings.Customize.Prediction = 0.11
    elseif ping > 20 then
    getgenv().ShirouSettings.Customize.Prediction = 0.12588
    elseif ping > 10 then
    getgenv().ShirouSettings.Customize.Prediction = 0.9
    end
    end
    if getgenv().ShirouSettings.Check.CheckIfKo == true and AimlockTarget and AimlockTarget.Character then
    local KOd = AimlockTarget.Character:WaitForChild("BodyEffects")["K.O"].Value
    local Grabbed = AimlockTarget.Character:FindFirstChild("GRABBING_CONSTRAINT") ~= nil
    if AimlockTarget.Character.Humanoid.health < 1 or KOd or Grabbed then
    if MousePressed == true then
    AimlockTarget = nil
    MousePressed = false
    end
    end
    end
    if
    getgenv().ShirouSettings.Check.DisableOnTargetDeath == true and AimlockTarget and
    AimlockTarget.Character:FindFirstChild("Humanoid")
    then
    if AimlockTarget.Character.Humanoid.health < 1 then
    if MousePressed == true then
    AimlockTarget = nil
    MousePressed = false
    end
    end
    end
    if
    getgenv().ShirouSettings.Check.DisableOnPlayerDeath == true and Client.Character and
    Client.Character:FindFirstChild("Humanoid") and
    Client.Character.Humanoid.health < 1
    then
    if MousePressed == true then
    AimlockTarget = nil
    MousePressed = false
    end
    end
    if getgenv().ShirouSettings.Part.CheckIfJumped == true and getgenv().ShirouSettings.Customize.NearestHitPart == false then
    if AimlockTarget and AimlockTarget.Character then
    if AimlockTarget.Character.Humanoid.FloorMaterial == Enum.Material.Air then
    getgenv().ShirouSettings.Customize.AimPart = getgenv().ShirouSettings.Customize.JumpAimPart
    else
    getgenv().ShirouSettings.Customize.AimPart = OldAimPart
    end
    end
    end
    if
    AimlockTarget and AimlockTarget.Character and
    AimlockTarget.Character:FindFirstChild(getgenv().ShirouSettings.Customize.AimPart)
    then
    if getgenv().ShirouSettings.Customize.FirstPerson == true then
    if CanNotify == true then
    if getgenv().ShirouSettings.Horizontal.PredictMovement == true then
    if getgenv().ShirouSettings.Smooth.EnabledSmoothness == true then
    local Main =
    CF(
    Camera.CFrame.p,
    AimlockTarget.Character[getgenv().ShirouSettings.Customize.AimPart].Position +
    AimlockTarget.Character[getgenv().ShirouSettings.Customize.AimPart].Velocity *
    getgenv().ShirouSettings.Customize.Prediction
    )
     
    Camera.CFrame =
    Camera.CFrame:Lerp(
    Main,
    getgenv().ShirouSettings.Customize.Smoothness,
    Enum.EasingStyle.Elastic,
    Enum.EasingDirection.InOut
    )
    else
    Camera.CFrame =
    CF(
    Camera.CFrame.p,
    AimlockTarget.Character[getgenv().ShirouSettings.Customize.AimPart].Position +
    AimlockTarget.Character[getgenv().ShirouSettings.Customize.AimPart].Velocity *
    getgenv().ShirouSettings.Customize.Prediction + Vector3
    )
    end
    elseif getgenv().ShirouSettings.Horizontal.PredictMovement == false then
    if getgenv().ShirouSettings.Smooth.EnabledSmoothness == true then
    local Main =
    CF(
    Camera.CFrame.p,
    AimlockTarget.Character[getgenv().ShirouSettings.Customize.AimPart].Position
    )
    Camera.CFrame =
    Camera.CFrame:Lerp(
    Main,
    getgenv().ShirouSettings.Customize.Smoothness,
    getgenv().ShirouSettings.Smooth.SmoothMethod,
    getgenv().ShirouSettings.Smooth.SmoothMethodV2
    )
    else
    Camera.CFrame =
    CF(
    Camera.CFrame.p,
    AimlockTarget.Character[getgenv().ShirouSettings.Customize.AimPart].Position
    )
    end
    end
    end
    end
    end
    end
    end
    )
    end

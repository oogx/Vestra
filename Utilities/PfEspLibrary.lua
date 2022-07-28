---------------------------------------------
--             VERSION 1.1.8               --
---------------------------------------------

local LocalPlayer = game.Players.LocalPlayer
local players = game.Players
local rs = game:GetService("RunService")
local Camera = workspace.CurrentCamera
-- Phantom Forces sucks i wanna kms

local utility = {}

animations = {}

-- Framework
getgenv().client = {};
do
    local gc = getgc(true)
    for i = #gc, 1, -1 do
        local v = gc[i]
        local type = type(v)
        if type == 'function' then
            if debug.getinfo(v).name == "loadmodules" then
                client.loadmodules = v
            end
            local name = getinfo(v).name 
            if name == "bulletcheck" then
				bulletCheck = v
			elseif name == "trajectory" then
				trajectory = v
			end
        end
        if type == "table" then
            if (rawget(v, 'send')) then
                network = v
                client.network = v
            elseif (rawget(v, 'basecframe')) then
                client.camera = v
            elseif (rawget(v, "gammo")) then
                client.gamelogic = v
            elseif (rawget(v, "getbodyparts")) then
                plrList = getupvalue(v.getbodyparts,1)
                client.replication = v
                client.replication.bodyparts = debug.getupvalue(client.replication.getbodyparts, 1)
            elseif (rawget(v, "updateammo")) then
                client.hud = v
            elseif (rawget(v, "setbasewalkspeed")) then
                client.char = v
            elseif (rawget(v, "getscale")) then
                client.uiscaler = v
            elseif (rawget(v, "isplayeralive")) then
                HUD = v
            elseif (rawget(v, "updateammo")) then
                client.hud = v    
            elseif (rawget(v, "play")) then
                client.sound = v
            end
        end
    end
end


function utility:IsAlive(player)
    if client.replication.bodyparts[player] and client.replication.bodyparts[player].head then
        return true
    end
    return false
end

function utility:GetHealth(Player)
    return client.hud:getplayerhealth(Player)
end

function utility:GetCharacter(Player)
    local Character = client.replication.getbodyparts(Player)

    return Character and Character.torso.Parent, Character and Character.torso
end

function utility:GetBodypart(Player, Part)
    local success, result = pcall(function()
        return client.replication.bodyparts[Player][Part:lower()]
    end)
    if success then
        return result
    else
        return nil
    end
end

function utility:getposlist2(list)
    local top = math.huge
    local bottom = -math.huge
    local right = -math.huge
    local left = math.huge

    for i, v in pairs(list) do
        top = (top > v.Y) and v.Y or top
        bottom = (bottom < v.Y) and v.Y or bottom
        left = (left > v.X) and v.X or left
        right = (right < v.X) and v.X or right
    end

    return {
        pos = {
            topLeft = Vector2.new(left, top),
            topRight = Vector2.new(right, top),
            bottomLeft = Vector2.new(left, bottom),
            middle = Vector2.new((right - left) / 2 + left, (bottom - top) / 2 + top),
            bottomRight = Vector2.new(right, bottom)
        },
        quad = {
            PointA = Vector2.new(right, top),
            PointB = Vector2.new(left, top),
            PointC = Vector2.new(left, bottom),
            PointD = Vector2.new(right, bottom)
        }
    }
end

function utility:wtvp(p) -- vector
    p = workspace.CurrentCamera:WorldToViewportPoint(p)
    return Vector2.new(p.X, p.Y), p.Z
end

function utility:get2dcorner(cf, s)
    local Top = s.Y / 2
    local Bottom = -s.Y / 2
    local Front = -s.Z / 2
    local Back = s.Z / 2
    local Left = -s.X / 2
    local Right = s.X / 2

    return {
        LeftTopFront = utility:wtvp((cf * CFrame.new(Vector3.new(Left, Top, Front))).Position),
        RightTopFront = utility:wtvp((cf * CFrame.new(Vector3.new(Right, Top, Front))).Position),
        LeftBottomFront = utility:wtvp((cf * CFrame.new(Vector3.new(Left, Bottom, Front))).Position),
        RightBottomFront = utility:wtvp((cf * CFrame.new(Vector3.new(Right, Bottom, Front))).Position),
        LeftTopBack = utility:wtvp((cf * CFrame.new(Vector3.new(Left, Top, Back))).Position),
        RightTopBack = utility:wtvp((cf * CFrame.new(Vector3.new(Right, Top, Back))).Position),
        LeftBottomBack = utility:wtvp((cf * CFrame.new(Vector3.new(Left, Bottom, Back))).Position),
        RightBottomBack = utility:wtvp((cf * CFrame.new(Vector3.new(Right, Bottom, Back))).Position)
    }
end

function utility:GetBoundingBox(Character)
    local Data = {}

    for i,v in pairs(Character:GetChildren()) do
        if (v:IsA("BasePart") and v.Name ~= "HumanoidRootPart") then
            for i2, v2 in pairs(utility:get2dcorner(v.CFrame, v.Size)) do
                table.insert(Data, v2)
            end
        end
    end

    return utility:getposlist2(Data)
end

local library = {}
esp_settings = {}
initialized = false
defaultsettings = {
    Visuals = {
        Boxes = false,
        Tracers = false,
        Skeletons = false,
        Healthbars = false,
        Outlines = false,
        VisibleOutlines = false,
        Chams = false,
        VisibleChams = false,
        Names = false,
        Distances = false,
        Weapons = false,
        Crosshair = false
    },
    Teams = {
        Boxes = true,
        Tracers = true,
        Skeletons = true,
        Healthbars = true,
        Outlines = true,
        VisibleOutlines = true,
        Chams = true,
        VisibleChams = true,
        Names = true,
        Distances = true
    },
    Colors = {
        BoxEnemyColor = Color3.fromRGB(255,0,0),
        BoxTeamColor = Color3.fromRGB(0,0,255),

        TracersEnemyColor = Color3.fromRGB(255,0,0),
        TracersTeamColor = Color3.fromRGB(0,0,255),

        SkeletonEnemyColor = Color3.fromRGB(255,0,0),
        SkeletonTeamColor = Color3.fromRGB(0,0,255),

        OutlinesEnemyColor = Color3.fromRGB(255,0,0),
        OutlinesTeamColor = Color3.fromRGB(0,0,255),

        VisibleOutlinesEnemyColor = Color3.fromRGB(255,0,0),
        VisibleOutlinesTeamColor = Color3.fromRGB(0,0,255),

        ChamsEnemyColor = Color3.fromRGB(255,0,0),
        ChamsTeamColor = Color3.fromRGB(0,0,255),

        VisibleChamsEnemyColor = Color3.fromRGB(255,0,0),
        VisibleChamsTeamColor = Color3.fromRGB(0,0,255),

        NameEnemyColor = Color3.fromRGB(255,0,0),
        NameTeamColor = Color3.fromRGB(0,0,255),

        DistanceEnemyColor = Color3.fromRGB(255,0,0),
        DistanceTeamColor = Color3.fromRGB(0,0,255),

        HealthbarFullColor = Color3.fromRGB(0,255,0),
        HealthbarEmptyColor = Color3.fromRGB(255,0,0),
        WeaponColor = Color3.fromRGB(0,255,0),

        CrosshairColor = Color3.fromRGB(255,255,255)
    },
    Other = {
        BoxesOutline = false,
        BoxesThickness = 1,
        BoxesTransparency = 1,

        TracerThickness = 1,
        TracerTransparency = 0.5,
        TracerOrigin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y),
        TracerPart = "head",

        NameTextSize = 15,
        NameTextOutline = false,
        NameFontFamily = Drawing.Fonts["UI"],

        WeaponTextSize = 15,
        WeaponTextOutline = false,
        WeaponFontFamily = Drawing.Fonts["UI"],

        SkeletonThickness = 2,
        SkeletonTransparency = 0.5,

        DistanceTextSize = 15,
        DistanceTextOutline = false,
        DistanceFontFamily = Drawing.Fonts["UI"],

        ChamsTransparency = 0.5,

        VisibleChamsTransparency = 0,

        OutlinesTransparency = 0,

        VisibleOutlinesTransparency = 0,

        HealthbarOffset = 10,

        CrosshairSize = 10,
        CrosshairThickness = 1,
        CrosshairTransparency = 1,

        MaxDistance = 1000,

        Refreshtime = 5
    }
}

function round(x)
    return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
end
function find2d(table, result)
    for i,v in pairs(table) do
        if v == result then
            return i
        end
    end
end

function getpos(pos)
    return Vector2.new(pos.X, pos.Y)
end

function removekey(t, key)
    local element = t[key]
    t[key] = nil
    return element
end

function library:Init(options)
    assert(initialized == false, "You can't initialize twice!")
    esp_settings = defaultsettings
    initialized = true
end

function library:UpdateSetting(option, value)
    assert(esp_settings.Other[option] ~= nil, "This option doesn't exist!")
    esp_settings.Other[option] = value
end

function library:UpdateColor(option, value)
    assert(esp_settings.Colors[option] ~= nil, "This option doesn't exist!")
    esp_settings.Colors[option] = value
end

function library:ToggleTeamcheck(option, value)
    assert(esp_settings.Teams[option] ~= nil, "This option doesn't exist!")
    assert(typeof(value) == "boolean", tostring(value) .. " is not a boolean!")
    esp_settings.Teams[option] = value
end

function library:Toggle(option, value)
    assert(esp_settings.Visuals[option] ~= nil, "This option doesn't exist!")
    assert(typeof(value) == "boolean", tostring(value) .. " is not a boolean!")
    esp_settings.Visuals[option] = value
end

local drawingshit = {}

function AddToRenderList(plr)

    if plr ~= LocalPlayer and drawingshit[plr] == nil then

        drawingshit[plr.Name] = {}

        local name = Drawing.new("Text")
        name.Visible = false
        name.Text = plr.Name
        name.Size = esp_settings.Other.NameTextSize
        name.Center = true
        name.Outline = esp_settings.Other.NameTextOutline
        name.Color = plr.TeamColor == LocalPlayer.TeamColor and esp_settings.Colors.NameTeamColor or esp_settings.Colors.NameEnemyColor
        name.Font = esp_settings.Other.NameFontFamily

        local box = Drawing.new("Square")
        box.Visible = false
        box.Color = plr.TeamColor == LocalPlayer.TeamColor and esp_settings.Colors.BoxTeamColor or esp_settings.Colors.BoxEnemyColor
        box.Thickness = esp_settings.Other.BoxesThickness
        box.Transparency = esp_settings.Other.BoxesTransparency

        local tracer = Drawing.new("Line")
        tracer.Visible = false
        tracer.From = esp_settings.Other.TracerOrigin
        tracer.To = Vector2.new(0,0)
        tracer.Thickness = esp_settings.Other.TracerThickness
        tracer.Color = plr.TeamColor == LocalPlayer.TeamColor and esp_settings.Colors.TracersTeamColor or esp_settings.Colors.TracersEnemyColor
        tracer.Transparency = esp_settings.Other.TracerTransparency

        local distance = Drawing.new("Text")
        distance.Visible = false
        distance.Center = true
        distance.Size = esp_settings.Other.DistanceTextSize
        distance.Outline = esp_settings.Other.DistanceTextOutline
        distance.Color = plr.TeamColor == LocalPlayer.TeamColor and esp_settings.Colors.DistanceTeamColor or esp_settings.Colors.DistanceEnemyColor
        distance.Font = esp_settings.Other.DistanceFontFamily

        local healthbar = Drawing.new("Square")
        healthbar.Visible = false
        healthbar.Filled = true
        healthbar.Color = esp_settings.Colors.HealthbarEmptyColor:lerp(esp_settings.Colors.HealthbarFullColor, utility:GetHealth(plr)/100);

        local crosshairvertical = Drawing.new("Line")
        crosshairvertical.Visible = false
        crosshairvertical.Thickness = esp_settings.Other.CrosshairThickness
        crosshairvertical.Transparency = esp_settings.Other.CrosshairTransparency
        crosshairvertical.Color = esp_settings.Colors.CrosshairColor

        local crosshairhorizontal = Drawing.new("Line")
        crosshairhorizontal.Visible = false
        crosshairhorizontal.Thickness = esp_settings.Other.CrosshairThickness
        crosshairhorizontal.Transparency = esp_settings.Other.CrosshairTransparency
        crosshairhorizontal.Color = esp_settings.Colors.CrosshairColor

        local headline = Drawing.new("Line")
        headline.Visible = false
        headline.Color = plr.TeamColor == LocalPlayer.TeamColor and esp_settings.Colors.SkeletonTeamColor or esp_settings.Colors.SkeletonEnemyColor
        headline.Thickness = esp_settings.Other.SkeletonThickness
        headline.Transparency = esp_settings.Other.SkeletonTransparency


        local torsoline = Drawing.new("Line")
        torsoline.Visible = false
        torsoline.Color = plr.TeamColor == LocalPlayer.TeamColor and esp_settings.Colors.SkeletonTeamColor or esp_settings.Colors.SkeletonEnemyColor
        torsoline.Thickness = esp_settings.Other.SkeletonThickness
        torsoline.Transparency = esp_settings.Other.SkeletonTransparency


        local leftarmline = Drawing.new("Line")
        leftarmline.Visible = false
        leftarmline.Color = plr.TeamColor == LocalPlayer.TeamColor and esp_settings.Colors.SkeletonTeamColor or esp_settings.Colors.SkeletonEnemyColor
        leftarmline.Thickness = esp_settings.Other.SkeletonThickness
        leftarmline.Transparency = esp_settings.Other.SkeletonTransparency


        local rightarmline = Drawing.new("Line")
        rightarmline.Visible = false
        rightarmline.Color = plr.TeamColor == LocalPlayer.TeamColor and esp_settings.Colors.SkeletonTeamColor or esp_settings.Colors.SkeletonEnemyColor
        rightarmline.Thickness = esp_settings.Other.SkeletonThickness
        rightarmline.Transparency = esp_settings.Other.SkeletonTransparency


        local leftlegline = Drawing.new("Line")
        leftlegline.Visible = false
        leftlegline.Color = plr.TeamColor == LocalPlayer.TeamColor and esp_settings.Colors.SkeletonTeamColor or esp_settings.Colors.SkeletonEnemyColor
        leftlegline.Thickness = esp_settings.Other.SkeletonThickness
        leftlegline.Transparency = esp_settings.Other.SkeletonTransparency


        local rightlegline = Drawing.new("Line")
        rightlegline.Visible = false
        rightlegline.Color = plr.TeamColor == LocalPlayer.TeamColor and esp_settings.Colors.SkeletonTeamColor or esp_settings.Colors.SkeletonEnemyColor
        rightlegline.Thickness = esp_settings.Other.SkeletonThickness
        rightlegline.Transparency = esp_settings.Other.SkeletonTransparency

        local leftupperconnector = Drawing.new("Line")
        leftupperconnector.Visible = false
        leftupperconnector.Color = plr.TeamColor == LocalPlayer.TeamColor and esp_settings.Colors.SkeletonTeamColor or esp_settings.Colors.SkeletonEnemyColor
        leftupperconnector.Thickness = esp_settings.Other.SkeletonThickness
        leftupperconnector.Transparency = esp_settings.Other.SkeletonTransparency

        local rightupperconnector = Drawing.new("Line")
        rightupperconnector.Visible = false
        rightupperconnector.Color = plr.TeamColor == LocalPlayer.TeamColor and esp_settings.Colors.SkeletonTeamColor or esp_settings.Colors.SkeletonEnemyColor
        rightupperconnector.Thickness = esp_settings.Other.SkeletonThickness
        rightupperconnector.Transparency = esp_settings.Other.SkeletonTransparency

        local leftlowerconnector = Drawing.new("Line")
        leftlowerconnector.Visible = false
        leftlowerconnector.Color = plr.TeamColor == LocalPlayer.TeamColor and esp_settings.Colors.SkeletonTeamColor or esp_settings.Colors.SkeletonEnemyColor
        leftlowerconnector.Thickness = esp_settings.Other.SkeletonThickness
        leftlowerconnector.Transparency = esp_settings.Other.SkeletonTransparency

        local rightlowerconnector = Drawing.new("Line")
        rightlowerconnector.Visible = false
        rightlowerconnector.Color = plr.TeamColor == LocalPlayer.TeamColor and esp_settings.Colors.SkeletonTeamColor or esp_settings.Colors.SkeletonEnemyColor
        rightlowerconnector.Thickness = esp_settings.Other.SkeletonThickness
        rightlowerconnector.Transparency = esp_settings.Other.SkeletonTransparency

        drawingshit[plr.Name].headline = headline
        drawingshit[plr.Name].torsoline = torsoline
        drawingshit[plr.Name].leftarmline = leftarmline
        drawingshit[plr.Name].rightarmline = rightarmline
        drawingshit[plr.Name].leftlegline = leftlegline
        drawingshit[plr.Name].rightlegline = rightlegline
        drawingshit[plr.Name].leftupperconnector = leftupperconnector
        drawingshit[plr.Name].rightupperconnector = rightupperconnector
        drawingshit[plr.Name].leftlowerconnector = leftlowerconnector
        drawingshit[plr.Name].rightlowerconnector = rightlowerconnector

        drawingshit[plr.Name].name = name
        drawingshit[plr.Name].box = box
        drawingshit[plr.Name].tracer = tracer
        drawingshit[plr.Name].distance = distance
        drawingshit[plr.Name].healthbar = healthbar
        drawingshit[plr.Name].crosshairvertical = crosshairvertical
        drawingshit[plr.Name].crosshairhorizontal = crosshairhorizontal

        local CanRun = true

        rs:BindToRenderStep(plr.Name .. "Mika Esp", 1, function()

            if (not CanRun) then
                return
            end

            CanRun = false
            if esp_settings.Visuals.Tracers then
                if utility:IsAlive(plr) then
                    if LocalPlayer.Character and (utility:GetBodypart(plr, "torso").Position - LocalPlayer.Character.Torso.Position).Magnitude <= esp_settings.Other.MaxDistance then
                        assert(utility:GetBodypart(plr, esp_settings.Other.TracerPart) ~= nil, "`" .. esp_settings.Other.TracerPart .. "` Doesn't exist in `" .. plr.Name .. ".Character`!")
                        local vec, onscreen = Camera:WorldToViewportPoint(utility:GetBodypart(plr, esp_settings.Other.TracerPart).Position)
                        if onscreen then
                            if plr.TeamColor == LocalPlayer.TeamColor then
                                if esp_settings.Teams.Tracers then
                                    tracer.To = Vector2.new(vec.X, vec.Y)
                                    tracer.Thickness = esp_settings.Other.TracerThickness
                                    tracer.Color = plr.TeamColor == LocalPlayer.TeamColor and esp_settings.Colors.TracersTeamColor or esp_settings.Colors.TracersEnemyColor
                                    tracer.Transparency = esp_settings.Other.TracerTransparency
                                    tracer.Visible = true
                                else
                                    tracer.Visible = false
                                end
                            else
                                tracer.To = Vector2.new(vec.X, vec.Y)
                                tracer.Thickness = esp_settings.Other.TracerThickness
                                tracer.Color = plr.TeamColor == LocalPlayer.TeamColor and esp_settings.Colors.TracersTeamColor or esp_settings.Colors.TracersEnemyColor
                                tracer.Transparency = esp_settings.Other.TracerTransparency
                                tracer.Visible = true
                            end
                        else
                            tracer.Visible = false
                        end
                    else
                        tracer.Visible = false
                    end
                else
                    tracer.Visible = false
                end
            else
                tracer.Visible = false
            end

        if esp_settings.Visuals.Boxes then
            if utility:IsAlive(plr) then
                if LocalPlayer.Character and (utility:GetBodypart(plr, "torso").Position - LocalPlayer.Character.Torso.Position).Magnitude <= esp_settings.Other.MaxDistance then
                    local data = utility:GetBoundingBox(utility:GetCharacter(plr))
                    local boxpos = Vector2.new(math.floor(data.pos.bottomRight.X), math.floor(data.pos.bottomRight.Y))
                    local Width, Height = math.floor(data.pos.topLeft.X - data.pos.topRight.X), math.floor(data.pos.topLeft.Y - data.pos.bottomLeft.Y)
                    local boxsize = Vector2.new(Width, Height)
                    local pos, onscreen = Camera:WorldToViewportPoint(utility:GetBodypart(plr, "torso").Position)
                    if onscreen then
                        if plr.TeamColor == LocalPlayer.TeamColor then
                            if esp_settings.Teams.Boxes then
                                box.Size = boxsize
                                box.Position = boxpos
                                box.Color = plr.TeamColor == LocalPlayer.TeamColor and esp_settings.Colors.BoxTeamColor or esp_settings.Colors.BoxEnemyColor
                                box.Thickness = esp_settings.Other.BoxesThickness
                                box.Transparency = esp_settings.Other.BoxesTransparency
                                box.Visible = true
                            else
                                box.Visible = false
                            end
                        else
                            box.Size = boxsize
                            box.Position = boxpos
                            box.Color = plr.TeamColor == LocalPlayer.TeamColor and esp_settings.Colors.BoxTeamColor or esp_settings.Colors.BoxEnemyColor
                            box.Thickness = esp_settings.Other.BoxesThickness
                            box.Transparency = esp_settings.Other.BoxesTransparency
                            box.Visible = true
                        end
                    else
                        box.Visible = false
                    end
                else
                    box.Visible = false
                end
            else
                box.Visible = false
            end
        else
            box.Visible = false
        end

        if esp_settings.Visuals.Skeletons then
            if utility:IsAlive(plr) then
                if LocalPlayer.Character and (utility:GetBodypart(plr, "torso").Position - LocalPlayer.Character.Torso.Position).Magnitude <= esp_settings.Other.MaxDistance then
                    local Vector, onScreen = Camera:worldToViewportPoint(utility:GetBodypart(plr, "torso").Position)

                    headline.From = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "Head").Position)) -- Head

                    torsoline.From = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "Torso").Position + Vector3.new(0,1,0))) -- Upper Torso

                    leftarmline.From = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "larm").Position + Vector3.new(0,-1,0))) -- LowerLeftArm

                    rightarmline.From = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "rarm").Position + Vector3.new(0,-1,0))) -- LowerRightarm

                    leftlegline.From = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "lleg").Position + Vector3.new(0,-1,0))) -- LowerLeftLeg

                    rightlegline.From = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "rleg").Position + Vector3.new(0,-1,0))) -- LowerRightLeg

                    leftupperconnector.From = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "larm").Position + Vector3.new(0,1,0))) -- UpperLeftArm

                    rightupperconnector.From = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "rarm").Position + Vector3.new(0,1,0))) -- UpperRightArm

                    leftlowerconnector.From = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "lleg").Position + Vector3.new(0,1,0))) -- UpperLeftLeg

                    rightlowerconnector.From = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "rleg").Position + Vector3.new(0,1,0))) -- UpperRightLeg



                    headline.To = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "Torso").Position + Vector3.new(0,1,0))) -- Upper Torso

                    torsoline.To = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "Torso").Position + Vector3.new(0,-1,0))) -- Lower Torso

                    leftarmline.To = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "larm").Position + Vector3.new(0,1,0))) -- UpperLeftArm

                    rightarmline.To = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "rarm").Position + Vector3.new(0,1,0))) -- UpperRightArm

                    leftlegline.To = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "lleg").Position + Vector3.new(0,1,0))) -- UpperLeftLeg

                    rightlegline.To = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "rleg").Position + Vector3.new(0,1,0))) -- UpperRightLeg

                    rightupperconnector.To = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "Torso").Position + Vector3.new(0,1,0))) -- UpperTorso

                    rightlowerconnector.To = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "Torso").Position + Vector3.new(0,-1,0))) -- LowerTorso

                    leftupperconnector.To = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "Torso").Position + Vector3.new(0,1,0))) -- UpperTorso

                    leftlowerconnector.To = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "Torso").Position + Vector3.new(0,-1,0))) -- LowerTorso

                    if onScreen then
                        if plr.TeamColor == LocalPlayer.TeamColor then
                            if esp_settings.Teams.Skeletons then
                                headline.Color = esp_settings.Colors.SkeletonTeamColor
                                headline.Thickness = esp_settings.Other.SkeletonThickness
                                headline.Transparency = esp_settings.Other.SkeletonTransparency
                                headline.Visible = true
                                torsoline.Color = esp_settings.Colors.SkeletonTeamColor
                                torsoline.Thickness = esp_settings.Other.SkeletonThickness
                                torsoline.Transparency = esp_settings.Other.SkeletonTransparency
                                torsoline.Visible = true
                                leftarmline.Color = esp_settings.Colors.SkeletonTeamColor
                                leftarmline.Thickness = esp_settings.Other.SkeletonThickness
                                leftarmline.Transparency = esp_settings.Other.SkeletonTransparency
                                leftarmline.Visible = true
                                rightarmline.Color = esp_settings.Colors.SkeletonTeamColor
                                rightarmline.Thickness = esp_settings.Other.SkeletonThickness
                                rightarmline.Transparency = esp_settings.Other.SkeletonTransparency
                                rightarmline.Visible = true
                                leftlegline.Color = esp_settings.Colors.SkeletonTeamColor
                                leftlegline.Thickness = esp_settings.Other.SkeletonThickness
                                leftlegline.Transparency = esp_settings.Other.SkeletonTransparency
                                leftlegline.Visible = true
                                rightlegline.Color = esp_settings.Colors.SkeletonTeamColor
                                rightlegline.Thickness = esp_settings.Other.SkeletonThickness
                                rightlegline.Transparency = esp_settings.Other.SkeletonTransparency
                                rightlegline.Visible = true
                                leftupperconnector.Color = esp_settings.Colors.SkeletonTeamColor
                                leftupperconnector.Thickness = esp_settings.Other.SkeletonThickness
                                leftupperconnector.Transparency = esp_settings.Other.SkeletonTransparency
                                leftupperconnector.Visible = true
                                rightupperconnector.Color = esp_settings.Colors.SkeletonTeamColor
                                rightupperconnector.Thickness = esp_settings.Other.SkeletonThickness
                                rightupperconnector.Transparency = esp_settings.Other.SkeletonTransparency
                                rightupperconnector.Visible = true
                                leftlowerconnector.Color = esp_settings.Colors.SkeletonTeamColor
                                leftlowerconnector.Thickness = esp_settings.Other.SkeletonThickness
                                leftlowerconnector.Transparency = esp_settings.Other.SkeletonTransparency
                                leftlowerconnector.Visible = true
                                rightlowerconnector.Color = esp_settings.Colors.SkeletonTeamColor
                                rightlowerconnector.Thickness = esp_settings.Other.SkeletonThickness
                                rightlowerconnector.Transparency = esp_settings.Other.SkeletonTransparency
                                rightlowerconnector.Visible = true
                            else
                                headline.Visible = false
                                torsoline.Visible = false
                                leftarmline.Visible = false
                                rightarmline.Visible = false
                                leftlegline.Visible = false
                                rightlegline.Visible = false
                                leftupperconnector.Visible = false
                                rightupperconnector.Visible = false
                                leftlowerconnector.Visible = false
                                rightlowerconnector.Visible = false
                            end
                        else
                            headline.Color = esp_settings.Colors.SkeletonEnemyColor
                            headline.Thickness = esp_settings.Other.SkeletonThickness
                            headline.Transparency = esp_settings.Other.SkeletonTransparency
                            headline.Visible = true

                            torsoline.Color = esp_settings.Colors.SkeletonEnemyColor
                            torsoline.Thickness = esp_settings.Other.SkeletonThickness
                            torsoline.Transparency = esp_settings.Other.SkeletonTransparency
                            torsoline.Visible = true

                            leftarmline.Color = esp_settings.Colors.SkeletonEnemyColor
                            leftarmline.Thickness = esp_settings.Other.SkeletonThickness
                            leftarmline.Transparency = esp_settings.Other.SkeletonTransparency
                            leftarmline.Visible = true

                            rightarmline.Color = esp_settings.Colors.SkeletonEnemyColor
                            rightarmline.Thickness = esp_settings.Other.SkeletonThickness
                            rightarmline.Transparency = esp_settings.Other.SkeletonTransparency
                            rightarmline.Visible = true

                            leftlegline.Color = esp_settings.Colors.SkeletonEnemyColor
                            leftlegline.Thickness = esp_settings.Other.SkeletonThickness
                            leftlegline.Transparency = esp_settings.Other.SkeletonTransparency
                            leftlegline.Visible = true

                            rightlegline.Color = esp_settings.Colors.SkeletonEnemyColor
                            rightlegline.Thickness = esp_settings.Other.SkeletonThickness
                            rightlegline.Transparency = esp_settings.Other.SkeletonTransparency
                            rightlegline.Visible = true

                            leftupperconnector.Color = esp_settings.Colors.SkeletonEnemyColor
                            leftupperconnector.Thickness = esp_settings.Other.SkeletonThickness
                            leftupperconnector.Transparency = esp_settings.Other.SkeletonTransparency
                            leftupperconnector.Visible = true

                            rightupperconnector.Color = esp_settings.Colors.SkeletonEnemyColor
                            rightupperconnector.Thickness = esp_settings.Other.SkeletonThickness
                            rightupperconnector.Transparency = esp_settings.Other.SkeletonTransparency
                            rightupperconnector.Visible = true

                            leftlowerconnector.Color = esp_settings.Colors.SkeletonEnemyColor
                            leftlowerconnector.Thickness = esp_settings.Other.SkeletonThickness
                            leftlowerconnector.Transparency = esp_settings.Other.SkeletonTransparency
                            leftlowerconnector.Visible = true

                            rightlowerconnector.Color = esp_settings.Colors.SkeletonEnemyColor
                            rightlowerconnector.Thickness = esp_settings.Other.SkeletonThickness
                            rightlowerconnector.Transparency = esp_settings.Other.SkeletonTransparency
                            rightlowerconnector.Visible = true
                        end

                    else
                        headline.Visible = false
                        torsoline.Visible = false
                        leftarmline.Visible = false
                        rightarmline.Visible = false
                        leftlegline.Visible = false
                        rightlegline.Visible = false
                        leftupperconnector.Visible = false
                        rightupperconnector.Visible = false
                        leftlowerconnector.Visible = false
                        rightlowerconnector.Visible = false
                    end
                else
                    headline.Visible = false
                    torsoline.Visible = false
                    leftarmline.Visible = false
                    rightarmline.Visible = false
                    leftlegline.Visible = false
                    rightlegline.Visible = false
                    leftupperconnector.Visible = false
                    rightupperconnector.Visible = false
                    leftlowerconnector.Visible = false
                    rightlowerconnector.Visible = false
                end
            else
                headline.Visible = false
                torsoline.Visible = false
                leftarmline.Visible = false
                rightarmline.Visible = false
                leftlegline.Visible = false
                rightlegline.Visible = false
                leftupperconnector.Visible = false
                rightupperconnector.Visible = false
                leftlowerconnector.Visible = false
                rightlowerconnector.Visible = false
            end
        else
            headline.Visible = false
            torsoline.Visible = false
            leftarmline.Visible = false
            rightarmline.Visible = false
            leftlegline.Visible = false
            rightlegline.Visible = false

            leftupperconnector.Visible = false
            rightupperconnector.Visible = false
            leftlowerconnector.Visible = false
            rightlowerconnector.Visible = false
        end

        if esp_settings.Visuals.Names then
            if utility:IsAlive(plr) then
                if LocalPlayer.Character and (utility:GetBodypart(plr, "torso").Position - LocalPlayer.Character.Torso.Position).Magnitude <= esp_settings.Other.MaxDistance then
                    local vec, onscreen = Camera:WorldToViewportPoint(utility:GetBodypart(plr, "head").Position)
                    if onscreen then
                        if plr.TeamColor == LocalPlayer.TeamColor then
                            if esp_settings.Teams.Names then
                                name.Position = Vector2.new(vec.X, vec.Y)
                                name.Size = esp_settings.Other.NameTextSize
                                name.Outline = esp_settings.Other.NameTextOutline
                                name.Color = plr.TeamColor == LocalPlayer.TeamColor and esp_settings.Colors.NameTeamColor or esp_settings.Colors.NameEnemyColor
                                name.Font = esp_settings.Other.NameFontFamily
                                name.Visible = true
                            else
                                name.Visible = false
                            end
                        else
                            name.Position = Vector2.new(vec.X, vec.Y)
                            name.Outline = esp_settings.Other.NameTextOutline
                            name.Color = plr.TeamColor == LocalPlayer.TeamColor and esp_settings.Colors.NameTeamColor or esp_settings.Colors.NameEnemyColor
                            name.Font = esp_settings.Other.NameFontFamily
                            name.Visible = true
                        end

                    else
                        name.Visible = false
                    end
                else
                    name.Visible = false
                end
            else
                name.Visible = false
            end
        else
            name.Visible = false
        end

        if esp_settings.Visuals.Distances then
            if utility:IsAlive(plr) then
                if LocalPlayer.Character and (utility:GetBodypart(plr, "torso").Position - LocalPlayer.Character.Torso.Position).Magnitude <= esp_settings.Other.MaxDistance then
                    local vec, onscreen = Camera:WorldToViewportPoint(utility:GetBodypart(plr, "head").Position)
                    if onscreen then
                        distance.Position = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "Torso").Position + Vector3.new(0,-1,0)))
                        if plr.TeamColor == LocalPlayer.TeamColor then
                            if esp_settings.Teams.Distances then
                                distance.Text = tostring(round((LocalPlayer.Character.Head.Position - utility:GetBodypart(plr, "head").Position).magnitude)) .. "Studs"
                                distance.Size = esp_settings.Other.DistanceTextSize
                                distance.Outline = esp_settings.Other.DistanceTextOutline
                                distance.Color = plr.TeamColor == LocalPlayer.TeamColor and esp_settings.Colors.DistanceTeamColor or esp_settings.Colors.DistanceEnemyColor
                                distance.Font = esp_settings.Other.DistanceFontFamily
                                distance.Visible = true
                            else
                                distance.Visible = false
                            end
                        else
                            distance.Text = tostring(round((LocalPlayer.Character.Head.Position - utility:GetBodypart(plr, "head").Position).magnitude)) .. "Studs"
                            distance.Size = esp_settings.Other.DistanceTextSize
                            distance.Outline = esp_settings.Other.DistanceTextOutline
                            distance.Color = plr.TeamColor == LocalPlayer.TeamColor and esp_settings.Colors.DistanceTeamColor or esp_settings.Colors.DistanceEnemyColor
                            distance.Font = esp_settings.Other.DistanceFontFamily
                            distance.Visible = true
                        end
                    else
                        distance.Visible = false
                    end
                else
                    distance.Visible = false
                end
            else
                distance.Visible = false
            end
        else
            distance.Visible = false
        end

        if esp_settings.Visuals.Healthbars then
            if utility:IsAlive(plr) and utility:GetBodypart(plr, "torso") ~= nil then
                if LocalPlayer.Character and (utility:GetBodypart(plr, "torso").Position - LocalPlayer.Character.Torso.Position).Magnitude <= esp_settings.Other.MaxDistance then
                    local Health, MaxHealth = utility:GetHealth(plr)
                    local data = utility:GetBoundingBox(utility:GetCharacter(plr))
                    local Width, Height = math.floor(data.pos.topLeft.X - data.pos.topRight.X), math.floor(data.pos.topLeft.Y - data.pos.bottomLeft.Y)

                    local BoxSize = Vector2.new(Width, Height)

                    local healthsize = Vector2.new(2, math.floor(BoxSize.Y * (Health / MaxHealth)))
                    local healthpos = Vector2.new(math.floor(data.pos.topLeft.X - ((4 + esp_settings.Other.HealthbarOffset))), math.floor(data.pos.bottomLeft.Y))

                    local pos, onscreen = Camera:WorldToViewportPoint(utility:GetBodypart(plr, "torso").Position)
                    if onscreen then

                        if plr.TeamColor == LocalPlayer.TeamColor then
                            if esp_settings.Teams.Healthbars then
                                healthbar.Size = healthsize
                                healthbar.Position = healthpos
                                healthbar.Visible = true
                                healthbar.Color = esp_settings.Colors.HealthbarEmptyColor:lerp(esp_settings.Colors.HealthbarFullColor, utility:GetHealth(plr)/100);
                            else
                                healthbar.Visible = false
                            end
                        else
                            healthbar.Size = healthsize
                            healthbar.Position = healthpos
                            healthbar.Visible = true
                            healthbar.Color = esp_settings.Colors.HealthbarEmptyColor:lerp(esp_settings.Colors.HealthbarFullColor, utility:GetHealth(plr)/100);
                        end
                    else
                        healthbar.Visible = false
                    end
                else
                    healthbar.Visible = false
                end
            else
                healthbar.Visible = false
            end
        else
            healthbar.Visible = false
        end

        if esp_settings.Visuals.Crosshair then
            local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

            crosshairvertical.From = Vector2.new(center.X - esp_settings.Other.CrosshairSize, center.Y)
            crosshairvertical.To = Vector2.new(center.X + esp_settings.Other.CrosshairSize, center.Y)

            crosshairvertical.Thickness = esp_settings.Other.CrosshairThickness
            crosshairvertical.Transparency = esp_settings.Other.CrosshairTransparency
            crosshairvertical.Color = esp_settings.Colors.CrosshairColor


            crosshairhorizontal.From = Vector2.new(center.X, center.Y - esp_settings.Other.CrosshairSize)
            crosshairhorizontal.To = Vector2.new(center.X, center.Y + esp_settings.Other.CrosshairSize)

            crosshairhorizontal.Thickness = esp_settings.Other.CrosshairThickness
            crosshairhorizontal.Transparency = esp_settings.Other.CrosshairTransparency
            crosshairhorizontal.Color = esp_settings.Colors.CrosshairColor

            crosshairvertical.Visible = true
            crosshairhorizontal.Visible = true
        else
            crosshairhorizontal.Visible = false
            crosshairvertical.Visible = false
        end

        CanRun = true
        end)
    end
end
local idtable = {}
local weapontable = {}
local counter = 0

function library:RefreshESP()
    for i,v in pairs(game:GetService("Players"):GetPlayers()) do
        RemoveFromRenderList(v)
        AddToRenderList(v)
    end
    for i,v in pairs(weapontable) do
        if v then
            v.Size = esp_settings.Other.WeaponTextSize
            v.Font = esp_settings.Other.WeaponFontFamily
            v.Outline = esp_settings.Other.WeaponTextOutline
            v.Color = esp_settings.Colors.WeaponColor
        end
    end
end

function RemoveFromRenderList(plr)
    if plr ~= LocalPlayer then
        rs:UnbindFromRenderStep(plr.Name .. "Mika Esp")
        if drawingshit[plr.Name] ~= nil then
            for i,v in pairs(drawingshit[plr.Name]) do
                removekey(drawingshit[plr.Name], find2d(drawingshit[plr.Name], v))
                if typeof(v) == "Instance" and v.ClassName == "Highlight" then
                    v:Destroy()
                else
                    v:Remove()
                end
            end
        end
    end
end

function AddWeaponsToRenderList(gun)
    counter += 1
    idtable[gun] = tostring(counter)

    local text = Drawing.new("Text")
    text.Visible = false
    text.Text = ""..gun.Gun.Value.."\n"..gun.Spare.Value.." Bullets"
    text.Color = esp_settings.Colors.WeaponColor
    text.Size = esp_settings.Other.WeaponTextSize
    text.Font = esp_settings.Other.WeaponFontFamily
    text.Outline = esp_settings.Other.WeaponTextOutline

    weapontable[gun] = text


    rs:BindToRenderStep(tostring(counter) .. "WeaponEsp", Enum.RenderPriority.Last.Value, function()
        if esp_settings.Visuals.Weapons then
            local pos, onscreen = Camera:WorldToViewportPoint(gun.Slot1.Position)
            if onscreen then
                text.Position = Vector2.new(pos.X, pos.Y)

                text.Size = esp_settings.Other.WeaponTextSize
                text.Font = esp_settings.Other.WeaponFontFamily
                text.Outline = esp_settings.Other.WeaponTextOutline
                text.Color = esp_settings.Colors.WeaponColor

                text.Visible = true
            else
                text.Visible = false
            end
        else
            text.Visible = false
        end
    end)

end

function RemoveWeaponFromRenderList(gun)
    rs:UnbindFromRenderStep(tostring(idtable[gun]) .. "WeaponEsp")
    if weapontable[gun] ~= nil then
        weapontable[gun]:Remove()
        weapontable[gun] = nil
    end
end

task.spawn(function()
    while not initialized do
        task.wait(0.5)
    end
    for i,v in pairs(players:GetPlayers()) do
        AddToRenderList(v)
    end

    players.PlayerAdded:Connect(function(player)
        AddToRenderList(player)
    end)

    players.PlayerRemoving:Connect(function(player)
        RemoveFromRenderList(player)
    end)

    for i,v in pairs(game:GetService("Workspace").Ignore.GunDrop:GetChildren()) do
        if v.Name == "Dropped" and v:FindFirstChild("Gun") then
            AddWeaponsToRenderList(v)
        end
    end
    game:GetService("Workspace").Ignore.GunDrop.ChildAdded:Connect(function(gun)
        if gun.Name == "Dropped" and gun:WaitForChild("Gun", 5) then
            AddWeaponsToRenderList(gun)
        end
    end)

    game:GetService("Workspace").Ignore.GunDrop.ChildRemoved:Connect(function(gun)
        RemoveWeaponFromRenderList(gun)
    end)
end)
return library
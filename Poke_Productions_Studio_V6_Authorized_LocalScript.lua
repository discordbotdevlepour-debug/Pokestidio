-- Poke Productions Studio V6 - Authorized Experience Camera Director
-- Place this LocalScript in StarterPlayer > StarterPlayerScripts
-- Intended only for a Roblox experience you own or have permission to edit.
-- This version uses a single coordinated render loop for camera playback and shake.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

local oldGui = playerGui:FindFirstChild("PokeStudioV6")
if oldGui then oldGui:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "PokeStudioV6"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.fromOffset(330, 470)
panel.Position = UDim2.new(0, 18, 0.5, -235)
panel.BackgroundColor3 = Color3.fromRGB(16, 16, 19)
panel.BorderSizePixel = 0
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(85, 85, 95)
stroke.Transparency = 0.25
stroke.Parent = panel

local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, -18, 0, 36)
header.Position = UDim2.fromOffset(10, 5)
header.BackgroundTransparency = 1
header.Text = "POKE PRODUCTIONS  |  V6"
header.Font = Enum.Font.GothamBold
header.TextSize = 15
header.TextColor3 = Color3.fromRGB(245, 245, 248)
header.TextXAlignment = Enum.TextXAlignment.Left
header.Parent = panel

local sub = Instance.new("TextLabel")
sub.Size = UDim2.new(1, -20, 0, 22)
sub.Position = UDim2.fromOffset(10, 38)
sub.BackgroundTransparency = 1
sub.Text = "CAMERA DIRECTOR • EXPERIENCE-OWNER BUILD"
sub.Font = Enum.Font.Gotham
sub.TextSize = 9
sub.TextColor3 = Color3.fromRGB(160, 160, 170)
sub.TextXAlignment = Enum.TextXAlignment.Left
sub.Parent = panel

local scroll = Instance.new("ScrollingFrame")
scroll.Name = "Controls"
scroll.Position = UDim2.fromOffset(8, 66)
scroll.Size = UDim2.new(1, -16, 1, -74)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 5
scroll.CanvasSize = UDim2.new()
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.ScrollingDirection = Enum.ScrollingDirection.Y
scroll.Parent = panel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 7)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scroll

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 2)
padding.PaddingBottom = UDim.new(0, 10)
padding.PaddingLeft = UDim.new(0, 2)
padding.PaddingRight = UDim.new(0, 2)
padding.Parent = scroll

local function makeButton(text, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -4, 0, 34)
    b.BackgroundColor3 = Color3.fromRGB(37, 37, 43)
    b.BorderSizePixel = 0
    b.Text = text
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 12
    b.TextColor3 = Color3.fromRGB(240, 240, 244)
    b.AutoButtonColor = true
    b.Parent = scroll
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(callback)
    return b
end

local function makeSection(text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -4, 0, 22)
    label.BackgroundTransparency = 1
    label.Text = text
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.TextColor3 = Color3.fromRGB(190, 190, 205)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = scroll
    return label
end

local function makeSlider(labelText, minValue, maxValue, initialValue, onChanged)
    local wrap = Instance.new("Frame")
    wrap.Size = UDim2.new(1, -4, 0, 48)
    wrap.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
    wrap.BorderSizePixel = 0
    wrap.Parent = scroll
    Instance.new("UICorner", wrap).CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -16, 0, 20)
    label.Position = UDim2.fromOffset(8, 2)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(235, 235, 240)
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = wrap

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -16, 0, 6)
    bar.Position = UDim2.fromOffset(8, 31)
    bar.BackgroundColor3 = Color3.fromRGB(65, 65, 75)
    bar.BorderSizePixel = 0
    bar.Parent = wrap
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((initialValue-minValue)/(maxValue-minValue), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(220, 220, 230)
    fill.BorderSizePixel = 0
    fill.Parent = bar
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local hit = Instance.new("TextButton")
    hit.Size = UDim2.new(1, 0, 1, 0)
    hit.BackgroundTransparency = 1
    hit.Text = ""
    hit.Parent = bar

    local value = initialValue
    local function setFromX(x)
        local pct = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        value = minValue + pct * (maxValue - minValue)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        label.Text = string.format("%s: %.2f", labelText, value)
        onChanged(value)
    end
    label.Text = string.format("%s: %.2f", labelText, value)
    local dragging = false
    hit.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            setFromX(input.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            setFromX(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    return wrap
end

-- Effect instances are created locally and reused.
local blur = Lighting:FindFirstChild("PokeV6_Blur") or Instance.new("BlurEffect")
blur.Name = "PokeV6_Blur"
blur.Size = 0
blur.Parent = Lighting

local color = Lighting:FindFirstChild("PokeV6_Color") or Instance.new("ColorCorrectionEffect")
color.Name = "PokeV6_Color"
color.Brightness = 0
color.Contrast = 0
color.Saturation = 0
color.TintColor = Color3.new(1, 1, 1)
color.Parent = Lighting

local bloom = Lighting:FindFirstChild("PokeV6_Bloom") or Instance.new("BloomEffect")
bloom.Name = "PokeV6_Bloom"
bloom.Intensity = 0
bloom.Size = 24
bloom.Threshold = 1
bloom.Parent = Lighting

local grainGui = Instance.new("Frame")
grainGui.Name = "FilmGrain"
grainGui.Size = UDim2.fromScale(1, 1)
grainGui.BackgroundColor3 = Color3.new(1, 1, 1)
grainGui.BackgroundTransparency = 1
grainGui.BorderSizePixel = 0
grainGui.ZIndex = 20
grainGui.Parent = gui

local vignette = Instance.new("Frame")
vignette.Name = "Vignette"
vignette.Size = UDim2.fromScale(1, 1)
vignette.BackgroundColor3 = Color3.new(0, 0, 0)
vignette.BackgroundTransparency = 1
vignette.BorderSizePixel = 0
vignette.ZIndex = 19
vignette.Parent = gui

local flash = Instance.new("Frame")
flash.Name = "Flash"
flash.Size = UDim2.fromScale(1, 1)
flash.BackgroundColor3 = Color3.new(1, 1, 1)
flash.BackgroundTransparency = 1
flash.BorderSizePixel = 0
flash.ZIndex = 30
flash.Parent = gui

local bars = Instance.new("Frame")
bars.Name = "Letterbox"
bars.Size = UDim2.fromScale(1, 1)
bars.BackgroundTransparency = 1
bars.ZIndex = 18
bars.Parent = gui

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 0)
topBar.BackgroundColor3 = Color3.new(0, 0, 0)
topBar.BorderSizePixel = 0
topBar.Parent = bars

local bottomBar = Instance.new("Frame")
bottomBar.AnchorPoint = Vector2.new(0, 1)
bottomBar.Position = UDim2.fromScale(0, 1)
bottomBar.Size = UDim2.new(1, 0, 0, 0)
bottomBar.BackgroundColor3 = Color3.new(0, 0, 0)
bottomBar.BorderSizePixel = 0
bottomBar.Parent = bars

local savedPositions = {}
local frames = {}
local effectEvents = {}
local recording = false
local playing = false
local paused = false
local recordStart = 0
local playStart = 0
local pauseAt = 0
local currentTime = 0
local recordConnection
local baseFov = camera.FieldOfView
local shakeStrength = 0
local shakeSpeed = 12
local shakeEnabled = false
local fadeTime = 0.5
local cutsceneLength = 8
local activeToken = 0
local lastCameraCFrame
local lastCameraType
local lastFov
local lastEffects = {}

local function setStatus(text)
    sub.Text = text
end

local function snapshotCamera()
    camera = workspace.CurrentCamera
    lastCameraCFrame = camera.CFrame
    lastCameraType = camera.CameraType
    lastFov = camera.FieldOfView
    camera.CameraType = Enum.CameraType.Scriptable
end

local function restoreCamera()
    camera = workspace.CurrentCamera
    if lastCameraType then camera.CameraType = lastCameraType end
    if lastCameraCFrame then camera.CFrame = lastCameraCFrame end
    if lastFov then camera.FieldOfView = lastFov end
end

local function easeTo(targetCFrame, targetFov, duration)
    local startCFrame = camera.CFrame
    local startFov = camera.FieldOfView
    local elapsed = 0
    while elapsed < duration and playing and not paused do
        elapsed += RunService.RenderStepped:Wait()
        local a = math.clamp(elapsed / duration, 0, 1)
        a = a * a * (3 - 2 * a)
        camera.CFrame = startCFrame:Lerp(targetCFrame, a)
        camera.FieldOfView = startFov + (targetFov - startFov) * a
    end
    if playing and not paused then
        camera.CFrame = targetCFrame
        camera.FieldOfView = targetFov
    end
end

local function tweenProperty(instance, property, value, duration)
    local tw = TweenService:Create(instance, TweenInfo.new(math.max(0.05, duration), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {[property] = value})
    tw:Play()
    return tw
end

local function runEffect(event)
    local duration = event.duration or 0.5
    if event.kind == "shake" then
        shakeStrength = event.amount or 0.5
        shakeSpeed = event.speed or 12
        shakeEnabled = true
        task.delay(duration, function()
            shakeEnabled = false
        end)
    elseif event.kind == "blur" then
        tweenProperty(blur, "Size", event.amount or 16, duration)
    elseif event.kind == "flash" then
        flash.BackgroundColor3 = event.color or Color3.new(1, 1, 1)
        flash.BackgroundTransparency = 0
        tweenProperty(flash, "BackgroundTransparency", 1, duration)
    elseif event.kind == "fade" then
        flash.BackgroundColor3 = Color3.new(0, 0, 0)
        flash.BackgroundTransparency = event.direction == "out" and 1 or 0
        tweenProperty(flash, "BackgroundTransparency", event.direction == "out" and 0 or 1, duration)
    elseif event.kind == "color" then
        tweenProperty(color, "Contrast", event.contrast or 0, duration)
        tweenProperty(color, "Saturation", event.saturation or 0, duration)
        tweenProperty(color, "Brightness", event.brightness or 0, duration)
    elseif event.kind == "bloom" then
        tweenProperty(bloom, "Intensity", event.amount or 0.5, duration)
    elseif event.kind == "vignette" then
        tweenProperty(vignette, "BackgroundTransparency", 1 - math.clamp(event.amount or 0.4, 0, 1), duration)
    elseif event.kind == "grain" then
        grainGui.BackgroundTransparency = 1 - math.clamp(event.amount or 0.08, 0, 0.25)
        task.delay(duration, function() grainGui.BackgroundTransparency = 1 end)
    elseif event.kind == "letterbox" then
        local size = math.floor(math.clamp(event.amount or 0.12, 0, 0.25) * workspace.CurrentCamera.ViewportSize.Y)
        tweenProperty(topBar, "Size", UDim2.new(1, 0, 0, size), duration)
        tweenProperty(bottomBar, "Size", UDim2.new(1, 0, 0, size), duration)
    end
end

local function stopCutscene(restore)
    activeToken += 1
    playing = false
    paused = false
    recording = false
    if restore then restoreCamera() end
    shakeEnabled = false
    setStatus("READY • V6")
end

RunService:BindToRenderStep("PokeV6_CameraDirector", Enum.RenderPriority.Camera.Value + 1, function(dt)
    camera = workspace.CurrentCamera
    if not camera then return end
    if shakeEnabled and playing then
        local t = os.clock() * shakeSpeed
        local offset = Vector3.new(
            math.noise(t, 0, 0),
            math.noise(0, t, 0),
            0
        ) * shakeStrength * 0.12
        local rotation = CFrame.Angles(
            math.noise(t, 2, 0) * shakeStrength * 0.018,
            math.noise(1, t, 0) * shakeStrength * 0.018,
            math.noise(0, 1, t) * shakeStrength * 0.012
        )
        camera.CFrame = camera.CFrame * CFrame.new(offset) * rotation
    end
end)

makeSection("CUTSCENE")
makeButton("●  Record Camera Path", function()
    if playing then return end
    frames = {}
    effectEvents = {}
    recording = true
    recordStart = os.clock()
    camera = workspace.CurrentCamera
    local origin = camera.CFrame
    local originFov = camera.FieldOfView
    table.insert(frames, {t = 0, cf = origin, fov = originFov})
    setStatus("RECORDING • move your camera")
    if recordConnection then recordConnection:Disconnect() end
    recordConnection = RunService.RenderStepped:Connect(function()
        if not recording then return end
        local t = os.clock() - recordStart
        camera = workspace.CurrentCamera
        local previous = frames[#frames]
        if not previous or t - previous.t >= 0.05 then
            table.insert(frames, {t = t, cf = camera.CFrame, fov = camera.FieldOfView})
        end
    end)
end)

makeButton("■  Stop Recording", function()
    recording = false
    if recordConnection then recordConnection:Disconnect(); recordConnection = nil end
    setStatus(("RECORDED • %d camera keys"):format(#frames))
end)

makeButton("▶  Play Cutscene", function()
    if recording or playing or #frames < 2 then
        setStatus(#frames < 2 and "RECORD A PATH FIRST" or "BUSY")
        return
    end
    snapshotCamera()
    activeToken += 1
    local myToken = activeToken
    playing = true
    paused = false
    playStart = os.clock()
    setStatus("PLAYING CUTSCENE")
    task.spawn(function()
        camera = workspace.CurrentCamera
        camera.CameraType = Enum.CameraType.Scriptable
        local index = 1
        while playing and activeToken == myToken and index < #frames do
            if paused then
                pauseAt = os.clock()
                repeat RunService.Heartbeat:Wait() until not paused or not playing or activeToken ~= myToken
                if not playing or activeToken ~= myToken then break end
                playStart += os.clock() - pauseAt
            end
            local a = frames[index]
            local b = frames[index + 1]
            local segment = math.max(0.001, b.t - a.t)
            local elapsed = 0
            while elapsed < segment and playing and not paused and activeToken == myToken do
                elapsed += RunService.RenderStepped:Wait()
                local alpha = math.clamp(elapsed / segment, 0, 1)
                alpha = alpha * alpha * (3 - 2 * alpha)
                camera.CFrame = a.cf:Lerp(b.cf, alpha)
                camera.FieldOfView = a.fov + (b.fov - a.fov) * alpha
                currentTime = a.t + (b.t - a.t) * alpha
                for _, event in ipairs(effectEvents) do
                    if not event.fired and event.t <= currentTime then
                        event.fired = true
                        runEffect(event)
                    end
                end
            end
            if paused then
                repeat RunService.Heartbeat:Wait() until not paused or not playing or activeToken ~= myToken
            else
                index += 1
            end
        end
        if playing and activeToken == myToken then
            stopCutscene(true)
            setStatus("CUTSCENE COMPLETE")
        end
    end)
end)

makeButton("Ⅱ  Pause / Resume", function()
    if playing then paused = not paused; setStatus(paused and "PAUSED" or "PLAYING CUTSCENE") end
end)

makeButton("■  Stop Cutscene", function()
    stopCutscene(true)
end)

makeSection("SAVE CAMERA POSITIONS")
makeButton("Save Current Position", function()
    camera = workspace.CurrentCamera
    table.insert(savedPositions, {cf = camera.CFrame, fov = camera.FieldOfView})
    setStatus(("SAVED POSITION %d"):format(#savedPositions))
end)

makeButton("Play Saved Positions", function()
    if playing or #savedPositions < 2 then
        setStatus(#savedPositions < 2 and "SAVE AT LEAST 2 POSITIONS" or "BUSY")
        return
    end
    local path = {}
    for i, pos in ipairs(savedPositions) do
        path[i] = {t = (i - 1) * 2, cf = pos.cf, fov = pos.fov}
    end
    frames = path
    for _, event in ipairs(effectEvents) do event.fired = false end
    -- The normal cutscene player handles the saved-position path.
    if #frames >= 2 then
        snapshotCamera()
        activeToken += 1
        local myToken = activeToken
        playing = true
        paused = false
        setStatus("PLAYING SAVED-POSITION PATH")
        task.spawn(function()
            camera = workspace.CurrentCamera
            camera.CameraType = Enum.CameraType.Scriptable
            for i = 1, #frames - 1 do
                local a, b = frames[i], frames[i + 1]
                local start = os.clock()
                local duration = math.max(0.1, b.t - a.t)
                while os.clock() - start < duration and playing and activeToken == myToken do
                    if paused then
                        local p = os.clock()
                        repeat RunService.Heartbeat:Wait() until not paused or not playing or activeToken ~= myToken
                        start += os.clock() - p
                    else
                        local alpha = math.clamp((os.clock() - start) / duration, 0, 1)
                        alpha = alpha * alpha * (3 - 2 * alpha)
                        camera.CFrame = a.cf:Lerp(b.cf, alpha)
                        camera.FieldOfView = a.fov + (b.fov - a.fov) * alpha
                        RunService.RenderStepped:Wait()
                    end
                end
            end
            if playing and activeToken == myToken then stopCutscene(true); setStatus("PATH COMPLETE") end
        end)
    end
end)

makeSection("SCREEN VFX")
makeSlider("Shake strength", 0, 2, 0.6, function(v) shakeStrength = v end)
makeSlider("Shake speed", 1, 30, 12, function(v) shakeSpeed = v end)
makeSlider("Blur amount", 0, 40, 0, function(v) blur.Size = v end)
makeSlider("Bloom intensity", 0, 2, 0, function(v) bloom.Intensity = v end)
makeSlider("Contrast", -1, 1, 0, function(v) color.Contrast = v end)
makeSlider("Saturation", -1, 1, 0, function(v) color.Saturation = v end)
makeSlider("Brightness", -1, 1, 0, function(v) color.Brightness = v end)
makeSlider("Vignette strength", 0, 1, 0, function(v) vignette.BackgroundTransparency = 1 - v end)
makeSlider("Film grain strength", 0, 0.25, 0, function(v) grainGui.BackgroundTransparency = 1 - v end)
makeSlider("Letterbox size", 0, 0.25, 0, function(v)
    local h = math.floor(v * workspace.CurrentCamera.ViewportSize.Y)
    topBar.Size = UDim2.new(1, 0, 0, h)
    bottomBar.Size = UDim2.new(1, 0, 0, h)
end)

makeButton("⚡ White Flash", function()
    runEffect({kind = "flash", amount = 1, duration = 0.35, color = Color3.new(1,1,1)})
end)

makeButton("🔴 Red Flash", function()
    runEffect({kind = "flash", amount = 1, duration = 0.35, color = Color3.fromRGB(255, 25, 35)})
end)

makeButton("🌑 Fade To Black", function()
    runEffect({kind = "fade", direction = "out", duration = fadeTime})
end)

makeButton("🌤 Fade From Black", function()
    runEffect({kind = "fade", direction = "in", duration = fadeTime})
end)

makeButton("📳 Test Shake", function()
    shakeEnabled = true
    task.delay(0.8, function() shakeEnabled = false end)
end)

makeButton("🎬 Add Shake Cue At Current Cutscene Time", function()
    table.insert(effectEvents, {t = currentTime, kind = "shake", amount = shakeStrength, speed = shakeSpeed, duration = 0.8})
    setStatus(("ADDED SHAKE CUE AT %.2fs"):format(currentTime))
end)

makeButton("💥 Add Flash Cue At Current Cutscene Time", function()
    table.insert(effectEvents, {t = currentTime, kind = "flash", color = Color3.new(1,1,1), duration = 0.35})
    setStatus(("ADDED FLASH CUE AT %.2fs"):format(currentTime))
end)

makeButton("🌫 Add Blur Cue At Current Cutscene Time", function()
    table.insert(effectEvents, {t = currentTime, kind = "blur", amount = 18, duration = 0.6})
    setStatus(("ADDED BLUR CUE AT %.2fs"):format(currentTime))
end)

makeButton("🎨 Add Cinematic Grade Cue At Current Time", function()
    table.insert(effectEvents, {t = currentTime, kind = "color", contrast = 0.18, saturation = -0.15, brightness = -0.03, duration = 1})
    setStatus(("ADDED GRADE CUE AT %.2fs"):format(currentTime))
end)

makeButton("🧹 Reset All VFX", function()
    blur.Size = 0
    color.Brightness = 0
    color.Contrast = 0
    color.Saturation = 0
    color.TintColor = Color3.new(1, 1, 1)
    bloom.Intensity = 0
    grainGui.BackgroundTransparency = 1
    vignette.BackgroundTransparency = 1
    flash.BackgroundTransparency = 1
    topBar.Size = UDim2.new(1, 0, 0, 0)
    bottomBar.Size = UDim2.new(1, 0, 0, 0)
    shakeEnabled = false
    setStatus("VFX RESET")
end)

makeButton("🗑 Clear Cutscene + Effect Cues", function()
    if playing then stopCutscene(true) end
    frames = {}
    effectEvents = {}
    currentTime = 0
    setStatus("CUTSCENE DATA CLEARED")
end)

makeButton("Hide / Show Panel", function()
    scroll.Visible = not scroll.Visible
    panel.Size = scroll.Visible and UDim2.fromOffset(330, 470) or UDim2.fromOffset(330, 55)
end)

-- Close key: RightControl. Does not destroy effects or data.
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        panel.Visible = not panel.Visible
    end
end)

gui.Destroying:Connect(function()
    stopCutscene(true)
    RunService:UnbindFromRenderStep("PokeV6_CameraDirector")
    if recordConnection then recordConnection:Disconnect() end
    if blur.Parent then blur:Destroy() end
    if color.Parent then color:Destroy() end
    if bloom.Parent then bloom:Destroy() end
end)

setStatus("READY • RIGHT CTRL HIDES PANEL")

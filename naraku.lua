-- Settings
section(settingsPage, "Panel settings", "Small controls for the interface.")
actionButton(settingsPage, "Hide panel", "RightShift to reopen", function()
    main.Visible = false
end)
actionButton(settingsPage, "Reset all local visuals", "Clean effects", function()
    for name, effect in pairs(effects) do
        if effect and effect.Parent then effect:Destroy() end
        effects[name] = nil
    end
    CONFIG.BlurEnabled = false
    CONFIG.BloomEnabled = false
    CONFIG.AtmosphereEnabled = false
    CONFIG.FOVEnabled = false
    if workspace.CurrentCamera then workspace.CurrentCamera.FieldOfView = 70 end
    notify("Local visual effects cleared.", "success")
end)
local hotkeyCard = card(settingsPage, 58)
make("TextLabel", {
    Position = UDim2.fromOffset(13, 0),
    Size = UDim2.new(1, -26, 1, 0),
    BackgroundTransparency = 1,
    Text = "SHOW / HIDE PANEL                              RIGHT SHIFT",
    TextColor3 = THEME.Text,
    TextSize = 10,
    Font = Enum.Font.GothamSemibold,
    TextXAlignment = Enum.TextXAlignment.Left,
}, hotkeyCard)

--// Initial page
pages.Overview.Visible = true
currentPage = "Overview"
tween(navButtons.Overview, 0.15, {
    BackgroundColor3 = THEME.Accent,
    TextColor3 = Color3.new(1, 1, 1),
})

--// Dragging
local dragging = false
local dragStart, startPosition
track(header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position
    end
end))
track(UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPosition.X.Scale, startPosition.X.Offset + delta.X,
            startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
        )
    end
end))
track(UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end))

--// Minimize / close / hotkey
local minimized = false
track(minimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    sidebar.Visible = not minimized
    content.Visible = not minimized
    tween(main, 0.22, {
        Size = minimized and UDim2.fromOffset(720, 76) or UDim2.fromOffset(720, 500),
    })
    minimizeButton.Text = minimized and "+" or "—"
end))

track(closeButton.MouseButton1Click:Connect(function()
    gui:Destroy()
end))

track(UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        main.Visible = not main.Visible
    end
end))

--// Re-apply movement after respawn
track(player.CharacterAdded:Connect(function()
    task.wait(0.35)
    applyMovement()
end))

--// Keep UI scaled on window resize
local cameraConnection
local function bindCamera()
    if cameraConnection then cameraConnection:Disconnect() end
    local camera = workspace.CurrentCamera
    if camera then
        cameraConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
        updateScale()
    end
end
bindCamera()
track(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindCamera))

--// Clean up connections and effects when GUI is removed
track(gui.Destroying:Connect(function()
    for _, connection in ipairs(connections) do
        pcall(function() connection:Disconnect() end)
    end
    if cameraConnection then cameraConnection:Disconnect() end
    for _, effect in pairs(effects) do
        if effect and effect.Parent then effect:Destroy() end
    end
end))

notify("Naraku Studio Panel loaded. Press RightShift to hide/show.", "success")

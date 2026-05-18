--[[
    ImGuiRoblox — ImGui-styled UI Library for Roblox
    Rounded edges, dark theme, draggable windows
    
    USAGE:
        local ImGui = require(script.ImGuiRoblox)
        local Gui = ImGui.new()

        local win = Gui:Window("My Window", {
            Position = UDim2.new(0, 100, 0, 100),
            Size     = UDim2.new(0, 320, 0, 500),
            Closable = true,
        })

        win:Header("Settings")
        win:Separator()
        win:Button("Click Me", function() print("clicked") end)
        win:Checkbox("Enable", false, function(v) print(v) end)
        win:Toggle("Feature", true, function(v) print(v) end)
        win:SliderInt("Count", 0, 100, 50, function(v) print(v) end)
        win:SliderFloat("Scale", 0, 1, 0.5, function(v) print(v) end)
        win:InputText("Name", "Enter name...", function(v) print(v) end)
        win:Dropdown("Mode", {"Fast","Normal","Slow"}, 2, function(i, v) print(i, v) end)
        win:ProgressBar(0.65, "Loading")
        win:ColorDisplay("Tint", Color3.fromRGB(110, 160, 255))
        win:TextDim("Status: ready")
]]

--------------------------------------------------------------------------------
-- Theme
--------------------------------------------------------------------------------

local T = {
    WindowBg      = Color3.fromRGB(30,  30,  46),
    TitleBg       = Color3.fromRGB(22,  22,  35),
    Border        = Color3.fromRGB(55,  55,  80),
    Button        = Color3.fromRGB(55,  59, 100),
    ButtonHover   = Color3.fromRGB(75,  79, 130),
    ButtonPress   = Color3.fromRGB(40,  43,  80),
    FrameBg       = Color3.fromRGB(38,  38,  58),
    FrameBgHover  = Color3.fromRGB(52,  52,  76),
    SliderGrab    = Color3.fromRGB(110, 160, 255),
    CheckMark     = Color3.fromRGB(110, 160, 255),
    Text          = Color3.fromRGB(220, 220, 230),
    TextDim       = Color3.fromRGB(130, 130, 155),
    Separator     = Color3.fromRGB(55,  55,  80),
    Accent        = Color3.fromRGB(110, 160, 255),
    DropBg        = Color3.fromRGB(35,  35,  52),
    CloseBtn      = Color3.fromRGB(180,  65,  65),
    CloseBtnHover = Color3.fromRGB(220,  80,  80),
    ScrollGrab    = Color3.fromRGB(75,  75, 115),

    Rounding      = 7,
    TitleH        = 30,
    ItemH         = 26,
    Spacing       = 5,
    Padding       = 10,
}

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------

local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local function corner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or T.Rounding)
    c.Parent = parent
    return c
end

local function stroke(parent, col, px)
    local s = Instance.new("UIStroke")
    s.Color = col or T.Border
    s.Thickness = px or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function tw(inst, props, t)
    TweenService:Create(inst, TweenInfo.new(t or 0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function makeDraggable(handle, target)
    local dragging, dragStart, startPos = false, nil, nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = i.Position
            startPos  = target.Position
        end
    end)
    handle.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - dragStart
            target.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
end

local function hsvToColor3(h, s, v)
    local r, g, b
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t2 = v * (1 - (1 - f) * s)
    i = i % 6
    if     i == 0 then r,g,b = v,t2,p
    elseif i == 1 then r,g,b = q,v,p
    elseif i == 2 then r,g,b = p,v,t2
    elseif i == 3 then r,g,b = p,q,v
    elseif i == 4 then r,g,b = t2,p,v
    elseif i == 5 then r,g,b = v,p,q
    end
    return Color3.new(r, g, b)
end

--------------------------------------------------------------------------------
-- Library
--------------------------------------------------------------------------------

local ImGuiRoblox = {}
ImGuiRoblox.__index = ImGuiRoblox

function ImGuiRoblox.new(parent)
    local self = setmetatable({}, ImGuiRoblox)
    local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    local gui = Instance.new("ScreenGui")
    gui.Name           = "ImGuiRoblox"
    gui.ResetOnSpawn   = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.IgnoreGuiInset = true
    gui.Parent         = parent or playerGui
    self._gui = gui
    return self
end

--------------------------------------------------------------------------------
-- Window
--------------------------------------------------------------------------------

function ImGuiRoblox:Window(title, opts)
    opts = opts or {}
    local pos       = opts.Position   or UDim2.new(0, 80, 0, 80)
    local size      = opts.Size       or UDim2.new(0, 300, 0, 420)
    local closable  = opts.Closable  ~= false
    local collapsible = opts.Collapsible ~= false

    -- root
    local root = Instance.new("Frame")
    root.Name                = "ImGui_" .. title
    root.Position            = pos
    root.Size                = size
    root.BackgroundColor3    = T.WindowBg
    root.BorderSizePixel     = 0
    root.ClipsDescendants    = true
    root.Parent              = self._gui
    corner(root)
    stroke(root, T.Border)

    -- title bar
    local bar = Instance.new("Frame")
    bar.Name             = "TitleBar"
    bar.Size             = UDim2.new(1, 0, 0, T.TitleH)
    bar.BackgroundColor3 = T.TitleBg
    bar.BorderSizePixel  = 0
    bar.ZIndex           = 5
    bar.Parent           = root
    corner(bar)

    -- patch bottom-corners of bar (they'd show round inside the window)
    local patch = Instance.new("Frame")
    patch.Size             = UDim2.new(1, 0, 0, T.Rounding)
    patch.Position         = UDim2.new(0, 0, 1, -T.Rounding)
    patch.BackgroundColor3 = T.TitleBg
    patch.BorderSizePixel  = 0
    patch.ZIndex           = 5
    patch.Parent           = bar

    -- title text
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text             = title
    titleLabel.TextSize         = 13
    titleLabel.Font             = Enum.Font.GothamBold
    titleLabel.TextColor3       = T.Text
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position         = UDim2.new(0, T.Padding, 0, 0)
    titleLabel.Size             = UDim2.new(1, -(T.Padding * 2 + (closable and 26 or 0)), 1, 0)
    titleLabel.TextXAlignment   = Enum.TextXAlignment.Left
    titleLabel.ZIndex           = 6
    titleLabel.Parent           = bar

    -- close button
    if closable then
        local closeBtn = Instance.new("TextButton")
        closeBtn.Text             = "×"
        closeBtn.TextSize         = 15
        closeBtn.Font             = Enum.Font.GothamBold
        closeBtn.TextColor3       = Color3.new(1,1,1)
        closeBtn.BackgroundColor3 = T.CloseBtn
        closeBtn.Size             = UDim2.new(0, 16, 0, 16)
        closeBtn.Position         = UDim2.new(1, -22, 0.5, -8)
        closeBtn.BorderSizePixel  = 0
        closeBtn.ZIndex           = 7
        closeBtn.Parent           = bar
        corner(closeBtn, 4)
        closeBtn.MouseEnter:Connect(function() tw(closeBtn, {BackgroundColor3 = T.CloseBtnHover}) end)
        closeBtn.MouseLeave:Connect(function() tw(closeBtn, {BackgroundColor3 = T.CloseBtn}) end)
        closeBtn.MouseButton1Click:Connect(function() root:Destroy() end)
    end

    -- collapse on double-click
    local collapsed  = false
    local lastClick  = 0
    if collapsible then
        bar.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                local now = tick()
                if now - lastClick < 0.3 then
                    collapsed = not collapsed
                    tw(root, {Size = collapsed
                        and UDim2.new(size.X.Scale, size.X.Offset, 0, T.TitleH)
                        or  size
                    }, 0.15)
                end
                lastClick = now
            end
        end)
    end

    makeDraggable(bar, root)

    -- scrolling content
    local scroll = Instance.new("ScrollingFrame")
    scroll.Name                  = "Content"
    scroll.Position              = UDim2.new(0, 0, 0, T.TitleH)
    scroll.Size                  = UDim2.new(1, 0, 1, -T.TitleH)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel       = 0
    scroll.ScrollBarThickness    = 4
    scroll.ScrollBarImageColor3  = T.ScrollGrab
    scroll.CanvasSize            = UDim2.new(0,0,0,0)
    scroll.AutomaticCanvasSize   = Enum.AutomaticSize.Y
    scroll.Parent                = root

    local layout = Instance.new("UIListLayout")
    layout.SortOrder  = Enum.SortOrder.LayoutOrder
    layout.Padding    = UDim.new(0, T.Spacing)
    layout.Parent     = scroll

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft   = UDim.new(0, T.Padding)
    pad.PaddingRight  = UDim.new(0, T.Padding)
    pad.PaddingTop    = UDim.new(0, T.Padding)
    pad.PaddingBottom = UDim.new(0, T.Padding)
    pad.Parent        = scroll

    -----------------------------------------------------------------------
    -- Window API
    -----------------------------------------------------------------------
    local win = { _root = root, _scroll = scroll, _order = 0 }

    local function item(h)
        win._order += 1
        local f = Instance.new("Frame")
        f.Size               = UDim2.new(1, 0, 0, h or T.ItemH)
        f.BackgroundTransparency = 1
        f.BorderSizePixel    = 0
        f.LayoutOrder        = win._order
        f.Parent             = scroll
        return f
    end

    -- Text
    function win:Text(text, color)
        local f = item(16)
        local l = Instance.new("TextLabel")
        l.Text             = text
        l.TextSize         = 13
        l.Font             = Enum.Font.Gotham
        l.TextColor3       = color or T.Text
        l.BackgroundTransparency = 1
        l.Size             = UDim2.new(1, 0, 1, 0)
        l.TextXAlignment   = Enum.TextXAlignment.Left
        l.TextWrapped      = true
        l.Parent           = f
        return self
    end

    function win:TextDim(text)   return self:Text(text, T.TextDim) end
    function win:TextGreen(text) return self:Text(text, Color3.fromRGB(100,200,120)) end
    function win:TextRed(text)   return self:Text(text, Color3.fromRGB(220, 90, 90)) end

    -- Header
    function win:Header(text)
        local f = item(18)
        local l = Instance.new("TextLabel")
        l.Text             = text
        l.TextSize         = 13
        l.Font             = Enum.Font.GothamBold
        l.TextColor3       = T.Accent
        l.BackgroundTransparency = 1
        l.Size             = UDim2.new(1, 0, 1, 0)
        l.TextXAlignment   = Enum.TextXAlignment.Left
        l.Parent           = f
        return self
    end

    -- Separator
    function win:Separator()
        local f = item(7)
        local line = Instance.new("Frame")
        line.Size             = UDim2.new(1, 0, 0, 1)
        line.Position         = UDim2.new(0, 0, 0.5, 0)
        line.BackgroundColor3 = T.Separator
        line.BorderSizePixel  = 0
        line.Parent           = f
        return self
    end

    -- Spacing
    function win:Spacing(h) item(h or 6) return self end

    -- Button
    function win:Button(text, callback)
        local f   = item(T.ItemH)
        local btn = Instance.new("TextButton")
        btn.Text             = text
        btn.TextSize         = 13
        btn.Font             = Enum.Font.Gotham
        btn.TextColor3       = T.Text
        btn.BackgroundColor3 = T.Button
        btn.Size             = UDim2.new(1, 0, 1, 0)
        btn.BorderSizePixel  = 0
        btn.Parent           = f
        corner(btn)
        stroke(btn, T.Border)

        btn.MouseEnter:Connect(function()    tw(btn, {BackgroundColor3 = T.ButtonHover}) end)
        btn.MouseLeave:Connect(function()    tw(btn, {BackgroundColor3 = T.Button}) end)
        btn.MouseButton1Down:Connect(function() tw(btn, {BackgroundColor3 = T.ButtonPress}, 0.05) end)
        btn.MouseButton1Up:Connect(function()   tw(btn, {BackgroundColor3 = T.ButtonHover}, 0.08) end)
        btn.MouseButton1Click:Connect(function() if callback then callback() end end)
        return self
    end

    -- Small inline button (right-aligned label + button)
    function win:ButtonRight(label, btnText, callback)
        local f = item(T.ItemH)
        local lbl = Instance.new("TextLabel")
        lbl.Text             = label
        lbl.TextSize         = 13
        lbl.Font             = Enum.Font.Gotham
        lbl.TextColor3       = T.Text
        lbl.BackgroundTransparency = 1
        lbl.Size             = UDim2.new(0.6, 0, 1, 0)
        lbl.TextXAlignment   = Enum.TextXAlignment.Left
        lbl.Parent           = f

        local btn = Instance.new("TextButton")
        btn.Text             = btnText
        btn.TextSize         = 12
        btn.Font             = Enum.Font.Gotham
        btn.TextColor3       = T.Text
        btn.BackgroundColor3 = T.Button
        btn.Size             = UDim2.new(0.38, 0, 0.85, 0)
        btn.Position         = UDim2.new(0.62, 0, 0.075, 0)
        btn.BorderSizePixel  = 0
        btn.Parent           = f
        corner(btn)
        stroke(btn, T.Border)

        btn.MouseEnter:Connect(function()    tw(btn, {BackgroundColor3 = T.ButtonHover}) end)
        btn.MouseLeave:Connect(function()    tw(btn, {BackgroundColor3 = T.Button}) end)
        btn.MouseButton1Click:Connect(function() if callback then callback() end end)
        return self
    end

    -- Checkbox
    function win:Checkbox(text, default, callback)
        local f       = item(T.ItemH)
        local checked = default == true

        local box = Instance.new("TextButton")
        box.Text             = ""
        box.BackgroundColor3 = checked and T.Accent or T.FrameBg
        box.Size             = UDim2.new(0, 18, 0, 18)
        box.Position         = UDim2.new(0, 0, 0.5, -9)
        box.BorderSizePixel  = 0
        box.Parent           = f
        corner(box, 4)
        stroke(box, T.Border)

        local tick = Instance.new("TextLabel")
        tick.Text             = "✓"
        tick.TextSize         = 12
        tick.Font             = Enum.Font.GothamBold
        tick.TextColor3       = Color3.new(1,1,1)
        tick.BackgroundTransparency = 1
        tick.Size             = UDim2.new(1,0,1,0)
        tick.Visible          = checked
        tick.Parent           = box

        local lbl = Instance.new("TextButton")
        lbl.Text             = text
        lbl.TextSize         = 13
        lbl.Font             = Enum.Font.Gotham
        lbl.TextColor3       = T.Text
        lbl.BackgroundTransparency = 1
        lbl.BorderSizePixel  = 0
        lbl.Size             = UDim2.new(1, -28, 1, 0)
        lbl.Position         = UDim2.new(0, 28, 0, 0)
        lbl.TextXAlignment   = Enum.TextXAlignment.Left
        lbl.Parent           = f

        local function toggle()
            checked      = not checked
            tick.Visible = checked
            tw(box, {BackgroundColor3 = checked and T.Accent or T.FrameBg})
            if callback then callback(checked) end
        end

        box.MouseButton1Click:Connect(toggle)
        lbl.MouseButton1Click:Connect(toggle)
        box.MouseEnter:Connect(function() tw(box, {BackgroundColor3 = checked and T.SliderGrab or T.FrameBgHover}) end)
        box.MouseLeave:Connect(function() tw(box, {BackgroundColor3 = checked and T.Accent or T.FrameBg}) end)
        return self
    end

    -- Toggle switch
    function win:Toggle(text, default, callback)
        local f  = item(T.ItemH)
        local on = default == true

        local track = Instance.new("Frame")
        track.Size             = UDim2.new(0, 38, 0, 20)
        track.Position         = UDim2.new(0, 0, 0.5, -10)
        track.BackgroundColor3 = on and T.Accent or T.FrameBg
        track.BorderSizePixel  = 0
        track.Parent           = f
        corner(track, 10)
        stroke(track, T.Border)

        local thumb = Instance.new("Frame")
        thumb.Size             = UDim2.new(0, 14, 0, 14)
        thumb.Position         = on and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)
        thumb.BackgroundColor3 = Color3.new(1,1,1)
        thumb.BorderSizePixel  = 0
        thumb.Parent           = track
        corner(thumb, 7)

        local btn = Instance.new("TextButton")
        btn.Text               = ""
        btn.BackgroundTransparency = 1
        btn.Size               = UDim2.new(1,0,1,0)
        btn.Parent             = track

        local lbl = Instance.new("TextLabel")
        lbl.Text             = text
        lbl.TextSize         = 13
        lbl.Font             = Enum.Font.Gotham
        lbl.TextColor3       = T.Text
        lbl.BackgroundTransparency = 1
        lbl.Position         = UDim2.new(0, 48, 0, 0)
        lbl.Size             = UDim2.new(1, -48, 1, 0)
        lbl.TextXAlignment   = Enum.TextXAlignment.Left
        lbl.Parent           = f

        btn.MouseButton1Click:Connect(function()
            on = not on
            tw(track, {BackgroundColor3 = on and T.Accent or T.FrameBg}, 0.12)
            tw(thumb, {Position = on and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)}, 0.12)
            if callback then callback(on) end
        end)
        return self
    end

    -- Internal slider builder
    local function buildSlider(parent, min, max, default, isInt, callback)
        local val = default or min
        local pct = math.clamp((val - min) / math.max(max - min, 0.001), 0, 1)

        local track = Instance.new("Frame")
        track.Size             = UDim2.new(1, 0, 0, 8)
        track.BackgroundColor3 = T.FrameBg
        track.BorderSizePixel  = 0
        track.Parent           = parent
        corner(track, 4)
        stroke(track, T.Border)

        local fill = Instance.new("Frame")
        fill.Size             = UDim2.new(pct, 0, 1, 0)
        fill.BackgroundColor3 = T.SliderGrab
        fill.BorderSizePixel  = 0
        fill.Parent           = track
        corner(fill, 4)

        local handle = Instance.new("Frame")
        handle.Size             = UDim2.new(0, 14, 0, 14)
        handle.Position         = UDim2.new(pct, -7, 0.5, -7)
        handle.BackgroundColor3 = Color3.new(1,1,1)
        handle.BorderSizePixel  = 0
        handle.ZIndex           = 3
        handle.Parent           = track
        corner(handle, 7)
        stroke(handle, T.Border, 1)

        local hitbox = Instance.new("TextButton")
        hitbox.Text               = ""
        hitbox.BackgroundTransparency = 1
        hitbox.Size               = UDim2.new(1, 0, 0, 20)
        hitbox.Position           = UDim2.new(0, 0, 0.5, -10)
        hitbox.ZIndex             = 4
        hitbox.Parent             = track

        local dragging = false

        local function update(x)
            local absX = track.AbsolutePosition.X
            local absW = track.AbsoluteSize.X
            local p    = math.clamp((x - absX) / absW, 0, 1)
            val = isInt
                and math.floor(min + (max - min) * p + 0.5)
                or  (min + (max - min) * p)
            local dp = (val - min) / math.max(max - min, 0.001)
            fill.Size        = UDim2.new(dp, 0, 1, 0)
            handle.Position  = UDim2.new(dp, -7, 0.5, -7)
            if callback then callback(val) end
            return val
        end

        hitbox.MouseButton1Down:Connect(function(x) dragging = true update(x) end)
        UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
        UIS.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then update(i.Position.X) end end)

        return track
    end

    -- SliderFloat
    function win:SliderFloat(text, min, max, default, callback)
        local f = item(T.ItemH + 22)

        local header = Instance.new("Frame")
        header.Size               = UDim2.new(1,0,0,16)
        header.BackgroundTransparency = 1
        header.Parent             = f

        local lbl = Instance.new("TextLabel")
        lbl.Text           = text
        lbl.TextSize       = 13
        lbl.Font           = Enum.Font.Gotham
        lbl.TextColor3     = T.Text
        lbl.BackgroundTransparency = 1
        lbl.Size           = UDim2.new(0.65, 0, 1, 0)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent         = header

        local valLabel = Instance.new("TextLabel")
        valLabel.Text           = string.format("%.2f", default or min)
        valLabel.TextSize       = 12
        valLabel.Font           = Enum.Font.Gotham
        valLabel.TextColor3     = T.TextDim
        valLabel.BackgroundTransparency = 1
        valLabel.Size           = UDim2.new(0.35, 0, 1, 0)
        valLabel.Position       = UDim2.new(0.65, 0, 0, 0)
        valLabel.TextXAlignment = Enum.TextXAlignment.Right
        valLabel.Parent         = header

        local sliderHolder = Instance.new("Frame")
        sliderHolder.Size             = UDim2.new(1,0,0,10)
        sliderHolder.Position         = UDim2.new(0,0,0,20)
        sliderHolder.BackgroundTransparency = 1
        sliderHolder.Parent           = f

        buildSlider(sliderHolder, min, max, default, false, function(v)
            valLabel.Text = string.format("%.2f", v)
            if callback then callback(v) end
        end)
        return self
    end

    -- SliderInt
    function win:SliderInt(text, min, max, default, callback)
        local f = item(T.ItemH + 22)

        local header = Instance.new("Frame")
        header.Size               = UDim2.new(1,0,0,16)
        header.BackgroundTransparency = 1
        header.Parent             = f

        local lbl = Instance.new("TextLabel")
        lbl.Text           = text
        lbl.TextSize       = 13
        lbl.Font           = Enum.Font.Gotham
        lbl.TextColor3     = T.Text
        lbl.BackgroundTransparency = 1
        lbl.Size           = UDim2.new(0.7, 0, 1, 0)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent         = header

        local valLabel = Instance.new("TextLabel")
        valLabel.Text           = tostring(math.floor(default or min))
        valLabel.TextSize       = 12
        valLabel.Font           = Enum.Font.Gotham
        valLabel.TextColor3     = T.TextDim
        valLabel.BackgroundTransparency = 1
        valLabel.Size           = UDim2.new(0.3, 0, 1, 0)
        valLabel.Position       = UDim2.new(0.7, 0, 0, 0)
        valLabel.TextXAlignment = Enum.TextXAlignment.Right
        valLabel.Parent         = header

        local sliderHolder = Instance.new("Frame")
        sliderHolder.Size             = UDim2.new(1,0,0,10)
        sliderHolder.Position         = UDim2.new(0,0,0,20)
        sliderHolder.BackgroundTransparency = 1
        sliderHolder.Parent           = f

        buildSlider(sliderHolder, min, max, default, true, function(v)
            valLabel.Text = tostring(v)
            if callback then callback(v) end
        end)
        return self
    end

    -- InputText
    function win:InputText(label, placeholder, callback)
        local f = item(T.ItemH + 22)

        local lbl = Instance.new("TextLabel")
        lbl.Text             = label
        lbl.TextSize         = 13
        lbl.Font             = Enum.Font.Gotham
        lbl.TextColor3       = T.Text
        lbl.BackgroundTransparency = 1
        lbl.Size             = UDim2.new(1,0,0,16)
        lbl.TextXAlignment   = Enum.TextXAlignment.Left
        lbl.Parent           = f

        local box = Instance.new("TextBox")
        box.Text              = ""
        box.PlaceholderText   = placeholder or ""
        box.PlaceholderColor3 = T.TextDim
        box.TextSize          = 13
        box.Font              = Enum.Font.Gotham
        box.TextColor3        = T.Text
        box.BackgroundColor3  = T.FrameBg
        box.Size              = UDim2.new(1, 0, 0, T.ItemH)
        box.Position          = UDim2.new(0, 0, 0, 18)
        box.BorderSizePixel   = 0
        box.ClearTextOnFocus  = false
        box.TextXAlignment    = Enum.TextXAlignment.Left
        box.Parent            = f
        corner(box)
        stroke(box, T.Border)

        local p = Instance.new("UIPadding")
        p.PaddingLeft  = UDim.new(0, 8)
        p.PaddingRight = UDim.new(0, 8)
        p.Parent       = box

        box.Focused:Connect(function()
            tw(box, {BackgroundColor3 = T.FrameBgHover})
        end)
        box.FocusLost:Connect(function(enter)
            tw(box, {BackgroundColor3 = T.FrameBg})
            if callback then callback(box.Text, enter) end
        end)
        return self
    end

    -- Dropdown / ComboBox
    function win:Dropdown(label, items, defaultIdx, callback)
        local f           = item(T.ItemH + 22)
        local selectedIdx = defaultIdx or 1
        local open        = false

        local lbl = Instance.new("TextLabel")
        lbl.Text             = label
        lbl.TextSize         = 13
        lbl.Font             = Enum.Font.Gotham
        lbl.TextColor3       = T.Text
        lbl.BackgroundTransparency = 1
        lbl.Size             = UDim2.new(1,0,0,16)
        lbl.TextXAlignment   = Enum.TextXAlignment.Left
        lbl.Parent           = f

        local btn = Instance.new("TextButton")
        btn.Text             = items[selectedIdx] or ""
        btn.TextSize         = 13
        btn.Font             = Enum.Font.Gotham
        btn.TextColor3       = T.Text
        btn.BackgroundColor3 = T.FrameBg
        btn.Size             = UDim2.new(1, 0, 0, T.ItemH)
        btn.Position         = UDim2.new(0, 0, 0, 18)
        btn.BorderSizePixel  = 0
        btn.TextXAlignment   = Enum.TextXAlignment.Left
        btn.Parent           = f
        corner(btn)
        stroke(btn, T.Border)

        local p = Instance.new("UIPadding")
        p.PaddingLeft  = UDim.new(0, 8)
        p.PaddingRight = UDim.new(0, 8)
        p.Parent       = btn

        local arrow = Instance.new("TextLabel")
        arrow.Text             = "▾"
        arrow.TextSize         = 11
        arrow.Font             = Enum.Font.GothamBold
        arrow.TextColor3       = T.TextDim
        arrow.BackgroundTransparency = 1
        arrow.Size             = UDim2.new(0, 18, 1, 0)
        arrow.Position         = UDim2.new(1, -20, 0, 0)
        arrow.Parent           = btn

        -- floating dropdown list (parented to root to go on top)
        local dropFrame = Instance.new("Frame")
        dropFrame.BackgroundColor3 = T.DropBg
        dropFrame.BorderSizePixel  = 0
        dropFrame.ZIndex           = 20
        dropFrame.Visible          = false
        dropFrame.ClipsDescendants = true
        dropFrame.Parent           = root
        corner(dropFrame)
        stroke(dropFrame, T.Border)

        local dropLayout = Instance.new("UIListLayout")
        dropLayout.SortOrder = Enum.SortOrder.LayoutOrder
        dropLayout.Parent    = dropFrame

        local dropPad = Instance.new("UIPadding")
        dropPad.PaddingTop    = UDim.new(0, 4)
        dropPad.PaddingBottom = UDim.new(0, 4)
        dropPad.Parent        = dropFrame

        local optBtns = {}
        for i, item2 in ipairs(items) do
            local opt = Instance.new("TextButton")
            opt.Text             = item2
            opt.TextSize         = 13
            opt.Font             = Enum.Font.Gotham
            opt.TextColor3       = i == selectedIdx and T.Accent or T.Text
            opt.BackgroundTransparency = 1
            opt.Size             = UDim2.new(1, 0, 0, T.ItemH)
            opt.BorderSizePixel  = 0
            opt.TextXAlignment   = Enum.TextXAlignment.Left
            opt.LayoutOrder      = i
            opt.ZIndex           = 21
            opt.Parent           = dropFrame
            optBtns[i]           = opt

            local op = Instance.new("UIPadding")
            op.PaddingLeft  = UDim.new(0, 10)
            op.PaddingRight = UDim.new(0, 10)
            op.Parent       = opt

            opt.MouseEnter:Connect(function()
                opt.BackgroundTransparency = 0
                opt.BackgroundColor3 = T.ButtonHover
            end)
            opt.MouseLeave:Connect(function()
                opt.BackgroundTransparency = 1
            end)
            opt.MouseButton1Click:Connect(function()
                local prev = selectedIdx
                selectedIdx = i
                btn.Text    = item2
                open        = false
                dropFrame.Visible = false
                for j, ob in ipairs(optBtns) do
                    ob.TextColor3 = j == i and T.Accent or T.Text
                end
                if callback then callback(i, item2) end
            end)
        end

        btn.MouseButton1Click:Connect(function()
            open = not open
            if open then
                local absPos  = btn.AbsolutePosition
                local absSize = btn.AbsoluteSize
                local rootPos = root.AbsolutePosition
                local dh      = math.min(#items * T.ItemH + 10, 160)
                dropFrame.Size = UDim2.new(0, absSize.X, 0, dh)
                dropFrame.Position = UDim2.new(
                    0, absPos.X - rootPos.X,
                    0, absPos.Y - rootPos.Y + absSize.Y + 3
                )
            end
            dropFrame.Visible = open
        end)
        btn.MouseEnter:Connect(function() tw(btn, {BackgroundColor3 = T.FrameBgHover}) end)
        btn.MouseLeave:Connect(function() tw(btn, {BackgroundColor3 = T.FrameBg}) end)
        return self
    end

    -- ProgressBar
    function win:ProgressBar(value, label)
        local totalH = label and (T.ItemH + 14) or T.ItemH
        local f = item(totalH)
        value   = math.clamp(value or 0, 0, 1)

        if label then
            local lbl = Instance.new("TextLabel")
            lbl.Text             = label
            lbl.TextSize         = 12
            lbl.Font             = Enum.Font.Gotham
            lbl.TextColor3       = T.Text
            lbl.BackgroundTransparency = 1
            lbl.Size             = UDim2.new(1,0,0,14)
            lbl.TextXAlignment   = Enum.TextXAlignment.Left
            lbl.Parent           = f
        end

        local track = Instance.new("Frame")
        track.Size             = UDim2.new(1, 0, 0, 10)
        track.Position         = UDim2.new(0, 0, 0, label and 16 or 8)
        track.BackgroundColor3 = T.FrameBg
        track.BorderSizePixel  = 0
        track.Parent           = f
        corner(track, 5)
        stroke(track, T.Border)

        local fill = Instance.new("Frame")
        fill.Size             = UDim2.new(value, 0, 1, 0)
        fill.BackgroundColor3 = T.Accent
        fill.BorderSizePixel  = 0
        fill.Parent           = track
        corner(fill, 5)

        local pctLbl = Instance.new("TextLabel")
        pctLbl.Text             = math.floor(value * 100) .. "%"
        pctLbl.TextSize         = 9
        pctLbl.Font             = Enum.Font.GothamBold
        pctLbl.TextColor3       = Color3.new(1,1,1)
        pctLbl.BackgroundTransparency = 1
        pctLbl.Size             = UDim2.new(1, 0, 1, 0)
        pctLbl.ZIndex           = 2
        pctLbl.Parent           = track

        return self
    end

    -- Color swatch display (read-only)
    function win:ColorDisplay(label, color3)
        local f = item(T.ItemH)

        local lbl = Instance.new("TextLabel")
        lbl.Text             = label
        lbl.TextSize         = 13
        lbl.Font             = Enum.Font.Gotham
        lbl.TextColor3       = T.Text
        lbl.BackgroundTransparency = 1
        lbl.Size             = UDim2.new(1, -40, 1, 0)
        lbl.TextXAlignment   = Enum.TextXAlignment.Left
        lbl.Parent           = f

        local swatch = Instance.new("Frame")
        swatch.Size             = UDim2.new(0, 32, 0, 18)
        swatch.Position         = UDim2.new(1, -34, 0.5, -9)
        swatch.BackgroundColor3 = color3 or Color3.new(1,1,1)
        swatch.BorderSizePixel  = 0
        swatch.Parent           = f
        corner(swatch, 4)
        stroke(swatch, T.Border)

        return self
    end

    -- Basic HSV Color Picker
    function win:ColorPicker(label, default, callback)
        local f = item(T.ItemH + 120)
        local col = default or Color3.new(1, 0, 0)
        local h, s, v = Color3.toHSV(col)

        local lbl = Instance.new("TextLabel")
        lbl.Text             = label
        lbl.TextSize         = 13
        lbl.Font             = Enum.Font.Gotham
        lbl.TextColor3       = T.Text
        lbl.BackgroundTransparency = 1
        lbl.Size             = UDim2.new(1, -40, 0, 18)
        lbl.TextXAlignment   = Enum.TextXAlignment.Left
        lbl.Parent           = f

        local swatch = Instance.new("Frame")
        swatch.Size             = UDim2.new(0, 32, 0, 18)
        swatch.Position         = UDim2.new(1, -34, 0, 0)
        swatch.BackgroundColor3 = col
        swatch.BorderSizePixel  = 0
        swatch.Parent           = f
        corner(swatch, 4)
        stroke(swatch, T.Border)

        local function updateSwatch()
            col = hsvToColor3(h, s, v)
            swatch.BackgroundColor3 = col
            if callback then callback(col) end
        end

        -- Hue bar
        local hueBarFrame = Instance.new("Frame")
        hueBarFrame.Size             = UDim2.new(1, 0, 0, 12)
        hueBarFrame.Position         = UDim2.new(0, 0, 0, 24)
        hueBarFrame.BackgroundTransparency = 1
        hueBarFrame.Parent           = f

        local hueBarBg = Instance.new("Frame")
        hueBarBg.Size             = UDim2.new(1, 0, 1, 0)
        hueBarBg.BackgroundColor3 = Color3.new(1,1,1)
        hueBarBg.BorderSizePixel  = 0
        hueBarBg.Parent           = hueBarFrame
        corner(hueBarBg, 4)
        stroke(hueBarBg, T.Border)

        -- gradient across hue 0-1
        local hueGrad = Instance.new("UIGradient")
        hueGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0/6, Color3.fromRGB(255,0,0)),
            ColorSequenceKeypoint.new(1/6, Color3.fromRGB(255,255,0)),
            ColorSequenceKeypoint.new(2/6, Color3.fromRGB(0,255,0)),
            ColorSequenceKeypoint.new(3/6, Color3.fromRGB(0,255,255)),
            ColorSequenceKeypoint.new(4/6, Color3.fromRGB(0,0,255)),
            ColorSequenceKeypoint.new(5/6, Color3.fromRGB(255,0,255)),
            ColorSequenceKeypoint.new(1,   Color3.fromRGB(255,0,0)),
        })
        hueGrad.Parent = hueBarBg

        local hueHandle = Instance.new("Frame")
        hueHandle.Size             = UDim2.new(0, 10, 0, 10)
        hueHandle.Position         = UDim2.new(h, -5, 0.5, -5)
        hueHandle.BackgroundColor3 = Color3.new(1,1,1)
        hueHandle.BorderSizePixel  = 0
        hueHandle.ZIndex           = 3
        hueHandle.Parent           = hueBarBg
        corner(hueHandle, 5)
        stroke(hueHandle, Color3.fromRGB(40,40,40))

        local hueHit = Instance.new("TextButton")
        hueHit.Text               = ""
        hueHit.BackgroundTransparency = 1
        hueHit.Size               = UDim2.new(1, 0, 1, 0)
        hueHit.ZIndex             = 4
        hueHit.Parent             = hueBarBg

        local draggingHue = false
        local function updateHue(x)
            local p = math.clamp((x - hueBarBg.AbsolutePosition.X) / hueBarBg.AbsoluteSize.X, 0, 1)
            h = p
            hueHandle.Position = UDim2.new(p, -5, 0.5, -5)
            updateSwatch()
        end
        hueHit.MouseButton1Down:Connect(function(x) draggingHue = true updateHue(x) end)
        UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingHue = false end end)
        UIS.InputChanged:Connect(function(i) if draggingHue and i.UserInputType == Enum.UserInputType.MouseMovement then updateHue(i.Position.X) end end)

        -- SV square (simplified: S slider + V slider)
        local function makeBar(label2, pos, initVal, onUpdate)
            local barLbl = Instance.new("TextLabel")
            barLbl.Text             = label2
            barLbl.TextSize         = 11
            barLbl.Font             = Enum.Font.Gotham
            barLbl.TextColor3       = T.TextDim
            barLbl.BackgroundTransparency = 1
            barLbl.Size             = UDim2.new(0, 14, 0, 12)
            barLbl.Position         = pos + UDim2.new(0,0,0,0)
            barLbl.TextXAlignment   = Enum.TextXAlignment.Left
            barLbl.Parent           = f

            local barBg = Instance.new("Frame")
            barBg.Size             = UDim2.new(1, -18, 0, 12)
            barBg.Position         = pos + UDim2.new(0, 16, 0, 0)
            barBg.BackgroundColor3 = T.FrameBg
            barBg.BorderSizePixel  = 0
            barBg.Parent           = f
            corner(barBg, 4)
            stroke(barBg, T.Border)

            local barFill = Instance.new("Frame")
            barFill.Size             = UDim2.new(initVal, 0, 1, 0)
            barFill.BackgroundColor3 = T.SliderGrab
            barFill.BorderSizePixel  = 0
            barFill.Parent           = barBg
            corner(barFill, 4)

            local barHandle = Instance.new("Frame")
            barHandle.Size             = UDim2.new(0, 10, 0, 10)
            barHandle.Position         = UDim2.new(initVal, -5, 0.5, -5)
            barHandle.BackgroundColor3 = Color3.new(1,1,1)
            barHandle.BorderSizePixel  = 0
            barHandle.ZIndex           = 3
            barHandle.Parent           = barBg
            corner(barHandle, 5)

            local barHit = Instance.new("TextButton")
            barHit.Text               = ""
            barHit.BackgroundTransparency = 1
            barHit.Size               = UDim2.new(1, 0, 1, 0)
            barHit.ZIndex             = 4
            barHit.Parent             = barBg

            local draggingBar = false
            local function updateBar(x)
                local p = math.clamp((x - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
                barFill.Size       = UDim2.new(p, 0, 1, 0)
                barHandle.Position = UDim2.new(p, -5, 0.5, -5)
                onUpdate(p)
            end
            barHit.MouseButton1Down:Connect(function(x) draggingBar = true updateBar(x) end)
            UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingBar = false end end)
            UIS.InputChanged:Connect(function(i) if draggingBar and i.UserInputType == Enum.UserInputType.MouseMovement then updateBar(i.Position.X) end end)
        end

        makeBar("S", UDim2.new(0,0,0,44), s, function(p) s = p updateSwatch() end)
        makeBar("V", UDim2.new(0,0,0,64), v, function(p) v = p updateSwatch() end)

        return self
    end

    -- Destroy window
    function win:Destroy() root:Destroy() end

    -- Set visibility
    function win:SetVisible(visible) root.Visible = visible end

    -- Get root frame
    function win:GetFrame() return root end

    table.insert(self._windows or {}, win)
    return win
end

--------------------------------------------------------------------------------

return ImGuiRoblox
